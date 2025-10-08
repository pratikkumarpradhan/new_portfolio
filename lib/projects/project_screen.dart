import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio/home_screen.dart';
import 'package:portfolio/projects/add_project.dart';
import 'package:portfolio/projects/project_details_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _listenToProjects();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _isAdmin = doc.data()?['role'] == 'admin';
      _loading = false;
    });
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
      floatingActionButton: (_isAdmin == true)
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
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF090C1A), // Deep navy
                    Color(0xFF0F172A), // Slate-900
                    Color(0xFF1E293B), // Slate-800
                  ],
                  stops: [0.0, 0.55, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 24),
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
                                    FirebaseFirestore.instance.collection('portfolio').doc(id).update({'order': i});
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
                                    FirebaseFirestore.instance.collection('portfolio').doc(id).update({'order': i});
                                  }
                                },
                              ),
                              // IconButton(
                              //   icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                              //   tooltip: 'Edit Project',
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (_) => AddProjectScreen(project: app, documentId: docId),
                              //       ),
                              //     );
                              //   },
                              // ),
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
                            // Glassmorphism card
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
                                        Color(0xCC0B132B), // deep navy glass
                                        Color(0x99112233), // slate glass
                                        Color(0x66121A2E), // subtle violet tint
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
                                      const SizedBox(width: 0),
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
                                                          // style: GoogleFonts.permanentMarker(
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
                                                                child: PhoneMockupNetwork(imageUrl: url),
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

  const PhoneMockup({super.key, required this.imagePath, this.isNetwork = false});

  @override
  State<PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<PhoneMockup> {
  double _tiltX = 0;
  double _tiltY = 0;
  bool _hovering = false;

  void _onHover(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(event.position);
    final size = box.size;

    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _tiltY = dx * 0.5;
      _tiltX = -dy * 0.5;
      _hovering = true;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
      _hovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(40));

    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0018)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY)
          ..scale(_hovering ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        child: Stack(
          children: [
            // Shadow underneath
            Positioned(
              left: 30,
              right: 30,
              top: 50,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                      offset: const Offset(10, 20),
                    ),
                  ],
                ),
              ),
            ),

            // Phone body
            Container(
              width: 260,
              height: 540,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF232526), // dark blue-grey
                    Color(0xFF414345), // slate
                    Color(0xFF232526), // dark again for depth
                  ],
                ),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Stack(
                  children: [
                    // Glass highlight overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Phone screen
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: widget.isNetwork
                            ? Image.network(widget.imagePath, fit: BoxFit.cover)
                            : Image.asset(widget.imagePath, fit: BoxFit.cover),
                      ),
                    ),
                    // Selfie camera and flash box (real phone style)
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Selfie camera
                              Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 0.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              // Flash
                              Container(
                                width: 7,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF9C4), // soft yellow
                                  borderRadius: BorderRadius.circular(1.5),
                                  border: Border.all(color: Colors.white70, width: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 1.5,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Simulated phone thickness via gradients
                    _buildSideShading(),

                    // Side buttons
                    Positioned(
                      top: 120,
                      left: -5,
                      child: Column(
                        children: [
                          _sideButton(),
                          const SizedBox(height: 10),
                          _sideButton(),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 150,
                      right: -5,
                      child: _sideButton(height: 60),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideButton({double height = 30}) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSideShading() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 12,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 12,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 12,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 12,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}