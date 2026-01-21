import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_flow/loginsignupscreen/loginscreen.dart';
// import 'package:task_flow/auth/login_screen.dart'; // enable when ready

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/firstintro.jpeg',
    'assets/images/secondi.jpeg',
    'assets/images/Untitled design-14.png',
  ];

  final List<String> _titles = [
    'Welcome to TaskFlow',
    'Organize Your Tasks',
    'Get Work Done Faster',
  ];

  final List<String> _descriptions = [
    'Manage your gig work tasks efficiently',
    'Track, prioritize, and complete tasks easily',
    'Stay productive and never miss deadlines',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// 🔹 Start / restart auto-slide timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (_currentPage < _images.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    // Restart timer only for first two pages
    if (index < _images.length - 1) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

void _goToLogin() {
  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
  );
}
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  /// Background image
                  Image.asset(
                    _images[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),

                  /// Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),

                  /// Text content
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(),

                        Text(
                          _titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _descriptions[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// 🔹 Bottom Indicator / Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _currentPage == _images.length - 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 88, 136, 239),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
