import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio/services/cloudinary.dart';
import 'package:portfolio/services/firebase.dart';

class AddProjectScreen extends StatefulWidget {
  final PortfolioProject? project;
  final String? documentId;
  const AddProjectScreen({super.key, this.project, this.documentId});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _youtubeController = TextEditingController();

  // Tagline controller
  final _taglineController = TextEditingController();

  // Description headings
  final _desc1HeadingController = TextEditingController();
  final _desc2HeadingController = TextEditingController();
  final _desc3HeadingController = TextEditingController();
  final _desc4HeadingController = TextEditingController();
  final _desc5HeadingController = TextEditingController();

  // Description contents
  final _desc1Controller = TextEditingController();
  final _desc2Controller = TextEditingController();
  final _desc3Controller = TextEditingController();
  final _desc4Controller = TextEditingController();
  final _desc5Controller = TextEditingController();
  bool _isLoading = false;
  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
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
          content: Text('Please fill title, overview, first description and pick at least one image.')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final imageUrls = <String>[];
    imageUrls.addAll(_existingImageUrls);
    for (var img in _pickedImages) {
      final url = await uploadToCloudinary(img);
      imageUrls.add(url);
    }

    int order = 0;
    if (widget.project != null) {
      order = widget.project!.order;
    } else {
      final snapshot = await FirebaseFirestore.instance
          .collection('portfolio')
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

    if (widget.project != null && widget.documentId != null) {
      await FirebaseFirestore.instance
          .collection('portfolio')
          .doc(widget.documentId)
          .update(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      await FirebaseFirestore.instance.collection('portfolio').add(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Something went wrong: $e')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.project != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Project" : "Add Project")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Title field with centered text input
            TextField(
              controller: _titleController,
              textAlign: TextAlign.center,  // Center only title text input
              decoration: const InputDecoration(labelText: 'Project Title'),
            ),
            const SizedBox(height: 12),

            // Project Overview field
            TextField(
              controller: _overviewController,
              decoration: const InputDecoration(
                labelText: 'Project Overview',
                border: OutlineInputBorder(),
                hintText: 'Brief overview of the project',
              ),
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),

            // Project Tagline field
            TextField(
              controller: _taglineController,
              decoration: const InputDecoration(
                labelText: 'Project Tagline',
                border: OutlineInputBorder(),
                hintText: 'A catchy tagline for your project (optional)',
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),

            // Youtube URL field
            TextField(
              controller: _youtubeController,
              decoration: const InputDecoration(
                labelText: 'Youtube Video URL',
                border: OutlineInputBorder(),
                hintText: 'e.g., https://www.youtube.com/watch?v=VIDEO_ID',
              ),
              keyboardType: TextInputType.url,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),

            // Description 1 with heading
            TextField(
              controller: _desc1HeadingController,
              decoration: const InputDecoration(labelText: 'Description 1 Heading'),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 1 field
            TextField(
              controller: _desc1Controller,
              decoration: const InputDecoration(labelText: 'Description 1'),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 2 with heading
            TextField(
              controller: _desc2HeadingController,
              decoration: const InputDecoration(labelText: 'Description 2 Heading'),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 2 field
            TextField(
              controller: _desc2Controller,
              decoration: const InputDecoration(labelText: 'Description 2'),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 3 with heading
            TextField(
              controller: _desc3HeadingController,
              decoration: const InputDecoration(labelText: 'Description 3 Heading'),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 3 field
            TextField(
              controller: _desc3Controller,
              decoration: const InputDecoration(labelText: 'Description 3'),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 4 with heading
            TextField(
              controller: _desc4HeadingController,
              decoration: const InputDecoration(labelText: 'Description 4 Heading'),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 4 field
            TextField(
              controller: _desc4Controller,
              decoration: const InputDecoration(labelText: 'Description 4'),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 5 with heading
            TextField(
              controller: _desc5HeadingController,
              decoration: const InputDecoration(labelText: 'Description 5 Heading'),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Description 5 field
            TextField(
              controller: _desc5Controller,
              decoration: const InputDecoration(labelText: 'Description 5'),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Existing images (for edit mode)
            if (_existingImageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _existingImageUrls.map((url) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () {
                        setState(() {
                          _existingImageUrls.remove(url);
                        });
                      },
                    ),
                  ],
                )).toList(),
              ),

            // New images
            Wrap(
              spacing: 8,
              children: _pickedImages.map((x) {
                return kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: x.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            return Image.memory(snapshot.data!,
                                width: 80, height: 80, fit: BoxFit.cover);
                          } else {
                            return const SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator());
                          }
                        },
                      )
                    : Image.file(io.File(x.path),
                        width: 80, height: 80, fit: BoxFit.cover);
              }).toList(),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _pickImages,
              child: const Text("Pick Images"),
            ),
            const SizedBox(height: 20),

         _isLoading
  ? const Center(child: CircularProgressIndicator())
  : ElevatedButton.icon(
      onPressed: _submitProject,
      icon: Icon(isEdit ? Icons.save : Icons.cloud_upload),
      label: Text(isEdit ? "Save Changes" : "Upload Project"),
    ),
          ],
        ),
      ),
    );
  }
}