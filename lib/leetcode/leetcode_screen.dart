import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/home_screen.dart';
import 'package:portfolio/leetcode/leet_contribution.dart';


class LeetcodeScreen extends StatefulWidget {
  const LeetcodeScreen({super.key});

  @override
  State<LeetcodeScreen> createState() => _LeetcodeScreenState();
}

class _LeetcodeScreenState extends State<LeetcodeScreen> {
  Widget? _sliderWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B1020),
                Color(0xFF101828),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leadingWidth: MediaQuery.of(context).size.width < 600 ? 130 : 160,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: MediaQuery.of(context).size.width < 600
                  ? const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                padding: MediaQuery.of(context).size.width < 600
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        // title: Text(
        //   'LeetcodeScreen',
        //    style: GoogleFonts.comfortaa(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //           letterSpacing: 1.2,
        //           fontSize: 28,
        //         ),
        // ),
        // centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Main content
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Text(
                            'Leetcode',
                            style: GoogleFonts.comfortaa(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: 800,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xCC0B132B),
                                    Color(0x99112233),
                                    Color(0x66121A2E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.14), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.06),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/LeetcodeScreen.png', 
                                            height: 38,
                                            width: 38,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Leetcode',
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 750,
                                    height: 180,
                                    child: Focus(
                                      autofocus: true,
                                      child: LeetCodeContributionsWidget(
                                        username: 'pratikkumarpradhan',

                                        token: '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',
                                        height: 180,
                                        contributionColors: const [
                                          Color(0xFF40C463),
                                          Color(0xFF7BC96F),
                                          Color(0xFF9BE9A8),
                                          Color(0xFFB8E6B8),
                                          Color(0xFFD4F4D4),
                                        ],
                                        emptyColor: const Color(0xff161b22),
                                        backgroundColor: Colors.transparent,
                                        loadingWidget: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                                        onSliderReady: (slider) {
                                          setState(() {
                                            _sliderWidget = slider;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Less',
                                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(width: 10, height: 10, color: const Color(0xff161b22)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, color: const Color(0xFF40C463)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, color: const Color(0xFF7BC96F)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, color: const Color(0xFF9BE9A8)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, color: const Color(0xFFB8E6B8)),
                                      const SizedBox(width: 2),
                                      Container(width: 10, height: 10, color: const Color(0xFFD4F4D4)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'More',
                                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Add bottom padding to prevent content from being hidden behind slider
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom slider positioned at the bottom of the screen
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xff0f0f1a).withOpacity(0.8),
                        const Color(0xff0f0f1a),
                      ],
                    ),
                  ),
                  child: _sliderWidget ?? const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
