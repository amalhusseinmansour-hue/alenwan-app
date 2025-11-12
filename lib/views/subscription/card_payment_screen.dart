import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/payment_service.dart';

class CardPaymentScreen extends StatefulWidget {
  final dynamic plan;

  const CardPaymentScreen({super.key, required this.plan});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _saveCard = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    final chunks = <String>[];
    for (var i = 0; i < cleaned.length; i += 4) {
      chunks.add(cleaned.substring(
          i, i + 4 > cleaned.length ? cleaned.length : i + 4));
    }
    return chunks.join(' ');
  }

  String _formatExpiry(String input) {
    final cleaned = input.replaceAll('/', '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  String _getCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith(RegExp(r'5[1-5]'))) return 'Mastercard';
    if (cleaned.startsWith(RegExp(r'3[47]'))) return 'Amex';
    if (cleaned.startsWith('6')) return 'Discover';
    return 'Card';
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Extract expiry month and year
      final expiry = _expiryController.text.split('/');
      final expMonth = int.parse(expiry[0]);
      final expYear = int.parse('20${expiry[1]}');

      // Tokenize card
      final tokenResponse = await _paymentService.tokenizeCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expMonth: expMonth,
        expYear: expYear,
        cvv: _cvvController.text,
        cardHolderName: _nameController.text,
      );

      if (tokenResponse['status'] == 'success') {
        final cardToken = tokenResponse['data']['token'];

        // Process payment with token
        final paymentResponse = await _paymentService.processCardPayment(
          planId: widget.plan['id'].toString(),
          cardToken: cardToken,
          saveCard: _saveCard,
        );

        if (paymentResponse['status'] == 'success') {
          setState(() => _isProcessing = false);
          _showSuccess('Payment successful! Subscription activated.');
          Navigator.pop(context, true);
        } else {
          setState(() => _isProcessing = false);
          _showError('Payment failed. Please check your card details.');
        }
      } else {
        setState(() => _isProcessing = false);
        _showError('Card validation failed. Please check your details.');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Payment error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.plan['price'];
    final currency = widget.plan['currency'] ?? 'AED';
    final planName = widget.plan['name'] ?? 'Subscription';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Card Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Alenwan Subscription',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      '$price $currency',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Card Number
              const Text(
                'Card Number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: InputDecoration(
                  hintText: '1234 5678 9012 3456',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.credit_card, color: Colors.white70),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/icons/${_getCardBrand(_cardNumberController.text).toLowerCase()}.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.credit_card),
                    ),
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  final formatted = _formatCardNumber(value);
                  if (formatted != value) {
                    _cardNumberController.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final cleaned = value.replaceAll(' ', '');
                  if (cleaned.length < 13 || cleaned.length > 19) {
                    return 'Invalid card number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expiryController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            counterText: '',
                          ),
                          onChanged: (value) {
                            final formatted = _formatExpiry(value);
                            if (formatted != value) {
                              _expiryController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                    offset: formatted.length),
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (!value.contains('/') || value.length != 5) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cvvController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText: '***',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 3) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Card Holder Name
              const Text(
                'Card Holder Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'JOHN DOE',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save Card Checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _saveCard,
                      onChanged: (value) =>
                          setState(() => _saveCard = value ?? false),
                      activeColor: const Color(0xFF667eea),
                    ),
                    const Expanded(
                      child: Text(
                        'Save card for future payments',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay $price $currency',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment is secured with 256-bit SSL encryption',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
