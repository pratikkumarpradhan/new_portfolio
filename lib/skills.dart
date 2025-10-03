// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'add_skill.dart';
// import 'dart:async';

// class SkillsScreen extends StatefulWidget {
//   const SkillsScreen({super.key});

//   @override
//   State<SkillsScreen> createState() => _SkillsScreenState();
// }

// class _SkillsScreenState extends State<SkillsScreen> {
//   bool? _isAdmin;
//   bool _loading = true;
//   Map<String, int> categoryOrder = {};
//   StreamSubscription<DocumentSnapshot>? _categoryOrderSubscription;
//   bool _isUpdatingOrder = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAdmin();
//     _listenToCategoryOrder();
//   }

//   @override
//   void dispose() {
//     _categoryOrderSubscription?.cancel();
//     super.dispose();
//   }

//   Future<void> _checkAdmin() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       setState(() {
//         _isAdmin = false;
//         _loading = false;
//       });
//       return;
//     }
//     final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//     setState(() {
//       _isAdmin = doc.data()?['role'] == 'admin';
//       _loading = false;
//     });
//   }

//   // Listen to category order changes in real-time
//   void _listenToCategoryOrder() {
//     _categoryOrderSubscription = FirebaseFirestore.instance
//         .collection('settings')
//         .doc('categoryOrder')
//         .snapshots()
//         .listen((snapshot) {
//       if (_isUpdatingOrder) {
//         debugPrint('🔄 Skipping update - we are the ones making the change');
//         return;
//       }
      
//       if (snapshot.exists && snapshot.data() != null) {
//         final data = snapshot.data()!;
//         setState(() {
//           categoryOrder = Map<String, int>.from(data);
//         });
//         debugPrint('📋 Real-time category order update: $categoryOrder');
//       } else {
//         debugPrint('📋 No category order found in Firestore, will initialize from skills');
//       }
//     }, onError: (error) {
//       debugPrint('❌ Error listening to category order: $error');
//     });
//   }

//   // Save category order to Firestore
//   Future<void> _saveCategoryOrder() async {
//     try {
//       _isUpdatingOrder = true;
//       await FirebaseFirestore.instance.collection('settings').doc('categoryOrder').set(categoryOrder);
//       debugPrint('💾 Saved category order to Firestore: $categoryOrder');
      
//       // Reset flag after a short delay to allow the listener to process
//       Future.delayed(const Duration(milliseconds: 100), () {
//         _isUpdatingOrder = false;
//       });
//     } catch (e) {
//       _isUpdatingOrder = false;
//       debugPrint('❌ Error saving category order: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save category order: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Update category order and save to Firestore
//   Future<void> _updateCategoryOrder(String category1, String category2) async {
//     debugPrint('🔄 Updating category order: $category1 ↔ $category2');
//     debugPrint('📋 Before: $categoryOrder');
    
//     // Show a brief snackbar to indicate the change is being saved
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Updating category order...'),
//         duration: const Duration(seconds: 1),
//         backgroundColor: Colors.blue,
//       ),
//     );
    
//     setState(() {
//       final temp = categoryOrder[category1]!;
//       categoryOrder[category1] = categoryOrder[category2]!;
//       categoryOrder[category2] = temp;
//     });
//     debugPrint('📋 After: $categoryOrder');
//     await _saveCategoryOrder();
//   }

//   // Helper function to create Firebase index
//   void _createFirebaseIndex() {
//     const indexUrl = 'https://console.firebase.google.com/v1/r/project/portfolio-7474e/firestore/indexes?create_composite=Ck5wcm9qZWN0cy9wb3J0Zm9saW8tNzQ3NGUvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3NraWxscy9pbmRleGVzL18QARoMCghjYXRlZ29yeRABGgkKBW9yZGVyEAIaDAoIX19uYW1lX18QAg';
//     // You can use url_launcher to open this URL
//     debugPrint('🔗 Firebase Index URL: $indexUrl');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Check console for Firebase index URL'),
//         action: SnackBarAction(
//           label: 'Copy URL',
//           onPressed: () {
//             // You can implement clipboard functionality here
//             debugPrint('📋 Index URL copied to console');
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     final isDesktop = MediaQuery.of(context).size.width >= 600;
    
//     if (isDesktop) {
//       // Desktop layout (unchanged from original)
//       return Scaffold(
//         backgroundColor: const Color(0xff0f0f1a),
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leadingWidth: MediaQuery.of(context).size.width < 600 ? 130 : 160,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF0B1020),
//                   Color(0xFF101828),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           leading: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                   );
//                 },
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 label: const Text(
//                   "Back",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.white),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   backgroundColor: Colors.transparent,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 ),
//               ),
//             ),
//           ),
//           actions: [
//             if (_isAdmin == true)
//               IconButton(
//                 icon: const Icon(Icons.add, color: Colors.white),
//                 tooltip: 'Add Skill',
//                 onPressed: () => _showAddSkillDialog(context),
//               ),
//           ],
//         ),
//         body: Center(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final containerWidth = 1000.0;
//               final containerHeight = 600.0;
//               final childAspectRatio = 1.2;
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     child: Text(
//                       "Skills",
//                       style: GoogleFonts.comfortaa(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.2,
//                         fontSize: 28,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   Container(
//                     width: containerWidth,
//                     height: containerHeight,
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.white.withOpacity(0.18)),
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFF090C1A),
//                           Color(0xFF0F172A),
//                           Color(0xFF1E293B),
//                         ],
//                         stops: [0.0, 0.55, 1.0],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 12),
//                         Expanded(
//                           child: StreamBuilder<QuerySnapshot>(
//                             stream: FirebaseFirestore.instance.collection('skills').snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 return const Center(child: CircularProgressIndicator());
//                               }
//                               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                                 return const Center(child: Text('No skills found', style: TextStyle(color: Colors.white70)));
//                               }
//                               // Group skills by category
//                               final skills = snapshot.data!.docs.map((doc) => SkillItem.fromFirestore(doc)).toList();
//                               skills.sort((a, b) => a.order.compareTo(b.order));
                              
//                               // Debug: Print loaded skills
//                               debugPrint('📊 Loaded ${skills.length} skills from Firebase:');
//                               for (final skill in skills) {
//                                 debugPrint('  - ${skill.name} (${skill.category}): ${skill.iconUrl ?? 'No icon'}');
//                               }
                              
