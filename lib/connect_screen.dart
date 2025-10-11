import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/home_screen.dart';
import 'package:portfolio/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String youtubeChannelUrl =
      'https://youtube.com/@pratik_kumar_pradhan._?si=9MGy58Ksq3qiikat';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: screenWidth < 600 ? 130 : 160,
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
              label: Text(
                "Back",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth < 600 ? 14 : 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                padding: screenWidth < 600
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xff0f0f1a),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect with me',
                style: GoogleFonts.comfortaa(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        padding: const EdgeInsets.all(36.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF090C1A),
                              Color(0xFF0F172A),
                              Color(0xFF1E293B),
                            ],
                            stops: [0.0, 0.55, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: isMobile
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _buildSocialButtons(),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: _buildSocialButtons(),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const GetInTouchCard(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSocialButtons() {
    return [
      Tooltip(
        message: 'Visit my YouTube channel',
        child: _YouTubeCircleButton(
          onTap: () async {
            final url = Uri.parse(youtubeChannelUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
      const SizedBox(width: 16),
      Tooltip(
        message: 'Visit my LinkedIn',
        child: _CircleBox(
          title: 'LinkedIn',
          isLinkedIn: true,
          onTap: () async {
            final url = Uri.parse(
                'https://www.linkedin.com/in/pratik-kumar-pradhan-692a19301/');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
      const SizedBox(width: 16),
      Tooltip(
        message: 'Visit my Instagram',
        child: _CircleBox(
          title: 'Instagram',
          isInstagram: true,
          onTap: () async {
            final url =
                Uri.parse('https://instagram.com/pratik_kumar_pradhan._');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
      const SizedBox(width: 16),
      Tooltip(
        message: 'Visit my Twitter',
        child: _CircleBox(
          title: 'Twitter',
          isTwitter: true,
          onTap: () async {
            final url = Uri.parse('https://twitter.com/@Pratik_jan2006');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    ];
  }
}

class _YouTubeCircleButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _YouTubeCircleButton({this.onTap});

  @override
  State<_YouTubeCircleButton> createState() => _YouTubeCircleButtonState();
}

class _YouTubeCircleButtonState extends State<_YouTubeCircleButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.93 : (_hovered ? 1.07 : 1.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: widget.onTap,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.transparent,
                 // shadowColor: Colors.redAccent.withOpacity(0.6),
                  elevation: 8,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: EdgeInsets.zero,
                ),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/youtube.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'YouTube',
                style: GoogleFonts.comfortaa(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetInTouchCard extends StatefulWidget {
  const GetInTouchCard({super.key});

  @override
  State<GetInTouchCard> createState() => _GetInTouchCardState();
}

class _GetInTouchCardState extends State<GetInTouchCard> {
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
      _userEmail = user?.email;
    });
  }

Future<void> _sendEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'pratikkumarpradhan2006@gmail.com',
    queryParameters: {
      'subject': 'Message from Portfolio App',
      'body': 'Hello Pratik,\n\n',
    },
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email app found on this device')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening email: $e')),
    );
  }
}

@override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      final user = snapshot.data;
      final isLoggedIn = user != null;

      return Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC0B132B),
                Color(0x99112233),
                Color(0x66121A2E),
              ],
            ),
            border: Border.all(color: Colors.white54, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade900,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/gmail.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Get In Touch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLoggedIn
                    ? 'Logged in as: ${user?.email ?? "Unknown"}'
                    : 'Please sign in to send a message',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                onPressed: () async {
                  if (isLoggedIn) {
                    await _sendEmail();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
                child: Text(
                  isLoggedIn ? 'Send Message' : 'Sign In / Sign Up',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}

class _CircleBox extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isEmail;
  final bool isInstagram;
  final bool isTwitter;
  final bool isLinkedIn;

  const _CircleBox({
    required this.title,
    this.onTap,
    this.isEmail = false,
    this.isInstagram = false,
    this.isTwitter = false,
    this.isLinkedIn = false,
  });

  @override
  State<_CircleBox> createState() => _CircleBoxState();
}

class _CircleBoxState extends State<_CircleBox> {
  bool _hovered = false;

 Widget _getSocialIcon() {
  if (widget.isLinkedIn) {
    return ClipOval(
      child: Image.asset(
        'assets/images/linkedin1.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  } else if (widget.isInstagram) {
    return ClipOval(
      child: Image.asset(
        'assets/images/instagram1.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  } else if (widget.isTwitter) {
    return ClipOval(
      child: Image.asset(
        'assets/images/twitter.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  } else if (widget.isEmail) {
    return const Icon(
      FontAwesomeIcons.envelope,
      color: Colors.teal,
      size: 60,
    );
  }
  return const SizedBox.shrink();
}

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.teal.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                transform: Matrix4.identity()..scale(_hovered ? 1.07 : 1.0),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(child: _getSocialIcon()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: GoogleFonts.comfortaa(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}