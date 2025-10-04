import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio/services/cloudinary.dart';

class AddSkillDialog extends StatefulWidget {
  const AddSkillDialog({super.key});

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  String category = '';
  String name = '';
  String iconUrl = '';
  bool isUploading = false;
  final categories = ['Languages', 'Framework', 'Databases', 'Tools'];

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.add, color: Colors.cyanAccent, size: 28),
                      const SizedBox(width: 10),
                      Text('Add Skill', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    value: category.isNotEmpty ? category : null,
                    items: categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (val) {
                      category = val ?? '';
                      debugPrint('📂 Category changed: $category');
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    dropdownColor: const Color(0xff23243a),
                    validator: (val) {
                      debugPrint('🔍 Validating category: $val');
                      if (val == null || val.isEmpty) {
                        debugPrint('❌ Category validation failed: empty');
                        return 'Select category';
                      }
                      debugPrint('✅ Category validation passed');
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Skill Name',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) {
                      name = val;
                      debugPrint('📝 Skill name changed: $name');
                    },
                    validator: (val) {
                      debugPrint('🔍 Validating skill name: $val');
                      if (val == null || val.isEmpty) {
                        debugPrint('❌ Skill name validation failed: empty');
                        return 'Enter skill name';
                      }
                      debugPrint('✅ Skill name validation passed');
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // SVG Upload Section
                  Text(
                    'SVG Icon',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isUploading ? null : () async {
                            await _uploadSvgFile(setDialogState);
                          },
                          icon: isUploading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : const Icon(Icons.upload, color: Colors.black),
                          label: Text(
                            isUploading ? 'Uploading...' : 'Upload SVG File',
                            style: const TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (iconUrl.isNotEmpty)
                        IconButton(
                          onPressed: () => setDialogState(() => iconUrl = ''),
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: 'Clear Icon',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'SVG Icon URL (Cloudinary)',
                      labelStyle: const TextStyle(color: Colors.cyanAccent),
                      hintText: 'https://res.cloudinary.com/.../skills/icon.svg',
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) {
                      setDialogState(() => iconUrl = val);
                      debugPrint('🔗 Icon URL changed: $val');
                    },
                    validator: (val) {
                      if (iconUrl.isEmpty) {
                        debugPrint('❌ Icon validation failed: no icon provided');
                        return 'Please upload an SVG file or provide a URL';
                      }
                      if (val != null && val.isNotEmpty && !val.startsWith('http')) {
                        debugPrint('❌ Icon URL validation failed: not a valid URL');
                        return 'Enter a valid URL';
                      }
                      debugPrint('✅ Icon validation passed');
                      return null;
                    },
                  ),
                  if (iconUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Icon Preview:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.network(
                            iconUrl,
                            width: 32,
                            height: 32,
                            placeholderBuilder: (context) => const Icon(
                              Icons.extension,
                              color: Colors.cyanAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SVG Icon Loaded',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  iconUrl.length > 50 
                                      ? '${iconUrl.substring(0, 50)}...' 
                                      : iconUrl,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                              debugPrint('🚀 Starting skill upload...');
                              debugPrint('  Category: $category');
                              debugPrint('  Name: $name');
                              debugPrint('  Icon URL: $iconUrl');
                              
                              // Get current max order for this category (simplified query)
                              final query = await FirebaseFirestore.instance
                                  .collection('skills')
                                  .where('category', isEqualTo: category)
                                  .get();
                              
                              int newOrder = 0;
                              if (query.docs.isNotEmpty) {
                                // Find the highest order in the category
                                final maxOrder = query.docs
                                    .map((doc) => doc.data()['order'] ?? 0)
                                    .reduce((a, b) => a > b ? a : b);
                                newOrder = maxOrder + 1;
                              }
                              debugPrint('  New order: $newOrder');
                              
                              // Prepare skill data
                              final skillData = {
                                'category': category,
                                'name': name,
                                'iconUrl': iconUrl,
                                'order': newOrder,
                              };
                              debugPrint('  Skill data: $skillData');
                              
                              // Upload to Firebase
                              final docRef = await FirebaseFirestore.instance.collection('skills').add(skillData);
                              debugPrint('✅ Skill uploaded successfully! Document ID: ${docRef.id}');
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Skill "$name" added successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              Navigator.pop(context);
                            } catch (e) {
                              debugPrint('❌ Error uploading skill: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add skill: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            debugPrint('❌ Form validation failed');
                          }
                        },
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
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
  }

  Future<void> _uploadSvgFile(Function setDialogState) async {
    try {
      setDialogState(() => isUploading = true);
      
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (file != null) {
        // Check if the file is an SVG
        if (!file.name.toLowerCase().endsWith('.svg')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select an SVG file'),
              backgroundColor: Colors.orange,
            ),
          );
          setDialogState(() => isUploading = false);
          return;
        }
        
        try {
          final url = await uploadSvgToCloudinary(file);
          setDialogState(() {
            iconUrl = url;
            isUploading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SVG uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload SVG: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setDialogState(() => isUploading = false);
        }
      } else {
        setDialogState(() => isUploading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setDialogState(() => isUploading = false);
    }
  }
} 