//                               final Map<String, List<SkillItem>> grouped = {};
//                               for (final skill in skills) {
//                                 grouped.putIfAbsent(skill.category, () => []).add(skill);
//                               }
//                               // Track and update category order
//                               if (categoryOrder.isEmpty) {
//                                 int idx = 0;
//                                 for (final cat in grouped.keys) {
//                                   categoryOrder[cat] = idx++;
//                                 }
//                                 // Save initial category order to Firestore
//                                 _saveCategoryOrder();
//                               } else {
//                                 // Add any new categories that aren't in the order yet
//                                 bool hasNewCategories = false;
//                                 for (final cat in grouped.keys) {
//                                   if (!categoryOrder.containsKey(cat)) {
//                                     categoryOrder[cat] = categoryOrder.values.isEmpty ? 0 : categoryOrder.values.reduce((a, b) => a > b ? a : b) + 1;
//                                     hasNewCategories = true;
//                                   }
//                                 }
//                                 if (hasNewCategories) {
//                                   _saveCategoryOrder();
//                                 }
//                               }
//                               final sortedCategories = grouped.keys.toList()
//                                 ..sort((a, b) => (categoryOrder[a] ?? 0).compareTo(categoryOrder[b] ?? 0));
//                               const crossAxisCount = 2;
//                               const mainAxisSpacing = 8.0;
//                               const crossAxisSpacing = 24.0;
//                               return GridView.count(
//                                 crossAxisCount: crossAxisCount,
//                                 crossAxisSpacing: crossAxisSpacing,
//                                 mainAxisSpacing: mainAxisSpacing,
//                                 childAspectRatio: childAspectRatio,
//                                 children: [
//                                   for (int i = 0; i < sortedCategories.length; i++)
//                                     Stack(
//                                       clipBehavior: Clip.none,
//                                       children: [
//                                         SkillCategory(
//                                           title: sortedCategories[i],
//                                           skills: grouped[sortedCategories[i]]!,
//                                           isAdmin: _isAdmin ?? false,
//                                           onReorder: (oldIndex, newIndex, category) async {
//                                             final categorySkills = skills.where((s) => s.category == category).toList();
//                                             if (newIndex < 0 || newIndex >= categorySkills.length) return;
//                                             final movedSkill = categorySkills[oldIndex];
//                                             categorySkills.removeAt(oldIndex);
//                                             categorySkills.insert(newIndex, movedSkill);
//                                             // Update order in Firestore for all skills in this category
//                                             for (int i = 0; i < categorySkills.length; i++) {
//                                               await FirebaseFirestore.instance.collection('skills').doc(categorySkills[i].id).update({'order': i});
//                                             }
//                                           },
//                                           onEditSkill: (skill) => _showEditSkillDialog(context, skill),
//                                           onDeleteSkill: (skill) => _showDeleteSkillDialog(context, skill),
//                                           onEditCategory: (category) => _showEditCategoryDialog(context, category),
//                                           onDeleteCategory: (category) => _showDeleteCategoryDialog(context, category),
//                                         ),
//                                         if (_isAdmin == true)
//                                           Positioned(
//                                             top: 8,
//                                             right: 8,
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(right: 16),
//                                                   child: Column(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       IconButton(
//                                                         icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
//                                                         padding: EdgeInsets.zero,
//                                                         constraints: const BoxConstraints(),
//                                                         onPressed: i > 0 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i-1]) : null,
//                                                         tooltip: 'Move up',
//                                                       ),
//                                                       IconButton(
//                                                         icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
//                                                         padding: EdgeInsets.zero,
//                                                         constraints: const BoxConstraints(),
//                                                         onPressed: i < sortedCategories.length - 1 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i+1]) : null,
//                                                         tooltip: 'Move down',
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     } else {
//       // Mobile layout with scrollable content and fixed AppBar
//       return Scaffold(
//         backgroundColor: const Color(0xff0f0f1a),
//         body: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               pinned: true,
//               flexibleSpace: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFF0B1020),
//                       Color(0xFF101828),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 130,
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const HomeScreen()),
//                               );
//                             },
//                             icon: const Icon(Icons.arrow_back, color: Colors.white),
//                             label: const Text(
//                               "Back",
//                               style: TextStyle(color: Colors.white, fontSize: 14),
//                             ),
//                             style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: Colors.white),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               backgroundColor: Colors.transparent,
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         if (_isAdmin == true)
//                           IconButton(
//                             icon: const Icon(Icons.add, color: Colors.white),
//                             tooltip: 'Add Skill',
//                             onPressed: () => _showAddSkillDialog(context),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               expandedHeight: kToolbarHeight,
//             ),
//             SliverToBoxAdapter(
//               child: Center(
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     final containerWidth = 1000.0;
//                     final containerHeight = 600.0;
//                     final childAspectRatio = 1.2;
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           child: Text(
//                             "Skills",
//                             style: GoogleFonts.comfortaa(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.2,
//                               fontSize: 28,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                         Container(
//                           width: containerWidth,
//                           height: containerHeight,
//                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(30),
//                             border: Border.all(color: Colors.white.withOpacity(0.18)),
//                             gradient: const LinearGradient(
//                               colors: [
//                                 Color(0xFF090C1A),
//                                 Color(0xFF0F172A),
//                                 Color(0xFF1E293B),
//                               ],
//                               stops: [0.0, 0.55, 1.0],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 12),
//                               Expanded(
//                                 child: StreamBuilder<QuerySnapshot>(
//                                   stream: FirebaseFirestore.instance.collection('skills').snapshots(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                       return const Center(child: CircularProgressIndicator());
//                                     }
//                                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                                       return const Center(child: Text('No skills found', style: TextStyle(color: Colors.white70)));
//                                     }
//                                     // Group skills by category
//                                     final skills = snapshot.data!.docs.map((doc) => SkillItem.fromFirestore(doc)).toList();
//                                     skills.sort((a, b) => a.order.compareTo(b.order));
                                    
//                                     // Debug: Print loaded skills
//                                     debugPrint('📊 Loaded ${skills.length} skills from Firebase:');
//                                     for (final skill in skills) {
//                                       debugPrint('  - ${skill.name} (${skill.category}): ${skill.iconUrl ?? 'No icon'}');
//                                     }
                                    
//                                     final Map<String, List<SkillItem>> grouped = {};
//                                     for (final skill in skills) {
//                                       grouped.putIfAbsent(skill.category, () => []).add(skill);
//                                     }
//                                     // Track and update category order
//                                     if (categoryOrder.isEmpty) {
//                                       int idx = 0;
//                                       for (final cat in grouped.keys) {
//                                         categoryOrder[cat] = idx++;
//                                       }
//                                       // Save initial category order to Firestore
//                                       _saveCategoryOrder();
//                                     } else {
//                                       // Add any new categories that aren't in the order yet
//                                       bool hasNewCategories = false;
//                                       for (final cat in grouped.keys) {
//                                         if (!categoryOrder.containsKey(cat)) {
//                                           categoryOrder[cat] = categoryOrder.values.isEmpty ? 0 : categoryOrder.values.reduce((a, b) => a > b ? a : b) + 1;
//                                           hasNewCategories = true;
//                                         }
//                                       }
//                                       if (hasNewCategories) {
//                                         _saveCategoryOrder();
//                                       }
//                                     }
//                                     final sortedCategories = grouped.keys.toList()
//                                       ..sort((a, b) => (categoryOrder[a] ?? 0).compareTo(categoryOrder[b] ?? 0));
//                                     const crossAxisCount = 1;
//                                     const mainAxisSpacing = 2.0;
//                                     const crossAxisSpacing = 4.0;
//                                     return GridView.count(
//                                       crossAxisCount: crossAxisCount,
//                                       crossAxisSpacing: crossAxisSpacing,
//                                       mainAxisSpacing: mainAxisSpacing,
//                                       childAspectRatio: childAspectRatio,
//                                       physics: const NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       children: [
//                                         for (int i = 0; i < sortedCategories.length; i++)
//                                           Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               SkillCategory(
//                                                 title: sortedCategories[i],
//                                                 skills: grouped[sortedCategories[i]]!,
//                                                 isAdmin: _isAdmin ?? false,
//                                                 onReorder: (oldIndex, newIndex, category) async {
//                                                   final categorySkills = skills.where((s) => s.category == category).toList();
//                                                   if (newIndex < 0 || newIndex >= categorySkills.length) return;
//                                                   final movedSkill = categorySkills[oldIndex];
//                                                   categorySkills.removeAt(oldIndex);
//                                                   categorySkills.insert(newIndex, movedSkill);
//                                                   // Update order in Firestore for all skills in this category
//                                                   for (int i = 0; i < categorySkills.length; i++) {
//                                                     await FirebaseFirestore.instance.collection('skills').doc(categorySkills[i].id).update({'order': i});
//                                                   }
//                                                 },
//                                                 onEditSkill: (skill) => _showEditSkillDialog(context, skill),
//                                                 onDeleteSkill: (skill) => _showDeleteSkillDialog(context, skill),
//                                                 onEditCategory: (category) => _showEditCategoryDialog(context, category),
//                                                 onDeleteCategory: (category) => _showDeleteCategoryDialog(context, category),
//                                               ),
//                                               if (_isAdmin == true)
//                                                 Positioned(
//                                                   top: 8,
//                                                   right: 8,
//                                                   child: Row(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       Padding(
//                                                         padding: const EdgeInsets.only(right: 16),
//                                                         child: Column(
//                                                           mainAxisSize: MainAxisSize.min,
//                                                           children: [
//                                                             IconButton(
//                                                               icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
//                                                               padding: EdgeInsets.zero,
//                                                               constraints: const BoxConstraints(),
//                                                               onPressed: i > 0 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i-1]) : null,
//                                                               tooltip: 'Move up',
//                                                             ),
//                                                             IconButton(
//                                                               icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
//                                                               padding: EdgeInsets.zero,
//                                                               constraints: const BoxConstraints(),
//                                                               onPressed: i < sortedCategories.length - 1 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i+1]) : null,
//                                                               tooltip: 'Move down',
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   void _showAddSkillDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const AddSkillDialog(),
//     );
//   }

//   void _showEditSkillDialog(BuildContext context, SkillItem skill) {
//     final _formKey = GlobalKey<FormState>();
//     String category = skill.category;
//     String name = skill.name;
//     String iconUrl = skill.iconUrl ?? '';
//     final categories = ['Languages', 'Framework', 'Databases', 'Tools'];
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               backgroundColor: const Color(0xff23243a),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.edit, color: Colors.cyanAccent, size: 28),
//                           const SizedBox(width: 10),
//                           Text('Edit Skill', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
//                           const Spacer(),
//                           if (iconUrl.isNotEmpty)
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.cyanAccent.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.all(8),
//                               child: SvgPicture.network(
//                                 iconUrl,
//                                 width: 28,
//                                 height: 28,
//                                 placeholderBuilder: (context) => const Icon(
//                                   Icons.extension,
//                                   color: Colors.cyanAccent,
//                                   size: 28,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 18),
//                       DropdownButtonFormField<String>(
//                         value: category,
//                         items: categories.map((cat) => DropdownMenuItem(
//                           value: cat,
//                           child: Text(cat, style: const TextStyle(color: Colors.white)),
//                         )).toList(),
//                         onChanged: (val) => category = val ?? '',
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: const TextStyle(color: Colors.cyanAccent),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.05),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         dropdownColor: const Color(0xff23243a),
//                         validator: (val) => val == null || val.isEmpty ? 'Select category' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: name,
//                         decoration: InputDecoration(
//                           labelText: 'Skill Name',
//                           labelStyle: const TextStyle(color: Colors.cyanAccent),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.05),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                         onChanged: (val) => name = val,
//                         validator: (val) => val == null || val.isEmpty ? 'Enter skill name' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: iconUrl,
//                         decoration: InputDecoration(
//                           labelText: 'SVG Icon URL (Cloudinary)',
//                           labelStyle: const TextStyle(color: Colors.cyanAccent),
//                           hintText: 'https://res.cloudinary.com/.../skills/icon.svg',
//                           hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.05),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                           suffixIcon: iconUrl.isNotEmpty
//                               ? IconButton(
//                                   onPressed: () => setDialogState(() => iconUrl = ''),
//                                   icon: const Icon(Icons.clear, color: Colors.red),
//                                   tooltip: 'Clear URL',
//                                 )
//                               : null,
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                         onChanged: (val) => setDialogState(() => iconUrl = val),
//                         validator: (val) => val == null || val.isEmpty ? 'Enter SVG URL' : null,
//                       ),
//                       if (iconUrl.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         Text('Icon Preview:', style: TextStyle(color: Colors.white70, fontSize: 12)),
//                         const SizedBox(height: 4),
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.05),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: SvgPicture.network(
//                             iconUrl,
//                             width: 32,
//                             height: 32,
//                             placeholderBuilder: (context) => const Icon(
//                               Icons.extension,
//                               color: Colors.cyanAccent,
//                               size: 32,
//                             ),
//                           ),
//                         ),
//                       ],
//                       const SizedBox(height: 18),
//                       const Divider(color: Colors.white24, thickness: 1),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.cyanAccent,
//                               foregroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                             ),
//                             onPressed: () async {
//                               if (_formKey.currentState!.validate()) {
//                                 try {
//                                   await FirebaseFirestore.instance.collection('skills').doc(skill.id).update({
//                                     'category': category,
//                                     'name': name,
//                                     'iconUrl': iconUrl,
//                                   });
//                                   Navigator.pop(context);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('Skill "$name" updated successfully!'),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   );
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('Failed to update skill: $e'),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               }
//                             },
//                             child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showDeleteSkillDialog(BuildContext context, SkillItem skill) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xff23243a),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(
//             'Delete Skill',
//             style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           content: Text(
//             'Are you sure you want to delete "${skill.name}"? This action cannot be undone.',
//             style: const TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () async {
//                 try {
//                   await FirebaseFirestore.instance.collection('skills').doc(skill.id).delete();
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Skill "${skill.name}" deleted successfully!'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Failed to delete skill: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditCategoryDialog(BuildContext context, String category) {
//     final _formKey = GlobalKey<FormState>();
//     String newCategoryName = category;
//     final categories = ['Languages', 'Framework', 'Databases', 'Tools'];
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xff23243a),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(
//             'Edit Category',
//             style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           content: Form(
//             key: _formKey,
//             child: DropdownButtonFormField<String>(
//               value: newCategoryName,
//               items: categories.map((cat) => DropdownMenuItem(
//                 value: cat,
//                 child: Text(cat, style: const TextStyle(color: Colors.white)),
//               )).toList(),
//               onChanged: (val) => newCategoryName = val ?? '',
//               decoration: InputDecoration(
//                 labelText: 'Category Name',
//                 labelStyle: const TextStyle(color: Colors.cyanAccent),
//                 filled: true,
//                 fillColor: Colors.white.withOpacity(0.05),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               dropdownColor: const Color(0xff23243a),
//               validator: (val) => val == null || val.isEmpty ? 'Select category' : null,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.cyanAccent,
//                 foregroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   try {
//                     // Update all skills in this category
//                     final query = await FirebaseFirestore.instance
//                         .collection('skills')
//                         .where('category', isEqualTo: category)
//                         .get();
                    
//                     final batch = FirebaseFirestore.instance.batch();
//                     for (final doc in query.docs) {
//                       batch.update(doc.reference, {'category': newCategoryName});
//                     }
//                     await batch.commit();
                    
//                     // Update category order if category name changed
//                     if (category != newCategoryName) {
//                       setState(() {
//                         categoryOrder[newCategoryName] = categoryOrder[category] ?? 0;
//                         categoryOrder.remove(category);
//                       });
//                       await _saveCategoryOrder();
//                     }
                    
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Category updated to "$newCategoryName"!'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to update category: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteCategoryDialog(BuildContext context, String category) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xff23243a),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(
//             'Delete Category',
//             style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           content: Text(
//             'Are you sure you want to delete the "$category" category and all its skills? This action cannot be undone.',
//             style: const TextStyle(color: Colors.white70),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () async {
//                 try {
//                   // Delete all skills in this category
//                   final query = await FirebaseFirestore.instance
//                       .collection('skills')
//                       .where('category', isEqualTo: category)
//                       .get();
                  
//                   final batch = FirebaseFirestore.instance.batch();
//                   for (final doc in query.docs) {
//                     batch.delete(doc.reference);
//                   }
//                   await batch.commit();
                  
//                   // Remove category from order
//                   setState(() {
//                     categoryOrder.remove(category);
//                   });
//                   await _saveCategoryOrder();
                  
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Category "$category" and all its skills deleted!'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Failed to delete category: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class SkillCategory extends StatefulWidget {
//   final String title;
//   final List<SkillItem> skills;
//   final bool isAdmin;
//   final void Function(int oldIndex, int newIndex, String category) onReorder;
//   final void Function(SkillItem skill) onEditSkill;
//   final void Function(SkillItem skill) onDeleteSkill;
//   final void Function(String category) onEditCategory;
//   final void Function(String category) onDeleteCategory;

//   const SkillCategory({
//     super.key, 
//     required this.title, 
//     required this.skills, 
//     required this.isAdmin, 
//     required this.onReorder,
//     required this.onEditSkill,
//     required this.onDeleteSkill,
//     required this.onEditCategory,
//     required this.onDeleteCategory,
//   });

//   @override
//   State<SkillCategory> createState() => _SkillCategoryState();
// }

// class _SkillCategoryState extends State<SkillCategory> {
//   bool _isHovered = false;
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 600;
//     final borderColor = (_isHovered || _isPressed) ? Colors.white : Colors.white.withOpacity(0.18);
//     final borderWidth = (_isHovered || _isPressed) ? 2.8 : 2.5;
//     final boxDecorationDesktop = BoxDecoration(
//       borderRadius: BorderRadius.circular(24),
//       gradient: const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0xCC0B132B), // deep navy glass
//           Color(0x99112233), // slate glass
//           Color(0x66121A2E), // subtle violet tint
//         ],
//       ),
//       border: Border.all(
//         color: (_isHovered || _isPressed) ? Colors.white : Colors.cyanAccent.withOpacity(0.14),
//         width: (_isHovered || _isPressed) ? 2.2 : 1.4,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.30),
//           blurRadius: 26,
//           spreadRadius: 1,
//           offset: const Offset(0, 10),
//         ),
//         BoxShadow(
//           color: Colors.cyanAccent.withOpacity(0.06),
//           blurRadius: 18,
//           spreadRadius: 1,
//         ),
//       ],
//     );
//     final boxDecorationMobile = BoxDecoration(
//       borderRadius: BorderRadius.circular(24),
//       gradient: const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Color(0xCC0B132B),
//           Color(0x99112233),
//           Color(0x66121A2E),
//         ],
//       ),
//       border: Border.all(
//         color: (_isHovered || _isPressed) ? Colors.white : Colors.cyanAccent.withOpacity(0.14),
//         width: (_isHovered || _isPressed) ? 2.2 : 1.4,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.28),
//           blurRadius: 22,
//           spreadRadius: 1,
//           offset: const Offset(0, 8),
//         ),
//         BoxShadow(
//           color: Colors.cyanAccent.withOpacity(0.05),
//           blurRadius: 14,
//           spreadRadius: 1,
//         ),
//       ],
//     );
//     Widget mainBox(Widget child, {double? width, double? height}) {
//       return MouseRegion(
//         onEnter: (_) => setState(() => _isHovered = true),
//         onExit: (_) => setState(() => _isHovered = false),
//         child: GestureDetector(
//           onTapDown: (_) => setState(() => _isPressed = true),
//           onTapUp: (_) => setState(() => _isPressed = false),
//           onTapCancel: () => setState(() => _isPressed = false),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             decoration: isDesktop ? boxDecorationDesktop : boxDecorationMobile,
//             width: width,
//             height: isDesktop ? 300 : height,
//             padding: isDesktop ? const EdgeInsets.all(32) : const EdgeInsets.all(16),
//             clipBehavior: isDesktop ? Clip.none : Clip.hardEdge,
//             child: child,
//           ),
//         ),
//       );
//     }
//     if (isDesktop) {
//       return Stack(
//         clipBehavior: Clip.none,
//         children: [
//           mainBox(
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     _buildCategoryIcon(widget.skills.first.iconUrl, 32, category: widget.title),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         widget.title,
//                         style: GoogleFonts.eduQldBeginner(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: widget.skills.asMap().entries.map((entry) {
//                     final i = entry.key;
//                     final skill = entry.value;
//                     return Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             _SkillChip(
//                               skill: skill,
//                               isDesktop: true,
//                               isAdmin: widget.isAdmin,
//                             ),
//                             if (widget.isAdmin) ...[
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 16),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
//                                       padding: EdgeInsets.zero,
//                                       constraints: const BoxConstraints(),
//                                       onPressed: i > 0 ? () => widget.onReorder(i, i - 1, widget.title) : null,
//                                       tooltip: 'Move up',
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
//                                       padding: EdgeInsets.zero,
//                                       constraints: const BoxConstraints(),
//                                       onPressed: i < widget.skills.length - 1 ? () => widget.onReorder(i, i + 1, widget.title) : null,
//                                       tooltip: 'Move down',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         if (widget.isAdmin)
//                           Positioned(
//                             top: -8,
//                             right: -8,
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 16),
//                                   onPressed: () => widget.onEditSkill(skill),
//                                   tooltip: 'Edit',
//                                   padding: const EdgeInsets.all(4),
//                                   constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
//                                 ),
//                                 const SizedBox(width: 0),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
//                                   onPressed: () => widget.onDeleteSkill(skill),
//                                   tooltip: 'Delete',
//                                   padding: const EdgeInsets.all(4),
//                                   constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             width: double.infinity,
//           ),
//           if (widget.isAdmin)
//             Positioned(
//               top: -18,
//               right: -18,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
//                     onPressed: () => widget.onEditCategory(widget.title),
//                     tooltip: 'Edit Category',
//                     padding: const EdgeInsets.all(6),
//                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//                   ),
//                   const SizedBox(width: 2),
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
//                     onPressed: () => widget.onDeleteCategory(widget.title),
//                     tooltip: 'Delete Category',
//                     padding: const EdgeInsets.all(6),
//                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       );
//     }
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         mainBox(
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   _buildCategoryIcon(widget.skills.first.iconUrl, 24, category: widget.title),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: GoogleFonts.eduQldBeginner(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     alignment: WrapAlignment.start,
//                     children: [
//                       for (int i = 0; i < widget.skills.length; i++)
//                         Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 _SkillChip(
//                                   skill: widget.skills[i],
//                                   isDesktop: true,
//                                   isAdmin: widget.isAdmin,
//                                 ),
//                                 if (widget.isAdmin) ...[
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 16),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
//                                           padding: EdgeInsets.zero,
//                                           constraints: BoxConstraints(),
//                                           onPressed: i > 0 ? () => widget.onReorder(i, i - 1, widget.title) : null,
//                                           tooltip: 'Move up',
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
//                                           padding: EdgeInsets.zero,
//                                           constraints: BoxConstraints(),
//                                           onPressed: i < widget.skills.length - 1 ? () => widget.onReorder(i, i + 1, widget.title) : null,
//                                           tooltip: 'Move down',
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                             if (widget.isAdmin)
//                               Positioned(
//                                 top: -6,
//                                 right: -6,
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 14),
//                                       onPressed: () => widget.onEditSkill(widget.skills[i]),
//                                       tooltip: 'Edit',
//                                       padding: const EdgeInsets.all(3),
//                                       constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
//                                     ),
//                                     const SizedBox(width: 0),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete, color: Colors.redAccent, size: 14),
//                                       onPressed: () => widget.onDeleteSkill(widget.skills[i]),
//                                       tooltip: 'Delete',
//                                       padding: const EdgeInsets.all(3),
//                                       constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           width: double.infinity,
//           height: 240,
//         ),
//         if (widget.isAdmin)
//           Positioned(
//             top: -12,
//             right: -12,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 16),
//                   onPressed: () => widget.onEditCategory(widget.title),
//                   tooltip: 'Edit Category',
//                   padding: const EdgeInsets.all(4),
//                   constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
//                 ),
//                 const SizedBox(width: 0),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
//                   onPressed: () => widget.onDeleteCategory(widget.title),
//                   tooltip: 'Delete Category',
//                   padding: const EdgeInsets.all(4),
//                   constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildCategoryIcon(String? iconUrl, double size, {String? category}) {
//     // Permanent SVGs for main categories
//     final categorySvgs = <String, String>{
//       'Languages': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751118819/ud5yvl7gbkj6oul7esqt.svg',
//       'Framework': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751117868/feinbsv6jyde9jccyrkg.svg',
//       'Databases': 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg',
//       'Tools': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751118421/x6b4ojkysonz0ro4hxle.svg',
//     };
//     if (category != null && categorySvgs.containsKey(category)) {
//       return SvgPicture.network(
//         categorySvgs[category]!,
//         width: size,
//         height: size,
//         placeholderBuilder: (context) => Icon(
//           Icons.extension,
//           size: size,
//           color: Colors.cyanAccent,
//         ),
//         errorBuilder: (context, error, stackTrace) {
//           debugPrint('❌ Category SVG loading error: $error');
//           return Icon(
//             Icons.extension,
//             size: size,
//             color: Colors.cyanAccent,
//           );
//         },
//       );
//     }
//     if (iconUrl != null && iconUrl.isNotEmpty) {
//       return SvgPicture.network(
//         iconUrl,
//         width: size,
//         height: size,
//         placeholderBuilder: (context) => Icon(
//           Icons.extension,
//           size: size,
//           color: Colors.cyanAccent,
//         ),
//         errorBuilder: (context, error, stackTrace) {
//           debugPrint('❌ Category SVG loading error: $error');
//           return Icon(
//             Icons.extension,
//             size: size,
//             color: Colors.cyanAccent,
//           );
//         },
//       );
//     }
//     return Icon(
//       Icons.extension,
//       size: size,
//       color: Colors.cyanAccent,
//     );
//   }
// }

