import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio/home_screen.dart';
import 'package:portfolio/projects/add_project.dart';
import 'package:portfolio/projects/project_details_screen.dart';
import 'package:portfolio/projects/web_dev_screen.dart';
import 'dart:ui';
import 'dart:async';

import 'package:portfolio/services/firebase.dart';



class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool? _isAdmin;
  bool _loading = true;
  List<QueryDocumentSnapshot> _docs = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  StreamSubscription<User?>? _authSubscription;

  int _selectedTab = 0; // 0 = App Dev, 1 = Web Dev

  @override
  void initState() {
    super.initState();
    _listenToAuthState();
    _listenToProjects();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthState() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('🔍 PortfolioScreen auth state changed: ${user?.email}');
      _checkAdmin(user);
    }, onError: (error) {
      debugPrint('❌ PortfolioScreen auth state error: $error');
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
    });
  }

  void _listenToProjects() {
    _subscription = FirebaseFirestore.instance
        .collection('portfolio')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _docs = snapshot.docs;
      });
    });
  }

  Future<void> _checkAdmin(User? user) async {
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _isAdmin = doc.data()?['role'] == 'admin';
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking admin in PortfolioScreen: $e');
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: MediaQuery.of(context).size.width < 600 ? 130 : 160,
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
      ),
      floatingActionButton: (_isAdmin == true && _selectedTab == 0)
          ? FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProjectScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ===== Spacer for transparent AppBar =====
                SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),

