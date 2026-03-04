import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_draft.dart';
import '../../services/api_service.dart';

class SellPreviewScreen extends StatefulWidget {
  final ListingDraft draft;
  const SellPreviewScreen({super.key, required this.draft});

  @override
  State<SellPreviewScreen> createState() => _SellPreviewScreenState();
}

class _SellPreviewScreenState extends State<SellPreviewScreen> {
  bool _isPosting = false;

  Future<void> _onPost() async {
    setState(() => _isPosting = true);

    try {
      // Build multipart form data
      final formData = FormData();

      // Text fields
      formData.fields.addAll([
        MapEntry('category', widget.draft.category),
        MapEntry('brand', widget.draft.brand),
        MapEntry('model', widget.draft.model),
        MapEntry('year', widget.draft.year),
        MapEntry('transmission', widget.draft.transmission),
        MapEntry('location', widget.draft.location),
        MapEntry('kmDriven', widget.draft.kmDriven),
        MapEntry('noOfOwners', widget.draft.noOfOwners),
        MapEntry('adTitle', widget.draft.adTitle),
        MapEntry('price', widget.draft.price),
      ]);

      // Vehicle photos
      for (final path in widget.draft.photoPaths) {
        formData.files.add(MapEntry(
          'photos',
          await MultipartFile.fromFile(path,
              filename: path.split('/').last),
        ));
      }

      // Battery certificate (PDF or image)
      if (widget.draft.batteryCertPath != null) {
        final certPath = widget.draft.batteryCertPath!;
        formData.files.add(MapEntry(
          'cert',
          await MultipartFile.fromFile(certPath,
              filename: certPath.split('/').last),
        ));
      }

      await ApiService.postListing(formData);

      if (!mounted) return;
      setState(() => _isPosting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Your ad is now live!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Pop back to home
      int count = 0;
      Navigator.popUntil(context, (route) => count++ >= 4);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post ad. Please try again.',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildPreviewContent()),
            _buildBottomBar(context),
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
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Preview',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo carousel or placeholder
          widget.draft.photoPaths.isNotEmpty
              ? SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: widget.draft.photoPaths.length,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.draft.photoPaths[i]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image,
                              color: Colors.black38, size: 48),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_library_outlined,
                        color: Colors.black38, size: 48),
                  ),
                ),

          const SizedBox(height: 16),

          Text(
            widget.draft.price.isNotEmpty ? '₹ ${widget.draft.price}' : '₹ --',
            style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w700),
          ),
          Text(
            widget.draft.adTitle.isNotEmpty ? widget.draft.adTitle : 'No title',
            style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 12),

          _detailRow('Category', widget.draft.category),
          _detailRow('Brand', widget.draft.brand),
          _detailRow('Model', widget.draft.model),
          _detailRow('Year', widget.draft.year),
          _detailRow('Transmission', widget.draft.transmission),
          _detailRow('KM Driven', widget.draft.kmDriven),
          _detailRow('No. of Owners', widget.draft.noOfOwners),

          if (widget.draft.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.black45),
                const SizedBox(width: 4),
                Text(widget.draft.location,
                    style: GoogleFonts.poppins(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ],

          if (widget.draft.batteryCertPath != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text('Battery Certificate attached',
                    style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.black45, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black38),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isPosting ? null : () => Navigator.pop(context),
              child: Text('Edit',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isPosting ? null : _onPost,
              child: _isPosting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2.5))
                  : Text('Post Ad',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
