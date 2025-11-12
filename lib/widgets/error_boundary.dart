import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final bool showStackTrace;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showStackTrace = false,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return ErrorDisplay(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
        showStackTrace: widget.showStackTrace,
      );
    }

    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
          });
          widget.onError?.call(details.exception, details.stack);
        }
      });
      return ErrorWidget(details.exception);
    };

    return widget.child;
  }
}

class ErrorDisplay extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final bool showStackTrace;
  final String? title;
  final String? message;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.showStackTrace = false,
    this.title,
    this.message,
  });

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _showDetails = false;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getErrorTitle() {
    if (widget.title != null) return widget.title!;

    final errorString = widget.error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Connection Error';
    } else if (errorString.contains('timeout')) {
      return 'Request Timeout';
    } else if (errorString.contains('permission')) {
      return 'Permission Denied';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'Content Not Found';
    } else {
      return 'Something Went Wrong';
    }
  }

  String _getErrorMessage() {
    if (widget.message != null) return widget.message!;

    final errorString = widget.error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'The request took too long to complete. Please try again.';
    } else if (errorString.contains('permission')) {
      return 'You don\'t have permission to access this content.';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'The content you\'re looking for could not be found.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  IconData _getErrorIcon() {
    final errorString = widget.error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('socket')) {
      return Icons.wifi_off_rounded;
    } else if (errorString.contains('timeout')) {
      return Icons.timer_off_rounded;
    } else if (errorString.contains('permission')) {
      return Icons.lock_outline_rounded;
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return Icons.search_off_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation:
          Listenable.merge([_fadeAnimation, _bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated error icon
                Transform.scale(
                  scale: _bounceAnimation.value * _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getErrorIcon(),
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Error title
                Transform.translate(
                  offset: Offset(0, (1 - _bounceAnimation.value) * 20),
                  child: Text(
                    _getErrorTitle(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Error message
                Transform.translate(
                  offset: Offset(0, (1 - _bounceAnimation.value) * 30),
                  child: Text(
                    _getErrorMessage(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Transform.translate(
                  offset: Offset(0, (1 - _bounceAnimation.value) * 40),
                  child: Column(
                    children: [
                      if (widget.onRetry != null)
                        _AnimatedButton(
                          onPressed: widget.onRetry!,
                          icon: Icons.refresh_rounded,
                          label: 'Try Again',
                          isPrimary: true,
                        ),
                      if (widget.onRetry != null && widget.showStackTrace)
                        const SizedBox(height: 12),
                      if (widget.showStackTrace)
                        _AnimatedButton(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          icon: _showDetails
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          label: _showDetails ? 'Hide Details' : 'Show Details',
                          isPrimary: false,
                        ),
                    ],
                  ),
                ),

                // Error details (stack trace)
                if (_showDetails && widget.showStackTrace) ...[
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.error.toString() +
                            (widget.stackTrace != null
                                ? '\n\nStack Trace:\n${widget.stackTrace.toString()}'
                                : ''),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: widget.onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      )
                    : null,
                color: widget.isPrimary
                    ? null
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200]),
                borderRadius: BorderRadius.circular(25),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isPrimary ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          widget.isPrimary ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Specialized error widgets for common scenarios
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: Exception('Network connection failed'),
      onRetry: onRetry,
      title: 'No Internet Connection',
      message: customMessage ??
          'Please check your internet connection and try again.',
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const LoadingErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: Exception('Failed to load content'),
      onRetry: onRetry,
      title: 'Failed to Load',
      message:
          customMessage ?? 'Something went wrong while loading the content.',
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NotFoundErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      error: Exception('Content not found'),
      onRetry: onRetry,
      title: 'Content Not Found',
      message: customMessage ??
          'The content you\'re looking for could not be found.',
    );
  }
}

// Error boundary wrapper for specific widgets
class SafeWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final String? errorMessage;

  const SafeWidget({
    super.key,
    required this.child,
    this.fallback,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: (error, stackTrace) {
        return fallback ??
            ErrorDisplay(
              error: error,
              stackTrace: stackTrace,
              message: errorMessage,
              onRetry: null,
            );
      },
      child: child,
    );
  }
}