// ===== Navigation Row =====
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  color: Colors.transparent,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // App Dev Button
      Expanded(
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedTab = 0;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "App Dev",
                style: TextStyle(
                  color: _selectedTab == 0 ? Colors.cyanAccent : Colors.white54,
                  fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 60,
                color: _selectedTab == 0 ? Colors.cyanAccent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      // Web Dev Button
      Expanded(
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedTab = 1;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Web Dev",
                style: TextStyle(
                  color: _selectedTab == 1 ? Colors.cyanAccent : Colors.white54,
                  fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 60,
                color: _selectedTab == 1 ? Colors.cyanAccent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

               // ===== Content based on selected tab =====
Expanded(
  child: IndexedStack(
    index: _selectedTab,
    children: [
      _buildAppDevList(), // App Dev tab
      const PortfolioWebScreen(), // Web Dev tab
    ],
  ),
),
              ],
            ),
    );
  }

  // ===== Build App Dev List =====
  Widget _buildAppDevList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF090C1A),
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _docs.length,
        itemBuilder: (context, index) {
          final doc = _docs[index];
          final app = PortfolioProject.fromMap(doc.data() as Map<String, dynamic>);
          final docId = doc.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isAdmin == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.orangeAccent),
                        tooltip: 'Move Up',
                        onPressed: () async {
                          setState(() {
                            int newIndex = index > 0 ? index - 1 : _docs.length - 1;
                            final temp = _docs[newIndex];
                            _docs[newIndex] = _docs[index];
                            _docs[index] = temp;
                          });
                          for (int i = 0; i < _docs.length; i++) {
                            final id = _docs[i].id;
                            FirebaseFirestore.instance
                                .collection('portfolio')
                                .doc(id)
                                .update({'order': i});
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, color: Colors.orangeAccent),
                        tooltip: 'Move Down',
                        onPressed: () async {
                          setState(() {
                            int newIndex = index < _docs.length - 1 ? index + 1 : 0;
                            final temp = _docs[newIndex];
                            _docs[newIndex] = _docs[index];
                            _docs[index] = temp;
                          });
                          for (int i = 0; i < _docs.length; i++) {
                            final id = _docs[i].id;
                            FirebaseFirestore.instance
                                .collection('portfolio')
                                .doc(id)
                                .update({'order': i});
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete Project',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Project'),
                              content: const Text('Are you sure you want to delete this project?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('portfolio')
                                .doc(docId)
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xCC0B132B),
                                Color(0x99112233),
                                Color(0x66121A2E),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.14), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 28,
                                offset: Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.06),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  app.title,
                                                  style: GoogleFonts.berkshireSwash(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  app.overview,
                                                  style: GoogleFonts.merienda(
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.cyanAccent,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ProjectDetailScreen(project: app),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.arrow_forward, color: Colors.black),
                                            label: const Text(
                                              "More",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: app.images
                                              .map((url) => Padding(
                                                    padding: const EdgeInsets.only(right: 16),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(18),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.18),
                                                              blurRadius: 12,
                                                              offset: Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          child: PhoneMockupNetwork(imageUrl: url),
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class PhoneMockupNetwork extends StatelessWidget {
  final String imageUrl;
  const PhoneMockupNetwork({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return PhoneMockup(
      imagePath: imageUrl,
      isNetwork: true,
    );
  }
}




class PhoneMockup extends StatefulWidget {
  final String imagePath;
  final bool isNetwork;

  const PhoneMockup({
    super.key,
    required this.imagePath,
    this.isNetwork = false,
  });

  @override
  State<PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<PhoneMockup> {
  double _tiltX = 0;
  double _tiltY = 0;
  bool _hovering = false;

  void _updateTilt(Offset localPosition, Size size) {
    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _tiltY = dx.clamp(-1, 1).toDouble();
      _tiltX = -dy.clamp(-1, 1).toDouble();
      _hovering = true;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
      _hovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(36));
    const moveFactor = 12.0;

  return Listener(
  onPointerDown: (_) {
    // When user touches phone area on mobile, stop parent scroll
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      ScrollableState? scrollableState = Scrollable.of(context);
      scrollableState?.position?.activity?.dispose();
    }
  },
  onPointerMove: (event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      _updateTilt(box.globalToLocal(event.position), box.size);
    }
  },
  onPointerUp: (_) => _resetTilt(),
  onPointerCancel: (_) => _resetTilt(),
  child: MouseRegion(
        onHover: (event) {
          // Desktop hover stays EXACTLY as before
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            _updateTilt(box.globalToLocal(event.position), box.size);
          }
        },
        onExit: (_) => _resetTilt(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: _build3DMatrix(),
          transformAlignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow behind phone
              AnimatedOpacity(
                opacity: _hovering ? 1 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: const Offset(0, 18),
                  child: Container(
                    width: 220,
                    height: 470,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main phone body
              Container(
                width: 230,
                height: 490,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1F2124),
                      Color(0xFF2C2E31),
                      Color(0xFF18191B),
                    ],
                  ),
                  border: Border.all(color: Colors.white10, width: 0.8),
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Screen
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        top: 14 - _tiltX * moveFactor,
                        left: 14 + _tiltY * moveFactor,
                        right: 14 - _tiltY * moveFactor,
                        bottom: 14 + _tiltX * moveFactor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: widget.isNetwork
                              ? Image.network(widget.imagePath, fit: BoxFit.cover)
                              : Image.asset(widget.imagePath, fit: BoxFit.cover),
                        ),
                      ),

                      // Glossy highlight
                      Positioned(
                        top: 0 - _tiltX * 3,
                        left: 0 + _tiltY * 3,
                        right: 0 - _tiltY * 3,
                        height: 40,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Selfie camera
                      Positioned(
                        top: 8 - _tiltX * 2,
                        left: 0 + _tiltY * 2,
                        right: 0 - _tiltY * 2,
                        child: Transform.translate(
                          offset: Offset(_tiltY * 4, -_tiltX * 3),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 80,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12, width: 0.8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white30, width: 0.7),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 3,
                                        height: 3,
                                        decoration: const BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 7,
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(1.5),
                                      border: Border.all(color: Colors.white30, width: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Side buttons
                      Positioned(
                        top: 120 - _tiltX * 5,
                        left: -3 + _tiltY * 5,
                        child: Transform.translate(
                          offset: Offset(_tiltY * 2, -_tiltX * 2),
                          child: _sideButton(height: 35),
                        ),
                      ),
                      Positioned(
                        top: 160 - _tiltX * 7,
                        left: -3 + _tiltY * 7,
                        child: Transform.translate(
                          offset: Offset(_tiltY * 3, -_tiltX * 3),
                          child: _sideButton(height: 50),
                        ),
                      ),
                      Positioned(
                        top: 150 - _tiltX * 6,
                        right: -3 - _tiltY * 6,
                        child: Transform.translate(
                          offset: Offset(_tiltY * -2, -_tiltX * 2),
                          child: _sideButton(height: 45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Matrix4 _build3DMatrix() {
    final tiltAmount = 0.03;
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateX(_tiltX * tiltAmount)
      ..rotateY(_tiltY * tiltAmount)
      ..scale(_hovering ? 1.02 : 1.0);
  }

  Widget _sideButton({double height = 30}) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}