// class _SkillChip extends StatefulWidget {
//   final SkillItem skill;
//   final bool isDesktop;
//   final bool isAdmin;

//   const _SkillChip({
//     required this.skill,
//     required this.isDesktop,
//     required this.isAdmin,
//   });

//   @override
//   State<_SkillChip> createState() => _SkillChipState();
// }

// class _SkillChipState extends State<_SkillChip> {
//   bool _isHovered = false;
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTapDown: (_) => setState(() => _isPressed = true),
//         onTapUp: (_) => setState(() => _isPressed = false),
//         onTapCancel: () => setState(() => _isPressed = false),
//         child: AnimatedScale(
//           scale: (_isHovered || _isPressed) ? 1.05 : 1.0,
//           duration: const Duration(milliseconds: 150),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             padding: EdgeInsets.symmetric(
//               vertical: widget.isDesktop ? 10 : 4,
//               horizontal: widget.isDesktop ? 18 : 10,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(widget.isDesktop ? 0.08 : 0.05),
//               borderRadius: BorderRadius.circular(widget.isDesktop ? 18 : 12),
//               border: Border.all(
//                 color: (_isHovered || _isPressed) ? Colors.white : Colors.white.withOpacity(0.18),
//                 width: (_isHovered || _isPressed) ? 1.5 : 1.2,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildSkillIcon(widget.skill, widget.isDesktop),
//                 SizedBox(width: 8),
//                 Text(
//                   widget.skill.name,
//                   style: GoogleFonts.comfortaa(
//                     fontSize: widget.isDesktop ? 16 : 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSkillIcon(SkillItem skill, bool isDesktop) {
//     if (skill.iconUrl != null && skill.iconUrl!.isNotEmpty) {
//       return SvgPicture.network(
//         skill.iconUrl!,
//         width: isDesktop ? 22 : 16,
//         height: isDesktop ? 22 : 16,
//         placeholderBuilder: (context) => Icon(
//           Icons.extension,
//           size: isDesktop ? 22 : 16,
//           color: Colors.cyanAccent,
//         ),
//         errorBuilder: (context, error, stackTrace) {
//           debugPrint('❌ SVG loading error for ${skill.name}: $error');
//           return Icon(
//             Icons.extension,
//             size: isDesktop ? 22 : 16,
//             color: Colors.cyanAccent,
//           );
//         },
//       );
//     }
//     return Icon(
//       Icons.extension,
//       size: isDesktop ? 22 : 16,
//       color: Colors.cyanAccent,
//     );
//   }
// }

