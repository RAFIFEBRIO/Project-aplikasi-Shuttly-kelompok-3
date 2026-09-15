import 'package:flutter/material.dart';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {

  final Widget nextPage;

  const SplashScreen({super.key, this.nextPage = const LoginPage()});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
 
  static const Color splashBlue = Color(0xFF0D5CFF);
  static const Color logoYellow = Color(0xFFFFC42D);

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Teks copyright di bawah muncul belakangan (fade in halus)
    _footerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // Setelah splash tampil beberapa saat, otomatis pindah halaman
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => widget.nextPage,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // Logo di tengah layar
            Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: _buildLogo(),
                ),
              ),
            ),

            
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: FadeTransition(
                opacity: _footerFade,
                child: _buildFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo_shuttly.png',
      width: 220,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: logoYellow, size: 34),
            const SizedBox(width: 4),
            Text(
              'Shuttly',
              style: TextStyle(
                color: logoYellow,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(-4, -10),
              child: const Icon(
                Icons.back_hand_rounded,
                color: logoYellow,
                size: 16,
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          '© 2026 PT Trans Nusantara Shuttle',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        SizedBox(height: 2),
        Text(
          'All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
