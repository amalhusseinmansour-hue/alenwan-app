// lib/core/animations/page_transitions.dart
import 'package:flutter/material.dart';

class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeSlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.02);
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.fastOutSlowIn;

            var scaleTween = Tween(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

class SlideFromRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideFromRightPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: child,
            );
          },
        );
}

class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;

  SharedAxisPageRoute({
    required this.page,
    this.transitionType = SharedAxisTransitionType.scaled,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }

class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: secondaryAnimation,
          builder: (context, child) {
            switch (transitionType) {
              case SharedAxisTransitionType.horizontal:
                return _buildHorizontalTransition();
              case SharedAxisTransitionType.vertical:
                return _buildVerticalTransition();
              case SharedAxisTransitionType.scaled:
                return _buildScaledTransition();
            }
          },
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildHorizontalTransition() {
    final isForward = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;

    final slideTween = Tween<Offset>(
      begin: Offset(isForward ? 0.3 : -0.3, 0.0),
      end: Offset.zero,
    );

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildVerticalTransition() {
    final slideTween = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    );

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildScaledTransition() {
    final scaleTween = Tween<double>(
      begin: 0.92,
      end: 1.0,
    );

    return ScaleTransition(
      scale: animation.drive(scaleTween),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: child,
      ),
    );
  }
}