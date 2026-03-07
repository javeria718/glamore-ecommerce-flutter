import 'dart:ui';

import 'package:ecom_app/Model/order_model.dart';
import 'package:ecom_app/Singleton/singleton.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/features/cart_core/presentation/cart_providers.dart';
import 'package:ecom_app/features/order_core/data/order_repository.dart';
import 'package:ecom_app/view/home.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/cartfields.dart';
import 'package:ecom_app/widgets/custombotton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  static const _shippingAddressKey = 'shipping_address';
  static const _shippingApartmentKey = 'shipping_apartment';
  static const _shippingCityKey = 'shipping_city';
  static const _shippingCountryKey = 'shipping_country';
  static const _shippingPhoneKey = 'shipping_phone';
  static const _claimedCouponsKey = 'claimed_coupon_codes';
  static const double _baseShippingFee = 1.50;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController appartmentController = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  final TextEditingController countryController =
      TextEditingController(text: 'Pakistan');

  String selectedPayment = 'Cash on Delivery';
  final _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _nameRegex = RegExp(r'^[A-Za-z][A-Za-z\s\-]{1,}$');
  final RegExp _cityCountryRegex = RegExp(r'^[A-Za-z][A-Za-z\s\-]{1,}$');
  final RegExp _phoneRegex = RegExp(r'^315\d{7}$');
  Set<String>? _claimedCouponCodes;

  Set<String> get _safeClaimedCouponCodes => _claimedCouponCodes ??= <String>{};

  bool _applyingCoupon = false;
  String? _appliedCouponCode;
  String? _couponMessage;
  double _discountAmount = 0;
  double _shippingFee = _baseShippingFee;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
    _loadSavedShippingDetails();
  }

  Future<void> _prefillUserData() async {
    final local = UserSingleton().userModel;
    if (local != null) {
      _applyProfileToFields(
        name: local.name,
        email: local.email,
        phone: local.phoneNumber,
      );
    }

    try {
      final remote = await ref.read(authRepositoryProvider).currentProfile();
      if (!mounted || remote == null) return;
      _applyProfileToFields(
        name: remote.name,
        email: remote.email,
        phone: remote.phoneNumber,
      );
    } catch (_) {
      // Keep local fallback values if remote prefill fails.
    }
  }

  void _applyProfileToFields({
    required String name,
    required String email,
    required String phone,
  }) {
    final cleanName = name.trim();
    if (cleanName.isNotEmpty) {
      final parts =
          cleanName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        firstNameController.text = parts.first;
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        }
      }
    }

    if (email.trim().isNotEmpty) {
      emailController.text = email.trim();
    }

    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalizedPhone.startsWith('315') && normalizedPhone.length == 10) {
      phoneController.text = normalizedPhone;
    } else if (normalizedPhone.startsWith('0315') &&
        normalizedPhone.length == 11) {
      phoneController.text = normalizedPhone.substring(1);
    } else if (normalizedPhone.startsWith('92315') &&
        normalizedPhone.length == 12) {
      phoneController.text = normalizedPhone.substring(2);
    }
  }

  Future<void> _loadSavedShippingDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString(_shippingAddressKey) ?? '';
    final savedApartment = prefs.getString(_shippingApartmentKey) ?? '';
    final savedCity = prefs.getString(_shippingCityKey) ?? '';
    final savedCountry = prefs.getString(_shippingCountryKey) ?? '';
    final savedPhone = prefs.getString(_shippingPhoneKey) ?? '';
    final savedCoupons = prefs.getStringList(_claimedCouponsKey) ?? const <String>[];

    if (!mounted) return;
    setState(() {
      if (savedAddress.trim().isNotEmpty) {
        addressController.text = savedAddress.trim();
      }
      if (savedApartment.trim().isNotEmpty) {
        appartmentController.text = savedApartment.trim();
      }
      if (savedCity.trim().isNotEmpty) {
        cityController.text = savedCity.trim();
      }
      if (savedCountry.trim().isNotEmpty) {
        countryController.text = savedCountry.trim();
      }

      final normalizedPhone = savedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (normalizedPhone.startsWith('315') && normalizedPhone.length == 10) {
        phoneController.text = normalizedPhone;
      }

      _safeClaimedCouponCodes
        ..clear()
        ..addAll(savedCoupons.where((e) => e.trim().isNotEmpty).map((e) => e.toUpperCase()));
    });
  }

  void _clearCoupon() {
    setState(() {
      couponController.clear();
      _appliedCouponCode = null;
      _couponMessage = null;
      _discountAmount = 0;
      _shippingFee = _baseShippingFee;
    });
  }

  Future<void> _applyCoupon(double subtotal) async {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _couponMessage = 'Enter a coupon code');
      return;
    }
    if (!_safeClaimedCouponCodes.contains(code)) {
      setState(
        () => _couponMessage =
            'Coupon not claimed yet. Claim it first from All Coupons.',
      );
      return;
    }

    setState(() {
      _applyingCoupon = true;
      _couponMessage = null;
    });

    try {
      var nextDiscount = 0.0;
      var nextShipping = _baseShippingFee;
      var successMessage = 'Coupon applied';

      if (code == 'GLAMOR10') {
        if (subtotal < 30) {
          throw Exception('GLAMOR10 requires minimum subtotal of \$30');
        }
        nextDiscount = subtotal * 0.10;
        successMessage = 'GLAMOR10 applied (10% off)';
      } else if (code == 'FREESHIP') {
        if (subtotal <= 50) {
          throw Exception('FREESHIP works for subtotal above \$50');
        }
        nextShipping = 0;
        successMessage = 'FREESHIP applied (shipping free)';
      } else if (code == 'NEW20') {
        final user = ref.read(supabaseClientProvider).auth.currentUser;
        if (user == null) {
          throw Exception('Please login to use NEW20');
        }
        final previousOrders =
            await ref.read(orderRepositoryProvider).fetchUserOrders(userId: user.id);
        if (previousOrders.isNotEmpty) {
          throw Exception('NEW20 is only for first order');
        }
        nextDiscount = subtotal * 0.20;
        successMessage = 'NEW20 applied (20% off)';
      } else {
        throw Exception('Invalid coupon code');
      }

      if (!mounted) return;
      setState(() {
        _appliedCouponCode = code;
        _discountAmount = nextDiscount;
        _shippingFee = nextShipping;
        _couponMessage = successMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appliedCouponCode = null;
        _discountAmount = 0;
        _shippingFee = _baseShippingFee;
        _couponMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _applyingCoupon = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    cityController.dispose();
    appartmentController.dispose();
    couponController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);

    return cartAsync.when(
      data: (cart) {
        final subtotal = cart.totalPrice;
        final total = (subtotal + _shippingFee - _discountAmount).clamp(0, double.infinity);
        return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: frostedTealAppBar(
          context: context,
          title: 'Checkout',
          onLeadingPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          },
          actions: const [],
        ),
        body: frostyLightBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _frostedSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Contact'),
                        const SizedBox(height: 10),
                        CartFields(
                          label: 'Email or mobile phone number',
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!_emailRegex.hasMatch(input)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _frostedSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Coupon'),
                        const SizedBox(height: 10),
                        CartFields(
                          label: 'Enter coupon code',
                          keyboardType: TextInputType.text,
                          controller: couponController,
                          validator: null,
                        ),
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 700;
                            final applyButton = FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 42),
                              ),
                              onPressed: _applyingCoupon
                                  ? null
                                  : () => _applyCoupon(subtotal),
                              child: _applyingCoupon
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Apply Coupon'),
                            );

                            return Row(
                              children: [
                                if (isWide)
                                  SizedBox(width: 180, child: applyButton)
                                else
                                  Expanded(child: applyButton),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: _clearCoupon,
                                  child: const Text('Clear'),
                                ),
                              ],
                            );
                          },
                        ),
                        if (_couponMessage != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _couponMessage!,
                            style: TextStyle(
                              color: _appliedCouponCode == null
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (_safeClaimedCouponCodes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Claimed: ${_safeClaimedCouponCodes.join(', ')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _frostedSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Delivery'),
                        const SizedBox(height: 10),
                        CartFields(
                          label: 'Country/Region',
                          keyboardType: TextInputType.text,
                          controller: countryController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'Country is required';
                            }
                            if (!_cityCountryRegex.hasMatch(input)) {
                              return 'Enter a valid country name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'First name',
                          keyboardType: TextInputType.name,
                          controller: firstNameController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'First name is required';
                            }
                            if (!_nameRegex.hasMatch(input)) {
                              return 'Enter a valid first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'Last name',
                          keyboardType: TextInputType.name,
                          controller: lastNameController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'Last name is required';
                            }
                            if (!_nameRegex.hasMatch(input)) {
                              return 'Enter a valid last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'Address',
                          keyboardType: TextInputType.streetAddress,
                          controller: addressController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'Address is required';
                            }
                            if (input.length < 8) {
                              return 'Address is too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'Apartment, suite, etc. (optional)',
                          keyboardType: TextInputType.text,
                          controller: appartmentController,
                          validator: null,
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'City',
                          keyboardType: TextInputType.text,
                          controller: cityController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'City is required';
                            }
                            if (!_cityCountryRegex.hasMatch(input)) {
                              return 'Enter a valid city name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CartFields(
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          helperText: 'Start from 3XX (e.g. 315XXXXXXX)',
                          validator: (value) {
                            final input = (value ?? '')
                                .replaceAll(RegExp(r'[^0-9]'), '')
                                .trim();
                            if (input.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!_phoneRegex.hasMatch(input)) {
                              return 'Enter a valid number (315XXXXXXX)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _frostedSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Shipping Method'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            border: Border.all(
                                color: Colors.teal.withValues(alpha: 0.25)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Home Delivery',
                                  style: TextStyle(fontSize: 13)),
                              Text('\$1.50',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _sectionTitle('Payment'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.teal.withValues(alpha: 0.30)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.teal, size: 18),
                              SizedBox(width: 8),
                              Text('Cash on Delivery (COD)',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _frostedSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Order Summary'),
                        const SizedBox(height: 8),
                        ...cart.items.map(
                          (item) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.productName,
                                style: const TextStyle(fontSize: 13)),
                            subtitle: Text('x${item.numberOfItems}',
                                style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              '\$ ${(item.productPrice * item.numberOfItems).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\$${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Shipping:'),
                            Text('\$${_shippingFee.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount${_appliedCouponCode != null ? ' (${_appliedCouponCode!})' : ''}:',
                              ),
                              Text(
                                '-\$${_discountAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Colors.black26),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '\$ ${total.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: CustomButton(
                            label: 'Place Order',
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              final user = ref
                                  .read(supabaseClientProvider)
                                  .auth
                                  .currentUser;
                              if (user == null) {
                                if (!mounted) return;
                                _showFrostedSnackBar('Please login first');
                                return;
                              }

                              final items = cart.items
                                  .map((item) => {
                                        'productName': item.productName,
                                        'quantity': item.numberOfItems,
                                        'price': item.productPrice,
                                        'total': item.productPrice *
                                            item.numberOfItems,
                                      })
                                  .toList();

                              final order = OrderModel(
                                userId: user.id,
                                email: emailController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                address: addressController.text,
                                phone: phoneController.text,
                                city: cityController.text,
                                country: countryController.text,
                                paymentMethod: selectedPayment,
                                shippingFee: _shippingFee,
                                totalAmount: total.toDouble(),
                                items: items,
                                timestamp: DateTime.now(),
                              );

                              await ref
                                  .read(orderRepositoryProvider)
                                  .placeOrder(order);
                              await ref
                                  .read(cartControllerProvider.notifier)
                                  .clear();

                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                barrierColor:
                                    Colors.black.withValues(alpha: 0.18),
                                builder: (BuildContext context) {
                                  return Dialog(
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 24),
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 460),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 13, sigmaY: 13),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      22, 20, 22, 16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withValues(
                                                        alpha: 0.84),
                                                    const Color(0xFFDDF6F3)
                                                        .withValues(
                                                            alpha: 0.78),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.88),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.teal
                                                        .withValues(
                                                            alpha: 0.16),
                                                    blurRadius: 24,
                                                    offset: const Offset(0, 12),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Order Placed Successfully!',
                                                    style: TextStyle(
                                                      color: Color(0xFF0B5E5A),
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 23,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'Thanks for shopping at Glamore.\nYour order will be delivered soon',
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.68),
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.28,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Center(
                                                    child: FilledButton(
                                                      style: FilledButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.teal,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 22,
                                                                vertical: 10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const HomePage()),
                                                          (route) => false,
                                                        );
                                                      },
                                                      child: const Text(
                                                        'OK',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
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
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: Color(0xFF0B6E69),
      ),
    );
  }

  Widget _frostedSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showFrostedSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.70),
            border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.teal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF0E4E4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
