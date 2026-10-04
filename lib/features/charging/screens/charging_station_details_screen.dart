import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/charging_station.dart';
import '../../../theme/app_theme.dart';

class ChargingStationDetailsScreen extends StatelessWidget {
  final ChargingStation station;

  const ChargingStationDetailsScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMapPreview(),
                    _buildInfoCard(),
                    _buildChargingInfo(),
                    _buildHours(),
                    _buildActions(),
                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              station.name,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(station.latitude, station.longitude),
          initialZoom: 15,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none, // Static map
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.evahan',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(station.latitude, station.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.ev_station, color: AppColors.green, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.name,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (station.address != null)
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: station.address!,
            ),
          if (station.distanceLabel.isNotEmpty)
            _InfoRow(
              icon: Icons.near_me_outlined,
              text: station.distanceLabel + ' away',
              color: AppColors.green,
            ),
          if (station.rating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${station.rating!.toStringAsFixed(1)}',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (station.reviewCount != null)
                  Text(
                    '  (${station.reviewCount} reviews)',
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
          if (station.isOpenNow != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: station.isOpenNow!
                    ? AppColors.green.withValues(alpha: 0.15)
                    : Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                station.isOpenNow! ? 'Open Now' : 'Currently Closed',
                style: GoogleFonts.poppins(
                  color: station.isOpenNow! ? AppColors.green : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChargingInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charging Info',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ChargingRow(
            icon: Icons.bolt,
            label: 'Max Power',
            value: station.chargingPowerKw != null
                ? '${station.chargingPowerKw!.toStringAsFixed(0)} kW (${station.chargerTypeLabel})'
                : 'Power info unavailable',
            unavailable: station.chargingPowerKw == null,
          ),
          const SizedBox(height: 10),
          _ChargingRow(
            icon: Icons.electrical_services_outlined,
            label: 'Connectors',
            value: (station.connectorTypes != null &&
                    station.connectorTypes!.isNotEmpty)
                ? station.connectorTypes!.join(', ')
                : 'Connector information unavailable',
            unavailable: station.connectorTypes == null ||
                station.connectorTypes!.isEmpty,
          ),
          const SizedBox(height: 10),
          if (station.totalConnectors != null)
            _ChargingRow(
              icon: Icons.numbers_outlined,
              label: 'Charger Ports',
              value: '${station.totalConnectors} port${station.totalConnectors! > 1 ? 's' : ''}',
            ),
        ],
      ),
    );
  }

  Widget _buildHours() {
    if (station.openingHours == null || station.openingHours!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opening Hours',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...station.openingHours!.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                line,
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ActionButton(
            icon: Icons.navigation_outlined,
            label: 'Navigate',
            color: AppColors.green,
            textColor: Colors.black,
            onTap: _openNavigation,
          ),
          if (station.phoneNumber != null)
            _ActionButton(
              icon: Icons.phone_outlined,
              label: 'Call',
              color: AppColors.cardBg,
              textColor: AppColors.white,
              borderColor: AppColors.borderColor,
              onTap: () => _launchUrl('tel:${station.phoneNumber}'),
            ),
          if (station.website != null)
            _ActionButton(
              icon: Icons.language_outlined,
              label: 'Website',
              color: AppColors.cardBg,
              textColor: AppColors.white,
              borderColor: AppColors.borderColor,
              onTap: () => _launchUrl(station.website!),
            ),
        ],
      ),
    );
  }

  Future<void> _openNavigation() async {
    // Geo URI opens the default map application (e.g. Google Maps, OSMAnd, Apple Maps)
    final url = 'geo:${station.latitude},${station.longitude}?q=${station.latitude},${station.longitude}(${Uri.encodeComponent(station.name)})';
    await _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.color = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool unavailable;

  const _ChargingRow({
    required this.icon,
    required this.label,
    required this.value,
    this.unavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            color: unavailable ? AppColors.grey : AppColors.green, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: unavailable ? AppColors.grey : AppColors.white,
                  fontSize: 13,
                  fontStyle:
                      unavailable ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 0.8)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
