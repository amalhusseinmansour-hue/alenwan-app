import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ProfessionalTheme.durationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Add welcome message
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            const ChatMessage(
              message: 'مرحباً بك! كيف يمكنني مساعدتك اليوم؟',
              isUser: false,
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final userMessage = _messageController.text;
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            message: userMessage,
            isUser: true,
          ),
        );
        _messageController.clear();
      });

      // Simulate support response
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                message: _getSimulatedResponse(userMessage),
                isUser: false,
              ),
            );
          });
        }
      });
    }
  }

  String _getSimulatedResponse(String userMessage) {
    final responses = [
      'شكراً لتواصلك معنا، سأقوم بمساعدتك في حل هذه المشكلة.',
      'دعني أتحقق من ذلك من أجلك.',
      'هذا سؤال جيد، هل يمكنك إعطائي المزيد من التفاصيل؟',
      'سأقوم بتوجيهك للقسم المناسب لحل هذه المشكلة.',
      'تم تسجيل طلبك وسيتم التواصل معك قريباً.',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: Container(
          decoration: BoxDecoration(
            gradient: ProfessionalTheme.darkGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _buildChatArea(),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: ProfessionalTheme.space16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: ProfessionalTheme.textPrimary,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.support_agent,
              color: ProfessionalTheme.primaryBrand,
              size: 24,
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'محادثة مباشرة',
                  style: ProfessionalTheme.titleMedium(
                    color: ProfessionalTheme.textPrimary,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ProfessionalTheme.accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ProfessionalTheme.accentGreen.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space8),
                    Text(
                      'متصل الآن',
                      style: ProfessionalTheme.bodySmall(
                        color: ProfessionalTheme.accentGreen,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ProfessionalTheme.space16),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: ProfessionalTheme.space16),
          itemCount: _messages.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: ProfessionalTheme.space12),
            child: _messages[index],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(ProfessionalTheme.space16),
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ProfessionalTheme.radiusL),
          topRight: Radius.circular(ProfessionalTheme.radiusL),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: ProfessionalTheme.glassMorphism.copyWith(
                borderRadius: BorderRadius.circular(ProfessionalTheme.radiusRound),
              ),
              child: TextField(
                controller: _messageController,
                style: ProfessionalTheme.bodyMedium(
                  color: ProfessionalTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  hintStyle: ProfessionalTheme.bodyMedium(
                    color: ProfessionalTheme.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ProfessionalTheme.space20,
                    vertical: ProfessionalTheme.space16,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: ProfessionalTheme.textPrimary,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) _buildSupportAvatar(),
        if (!isUser) const SizedBox(width: ProfessionalTheme.space12),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ProfessionalTheme.space16,
                    vertical: ProfessionalTheme.space12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? ProfessionalTheme.primaryBrand
                        : ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL)
                        .copyWith(
                      bottomLeft: isUser
                          ? const Radius.circular(ProfessionalTheme.radiusL)
                          : const Radius.circular(ProfessionalTheme.radiusS),
                      bottomRight: isUser
                          ? const Radius.circular(ProfessionalTheme.radiusS)
                          : const Radius.circular(ProfessionalTheme.radiusL),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: ProfessionalTheme.bodyMedium(
                      color: isUser
                          ? ProfessionalTheme.textPrimary
                          : ProfessionalTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space4),
                Text(
                  _formatTime(),
                  style: ProfessionalTheme.bodySmall(
                    color: ProfessionalTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isUser) const SizedBox(width: ProfessionalTheme.space12),
        if (isUser) _buildUserAvatar(),
      ],
    );
  }

  Widget _buildSupportAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.support_agent,
        color: ProfessionalTheme.primaryBrand,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ProfessionalTheme.accentGreen.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: ProfessionalTheme.accentGreen.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: ProfessionalTheme.accentGreen,
        size: 20,
      ),
    );
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
