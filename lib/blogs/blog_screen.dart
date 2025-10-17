import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/home_screen.dart';
import 'dart:ui';
import 'dart:async';

import 'package:portfolio/login/login_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  bool _isLoggedIn = false;
  String? _userEmail;
  final _postController = TextEditingController();
  bool _isSubmitting = false;
  String? _editingPostId;
  final String _adminEmail = 'pratikkumarpradhan2006@gmail.com';
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _listenToAuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _postController.dispose();
    super.dispose();
  }

  void _listenToAuthState() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('🔍 BlogScreen auth state changed: ${user?.email}');
      setState(() {
        _isLoggedIn = user != null;
        _userEmail = user?.email;
      });
    }, onError: (error) {
      debugPrint('❌ BlogScreen auth state error: $error');
      setState(() {
        _isLoggedIn = false;
        _userEmail = null;
      });
    });
  }

  Future<void> _submitPost() async {
    if (_postController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      if (_editingPostId == null) {
        await FirebaseFirestore.instance.collection('posts').add({
          'authorEmail': _userEmail,
          'content': _postController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(_editingPostId)
            .update({
          'content': _postController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      _postController.clear();
      setState(() {
        _editingPostId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit post: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _editPost(String postId, String currentContent) async {
    setState(() {
      _editingPostId = postId;
      _postController.text = currentContent;
    });
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
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
        leadingWidth: isMobile ? 120 : 160,
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
                  fontSize: isMobile ? 12 : 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        // title: Text(
        //   'Blog',
        //   style: GoogleFonts.poppins(
        //     color: Colors.cyanAccent,
        //     fontSize: isMobile ? 18 : 24,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                  'Community Blog',
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
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.92
                            : MediaQuery.of(context).size.width > 1200
                                ? 1200
                                : MediaQuery.of(context).size.width * 0.9,
                        margin: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: isMobile && isLandscape ? 8 : 16,
                        ),
                        padding: const EdgeInsets.all(0),
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
                            const SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoggedIn)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.cyanAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  const SizedBox(width: 18),
                                  Flexible(
                                    child: Text(
                                      _isLoggedIn
                                          ? 'Logged in as: ${_userEmail ?? "Unknown"}'
                                          : 'Please sign in to write a post',
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white70,
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!_isLoggedIn)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      elevation: 4,
                                      shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                    ),
                                    onPressed: _isLoggedIn
                                        ? (_isSubmitting ? null : _submitPost)
                                        : () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                            );
                                            if (result == true) {
                                              // Auth state will be updated automatically via listener
                                            }
                                          },
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                            ),
                                          )
                                        : Text(
                                            _isLoggedIn
                                                ? (_editingPostId == null ? 'Write Post' : 'Update Post')
                                                : 'Sign In / Sign Up',
                                            style: GoogleFonts.poppins(
                                              fontSize: isMobile ? 11 : 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            if (!_isLoggedIn) const SizedBox(height: 12),
                            if (_isLoggedIn)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      child: TextField(
                                        controller: _postController,
                                        style: const TextStyle(color: Colors.white),
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          labelText: _editingPostId == null ? 'Write your post' : 'Edit your post',
                                          labelStyle: GoogleFonts.poppins(
                                            color: Colors.cyanAccent,
                                            fontWeight: FontWeight.w500,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                                          ),
                                          prefixIcon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyanAccent,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          elevation: 4,
                                          shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                        ),
                                        onPressed: _isLoggedIn
                                            ? (_isSubmitting ? null : _submitPost)
                                            : () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                                );
                                                if (result == true) {
                                                  // Auth state will be updated automatically via listener
                                                }
                                              },
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                                ),
                                              )
                                            : Text(
                                                _isLoggedIn
                                                    ? (_editingPostId == null ? ' Post' : 'Update Post')
                                                    : 'Sign In / Sign Up',
                                                style: GoogleFonts.poppins(
                                                  fontSize: isMobile ? 11 : 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'Error loading posts',
                                        style: GoogleFonts.poppins(
                                          color: Colors.redAccent,
                                          fontSize: isMobile ? 11 : 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final posts = snapshot.data?.docs ?? [];
                                if (posts.isEmpty && _isLoggedIn) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              border: Border.all(
                                                color: Colors.cyanAccent.withOpacity(0.3),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'No blogs yet',
                                              style: GoogleFonts.poppins(
                                                color: Colors.cyanAccent,
                                                fontSize: isMobile ? 12 : 14,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    final doc = posts[index];
                                    final data = doc.data() as Map<String, dynamic>;
                                    final isAuthor = _isLoggedIn && data['authorEmail'] == _userEmail;
                                    final isAdmin = _isLoggedIn && _userEmail == _adminEmail;
                                    final postCard = ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        child: Card(
                                          elevation: 4,
                                          shadowColor: Colors.cyanAccent.withOpacity(0.3),
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(0.18),
                                              width: 1.2,
                                            ),
                                          ),
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
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.24),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {},
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeOut,
                                                  transform: Matrix4.identity()..scale((isAuthor || isAdmin) ? 1.0 : 1.0),
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: isMobile ? 8 : 12,
                                                      vertical: 8,
                                                    ),
                                                    leading: Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.cyanAccent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Colors.black,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      data['authorEmail'] ?? 'Anonymous',
                                                      style: GoogleFonts.comfortaa(
                                                        color: Colors.cyanAccent,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: isMobile ? 12 : 14,
                                                        letterSpacing: 0.4,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    subtitle: Padding(
                                                      padding: const EdgeInsets.only(top: 6),
                                                      child: Text(
                                                        data['content'] ?? '',
                                                        style: GoogleFonts.varelaRound(
                                                          color: Colors.white,
                                                          fontSize: isMobile ? 11 : 13,
                                                          height: 1.4,
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    trailing: (isAuthor || isAdmin)
                                                        ? Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              if (isAuthor)
                                                                IconButton(
                                                                  icon: const Icon(
                                                                    Icons.edit,
                                                                    color: Colors.cyanAccent,
                                                                    size: 16,
                                                                  ),
                                                                  onPressed: () => _editPost(doc.id, data['content']),
                                                                  tooltip: 'Edit Post',
                                                                ),
                                                              if (isAuthor || isAdmin)
                                                                IconButton(
                                                                  icon: const Icon(
                                                                    Icons.delete,
                                                                    color: Colors.redAccent,
                                                                    size: 16,
                                                                  ),
                                                                  onPressed: () => _deletePost(doc.id),
                                                                  tooltip: 'Delete Post',
                                                                ),
                                                            ],
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 8 : 16,
                                        vertical: 4,
                                      ),
                                      child: Column(
                                        children: [
                                          if (!isMobile && index % 2 == 0)
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: postCard),
                                                const PostConnector(),
                                                const Spacer(),
                                              ],
                                            )
                                          else if (!isMobile)
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Spacer(),
                                                const PostConnector(),
                                                Expanded(child: postCard),
                                              ],
                                            )
                                          else
                                            postCard,
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
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
      ),
    );
  }
}

class PostConnector extends StatelessWidget {
  const PostConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      child: Column(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}