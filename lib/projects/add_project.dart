

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

  /// Whether this is for web dev or app dev
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
                'Please fill title, overview, first description and pick at least one image.')),
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

      if (widget.project != null && widget.documentId != null) {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(widget.documentId)
            .update(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project updated successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        await FirebaseFirestore.instance.collection(collectionName).add(data);
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
            // Collection Selector
            Row(
              children: [
                const Text("Project Type: "),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("App Dev"),
                  selected: !_isWebDevSelected,
                  onSelected: (val) {
                    setState(() {
                      _isWebDevSelected = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Web Dev"),
                  selected: _isWebDevSelected,
                  onSelected: (val) {
                    setState(() {
                      _isWebDevSelected = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: _titleController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(labelText: 'Project Title'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _overviewController,
              decoration: const InputDecoration(
                labelText: 'Project Overview',
                border: OutlineInputBorder(),
                hintText: 'Brief overview of the project',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _taglineController,
              decoration: const InputDecoration(
                labelText: 'Project Tagline',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _youtubeController,
              decoration: const InputDecoration(
                labelText: 'YouTube Video URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            _buildDescriptionField(1, _desc1HeadingController, _desc1Controller),
            _buildDescriptionField(2, _desc2HeadingController, _desc2Controller),
            _buildDescriptionField(3, _desc3HeadingController, _desc3Controller),
            _buildDescriptionField(4, _desc4HeadingController, _desc4Controller),
            _buildDescriptionField(5, _desc5HeadingController, _desc5Controller),

            const SizedBox(height: 16),

            // Existing images
            if (_existingImageUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _existingImageUrls.map((url) {
                  return Stack(
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
                  );
                }).toList(),
              ),

            // Picked images
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
                              child: CircularProgressIndicator(),
                            );
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

  Widget _buildDescriptionField(
    int index,
    TextEditingController headingController,
    TextEditingController descController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: headingController,
          decoration:
              InputDecoration(labelText: 'Description $index Heading'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descController,
          decoration: InputDecoration(labelText: 'Description $index'),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}