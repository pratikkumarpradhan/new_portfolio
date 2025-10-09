
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/blogs/blog_screen.dart';
import 'package:portfolio/connect_screen.dart';
import 'package:portfolio/github/github_screen.dart';
import 'package:portfolio/leetcode/leetcode_screen.dart';
import 'package:portfolio/login/login_screen.dart';
import 'package:portfolio/projects/project_screen.dart';
import 'package:portfolio/skills/skills.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:ui';

// Navigation Button Model
class NavigationButton {
  final String id;
  final String title;
  final String screenType;
  final int order;
  final bool isActive;
  final bool showOnHome;

  NavigationButton({
    required this.id,
    required this.title,
    required this.screenType,
    required this.order,
    this.isActive = true,
    this.showOnHome = true,
  });

  factory NavigationButton.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NavigationButton(
      id: doc.id,
      title: data['title'] ?? '',
      screenType: data['screenType'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      showOnHome: data['showOnHome'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'screenType': screenType,
      'order': order,
      'isActive': isActive,
      'showOnHome': showOnHome,
    };
  }
}

// Typewriter Text Widget for animated text display
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 100),
    this.delay = const Duration(milliseconds: 500),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _cursorController;
  late Animation<int> _animation;
  late Animation<double> _cursorAnimation;
  String _displayText = '';
  int _currentIndex = 0;
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
      vsync: this,
    );

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      setState(() {
        _currentIndex = _animation.value;
        _displayText = widget.text.substring(0, _currentIndex);
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTypingComplete = true;
        });
        widget.onComplete?.call();
      }
    });

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            _displayText,
            style: widget.style,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
          ),
        ),
        if (!_isTypingComplete)
          AnimatedBuilder(
            animation: _cursorAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorAnimation.value,
                child: Container(
                  width: 2,
                  height: widget.style?.fontSize ?? 20,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: widget.style?.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// Reorderable button grid for admin navigation buttons
class _ReorderableButtonGrid extends StatefulWidget {
  final List<NavigationButton> navigationButtons;
  final int selectedIndex;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onTap;
  final Function(NavigationButton button) onEdit;
  final Function(NavigationButton button) onDelete;
  final VoidCallback onAdd;

  const _ReorderableButtonGrid({
    required this.navigationButtons,
    required this.selectedIndex,
    required this.onReorder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<_ReorderableButtonGrid> createState() => _ReorderableButtonGridState();
}

class _ReorderableButtonGridState extends State<_ReorderableButtonGrid> {
  @override
  Widget build(BuildContext context) {
    final filteredButtons = widget.navigationButtons
        .asMap()
        .entries
        .where((entry) => entry.value.showOnHome)
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();

    return Wrap(
      spacing: 30,
      runSpacing: 26,
      alignment: WrapAlignment.center,
      children: [
        ...filteredButtons.map((entry) {
          final index = entry.key;
          final button = entry.value;
          final isSelected = widget.selectedIndex == index;

          return _HoverZoomButton(
            title: button.title,
            isSelected: isSelected,
            onTap: () => widget.onTap(index),
            isAdmin: true,
            onEdit: () => widget.onEdit(button),
            onDelete: () => widget.onDelete(button),
            onMoveUp: index > 0 ? () => widget.onReorder(index, index - 1) : null,
            onMoveDown: index < widget.navigationButtons.length - 1 ? () => widget.onReorder(index, index + 1) : null,
          );
        }),
        _AddButtonWidget(
          onAdd: widget.onAdd,
        ),
      ],
    );
  }
}

// Add button widget for admin to add new navigation buttons
class _AddButtonWidget extends StatefulWidget {
  final VoidCallback onAdd;

  const _AddButtonWidget({required this.onAdd});

  @override
  State<_AddButtonWidget> createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<_AddButtonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onAdd,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              border: Border.all(
                color: _isHovered ? Colors.cyanAccent : Colors.cyanAccent.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add',
                  style: GoogleFonts.satisfy(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Main HomeScreen widget
// ... (All imports, NavigationButton, TypewriterText, _ReorderableButtonGrid, 
// _AddButtonWidget, HomePage, _HoverZoomButton, and _HoverSlideButton classes remain unchanged)

// Main HomeScreen widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late PageController _pageController;
  bool? _isAdmin;
  bool _loading = true;
  List<NavigationButton> navigationButtons = [];
  StreamSubscription<QuerySnapshot>? _navigationSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _showLoginMessage = false;
  String? _userEmail;
  Timer? _messageTimer;

  final Map<String, Widget> screenMap = {
    'home': const HomePage(),
    'projects': const PortfolioScreen(),
    'skills': const SkillsScreen(),
    // 'experience': LearningScreen(),
    'github': const GitHubScreen(),
    'leetcode': const LeetcodeScreen(),
    'about': const AboutScreen(),
    'blog': const BlogScreen(),
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _listenToNavigationButtons();
    _listenToAuthState();
  }

  @override
  void dispose() {
    _navigationSubscription?.cancel();
    _authSubscription?.cancel();
    _messageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _listenToAuthState() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('🔍 Auth state changed: ${user?.email}');
      _checkAdmin(user);
    }, onError: (error) {
      debugPrint('❌ Auth state error: $error');
      setState(() {
        _isAdmin = false;
        _loading = false;
        _userEmail = null;
        _showLoginMessage = false;
      });
    });
  }

  Future<void> _checkAdmin(User? user) async {
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
        _userEmail = null;
        _showLoginMessage = false;
      });
      debugPrint('🚫 No user logged in');
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _isAdmin = doc.data()?['role'] == 'admin';
        _userEmail = user.email ?? 'Unknown User';
        _loading = false;
        _showLoginMessage = true;
      });
      debugPrint('✅ User: $_userEmail, Admin: $_isAdmin, Showing message: $_showLoginMessage');
      _messageTimer?.cancel(); // Cancel any existing timer
      _messageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showLoginMessage = false;
          });
          debugPrint('⏲️ Login message hidden');
        }
      });
    } catch (e) {
      debugPrint('❌ Error checking admin: $e');
      setState(() {
        _isAdmin = false;
        _loading = false;
        _userEmail = null;
        _showLoginMessage = false;
      });
    }
  }

  void _listenToNavigationButtons() {
    _navigationSubscription = FirebaseFirestore.instance
        .collection('navigationButtons')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        navigationButtons = snapshot.docs
            .map((doc) => NavigationButton.fromFirestore(doc))
            .where((button) => button.isActive)
            .toList();
        _loading = false;
      });
      debugPrint('📋 Loaded ${navigationButtons.length} navigation buttons');
    }, onError: (error) {
      debugPrint('❌ Error loading navigation buttons: $error');
      setState(() => _loading = false);
    });
  }

  Future<void> _updateButtonOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    debugPrint('🔄 Reordering button: $oldIndex → $newIndex');

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating button order...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );

      final allButtonsQuery = await FirebaseFirestore.instance
          .collection('navigationButtons')
          .orderBy('order')
          .get();

      final allButtons = allButtonsQuery.docs
          .map((doc) => NavigationButton.fromFirestore(doc))
          .toList();

      final movedButton = allButtons[oldIndex];
      allButtons.removeAt(oldIndex);
      allButtons.insert(newIndex, movedButton);

      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < allButtons.length; i++) {
        batch.update(
          FirebaseFirestore.instance.collection('navigationButtons').doc(allButtons[i].id),
          {'order': i},
        );
      }
      await batch.commit();

      debugPrint('✅ Button order updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating button order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update button order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Widget> get screens {
    return navigationButtons.map((button) => screenMap[button.screenType] ?? const SizedBox()).toList();
  }

  List<String> get navTitles {
    return navigationButtons.map((button) => button.title).toList();
  }

  void _showAddButtonDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String screenType = 'home';
    bool showOnHome = true;
    final screenTypes = ['home', 'projects', 'skills', 'experience', 'github', 'leetcode', 'about', 'blog'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Navigation Button',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Button Title',
                    labelStyle: const TextStyle(color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => title = val,
                  validator: (val) => val == null || val.isEmpty ? 'Enter button title' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: screenType,
                  items: screenTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (val) => screenType = val ?? 'home',
                  decoration: InputDecoration(
                    labelText: 'Screen Type',
                    labelStyle: const TextStyle(color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  dropdownColor: const Color(0xff23243a),
                  validator: (val) => val == null || val.isEmpty ? 'Select screen type' : null,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: const Text(
                        'Show on Home Page',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: showOnHome,
                      onChanged: (val) => setState(() => showOnHome = val ?? true),
                      activeColor: Colors.cyanAccent,
                      checkColor: Colors.black,
                    );
                  },
                ),
              ],
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
                    final newOrder = navigationButtons.isEmpty ? 0 : navigationButtons.map((b) => b.order).reduce((a, b) => a > b ? a : b) + 1;
                    await FirebaseFirestore.instance.collection('navigationButtons').add({
                      'title': title,
                      'screenType': screenType,
                      'order': newOrder,
                      'isActive': true,
                      'showOnHome': showOnHome,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Navigation button "$title" added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add button: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditButtonDialog(NavigationButton button) {
    final _formKey = GlobalKey<FormState>();
    String title = button.title;
    String screenType = button.screenType;
    bool showOnHome = button.showOnHome;
    final screenTypes = ['home', 'projects', 'skills', 'experience', 'github', 'leetcode', 'about', 'blog'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Navigation Button',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: InputDecoration(
                    labelText: 'Button Title',
                    labelStyle: const TextStyle(color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => title = val,
                  validator: (val) => val == null || val.isEmpty ? 'Enter button title' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: screenType,
                  items: screenTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (val) => screenType = val ?? 'home',
                  decoration: InputDecoration(
                    labelText: 'Screen Type',
                    labelStyle: const TextStyle(color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  dropdownColor: const Color(0xff23243a),
                  validator: (val) => val == null || val.isEmpty ? 'Select screen type' : null,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: const Text(
                        'Show on Home Page',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: showOnHome,
                      onChanged: (val) => setState(() => showOnHome = val ?? true),
                      activeColor: Colors.cyanAccent,
                      checkColor: Colors.black,
                    );
                  },
                ),
              ],
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
                    await FirebaseFirestore.instance.collection('navigationButtons').doc(button.id).update({
                      'title': title,
                      'screenType': screenType,
                      'showOnHome': showOnHome,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Navigation button updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update button: $e'),
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

  void _showDeleteButtonDialog(NavigationButton button) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff23243a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Navigation Button',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${button.title}"? This action cannot be undone.',
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
                  await FirebaseFirestore.instance.collection('navigationButtons').doc(button.id).delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigation button "${button.title}" deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete button: $e'),
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

  void onNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Navigator.of(context).pop();
  }

  void changePageAnimated(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      selectedIndex = index;
    });
  }

  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(64),
  child: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 4,
    automaticallyImplyLeading: false,
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
    title: LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Portfolio title on the left
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  changePageAnimated(0);
                },
                child: AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.home, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Portfolio",
                        style: GoogleFonts.varelaRound(
                          color: Colors.cyanAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation buttons on the right for desktop or mobile landscape
            if (isDesktop || (isLandscape && !isDesktop))
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                        navigationButtons.length,
                        (index) {
                          final button = navigationButtons[index];
                          final isSelected = selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _HoverSlideButton(
                              title: button.title,
                              isSelected: isSelected,
                              onTap: () => changePageAnimated(index),
                              isAdmin: _isAdmin == true,
                              onEdit: _isAdmin == true
                                  ? () => _showEditButtonDialog(button)
                                  : null,
                              onDelete: _isAdmin == true
                                  ? () => _showDeleteButtonDialog(button)
                                  : null,
                              onMoveUp: _isAdmin == true && index > 0
                                  ? () => _updateButtonOrder(index, index - 1)
                                  : null,
                              onMoveDown: _isAdmin == true &&
                                      index < navigationButtons.length - 1
                                  ? () => _updateButtonOrder(index, index + 1)
                                  : null,
                              fontSize: isDesktop ? 16 : 14,
                              padding: isDesktop
                                  ? const EdgeInsets.all(12)
                                  : const EdgeInsets.all(10),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _HoverSlideButton(
                          title: "Login",
                          isSelected: false,
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            }
                          },
                          isAdmin: false,
                          fontSize: isDesktop ? 16 : 14,
                          padding: isDesktop
                              ? const EdgeInsets.all(12)
                              : const EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
    actions: [
      if (!isDesktop && !isLandscape)
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
    ],
  ),
),
      endDrawer: (isDesktop || isLandscape)
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
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
                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.05),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                              child: Text(
                                'Navigation',
                                style: GoogleFonts.varelaRound(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_isAdmin == true) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ListTile(
                                  onTap: _showAddButtonDialog,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  tileColor: Colors.cyanAccent.withOpacity(0.08),
                                  leading: const Icon(Icons.add, color: Colors.cyanAccent),
                                  title: Text(
                                    'Add New Button',
                                    style: GoogleFonts.varelaRound(
                                      fontSize: 16,
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Expanded(
                              child: _loading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _isAdmin == true
                                      ? ReorderableListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          itemCount: navigationButtons.length,
                                          onReorder: _updateButtonOrder,
                                          itemBuilder: (context, index) {
                                            final button = navigationButtons[index];
                                            final isSelected = selectedIndex == index;
                                            return Padding(
                                              key: ValueKey(button.id),
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: ListTile(
                                                onTap: () => onNavTap(index),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                tileColor: isSelected ? Colors.cyan.withOpacity(0.18) : Colors.transparent,
                                                leading: const Icon(Icons.drag_handle, color: Colors.white54, size: 20),
                                                title: Text(
                                                  button.title,
                                                  style: GoogleFonts.varelaRound(
                                                    fontSize: 18,
                                                    color: isSelected ? Colors.cyanAccent : Colors.white,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: isSelected
                                                    ? const Icon(Icons.check_circle, color: Colors.cyanAccent)
                                                    : const SizedBox.shrink(),
                                              ),
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          itemCount: navigationButtons.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == navigationButtons.length) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: ListTile(
                                                  onTap: () async {
                                                    await FirebaseAuth.instance.signOut();
                                                    if (context.mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (_) => const LoginPage()),
                                                      );
                                                    }
                                                  },
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  tileColor: Colors.transparent,
                                                  title: Text(
                                                    'Login',
                                                    style: GoogleFonts.varelaRound(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            final button = navigationButtons[index];
                                            final isSelected = selectedIndex == index;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: ListTile(
                                                onTap: () => onNavTap(index),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                tileColor: isSelected ? Colors.cyan.withOpacity(0.18) : Colors.transparent,
                                                title: Text(
                                                  button.title,
                                                  style: GoogleFonts.varelaRound(
                                                    fontSize: 18,
                                                    color: isSelected ? Colors.cyanAccent : Colors.white,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                  ),
                                                ),
                                                trailing: isSelected
                                                    ? const Icon(Icons.check_circle, color: Colors.cyanAccent)
                                                    : const SizedBox.shrink(),
                                              ),
                                            );
                                          },
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
      body: Stack(
        children: [
          Container(
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
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: selectedIndex == 0
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: screens.map((screen) => Center(child: screen)).toList(),
            ),
          ),
          if (_showLoginMessage && _userEmail != null)
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _showLoginMessage ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Signed in as $_userEmail',
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.of(context).size.width <= 600 ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ... (HomePage, _HoverZoomButton, and _HoverSlideButton classes remain unchanged)

// Home page content
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToProjects() {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    if (state != null) {
      state.changePageAnimated(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 1),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600; // <600 = mobile
          return Text(
            "Hello, I'm ",
            style: GoogleFonts.saira(
              color: Colors.white,
              fontSize: isMobile ? 27 : 40, // smaller on mobile
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: const [
                                Color(0x220B132B),
                                Color(0x11112233),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
  builder: (context, constraints) {
    // check screen width
    bool isMobile = constraints.maxWidth < 600; // <600 means mobile
    return TypewriterText(
      text: "Pratik Kumar Pradhan",
      style: GoogleFonts.cinzelDecorative(
        fontSize: isMobile ? 33 : 45, // small on mobile
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [
              Colors.tealAccent,
              Colors.lightBlueAccent,
              Colors.cyanAccent,
            ],
          ).createShader(
            const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
          ),
      ),
      duration: const Duration(milliseconds: 150),
      delay: const Duration(milliseconds: 500),
    );
  },
),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                bool isHovered = false;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: GestureDetector(
                    onTap: () {
                      final state = context.findAncestorStateOfType<_HomeScreenState>();
                      if (state != null) {
                        state.changePageAnimated(0);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AnimatedContainer
                        (
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0x330B132B),
                                const Color(0x22112233),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isHovered ? Colors.cyanAccent : Colors.white.withOpacity(0.18),
                              width: isHovered ? 2.0 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isHovered ? 0.28 : 0.20),
                                blurRadius: isHovered ? 18 : 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                         child: TypewriterText(
  text: 'App Developer . Web Developer',
  style: GoogleFonts.comfortaa(
    fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18, // smaller on mobile
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.1,
  ),
  duration: const Duration(milliseconds: 100),
  delay: const Duration(milliseconds: 500),
),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            StatefulBuilder(
              builder: (context, setState) {
                bool isHovered = false;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: GestureDetector(
                    onTap: () async {
                      const url = 'https://www.overleaf.com/project/682202b2b010d50556f5169b';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open CV link'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              colors: const [
                                Color(0x330B132B),
                                Color(0x22112233),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isHovered ? Colors.cyanAccent : Colors.white.withOpacity(0.18),
                              width: isHovered ? 2.0 : 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isHovered ? 0.28 : 0.18),
                                blurRadius: isHovered ? 18 : 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: isHovered ? Colors.cyanAccent.shade200 : Colors.cyanAccent,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                           Text(
  'View CV',
  style: GoogleFonts.playwriteAuNsw(
    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 17, // smaller on mobile
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  ),
),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            if (context.findAncestorStateOfType<_HomeScreenState>()?._loading == true)
              const Center(child: CircularProgressIndicator())
            else
              context.findAncestorStateOfType<_HomeScreenState>()?._isAdmin == true
                  ? _ReorderableButtonGrid(
                      navigationButtons: context.findAncestorStateOfType<_HomeScreenState>()?.navigationButtons ?? [],
                      selectedIndex: context.findAncestorStateOfType<_HomeScreenState>()?.selectedIndex ?? 0,
                      onReorder: (oldIndex, newIndex) => context.findAncestorStateOfType<_HomeScreenState>()?._updateButtonOrder(oldIndex, newIndex),
                      onTap: (index) => context.findAncestorStateOfType<_HomeScreenState>()?.changePageAnimated(index),
                      onEdit: (button) => context.findAncestorStateOfType<_HomeScreenState>()?._showEditButtonDialog(button),
                      onDelete: (button) => context.findAncestorStateOfType<_HomeScreenState>()?._showDeleteButtonDialog(button),
                      onAdd: () => context.findAncestorStateOfType<_HomeScreenState>()?._showAddButtonDialog(),
                    )
                  : Wrap(
                      spacing: 30,
                      runSpacing: 26,
                      alignment: WrapAlignment.center,
                      children: [
                        ...List.generate(
                          context.findAncestorStateOfType<_HomeScreenState>()?.navigationButtons.length ?? 0,
                          (index) {
                            final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                            final button = homeState?.navigationButtons[index];
                            final isSelected = homeState?.selectedIndex == index;
                            if (button != null && button.showOnHome) {
                              return _HoverZoomButton(
                                title: button.title,
                                isSelected: isSelected ?? false,
                                onTap: () => homeState?.changePageAnimated(index),
                                isAdmin: false,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
            const SizedBox(height: 40),
            StatefulBuilder(
              builder: (context, setState) {
                bool isHovered = false;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: GestureDetector(
                          onTap: _goToProjects,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isHovered ? Colors.cyanAccent.shade400 : Colors.cyanAccent,
                                width: isHovered ? 3 : 2,
                              ),
                              color: isHovered ? Colors.cyanAccent.withOpacity(0.1) : Colors.transparent,
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                              color: isHovered ? Colors.cyanAccent.shade200 : Colors.cyanAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Hover zoom button for navigation buttons
class _HoverZoomButton extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final double? fontSize;
  final EdgeInsets? padding;

  const _HoverZoomButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
    this.fontSize,
    this.padding,
  });

  @override
  State<_HoverZoomButton> createState() => _HoverZoomButtonState();
}

class _HoverZoomButtonState extends State<_HoverZoomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final showCyanBorder = widget.isSelected || _isHovered;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: _onEnter,
          onExit: _onExit,
          child: GestureDetector(
            onTap: widget.onTap,
            child: ScaleTransition(
              scale: _scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
                  border: Border.all(
                    color: showCyanBorder ? Colors.cyanAccent : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: showCyanBorder ? [] : [],
                ),
                child: Text(
                  widget.title,
                  //style: GoogleFonts.pacifico(
                  style: GoogleFonts.montaga(
                    //fontWeight: FontWeight.w600,
                    fontSize: widget.fontSize ?? 18,
                    color: widget.isSelected ? Colors.cyanAccent : Colors.white,
                  ),
                ),
              ),
            ),
          ),
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
                  onPressed: widget.onEdit,
                  tooltip: 'Edit',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
        if (widget.isAdmin)
          Positioned(
            top: -8,
            left: -8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onMoveUp,
                  tooltip: 'Move up',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onMoveDown,
                  tooltip: 'Move down',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Hover slide button for navigation buttons in AppBar
class _HoverSlideButton extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final double? fontSize;
  final EdgeInsets? padding;

  const _HoverSlideButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
    this.fontSize,
    this.padding,
  });

  @override
  State<_HoverSlideButton> createState() => _HoverSlideButtonState();
}

class _HoverSlideButtonState extends State<_HoverSlideButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final showCyanBorder = widget.isSelected || _isHovered;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: _onEnter,
          onExit: _onExit,
          child: GestureDetector(
            onTap: widget.onTap,
            child: SlideTransition(
              position: _slide,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: widget.padding ?? const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
                  border: Border.all(
                    color: showCyanBorder ? Colors.cyanAccent : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: showCyanBorder ? [] : [],
                ),
                child: Text(
                  widget.title,
                  style: GoogleFonts.montaga(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.fontSize ?? 16,
                    color: widget.isSelected ? Colors.cyanAccent : Colors.white,
                  ),
                ),
              ),
            ),
          ),
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
                  onPressed: widget.onEdit,
                  tooltip: 'Edit',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
        if (widget.isAdmin)
          Positioned(
            top: -8,
            left: -8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onMoveUp,
                  tooltip: 'Move up',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onMoveDown,
                  tooltip: 'Move down',
                ),
              ],
            ),
          ),
      ],
    );
  }
}