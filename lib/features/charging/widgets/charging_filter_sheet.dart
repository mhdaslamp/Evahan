import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/charging_station.dart';
import '../../../theme/app_theme.dart';

/// Bottom sheet for filtering and sorting charging stations.
/// All filters are applied locally — no new API calls.
class ChargingFilterSheet extends StatefulWidget {
  final ChargingFilter initialFilter;
  final void Function(ChargingFilter) onApply;

  const ChargingFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<ChargingFilterSheet> createState() => _ChargingFilterSheetState();
}

class _ChargingFilterSheetState extends State<ChargingFilterSheet> {
  late ChargingFilter _filter;

  static const _radiusOptions = [5.0, 10.0, 25.0, 50.0];
  static const _connectorOptions = ['CCS', 'Type 2', 'CHAdeMO', 'Type 1', 'GB/T'];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Filter & Sort',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // ── Distance ──────────────────────────────────────────
          _SectionLabel('Search Radius'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _radiusOptions
                .map((r) => _FilterChip(
                      label: '${r.toStringAsFixed(0)} km',
                      selected: _filter.radiusKm == r,
                      onTap: () => setState(
                          () => _filter = _filter.copyWith(radiusKm: r)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // ── Charger Speed ──────────────────────────────────────
          _SectionLabel('Charger Speed'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter.speed == null,
                onTap: () => setState(
                    () => _filter = _filter.copyWith(clearSpeed: true)),
              ),
              _FilterChip(
                label: 'Fast (≥50 kW)',
                selected: _filter.speed == ChargerType.fast,
                onTap: () => setState(() =>
                    _filter = _filter.copyWith(speed: ChargerType.fast)),
              ),
              _FilterChip(
                label: 'Ultra Fast (≥150 kW)',
                selected: _filter.speed == ChargerType.ultraFast,
                onTap: () => setState(() =>
                    _filter = _filter.copyWith(speed: ChargerType.ultraFast)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Connector ──────────────────────────────────────────
          _SectionLabel('Connector Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter.connector == null,
                onTap: () => setState(
                    () => _filter = _filter.copyWith(clearConnector: true)),
              ),
              ..._connectorOptions.map((c) => _FilterChip(
                    label: c,
                    selected: _filter.connector == c,
                    onTap: () => setState(
                        () => _filter = _filter.copyWith(connector: c)),
                  )),
            ],
          ),
          const SizedBox(height: 20),

          // ── Sort ──────────────────────────────────────────────
          _SectionLabel('Sort By'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Nearest',
                selected: _filter.sort == SortOption.nearest,
                onTap: () => setState(() =>
                    _filter = _filter.copyWith(sort: SortOption.nearest)),
              ),
              _FilterChip(
                label: 'Highest Power',
                selected: _filter.sort == SortOption.highestPower,
                onTap: () => setState(() =>
                    _filter = _filter.copyWith(sort: SortOption.highestPower)),
              ),
              _FilterChip(
                label: 'Highest Rating',
                selected: _filter.sort == SortOption.highestRating,
                onTap: () => setState(() =>
                    _filter = _filter.copyWith(sort: SortOption.highestRating)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Open Now ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Open Now Only',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _filter.openNowOnly,
                onChanged: (v) =>
                    setState(() => _filter = _filter.copyWith(openNowOnly: v)),
                activeColor: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.borderColor,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.black : AppColors.white,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
