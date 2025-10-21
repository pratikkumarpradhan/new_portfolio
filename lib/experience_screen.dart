import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio/home_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool _isAdmin = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _listenToAuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthState() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('🔍 LearningScreen auth state changed: ${user?.email}');
      _checkAdmin(user);
    }, onError: (error) {
      debugPrint('❌ LearningScreen auth state error: $error');
      setState(() => _isAdmin = false);
    });
  }

  Future<void> _checkAdmin(User? user) async {
    if (user == null) {
      setState(() => _isAdmin = false);
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() => _isAdmin = doc.exists && doc.data()?['role'] == 'admin');
    } catch (e) {
      debugPrint('❌ Error checking admin in LearningScreen: $e');
      setState(() => _isAdmin = false);
    }
  }

  /// 🟩 Dialog to add new experience card (with checkbox for new section)
  Future<void> _showAddExperienceDialog() async {
    final _titleController = TextEditingController();
    final _descController = TextEditingController();
    bool _startNewSection = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Experience"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration:
                        const InputDecoration(labelText: "Title (optional)"),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: "Description *",
                      hintText: "Write about your experience...",
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _startNewSection,
                    onChanged: (val) {
                      setStateDialog(() => _startNewSection = val ?? false);
                    },
                    title: const Text("Start new section (no line above)"),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () async {
                if (_descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Description cannot be empty.")),
                  );
                  return;
                }

                final docs = await FirebaseFirestore.instance
                    .collection('journeySteps')
                    .get();
                final order = docs.size;

                await FirebaseFirestore.instance
                    .collection('journeySteps')
                    .add({
                  'title': _titleController.text.trim().isEmpty
                      ? 'Untitled Step'
                      : _titleController.text.trim(),
                  'description': _descController.text.trim(),
                  'order': order,
                  'isNewSection': _startNewSection,
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// ✏️ Edit existing step
Future<void> _showEditDialog(
  String docId,
  String currentTitle,
  String currentDescription,
) async {
  final titleController = TextEditingController(text: currentTitle);
  final descController = TextEditingController(text: currentDescription);

  bool isNewSection = false;

  // Fetch the current isNewSection value before editing
  final doc = await FirebaseFirestore.instance
      .collection('journeySteps')
      .doc(docId)
      .get();
  if (doc.exists && doc.data()?['isNewSection'] == true) {
    isNewSection = true;
  }

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Step"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: descController,
                  decoration:
                      const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: isNewSection,
                  onChanged: (val) {
                    setStateDialog(() => isNewSection = val ?? false);
                  },
                  title: const Text("Start new section (no line above)"),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('journeySteps')
                  .doc(docId)
                  .update({
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
                'isNewSection': isNewSection,
              });
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

  Future<void> _deleteStep(String docId) async {
    await FirebaseFirestore.instance
        .collection('journeySteps')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width <= 1000;
    final isDesktop = width > 1000;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: screenWidth < 600 ? 130 : 160,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1020), Color(0xFF101828)],
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.transparent,
                padding: screenWidth < 600
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                    : const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'My Flutter Journey',
                    style: GoogleFonts.comfortaa(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 28,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.92
                          : width > 1200
                              ? 1200
                              : MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.symmetric(
                          vertical: 16, horizontal: isMobile ? 8 : 16),
                      padding:
                          EdgeInsets.all(isMobile ? 12 : 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.2),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF090C1A),
                            Color(0xFF0F172A),
                            Color(0xFF1E293B)
                          ],
                          stops: [0.0, 0.55, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('journeySteps')
                            .orderBy('order')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text("No steps available",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white)),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          return FadeInUp(
                            duration:
                                const Duration(milliseconds: 800),
                            child: _buildOuterCard(
                                context, isTablet, isDesktop, isMobile, docs),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              onPressed: _showAddExperienceDialog,
              child:
                  const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  /// 🧩 Timeline builder (no side lines, no gaps)
Widget _buildOuterCard(
  BuildContext context,
  bool isTablet,
  bool isDesktop,
  bool isMobile,
  List<QueryDocumentSnapshot> docs,
) {
  final boxes = docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'widget': _buildInnerBox(
        data['title'] ?? '',
        data['description'] ?? '',
        isMobile,
        docId: doc.id,
      ),
      'isNewSection': data['isNewSection'] ?? false,
    };
  }).toList();

  return Column(
    children: List.generate(boxes.length, (index) {
      final isLeft = index.isEven;
      final isNewSection = boxes[index]['isNewSection'] as bool;

      return Column(
        children: [
          // 🔹 Add a small gap before a new section
          if (isNewSection && index != 0)
            const SizedBox(height: 40),

         // 🔹 Line connecting previous card (no line for new section or first)
if (!isNewSection && index != 0)
  Container(
    width: 1.5,
    height: isMobile ? 20 : 40, // smaller line for mobile
    color: Colors.cyanAccent.withOpacity(0.5),
  ),
          // 🔹 Card itself
          if (isMobile)
            boxes[index]['widget'] as Widget
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLeft) ...[
                  Expanded(flex: 5, child: boxes[index]['widget'] as Widget),
                  const Spacer(flex: 2),
                ] else ...[
                  const Spacer(flex: 2),
                  Expanded(flex: 5, child: boxes[index]['widget'] as Widget),
                ],
              ],
            ),
        ],
      );
    }),
  );
}

Widget _buildInnerBox(String title, String description, bool isMobile,
    {String? docId}) {
  final hasTitle = title.trim().isNotEmpty && title.trim() != 'Untitled Step';

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: Colors.cyanAccent.withOpacity(0.18), width: 1.2),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC0B132B),
                Color(0x99112233),
                Color(0x66121A2E)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.14), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 10)),
              BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.05),
                  blurRadius: 14,
                  spreadRadius: 1),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14,
                vertical: isMobile ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  hasTitle ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (hasTitle) ...[
                  Text(title,
                      style: GoogleFonts.tinos(
                        color: Colors.cyanAccent,
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 8),
                ],
                Text(description,
                    style: GoogleFonts.redHatDisplay(
                      color: Colors.white,
                      fontSize: isMobile ? 11.5 : 13,
                      height: 1.45,
                    )),
                if (_isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.cyanAccent, size: 18),
                          onPressed: () =>
                              _showEditDialog(docId!, title, description)),
                      IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent, size: 18),
                          onPressed: () => _deleteStep(docId!)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}