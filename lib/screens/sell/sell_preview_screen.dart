import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_draft.dart';

class SellPreviewScreen extends StatelessWidget {
  final ListingDraft draft;
  const SellPreviewScreen({super.key, required this.draft});

  void _onPost(BuildContext context) {
    // TODO: Connect to Firebase — upload photos, then save listing doc
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your ad will be posted live when Firebase is connected! 🚀',
            style: GoogleFonts.poppins()),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
    // Pop all sell screens back to home
    int count = 0;
    Navigator.popUntil(context, (route) => count++ >= 4);
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
                    width: 22, height: 2.5,
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
                'Preview',
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

  Widget _buildPreviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo carousel or placeholder
          draft.photoPaths.isNotEmpty
              ? SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: draft.photoPaths.length,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(draft.photoPaths[i]),
                        fit: BoxFit.cover,
                        width: double.infinity,
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

          // Price & title
          Text(
            draft.price.isNotEmpty ? '₹ ${draft.price}' : '₹ --',
            style: GoogleFonts.poppins(
                color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            draft.adTitle.isNotEmpty ? draft.adTitle : 'No title',
            style: GoogleFonts.poppins(
                color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 12),

          // Details rows
          _detailRow('Category', draft.category),
          _detailRow('Brand', draft.brand),
          _detailRow('Model', draft.model),
          _detailRow('Year', draft.year),
          _detailRow('Transmission', draft.transmission),
          _detailRow('KM Driven', draft.kmDriven),
          _detailRow('No. of Owners', draft.noOfOwners),

          if (draft.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 4),
                Text(draft.location, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ],

          const SizedBox(height: 12),
          if (draft.batteryCertPath != null) ...[
            const Divider(color: Colors.black12),
            const SizedBox(height: 12),
            Text('Battery Certificate',
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(draft.batteryCertPath!), height: 100, fit: BoxFit.cover),
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
                style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          // Edit
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Edit',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 12),
          // Post
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _onPost(context),
              child: Text('Post',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
