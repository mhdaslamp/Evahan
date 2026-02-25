import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_draft.dart';
import 'sell_photos_screen.dart';

class SellDetailsScreen extends StatefulWidget {
  final ListingDraft draft;
  const SellDetailsScreen({super.key, required this.draft});

  @override
  State<SellDetailsScreen> createState() => _SellDetailsScreenState();
}

class _SellDetailsScreenState extends State<SellDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _kmCtrl;
  late TextEditingController _ownersCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _priceCtrl;
  late String _transmission;

  String? _batteryCertPath;
  String? _batteryCertName; // just the filename for display

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _brandCtrl = TextEditingController(text: d.brand);
    _modelCtrl = TextEditingController(text: d.model);
    _yearCtrl = TextEditingController(text: d.year);
    _locationCtrl = TextEditingController(text: d.location);
    _kmCtrl = TextEditingController(text: d.kmDriven);
    _ownersCtrl = TextEditingController(text: d.noOfOwners);
    _titleCtrl = TextEditingController(text: d.adTitle);
    _priceCtrl = TextEditingController(text: d.price);
    _transmission = d.transmission.isNotEmpty ? d.transmission : 'Automatic';
    _batteryCertPath = d.batteryCertPath;
  }

  @override
  void dispose() {
    for (final c in [_brandCtrl, _modelCtrl, _yearCtrl, _locationCtrl, _kmCtrl, _ownersCtrl, _titleCtrl, _priceCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBatteryCert() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _batteryCertPath = file.path;
        _batteryCertName = file.name;
      });
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    final updatedDraft = widget.draft.copyWith(
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      transmission: _transmission,
      location: _locationCtrl.text.trim(),
      kmDriven: _kmCtrl.text.trim(),
      noOfOwners: _ownersCtrl.text.trim(),
      adTitle: _titleCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      batteryCertPath: _batteryCertPath,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SellPhotosScreen(draft: updatedDraft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Upload Battery Certificate*'),
                      const SizedBox(height: 10),
                      _uploadBox(
                        onTap: _pickBatteryCert,
                        filePath: _batteryCertPath,
                        fileName: _batteryCertName,
                      ),
                      const SizedBox(height: 24),

                      _textField('Brand*', _brandCtrl, required: true),
                      _textField('Model*', _modelCtrl, required: true),
                      _textField('Year*', _yearCtrl, required: true, inputType: TextInputType.number),

                      _sectionLabel('Transmission'),
                      const SizedBox(height: 8),
                      _transmissionSelector(),
                      const SizedBox(height: 16),

                      _textField('Location', _locationCtrl),
                      _textField('KM Driven*', _kmCtrl, required: true, inputType: TextInputType.number),
                      _textField('No. of Owners', _ownersCtrl, inputType: TextInputType.number),
                      _textField('Price (₹)*', _priceCtrl, required: true, inputType: TextInputType.number),

                      _sectionLabel('Ad title*'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        maxLines: 3,
                        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Mention the key features of your item\n(eg. brand, model, age, type ..)',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 12),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.green, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _onNext,
                          child: Text(
                            'Next',
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
                        color: AppColors.green, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: 'AHAN',
                    style: GoogleFonts.poppins(
                        color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w800),
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
                        color: AppColors.white, borderRadius: BorderRadius.circular(4)),
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        inputFormatters: inputType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.green, width: 1.5)),
          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _transmissionSelector() {
    return Row(
      children: ['Automatic', 'Manual'].map((t) {
        final selected = _transmission == t;
        return GestureDetector(
          onTap: () => setState(() => _transmission = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.green : Colors.black38,
                width: 1.4,
              ),
            ),
            child: Text(
              t,
              style: GoogleFonts.poppins(
                color: selected ? Colors.black : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _uploadBox({required VoidCallback onTap, String? filePath, String? fileName}) {
    final isPdf = fileName != null && fileName.toLowerCase().endsWith('.pdf');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26, width: 1.2),
          color: filePath != null ? const Color(0xFFF0FFF0) : Colors.transparent,
        ),
        child: filePath != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                    color: isPdf ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName ?? 'File selected',
                          style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to change',
                          style: GoogleFonts.poppins(
                              color: AppColors.green,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined,
                      color: Colors.black38, size: 30),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a file & drop it here.',
                    style: GoogleFonts.poppins(
                        color: Colors.black45, fontSize: 12),
                  ),
                  Text(
                    'Click to Browse  (PDF / Image)',
                    style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }
}
