// import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:ui';

// class LearningScreen extends StatelessWidget {
//   const LearningScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final isMobile = width < 600;
//     final isTablet = width >= 600 && width <= 1000;
//     final isDesktop = width > 1000;

//     return Scaffold(
//       backgroundColor: const Color(0xff0f0f1a),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'My Flutter Journey',
//           style: GoogleFonts.poppins(
//             color: Colors.cyanAccent,
//             fontSize: isMobile ? 18 : 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                 child: Container(
//                   width: isMobile
//                       ? MediaQuery.of(context).size.width * 0.92
//                       : width > 1200
//                           ? 1200
//                           : MediaQuery.of(context).size.width * 0.9,
//                   margin: EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: isMobile ? 8 : 16,
//                   ),
//                   padding: EdgeInsets.all(isMobile ? 12 : 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.cyanAccent.withOpacity(0.3),
//                       width: 1.2,
//                     ),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.cyanAccent.withOpacity(0.1),
//                         Colors.white.withOpacity(0.02),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(bottom: isMobile ? 12 : 20),
//                         child: Text(
//                           'My Flutter Journey',
//                           style: GoogleFonts.poppins(
//                             color: Colors.cyanAccent,
//                             fontSize: isMobile ? 16 : 22,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.0,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 800),
//                         child: _buildOuterCard(
//                           context,
//                           isTablet,
//                           isDesktop,
//                           isMobile,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOuterCard(
//       BuildContext context, bool isTablet, bool isDesktop, bool isMobile) {
//     final boxes = [
//       _buildInnerBox(
//         "Skills Learned",
//         "Dart programming, state management (Provider, Riverpod), responsive UI design, REST API and Firebase integration.",
//         isMobile,
//         isFirst: true,
//       ),
//       _buildInnerBox(
//         "Tools & Technologies",
//         "Flutter SDK, Visual Studio Code, Android Studio, Git & GitHub for version control and collaboration.",
//         isMobile,
//       ),
//       _buildInnerBox(
//         "Project Experience",
//         "Built responsive and interactive mobile apps, focusing on intuitive UI/UX and performance optimization.",
//         isMobile,
//       ),
//       _buildInnerBox(
//         "Learning Approach",
//         "Hands-on projects, reading documentation, exploring community best practices, and continuous improvement.",
//         isMobile,
//         isLast: true,
//       ),
//     ];

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: List.generate(boxes.length, (index) {
//           final isLeft = index.isEven;
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 28.0), // bigger vertical gap
//             child: Row(
//               children: [
//                 if (isLeft) ...[
//                   Expanded(flex: 5, child: boxes[index]),
//                   Expanded(flex: 2, child: _buildConnectorLine(index, boxes.length)),
//                 ] else ...[
//                   Expanded(flex: 2, child: _buildConnectorLine(index, boxes.length)),
//                   Expanded(flex: 5, child: boxes[index]),
//                 ]
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildConnectorLine(int index, int total) {
//     final isLast = index == total - 1;
//     return Container(
//       height: 140, // taller to match bigger gap
//       alignment: Alignment.center,
//       child: !isLast
//           ? Container(
//               width: 1.5, // thin cyan line like before
//               height: double.infinity,
//               color: Colors.cyanAccent.withOpacity(0.5),
//             )
//           : const SizedBox.shrink(),
//     );
//   }

//   Widget _buildInnerBox(
//     String title,
//     String description,
//     bool isMobile, {
//     bool isFirst = false,
//     bool isLast = false,
//   }) {
//     return ClipRRect(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(isFirst ? 12 : 0),
//         topRight: Radius.circular(isFirst ? 12 : 0),
//         bottomLeft: Radius.circular(isLast ? 12 : 0),
//         bottomRight: Radius.circular(isLast ? 12 : 0),
//       ),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//         child: Card(
//           elevation: 4,
//           shadowColor: Colors.cyanAccent.withOpacity(0.3),
//           color: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(isFirst ? 12 : 0),
//               topRight: Radius.circular(isFirst ? 12 : 0),
//               bottomLeft: Radius.circular(isLast ? 12 : 0),
//               bottomRight: Radius.circular(isLast ? 12 : 0),
//             ),
//             side: BorderSide(
//               color: Colors.cyanAccent.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: Container(
//             height: isMobile ? 120 : 150,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.cyanAccent.withOpacity(0.05),
//                   Colors.white.withOpacity(0.02),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 10 : 14,
//                 vertical: isMobile ? 10 : 14,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       color: Colors.cyanAccent,
//                       fontSize: isMobile ? 13 : 15,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: Text(
//                       description,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: isMobile ? 11 : 13,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
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

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() => _isAdmin = true);
      }
    }
  }

  Future<void> _showAddExperienceDialog() async {
    final _titleController = TextEditingController();
    final _descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Experience"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () async {
                if (_titleController.text.trim().isEmpty ||
                    _descController.text.trim().isEmpty) {
                  return;
                }
                final docs = await FirebaseFirestore.instance.collection('journeySteps').get();
                final order = docs.size;

                await FirebaseFirestore.instance.collection('journeySteps').add({
                  'title': _titleController.text.trim(),
                  'description': _descController.text.trim(),
                  'order': order,
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(String docId, String currentTitle, String currentDescription) async {
    final titleController = TextEditingController(text: currentTitle);
    final descController = TextEditingController(text: currentDescription);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Step"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('journeySteps').doc(docId).update({
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
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
    await FirebaseFirestore.instance.collection('journeySteps').doc(docId).delete();
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
                  fontSize: screenWidth < 600 ? 14 : 16,
                ),
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
        // title: Text(
        //   'My Flutter Journey',
        //   style: GoogleFonts.poppins(
        //     color: Colors.cyanAccent,
        //     fontSize: isMobile ? 18 : 24,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'My Flutter Journey',
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
                        vertical: 16,
                        horizontal: isMobile ? 8 : 16,
                      ),
                      padding: EdgeInsets.all(isMobile ? 12 : 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.2,
                        ),
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
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('journeySteps')
                                .orderBy('order')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No steps available",
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;
                              return FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                child: _buildOuterCard(
                                  context,
                                  isTablet,
                                  isDesktop,
                                  isMobile,
                                  docs,
                                ),
                              );
                            },
                          ),
                        ],
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
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildOuterCard(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    bool isMobile,
    List<QueryDocumentSnapshot> docs,
  ) {
    final boxes = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _buildInnerBox(
        data['title'] ?? '',
        data['description'] ?? '',
        isMobile,
        docId: doc.id,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: List.generate(boxes.length, (index) {
          final isLeft = index.isEven;
          return Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
            child: Row(
              children: [
                if (isLeft) ...[
                  Expanded(flex: 5, child: boxes[index]),
                  Expanded(flex: 2, child: _buildConnectorLine(index, boxes.length)),
                ] else ...[
                  Expanded(flex: 2, child: _buildConnectorLine(index, boxes.length)),
                  Expanded(flex: 5, child: boxes[index]),
                ]
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConnectorLine(int index, int total) {
    final isLast = index == total - 1;
    return Container(
      height: 140,
      alignment: Alignment.center,
      child: !isLast
          ? Container(
              width: 1.5,
              height: double.infinity,
              color: Colors.cyanAccent.withOpacity(0.5),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInnerBox(
    String title,
    String description,
    bool isMobile, {
    String? docId,
    bool isFirst = false,
    bool isLast = false,
  }) {
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
              color: Colors.cyanAccent.withOpacity(0.18),
              width: 1.2,
            ),
          ),
          child: Container(
            height: isMobile ? 140 : 170,
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.14), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.05),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14,
                vertical: isMobile ? 10 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.cyanAccent,
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 11 : 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (_isAdmin) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 18),
                          onPressed: () => _showEditDialog(docId!, title, description),
                          tooltip: "Edit",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          onPressed: () => _deleteStep(docId!),
                          tooltip: "Delete",
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}