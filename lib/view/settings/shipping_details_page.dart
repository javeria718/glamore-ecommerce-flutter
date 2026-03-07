import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/custom_textfornfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingDetailsPage extends StatefulWidget {
  const ShippingDetailsPage({super.key});

  @override
  State<ShippingDetailsPage> createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
  static const _addressKey = 'shipping_address';
  static const _apartmentKey = 'shipping_apartment';
  static const _cityKey = 'shipping_city';
  static const _countryKey = 'shipping_country';
  static const _phoneKey = 'shipping_phone';

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'Pakistan');
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _addressController.text = prefs.getString(_addressKey) ?? '';
      _apartmentController.text = prefs.getString(_apartmentKey) ?? '';
      _cityController.text = prefs.getString(_cityKey) ?? '';
      _countryController.text = prefs.getString(_countryKey) ?? 'Pakistan';
      _phoneController.text = prefs.getString(_phoneKey) ?? '';
    });
  }

  Future<void> _save() async {
    if (_addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _show('Please fill required shipping fields', true);
      return;
    }

    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, _addressController.text.trim());
    await prefs.setString(_apartmentKey, _apartmentController.text.trim());
    await prefs.setString(_cityKey, _cityController.text.trim());
    await prefs.setString(_countryKey, _countryController.text.trim());
    await prefs.setString(_phoneKey, _phoneController.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);
    _show('Shipping details saved', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(context: context, title: 'Shipping Details'),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: FrostedGlassCard(
                maxWidth: 540,
                child: Column(
                  children: [
                    CustomTextFormField(
                      label: 'Address',
                      icon: Icons.home_outlined,
                      keyboardType: TextInputType.streetAddress,
                      controller: _addressController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      label: 'Apartment / Suite (Optional)',
                      icon: Icons.apartment_outlined,
                      keyboardType: TextInputType.text,
                      controller: _apartmentController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      keyboardType: TextInputType.text,
                      controller: _cityController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      label: 'Country',
                      icon: Icons.public_outlined,
                      keyboardType: TextInputType.text,
                      controller: _countryController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      label: 'Phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      helperText: 'Start from 3XX (e.g. 315XXXXXXX)',
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 46),
                        ),
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Shipping Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _show(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
