import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/projects/project_screen.dart';
import 'package:portfolio/services/firebase.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

class ProjectDetailScreen extends StatefulWidget {
  final PortfolioProject project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  // Removed YoutubePlayerController
  
  bool _isPlayButtonHovered = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextIndex = (_currentIndex + 1) % widget.project.images.length;
      _goToPage(nextIndex);
    });
  }

  void _goToPage(int index) {
    if (index >= 0 && index < widget.project.images.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = index);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  // Function to launch YouTube URL
  Future<void> _launchYouTubeUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to web if app launch fails
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url', style: TextStyle(color: Colors.white))),
        );
      }
    }
  }

  // Function to get YouTube thumbnail URL
  String? _getYoutubeThumbnail(String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final youtubeThumbnailUrl = _getYoutubeThumbnail(project.youtubeUrl);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090C1A),
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Center( // Center the content column horizontally
            child: Card(
margin: EdgeInsets.symmetric(
  horizontal: MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0,
  vertical: 16.0,
),              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.transparent,
              // Content inside the card with subtle dark gradient and padding
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xCC0B132B), // deep navy glass
                          Color(0x99112233), // slate glass
                          Color(0x66121A2E), // subtle violet tint
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.05),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Stack(
                      children: [
                        // Fixed back button in the inner box top left
                        Positioned(
                          top: 0,
                          left: 0,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const PortfolioScreen()),
                              );
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            label: const Text(
                              "Back",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        // Main content
                        Padding(
                          padding: const EdgeInsets.only(top: 56.0), // Add space for the button
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Carousel
                              SizedBox(
                                height: 600,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          PageView.builder(
                                            controller: _pageController,
                                            itemCount: project.images.length,
                                            physics: const BouncingScrollPhysics(),
                                            onPageChanged: (index) {
                                              setState(() => _currentIndex = index);
                                            },
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                child: ClipRect(
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    heightFactor: 1.0,
                                                    child: PhoneMockupNetwork(imageUrl: project.images[index]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                  // Arrows (square shape for all screens)
Positioned(
  left: 12,
  top: 0,
  bottom: 0,
  child: Center(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _goToPage(_currentIndex - 1),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
      ),
    ),
  ),
),
Positioned(
  right: 12,
  top: 0,
  bottom: 0,
  child: Center(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _goToPage(_currentIndex + 1),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
        ),
      ),
    ),
  ),
),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Indicator Dots
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        project.images.length,
                                        (index) => AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: _currentIndex == index ? 12 : 8,
                                          height: _currentIndex == index ? 12 : 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentIndex == index ? Colors.white : Colors.white54,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),

                              // Title and Overview in a centered container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xCC0B132B),
                                        Color(0x99112233),
                                        Color(0x66121A2E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.22),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  child: Column(
                                    children: [
                                      Text(
                                        project.title,
                                        style:  GoogleFonts.berkshireSwash(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        project.overview,
                                        style: GoogleFonts.merienda(fontSize: 16, height: 1.5, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tagline display
                              if (project.tagline != null && project.tagline.trim().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    project.tagline,
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),

                              // Description sections (left-aligned)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Description 1
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xCC0B132B),
                                            Color(0x99112233),
                                            Color(0x66121A2E),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.22),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.description1Heading,
                                            style:GoogleFonts.pangolin(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            project.description1,
                                            style:GoogleFonts.delius(fontSize: 16, height: 1.5, color: Colors.white),
                                            maxLines: null,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Description 2
                                    if (project.description2.isNotEmpty) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xCC0B132B),
                                              Color(0x99112233),
                                              Color(0x66121A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.22),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project.description2Heading,
                                              style: GoogleFonts.pangolin(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              project.description2,
                                              style:GoogleFonts.delius(fontSize: 16, height: 1.5, color: Colors.white),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Description 3
                                    if (project.description3.isNotEmpty) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xCC0B132B),
                                              Color(0x99112233),
                                              Color(0x66121A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.22),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project.description3Heading,
                                              style: GoogleFonts.pangolin(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              project.description3,
                                              style: GoogleFonts.delius(fontSize: 16, height: 1.5, color: Colors.white),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Description 4
                                    if (project.description4.isNotEmpty) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xCC0B132B),
                                              Color(0x99112233),
                                              Color(0x66121A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.22),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project.description4Heading,
                                              style:GoogleFonts.pangolin(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              project.description4,
                                              style: GoogleFonts.delius(fontSize: 16, height: 1.5, color: Colors.white),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Description 5
                                    if (project.description5.isNotEmpty) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xCC0B132B),
                                              Color(0x99112233),
                                              Color(0x66121A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.22),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project.description5Heading,
                                              style: GoogleFonts.pangolin(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              project.description5,
                                              style: GoogleFonts.delius(fontSize: 16, height: 1.5, color: Colors.white),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                              ),

                              // Youtube Video Thumbnail (clickable)
                              if (youtubeThumbnailUrl != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xCC0B132B),
                                          Color(0x99112233),
                                          Color(0x66121A2E),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.22),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () => _launchYouTubeUrl(project.youtubeUrl),
                                      child: AspectRatio(
                                        aspectRatio: 20 / 9, // Standard YouTube aspect ratio
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.network(
                                                youtubeThumbnailUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            // YouTube-style red play button with hover effect
                                            MouseRegion(
                                              onEnter: (_) => setState(() => _isPlayButtonHovered = true),
                                              onExit: (_) => setState(() => _isPlayButtonHovered = false),
                                              child: AnimatedScale(
                                                scale: _isPlayButtonHovered ? 1.1 : 1.0, // Zoom in by 10% on hover
                                                duration: const Duration(milliseconds: 200),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red, // Using a brighter red color
                                                    borderRadius: BorderRadius.circular(8.0), // Increased border radius for more rounded corners
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 35.0, // Adjust size as needed
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}