// class SkillBox extends StatefulWidget {
//   final SkillItem skill;
//   final bool isAdmin;

//   const SkillBox({
//     super.key,
//     required this.skill,
//     required this.isAdmin,
//   });

//   @override
//   State<SkillBox> createState() => _SkillBoxState();
// }

// class _SkillBoxState extends State<SkillBox> {
//   bool _isHovered = false;
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTapDown: (_) => setState(() => _isPressed = true),
//         onTapUp: (_) => setState(() => _isPressed = false),
//         onTapCancel: () => setState(() => _isPressed = false),
//         child: AnimatedScale(
//           scale: (_isHovered || _isPressed) ? 1.05 : 1.0,
//           duration: const Duration(milliseconds: 150),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white.withOpacity(0.05),
//               border: Border.all(
//                 color: (_isHovered || _isPressed) ? Colors.white : Colors.white.withOpacity(0.2),
//                 width: (_isHovered || _isPressed) ? 1.5 : 1,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildSkillIcon(widget.skill),
//                 const SizedBox(width: 4),
//                 Text(
//                   widget.skill.name,
//                   style: GoogleFonts.comfortaa(
//                     fontSize: 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillIcon(SkillItem skill) {
//     if (skill.iconUrl != null && skill.iconUrl!.isNotEmpty) {
//       return SvgPicture.network(
//         skill.iconUrl!,
//         width: 16,
//         height: 16,
//         placeholderBuilder: (context) => Icon(
//           Icons.extension,
//           size: 16,
//           color: Colors.cyanAccent,
//         ),
//         errorBuilder: (context, error, stackTrace) {
//           debugPrint('❌ SVG loading error for ${skill.name}: $error');
//           return Icon(
//             Icons.extension,
//             size: 16,
//             color: Colors.cyanAccent,
//           );
//         },
//       );
//     }
//     return Icon(
//       Icons.extension,
//       size: 16,
//       color: Colors.cyanAccent,
//     );
//   }
// }

