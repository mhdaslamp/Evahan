import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_draft.dart';
import 'sell_details_screen.dart';

const List<Map<String, Object>> _categories = [
  {'label': 'Cars', 'icon': Icons.directions_car_outlined},
  {'label': 'Bikes', 'icon': Icons.two_wheeler_outlined},
  {'label': 'Scooters', 'icon': Icons.electric_moped_outlined},
  {'label': 'Bicycles', 'icon': Icons.pedal_bike_outlined},
  {'label': 'Rickshaw', 'icon': Icons.airport_shuttle_outlined},
];

class SellCategoryScreen extends StatelessWidget {
  const SellCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: _buildCategoryGrid(context),
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
                'What are we offering ?',
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

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SellDetailsScreen(
                draft: ListingDraft(category: cat['label'] as String),
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  child: Icon(cat['icon'] as IconData,
                      color: AppColors.green, size: 36),
                ),
                const SizedBox(height: 10),
                Text(
                  cat['label'] as String,
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
