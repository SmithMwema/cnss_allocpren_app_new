import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_pages.dart';

class LancementModerneVue extends StatefulWidget {
  const LancementModerneVue({super.key});

  @override
  State<LancementModerneVue> createState() => _LancementModerneVueState();
}

class _LancementModerneVueState extends State<LancementModerneVue> with TickerProviderStateMixin {
  late AnimationController _widgetAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _textSlideAnimation1;
  late Animation<Offset> _textSlideAnimation2;
  late Animation<Offset> _textSlideAnimation3;
  late Animation<Alignment> _gradientTopAnimation;
  late Animation<Alignment> _gradientBottomAnimation;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startRedirectTimer();
  }

  void _setupAnimations() {
    _widgetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _widgetAnimationController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _widgetAnimationController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _textSlideAnimation1 = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _widgetAnimationController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );
    _textSlideAnimation2 = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _widgetAnimationController, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );
    _textSlideAnimation3 = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _widgetAnimationController, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );
    
    _gradientTopAnimation = Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight).animate(_backgroundAnimationController);
    _gradientBottomAnimation = Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft).animate(_backgroundAnimationController);

    _widgetAnimationController.forward();
  }

  // --- MÉTHODE DE REDIRECTION SIMPLIFIÉE ---
  void _startRedirectTimer() {
    Timer(const Duration(seconds: 8), () {
      // Après 8 secondes, on va simplement et directement à la page d'authentification.
      Get.offAllNamed(AppPages.auth);
    });
  }

  @override
  void dispose() {
    _widgetAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xff0b3d76), Color(0xff26a69a)],
                begin: _gradientTopAnimation.value,
                end: _gradientBottomAnimation.value,
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScaleAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                    decoration: BoxDecoration(
                      color: const Color(0xff0b3d76).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Text(
                      "CNSS",
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              ClipRect(
                child: SlideTransition(
                  position: _textSlideAnimation1,
                  child: Text(
                    "Simplifions vos",
                    style: GoogleFonts.poppins(fontSize: 32, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ),
              ClipRect(
                child: SlideTransition(
                  position: _textSlideAnimation2,
                  child: Text(
                    "allocations prénatales",
                    style: GoogleFonts.poppins(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ClipRect(
                child: SlideTransition(
                  position: _textSlideAnimation3,
                  child: Text(
                    "avec la CNSS",
                    style: GoogleFonts.poppins(fontSize: 32, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}