// class SkillItem {
//   final String name;
//   final String? iconUrl;
//   final String category;
//   final int order;
//   final String id;

//   SkillItem({required this.name, this.iconUrl, required this.category, required this.order, required this.id});

//   factory SkillItem.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return SkillItem(
//       name: data['name'] ?? '',
//       iconUrl: data['iconUrl'] ?? data['icon'] ?? '',
//       category: data['category'] ?? '',
//       order: data['order'] ?? 0,
//       id: doc.id,
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portfolio/home_screen.dart';
import 'add_skill.dart';
import 'dart:async';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  bool? _isAdmin;
  bool _loading = true;
  Map<String, int> categoryOrder = {};
  StreamSubscription<DocumentSnapshot>? _categoryOrderSubscription;
  bool _isUpdatingOrder = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _listenToCategoryOrder();
  }

  @override
  void dispose() {
    _categoryOrderSubscription?.cancel();
    super.dispose();
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

  void _listenToCategoryOrder() {
    _categoryOrderSubscription = FirebaseFirestore.instance
        .collection('settings')
        .doc('categoryOrder')
        .snapshots()
        .listen((snapshot) {
      if (_isUpdatingOrder) {
        debugPrint('🔄 Skipping update - we are the ones making the change');
        return;
      }
      
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          categoryOrder = Map<String, int>.from(data);
        });
        debugPrint('📋 Real-time category order update: $categoryOrder');
      } else {
        debugPrint('📋 No category order found in Firestore, will initialize from skills');
      }
    }, onError: (error) {
      debugPrint('❌ Error listening to category order: $error');
    });
  }

  Future<void> _saveCategoryOrder() async {
    try {
      _isUpdatingOrder = true;
      await FirebaseFirestore.instance.collection('settings').doc('categoryOrder').set(categoryOrder);
      debugPrint('💾 Saved category order to Firestore: $categoryOrder');
      
      Future.delayed(const Duration(milliseconds: 100), () {
        _isUpdatingOrder = false;
      });
    } catch (e) {
      _isUpdatingOrder = false;
      debugPrint('❌ Error saving category order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateCategoryOrder(String category1, String category2) async {
    debugPrint('🔄 Updating category order: $category1 ↔ $category2');
    debugPrint('📋 Before: $categoryOrder');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updating category order...'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
    
    setState(() {
      final temp = categoryOrder[category1]!;
      categoryOrder[category1] = categoryOrder[category2]!;
      categoryOrder[category2] = temp;
    });
    debugPrint('📋 After: $categoryOrder');
    await _saveCategoryOrder();
  }

  void _createFirebaseIndex() {
    const indexUrl = 'https://console.firebase.google.com/v1/r/project/portfolio-7474e/firestore/indexes?create_composite=Ck5wcm9qZWN0cy9wb3J0Zm9saW8tNzQ3NGUvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3NraWxscy9pbmRleGVzL18QARoMCghjYXRlZ29yeRABGgkKBW9yZGVyEAIaDAoIX19uYW1lX18QAg';
    debugPrint('🔗 Firebase Index URL: $indexUrl');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Check console for Firebase index URL'),
        action: SnackBarAction(
          label: 'Copy URL',
          onPressed: () {
            debugPrint('📋 Index URL copied to console');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    
    if (isDesktop) {
      // Desktop layout with scrollable content
      return Scaffold(
        backgroundColor: const Color(0xff0f0f1a),
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
                label: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
          ),
          actions: [
            if (_isAdmin == true)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Skill',
                onPressed: () => _showAddSkillDialog(context),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = 1000.0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        "Skills",
                        style: GoogleFonts.comfortaa(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: containerWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('skills').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text('No skills found', style: TextStyle(color: Colors.white70)));
                              }
                              final skills = snapshot.data!.docs.map((doc) => SkillItem.fromFirestore(doc)).toList();
                              skills.sort((a, b) => a.order.compareTo(b.order));
                              
                              debugPrint('📊 Loaded ${skills.length} skills from Firebase:');
                              for (final skill in skills) {
                                debugPrint('  - ${skill.name} (${skill.category}): ${skill.iconUrl ?? 'No icon'}');
                              }
                              
                              final Map<String, List<SkillItem>> grouped = {};
                              for (final skill in skills) {
                                grouped.putIfAbsent(skill.category, () => []).add(skill);
                              }
                              if (categoryOrder.isEmpty) {
                                int idx = 0;
                                for (final cat in grouped.keys) {
                                  categoryOrder[cat] = idx++;
                                }
                                _saveCategoryOrder();
                              } else {
                                bool hasNewCategories = false;
                                for (final cat in grouped.keys) {
                                  if (!categoryOrder.containsKey(cat)) {
                                    categoryOrder[cat] = categoryOrder.values.isEmpty ? 0 : categoryOrder.values.reduce((a, b) => a > b ? a : b) + 1;
                                    hasNewCategories = true;
                                  }
                                }
                                if (hasNewCategories) {
                                  _saveCategoryOrder();
                                }
                              }
                              final sortedCategories = grouped.keys.toList()
                                ..sort((a, b) => (categoryOrder[a] ?? 0).compareTo(categoryOrder[b] ?? 0));
                              const crossAxisCount = 2;
                              const mainAxisSpacing = 8.0;
                              const crossAxisSpacing = 24.0;
                              const childAspectRatio = 1.2;
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: crossAxisSpacing,
                                mainAxisSpacing: mainAxisSpacing,
                                childAspectRatio: childAspectRatio,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (int i = 0; i < sortedCategories.length; i++)
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        SkillCategory(
                                          title: sortedCategories[i],
                                          skills: grouped[sortedCategories[i]]!,
                                          isAdmin: _isAdmin ?? false,
                                          onReorder: (oldIndex, newIndex, category) async {
                                            final categorySkills = skills.where((s) => s.category == category).toList();
                                            if (newIndex < 0 || newIndex >= categorySkills.length) return;
                                            final movedSkill = categorySkills[oldIndex];
                                            categorySkills.removeAt(oldIndex);
                                            categorySkills.insert(newIndex, movedSkill);
                                            for (int i = 0; i < categorySkills.length; i++) {
                                              await FirebaseFirestore.instance.collection('skills').doc(categorySkills[i].id).update({'order': i});
                                            }
                                          },
                                          onEditSkill: (skill) => _showEditSkillDialog(context, skill),
                                          onDeleteSkill: (skill) => _showDeleteSkillDialog(context, skill),
                                          onEditCategory: (category) => _showEditCategoryDialog(context, category),
                                          onDeleteCategory: (category) => _showDeleteCategoryDialog(context, category),
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Tapped category: ${sortedCategories[i]}'),
                                                backgroundColor: Colors.blue,
                                              ),
                                            );
                                          },
                                        ),
                                        if (_isAdmin == true)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        onPressed: i > 0 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i-1]) : null,
                                                        tooltip: 'Move up',
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        onPressed: i < sortedCategories.length - 1 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i+1]) : null,
                                                        tooltip: 'Move down',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Add padding at the bottom
                  ],
                );
              },
            ),
          ),
        ),
      );
    } else {
      // Mobile layout (already scrollable via CustomScrollView)
      return Scaffold(
        backgroundColor: const Color(0xff0f0f1a),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            label: const Text(
                              "Back",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_isAdmin == true)
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: 'Add Skill',
                            onPressed: () => _showAddSkillDialog(context),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              expandedHeight: kToolbarHeight,
            ),
            SliverToBoxAdapter(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerWidth = 1000.0;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Text(
                            "Skills",
                            style: GoogleFonts.comfortaa(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: containerWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('skills').snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return const Center(child: Text('No skills found', style: TextStyle(color: Colors.white70)));
                                  }
                                  final skills = snapshot.data!.docs.map((doc) => SkillItem.fromFirestore(doc)).toList();
                                  skills.sort((a, b) => a.order.compareTo(b.order));
                                  
                                  debugPrint('📊 Loaded ${skills.length} skills from Firebase:');
                                  for (final skill in skills) {
                                    debugPrint('  - ${skill.name} (${skill.category}): ${skill.iconUrl ?? 'No icon'}');
                                  }
                                  
                                  final Map<String, List<SkillItem>> grouped = {};
                                  for (final skill in skills) {
                                    grouped.putIfAbsent(skill.category, () => []).add(skill);
                                  }
                                  if (categoryOrder.isEmpty) {
                                    int idx = 0;
                                    for (final cat in grouped.keys) {
                                      categoryOrder[cat] = idx++;
                                    }
                                    _saveCategoryOrder();
                                  } else {
                                    bool hasNewCategories = false;
                                    for (final cat in grouped.keys) {
                                      if (!categoryOrder.containsKey(cat)) {
                                        categoryOrder[cat] = categoryOrder.values.isEmpty ? 0 : categoryOrder.values.reduce((a, b) => a > b ? a : b) + 1;
                                        hasNewCategories = true;
                                      }
                                    }
                                    if (hasNewCategories) {
                                      _saveCategoryOrder();
                                    }
                                  }
                                  final sortedCategories = grouped.keys.toList()
                                    ..sort((a, b) => (categoryOrder[a] ?? 0).compareTo(categoryOrder[b] ?? 0));
                                  const crossAxisCount = 1;
                                  const mainAxisSpacing = 2.0;
                                  const crossAxisSpacing = 4.0;
                                  const childAspectRatio = 1.2;
                                  return GridView.count(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: mainAxisSpacing,
                                    childAspectRatio: childAspectRatio,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      for (int i = 0; i < sortedCategories.length; i++)
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            SkillCategory(
                                              title: sortedCategories[i],
                                              skills: grouped[sortedCategories[i]]!,
                                              isAdmin: _isAdmin ?? false,
                                              onReorder: (oldIndex, newIndex, category) async {
                                                final categorySkills = skills.where((s) => s.category == category).toList();
                                                if (newIndex < 0 || newIndex >= categorySkills.length) return;
                                                final movedSkill = categorySkills[oldIndex];
                                                categorySkills.removeAt(oldIndex);
                                                categorySkills.insert(newIndex, movedSkill);
                                                for (int i = 0; i < categorySkills.length; i++) {
                                                  await FirebaseFirestore.instance.collection('skills').doc(categorySkills[i].id).update({'order': i});
                                                }
                                              },
                                              onEditSkill: (skill) => _showEditSkillDialog(context, skill),
                                              onDeleteSkill: (skill) => _showDeleteSkillDialog(context, skill),
                                              onEditCategory: (category) => _showEditCategoryDialog(context, category),
                                              onDeleteCategory: (category) => _showDeleteCategoryDialog(context, category),
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Tapped category: ${sortedCategories[i]}'),
                                                    backgroundColor: Colors.blue,
                                                  ),
                                                );
                                              },
                                            ),
                                            if (_isAdmin == true)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 16),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                            onPressed: i > 0 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i-1]) : null,
                                                            tooltip: 'Move up',
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                            onPressed: i < sortedCategories.length - 1 ? () => _updateCategoryOrder(sortedCategories[i], sortedCategories[i+1]) : null,
                                                            tooltip: 'Move down',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16), // Add padding at the bottom
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAddSkillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSkillDialog(),
    );
  }

  void _showEditSkillDialog(BuildContext context, SkillItem skill) {
    final _formKey = GlobalKey<FormState>();
    String category = skill.category;
    String name = skill.name;
    String iconUrl = skill.iconUrl ?? '';
    final categories = ['Languages', 'Framework', 'Databases', 'Tools'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xff23243a),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.cyanAccent, size: 28),
                          const SizedBox(width: 10),
                          Text('Edit Skill', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Spacer(),
                          if (iconUrl.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.network(
                                iconUrl,
                                width: 28,
                                height: 28,
                                placeholderBuilder: (context) => const Icon(
                                  Icons.extension,
                                  color: Colors.cyanAccent,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: category,
                        items: categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (val) => category = val ?? '',
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        dropdownColor: const Color(0xff23243a),
                        validator: (val) => val == null || val.isEmpty ? 'Select category' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          labelText: 'Skill Name',
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => name = val,
                        validator: (val) => val == null || val.isEmpty ? 'Enter skill name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: iconUrl,
                        decoration: InputDecoration(
                          labelText: 'SVG Icon URL (Cloudinary)',
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          hintText: 'https://res.cloudinary.com/.../skills/icon.svg',
                          hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: iconUrl.isNotEmpty
                              ? IconButton(
                                  onPressed: () => setDialogState(() => iconUrl = ''),
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  tooltip: 'Clear URL',
                                )
                              : null,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => setDialogState(() => iconUrl = val),
                        validator: (val) => val == null || val.isEmpty ? 'Enter SVG URL' : null,
                      ),
                      if (iconUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Icon Preview:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.network(
                            iconUrl,
                            width: 32,
                            height: 32,
                            placeholderBuilder: (context) => const Icon(
                              Icons.extension,
                              color: Colors.cyanAccent,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await FirebaseFirestore.instance.collection('skills').doc(skill.id).update({
                                    'category': category,
                                    'name': name,
                                    'iconUrl': iconUrl,
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Skill "$name" updated successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update skill: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteSkillDialog(BuildContext context, SkillItem skill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Skill',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${skill.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('skills').doc(skill.id).delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Skill "${skill.name}" deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete skill: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, String category) {
    final _formKey = GlobalKey<FormState>();
    String newCategoryName = category;
    final categories = ['Languages', 'Framework', 'Databases', 'Tools'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Category',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: DropdownButtonFormField<String>(
              value: newCategoryName,
              items: categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat, style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: (val) => newCategoryName = val ?? '',
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: const Color(0xff23243a),
              validator: (val) => val == null || val.isEmpty ? 'Select category' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final query = await FirebaseFirestore.instance
                        .collection('skills')
                        .where('category', isEqualTo: category)
                        .get();
                    
                    final batch = FirebaseFirestore.instance.batch();
                    for (final doc in query.docs) {
                      batch.update(doc.reference, {'category': newCategoryName});
                    }
                    await batch.commit();
                    
                    if (category != newCategoryName) {
                      setState(() {
                        categoryOrder[newCategoryName] = categoryOrder[category] ?? 0;
                        categoryOrder.remove(category);
                      });
                      await _saveCategoryOrder();
                    }
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category updated to "$newCategoryName"!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update category: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Category',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete the "$category" category and all its skills? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                try {
                  final query = await FirebaseFirestore.instance
                      .collection('skills')
                      .where('category', isEqualTo: category)
                      .get();
                  
                  final batch = FirebaseFirestore.instance.batch();
                  for (final doc in query.docs) {
                    batch.delete(doc.reference);
                  }
                  await batch.commit();
                  
                  setState(() {
                    categoryOrder.remove(category);
                  });
                  await _saveCategoryOrder();
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category "$category" and all its skills deleted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete category: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class SkillCategory extends StatefulWidget {
  final String title;
  final List<SkillItem> skills;
  final bool isAdmin;
  final void Function(int oldIndex, int newIndex, String category) onReorder;
  final void Function(SkillItem skill) onEditSkill;
  final void Function(SkillItem skill) onDeleteSkill;
  final void Function(String category) onEditCategory;
  final void Function(String category) onDeleteCategory;
  final VoidCallback? onTap; // Added for button functionality

  const SkillCategory({
    super.key,
    required this.title,
    required this.skills,
    required this.isAdmin,
    required this.onReorder,
    required this.onEditSkill,
    required this.onDeleteSkill,
    required this.onEditCategory,
    required this.onDeleteCategory,
    this.onTap,
  });

  @override
  State<SkillCategory> createState() => _SkillCategoryState();
}

class _SkillCategoryState extends State<SkillCategory> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final borderColor = (_isHovered || _isPressed) ? Colors.white : Colors.white.withOpacity(0.18);
    final borderWidth = (_isHovered || _isPressed) ? 2.8 : 2.5;
    final boxDecorationDesktop = BoxDecoration(
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
      border: Border.all(
        color: (_isHovered || _isPressed) ? Colors.white : Colors.cyanAccent.withOpacity(0.14),
        width: (_isHovered || _isPressed) ? 2.2 : 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.30),
          blurRadius: 26,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.06),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ],
    );
    final boxDecorationMobile = BoxDecoration(
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
      border: Border.all(
        color: (_isHovered || _isPressed) ? Colors.white : Colors.cyanAccent.withOpacity(0.14),
        width: (_isHovered || _isPressed) ? 2.2 : 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.05),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ],
    );
    Widget mainBox(Widget child, {double? width, double? height}) {
      return InkWell(
        onTap: widget.onTap,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: isDesktop ? boxDecorationDesktop : boxDecorationMobile,
          width: width,
          height: isDesktop ? 300 : height,
          padding: isDesktop ? const EdgeInsets.all(32) : const EdgeInsets.all(16),
          clipBehavior: isDesktop ? Clip.none : Clip.hardEdge,
          child: child,
        ),
      );
    }
    if (isDesktop) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          mainBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildCategoryIcon(widget.skills.first.iconUrl, 32, category: widget.title),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.eduQldBeginner(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: widget.skills.asMap().entries.map((entry) {
                    final i = entry.key;
                    final skill = entry.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _SkillChip(
                              skill: skill,
                              isDesktop: true,
                              isAdmin: widget.isAdmin,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tapped skill: ${skill.name}'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                            if (widget.isAdmin) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: i > 0 ? () => widget.onReorder(i, i - 1, widget.title) : null,
                                      tooltip: 'Move up',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: i < widget.skills.length - 1 ? () => widget.onReorder(i, i + 1, widget.title) : null,
                                      tooltip: 'Move down',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.isAdmin)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 16),
                                  onPressed: () => widget.onEditSkill(skill),
                                  tooltip: 'Edit',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                                const SizedBox(width: 0),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                                  onPressed: () => widget.onDeleteSkill(skill),
                                  tooltip: 'Delete',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            width: double.infinity,
          ),
          if (widget.isAdmin)
            Positioned(
              top: -18,
              right: -18,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
                    onPressed: () => widget.onEditCategory(widget.title),
                    tooltip: 'Edit Category',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: () => widget.onDeleteCategory(widget.title),
                    tooltip: 'Delete Category',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainBox(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCategoryIcon(widget.skills.first.iconUrl, 24, category: widget.title),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.eduQldBeginner(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: [
                      for (int i = 0; i < widget.skills.length; i++)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _SkillChip(
                                  skill: widget.skills[i],
                                  isDesktop: false,
                                  isAdmin: widget.isAdmin,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Tapped skill: ${widget.skills[i].name}'),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  },
                                ),
                                if (widget.isAdmin) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: i > 0 ? () => widget.onReorder(i, i - 1, widget.title) : null,
                                          tooltip: 'Move up',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: i < widget.skills.length - 1 ? () => widget.onReorder(i, i + 1, widget.title) : null,
                                          tooltip: 'Move down',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (widget.isAdmin)
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 14),
                                      onPressed: () => widget.onEditSkill(widget.skills[i]),
                                      tooltip: 'Edit',
                                      padding: const EdgeInsets.all(3),
                                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                    ),
                                    const SizedBox(width: 0),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 14),
                                      onPressed: () => widget.onDeleteSkill(widget.skills[i]),
                                      tooltip: 'Delete',
                                      padding: const EdgeInsets.all(3),
                                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          width: double.infinity,
          height: 240,
        ),
        if (widget.isAdmin)
          Positioned(
            top: -12,
            right: -12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 16),
                  onPressed: () => widget.onEditCategory(widget.title),
                  tooltip: 'Edit Category',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                const SizedBox(width: 0),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                  onPressed: () => widget.onDeleteCategory(widget.title),
                  tooltip: 'Delete Category',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryIcon(String? iconUrl, double size, {String? category}) {
    final categorySvgs = <String, String>{
      'Languages': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751118819/ud5yvl7gbkj6oul7esqt.svg',
      'Framework': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751117868/feinbsv6jyde9jccyrkg.svg',
      'Databases': 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg',
      'Tools': 'https://res.cloudinary.com/dyp8u0ka1/image/upload/v1751118421/x6b4ojkysonz0ro4hxle.svg',
    };
    if (category != null && categorySvgs.containsKey(category)) {
      return SvgPicture.network(
        categorySvgs[category]!,
        width: size,
        height: size,
        placeholderBuilder: (context) => Icon(
          Icons.extension,
          size: size,
          color: Colors.cyanAccent,
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Category SVG loading error: $error');
          return Icon(
            Icons.extension,
            size: size,
            color: Colors.cyanAccent,
          );
        },
      );
    }
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return SvgPicture.network(
        iconUrl,
        width: size,
        height: size,
        placeholderBuilder: (context) => Icon(
          Icons.extension,
          size: size,
          color: Colors.cyanAccent,
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Category SVG loading error: $error');
          return Icon(
            Icons.extension,
            size: size,
            color: Colors.cyanAccent,
          );
        },
      );
    }
    return Icon(
      Icons.extension,
      size: size,
      color: Colors.cyanAccent,
    );
  }
}

class _SkillChip extends StatefulWidget {
  final SkillItem skill;
  final bool isDesktop;
  final bool isAdmin;
  final VoidCallback? onTap; // Added for button functionality

  const _SkillChip({
    required this.skill,
    required this.isDesktop,
    required this.isAdmin,
    this.onTap,
  });

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovered) => setState(() => _isHovered = hovered),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      borderRadius: BorderRadius.circular(widget.isDesktop ? 18 : 12),
      child: AnimatedScale(
        scale: (_isHovered || _isPressed) ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            vertical: widget.isDesktop ? 10 : 4,
            horizontal: widget.isDesktop ? 18 : 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(widget.isDesktop ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(widget.isDesktop ? 18 : 12),
            border: Border.all(
              color: (_isHovered || _isPressed) ? Colors.white : Colors.white.withOpacity(0.18),
              width: (_isHovered || _isPressed) ? 1.5 : 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSkillIcon(widget.skill, widget.isDesktop),
              SizedBox(width: 8),
              Text(
                widget.skill.name,
                style: GoogleFonts.comfortaa(
                  fontSize: widget.isDesktop ? 16 : 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSkillIcon(SkillItem skill, bool isDesktop) {
    if (skill.iconUrl != null && skill.iconUrl!.isNotEmpty) {
      return SvgPicture.network(
        skill.iconUrl!,
        width: isDesktop ? 22 : 16,
        height: isDesktop ? 22 : 16,
        placeholderBuilder: (context) => Icon(
          Icons.extension,
          size: isDesktop ? 22 : 16,
          color: Colors.cyanAccent,
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SVG loading error for ${skill.name}: $error');
          return Icon(
            Icons.extension,
            size: isDesktop ? 22 : 16,
            color: Colors.cyanAccent,
          );
        },
      );
    }
    return Icon(
      Icons.extension,
      size: isDesktop ? 22 : 16,
      color: Colors.cyanAccent,
    );
  }
}

class SkillItem {
  final String name;
  final String? iconUrl;
  final String category;
  final int order;
  final String id;

  SkillItem({required this.name, this.iconUrl, required this.category, required this.order, required this.id});

  factory SkillItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillItem(
      name: data['name'] ?? '',
      iconUrl: data['iconUrl'] ?? data['icon'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      id: doc.id,
    );
  }
}