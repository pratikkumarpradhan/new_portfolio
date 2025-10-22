import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/projects/add_project.dart';
import 'package:portfolio/projects/project_details_screen.dart';
import 'package:portfolio/services/firebase.dart';

class PortfolioWebScreen extends StatefulWidget {
  const PortfolioWebScreen({super.key});

  @override
  State<PortfolioWebScreen> createState() => _PortfolioWebScreenState();
}

class _PortfolioWebScreenState extends State<PortfolioWebScreen> {
  List<QueryDocumentSnapshot> _docs = [];
  bool _loading = true;
  bool? _isAdmin;
  StreamSubscription<User?>? _authSubscription;
  late StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _listenToAuth();
    _listenToProjects();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuth() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
      } else {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          setState(() {
            _isAdmin = doc.data()?['role'] == 'admin';
            _loading = false;
          });
        } catch (e) {
          debugPrint('Error checking admin: $e');
          setState(() {
            _isAdmin = false;
            _loading = false;
          });
        }
      }
    });
  }

  void _listenToProjects() {
    _subscription = FirebaseFirestore.instance
        .collection('portfolio_web')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _docs = snapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: _docs.isEmpty
                  ? const Center(
                      child: Text(
                        "No Web Projects Found",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      tooltip: 'Edit Project',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddProjectScreen(
                                              project: app,
                                              documentId: docId,
                                              isWebDev: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                                              .collection('portfolio_web')
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
                                              .collection('portfolio_web')
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
                                          await FirebaseFirestore.instance.collection('portfolio_web').doc(docId).delete();
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
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xCC0B132B),
                                              Color(0x99112233),
                                              Color(0x66121A2E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(
                                            color: Colors.cyanAccent.withOpacity(0.14),
                                            width: 1.2,
                                          ),
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
                                                                      offset: const Offset(0, 4),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: TabletMockupNetwork(imageUrl: url),
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
    floatingActionButton: (_isAdmin == true)
    ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProjectScreen(isWebDev: true),
            ),
          );
        },
        child: const Icon(Icons.add), // Only + icon
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
      )
    : null,
    );
  }
}


// === Tablet Mockup for Web Projects =====


class TabletMockupNetwork extends StatelessWidget {
  final String imageUrl;
  const TabletMockupNetwork({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return TabletMockup(
      imagePath: imageUrl,
      isNetwork: true,
    );
  }
}

class TabletMockup extends StatefulWidget {
  final String imagePath;
  final bool isNetwork;

  const TabletMockup({
    super.key,
    required this.imagePath,
    this.isNetwork = false,
  });

  @override
  State<TabletMockup> createState() => _TabletMockupState();
}

class _TabletMockupState extends State<TabletMockup> {
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
    const borderRadius = BorderRadius.all(Radius.circular(28));
    const moveFactor = 10.0;

    return Listener(
      onPointerMove: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) _updateTilt(box.globalToLocal(event.position), box.size);
      },
      onPointerUp: (_) => _resetTilt(),
      onPointerCancel: (_) => _resetTilt(),
      child: MouseRegion(
        onHover: (event) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) _updateTilt(box.globalToLocal(event.position), box.size);
        },
        onExit: (_) => _resetTilt(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: _build3DMatrix(),
          transformAlignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ===== Shadow beneath tablet =====
              AnimatedOpacity(
                opacity: _hovering ? 1 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Transform.translate(
                  offset: const Offset(0, 28),
                  child: Container(
                    width: 440,
                    height: 310,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.55),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== Tablet body =====
              Container(
                width: 440,
                height: 300,
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
                  border: Border.all(color: Colors.white12, width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    children: [
                      // ===== Inner screen (added padding so not hidden) =====
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        top: 12 - _tiltX * moveFactor,
                        left: 12 + _tiltY * moveFactor,
                        right: 12 - _tiltY * moveFactor,
                        bottom: 12 + _tiltX * moveFactor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.all(6),
                            child: widget.isNetwork
                                ? Image.network(widget.imagePath, fit: BoxFit.contain)
                                : Image.asset(widget.imagePath, fit: BoxFit.contain),
                          ),
                        ),
                      ),

                      // ===== Glossy reflection =====
                      Positioned(
                        top: 0 - _tiltX * 3,
                        left: 0 + _tiltY * 3,
                        right: 0 - _tiltY * 3,
                        height: 60,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== Camera Bar =====
                      Positioned(
                        top: 5 - _tiltX * 2,
                        left: 0 + _tiltY * 2,
                        right: 0 - _tiltY * 2,
                        child: Transform.translate(
                          offset: Offset(_tiltY * 4, -_tiltX * 3),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white10, width: 0.8),
                              ),
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white30,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 2.2,
                                      height: 2.2,
                                      decoration: const BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== Slim Side Buttons (always visible) =====
                      _buildSideButton(top: 100, height: 50, delay: 4),
                      _buildSideButton(top: 165, height: 65, delay: 5),
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

  /// Tilt animation matrix
  Matrix4 _build3DMatrix() {
    const tiltAmount = 0.03;
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(_tiltX * tiltAmount)
      ..rotateY(_tiltY * tiltAmount)
      ..scale(_hovering ? 1.02 : 1.0);
  }

  /// Slim side button (visible even when idle)
  Widget _buildSideButton({
    required double top,
    required double height,
    required double delay,
  }) {
    return Positioned(
      top: top - _tiltX * delay,
      right: 2 - _tiltY * delay, // slightly inside the frame
      child: Transform.translate(
        offset: Offset(-_tiltY * 2, -_tiltX * 2),
        child: Container(
          width: 3.5, // thinner look
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFAAAAAA), Color(0xFF666666)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}