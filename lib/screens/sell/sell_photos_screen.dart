import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_draft.dart';
import 'sell_preview_screen.dart';

class SellPhotosScreen extends StatefulWidget {
  final ListingDraft draft;
  const SellPhotosScreen({super.key, required this.draft});

  @override
  State<SellPhotosScreen> createState() => _SellPhotosScreenState();
}

class _SellPhotosScreenState extends State<SellPhotosScreen> {
  final List<XFile> _photos = [];
  final _picker = ImagePicker();
  static const int _maxPhotos = 10;

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    setState(() {
      for (final f in files) {
        if (_photos.length < _maxPhotos) _photos.add(f);
      }
    });
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _onPreview() {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload at least one photo.',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final updatedDraft = widget.draft.copyWith(
      photoPaths: _photos.map((f) => f.path).toList(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SellPreviewScreen(draft: updatedDraft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewPhotos = _photos.take(4).toList();
    final extra = _photos.length > 4 ? _photos.length - 4 : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Your Vehicle Picture',
                      style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    // Upload drop zone
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor, width: 1.2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined,
                                color: AppColors.grey, size: 30),
                            const SizedBox(height: 6),
                            Text(
                              'Choose a file & drop it here.',
                              style: GoogleFonts.poppins(
                                  color: AppColors.grey, fontSize: 12),
                            ),
                            Text(
                              'Click to Browse',
                              style: GoogleFonts.poppins(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_photos.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: previewPhotos.length,
                        itemBuilder: (context, index) {
                          final isLast = index == 3 && extra > 0;
                          final xfile = previewPhotos[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(xfile.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.cardBg,
                                    child: const Icon(Icons.broken_image,
                                        color: AppColors.grey),
                                  ),
                                ),
                              ),
                              if (isLast)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: Colors.black54,
                                    child: Center(
                                      child: Text(
                                        '+$extra',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isLast)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_photos.length}/$_maxPhotos photo(s) selected',
                        style: GoogleFonts.poppins(
                            color: AppColors.grey, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _onPreview,
                        child: Text(
                          'Preview',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'EV',
                    style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: 'AHAN',
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                ]),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: 22,
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Include some details',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
