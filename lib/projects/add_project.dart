import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/services/cloudinary.dart';
import 'package:portfolio/services/firebase.dart';

class AddProjectScreen extends StatefulWidget {
  final PortfolioProject? project;
  final String? documentId;
  final bool isWebDev;

  const AddProjectScreen({
    super.key,
    this.project,
    this.documentId,
    this.isWebDev = false,
  });

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _taglineController = TextEditingController();
  final _desc1HeadingController = TextEditingController();
  final _desc2HeadingController = TextEditingController();
  final _desc3HeadingController = TextEditingController();
  final _desc4HeadingController = TextEditingController();
  final _desc5HeadingController = TextEditingController();
  final _desc1Controller = TextEditingController();
  final _desc2Controller = TextEditingController();
  final _desc3Controller = TextEditingController();
  final _desc4Controller = TextEditingController();
  final _desc5Controller = TextEditingController();

  bool _isLoading = false;
  bool _isWebDevSelected = false;
  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    _isWebDevSelected = widget.isWebDev;
    if (widget.project != null) {
      final p = widget.project!;
      _titleController.text = p.title;
      _overviewController.text = p.overview;
      _youtubeController.text = p.youtubeUrl;
      _taglineController.text = p.tagline;
      _desc1HeadingController.text = p.description1Heading;
      _desc2HeadingController.text = p.description2Heading;
      _desc3HeadingController.text = p.description3Heading;
      _desc4HeadingController.text = p.description4Heading;
      _desc5HeadingController.text = p.description5Heading;
      _desc1Controller.text = p.description1;
      _desc2Controller.text = p.description2;
      _desc3Controller.text = p.description3;
      _desc4Controller.text = p.description4;
      _desc5Controller.text = p.description5;
      _existingImageUrls = List<String>.from(p.images);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images);
      });
    }
  }

  Future<void> _submitProject() async {
    if (_titleController.text.isEmpty ||
        _overviewController.text.isEmpty ||
        _desc1Controller.text.isEmpty ||
        (_pickedImages.isEmpty && _existingImageUrls.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill title, overview, first description and pick at least one image.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrls = <String>[];
      imageUrls.addAll(_existingImageUrls);
      for (var img in _pickedImages) {
        final url = await uploadToCloudinary(img);
        imageUrls.add(url);
      }

      final collectionName = _isWebDevSelected ? 'portfolio_web' : 'portfolio';
      int order = 0;
      if (widget.project != null) {
        order = widget.project!.order;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('order', descending: true)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          order = (snapshot.docs.first.data()['order'] ?? 0) + 1;
        }
      }

      final data = {
        'title': _titleController.text.trim(),
        'overview': _overviewController.text.trim(),
        'tagline': _taglineController.text.trim(),
        'youtube_url': _youtubeController.text.trim(),
        'description1_heading': _desc1HeadingController.text.trim(),
        'description1': _desc1Controller.text.trim(),
        'description2_heading': _desc2HeadingController.text.trim(),
        'description2': _desc2Controller.text.trim(),
        'description3_heading': _desc3HeadingController.text.trim(),
        'description3': _desc3Controller.text.trim(),
        'description4_heading': _desc4HeadingController.text.trim(),
        'description4': _desc4Controller.text.trim(),
        'description5_heading': _desc5HeadingController.text.trim(),
        'description5': _desc5Controller.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'order': order,
      };

      final ref = FirebaseFirestore.instance.collection(collectionName);
      if (widget.project != null && widget.documentId != null) {
        await ref.doc(widget.documentId).update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Project updated successfully!')),
        );
      } else {
        await ref.add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚀 Project uploaded successfully!')),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.project != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
appBar: AppBar(
  elevation: 0,
  centerTitle: true,
  backgroundColor: Colors.transparent,
  leadingWidth: 140,
  leading: Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
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
  title: Text(
    isEdit ? "Edit Project" : "Add Project",
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF101828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Project Type"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  _modernChip("App Dev", !_isWebDevSelected, () {
                    setState(() => _isWebDevSelected = false);
                  }),
                  _modernChip("Web Dev", _isWebDevSelected, () {
                    setState(() => _isWebDevSelected = true);
                  }),
                ],
              ),
              const SizedBox(height: 24),
              _sectionHeader("Basic Info"),
              _styledField(_titleController, "Project Title"),
              _styledField(_overviewController, "Overview", maxLines: 3),
              _styledField(_taglineController, "Tagline"),
              _styledField(_youtubeController, "YouTube URL"),
              const SizedBox(height: 24),
              _sectionHeader("Descriptions"),
              for (int i = 1; i <= 5; i++)
                _buildDescriptionField(
                  i,
                  [
                    _desc1HeadingController,
                    _desc2HeadingController,
                    _desc3HeadingController,
                    _desc4HeadingController,
                    _desc5HeadingController,
                  ][i - 1],
                  [
                    _desc1Controller,
                    _desc2Controller,
                    _desc3Controller,
                    _desc4Controller,
                    _desc5Controller,
                  ][i - 1],
                ),
              const SizedBox(height: 24),
              _sectionHeader("Images"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._existingImageUrls.map((url) => _imagePreview(url: url)),
                  ..._pickedImages.map((x) => _imagePreview(xfile: x)),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: const Icon(Icons.add_photo_alternate_rounded,
                          color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white70)
                    : ElevatedButton.icon(
                        onPressed: _submitProject,
                        icon: Icon(isEdit ? Icons.save_rounded : Icons.cloud_upload_rounded),
                        label: Text(
                          isEdit ? "Save Changes" : "Upload Project",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0xFF4ECDC4).withOpacity(0.4),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      );

  Widget _styledField(TextEditingController c, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

Widget _buildDescriptionField(
    int index, TextEditingController h, TextEditingController d) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number box
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$index",
              style: GoogleFonts.poppins(
                color: const Color(0xFF4ECDC4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Heading + Description
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: h,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Heading",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: d,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _imagePreview({String? url, XFile? xfile}) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url != null
              ? Image.network(url, width: 85, height: 85, fit: BoxFit.cover)
              : kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: xfile!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!,
                              width: 85, height: 85, fit: BoxFit.cover);
                        }
                        return const SizedBox(
                          width: 85,
                          height: 85,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
                  : Image.file(io.File(xfile!.path),
                      width: 85, height: 85, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (url != null) {
                  _existingImageUrls.remove(url);
                } else {
                  _pickedImages.remove(xfile);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child:
                  const Icon(Icons.close_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

 Widget _modernChip(String label, bool selected, VoidCallback onTap) {
  return ChoiceChip(
    label: Text(
      label,
      style: GoogleFonts.poppins(
        color: selected ? const Color(0xFF0B1020) : Colors.black.withOpacity(0.9),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFF4ECDC4),
    backgroundColor: Colors.white.withOpacity(0.07),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: selected ? const Color(0xFF4ECDC4) : Colors.white.withOpacity(0.15),
        width: 1,
      ),
    ),
  );
}
}