import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  static const _claimedCouponsKey = 'claimed_coupon_codes';
  final Set<String> _claimedCodes = <String>{};

  final List<_CouponItem> _coupons = const [
    _CouponItem(
      code: 'GLAMOR10',
      title: '10% off on all products',
      subtitle: 'Min order \$30',
      expiry: '31 Dec 2026',
    ),
    _CouponItem(
      code: 'FREESHIP',
      title: 'Free shipping on checkout',
      subtitle: 'For orders above \$50',
      expiry: '31 Dec 2026',
    ),
    _CouponItem(
      code: 'NEW20',
      title: '20% off for new customers',
      subtitle: 'First order only',
      expiry: '31 Dec 2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadClaimedCoupons();
  }

  Future<void> _loadClaimedCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_claimedCouponsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _claimedCodes
        ..clear()
        ..addAll(saved.map((e) => e.toUpperCase()));
    });
  }

  Future<void> _saveClaimedCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _claimedCouponsKey,
      _claimedCodes.toList()..sort(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(context: context, title: 'All Coupons'),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            itemCount: _coupons.length,
            itemBuilder: (context, index) {
              final coupon = _coupons[index];
              final claimed = _claimedCodes.contains(coupon.code);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.discount_outlined, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            coupon.title,
                            style: const TextStyle(
                              color: Color(0xFF1B4542),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      coupon.subtitle,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.66),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires: ${coupon.expiry}',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.52),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              coupon.code,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: claimed ? const Color(0xFF67A7A2) : Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await Clipboard.setData(ClipboardData(text: coupon.code));
                            if (!mounted) return;
                            setState(
                              () => _claimedCodes.add(coupon.code.toUpperCase()),
                            );
                            await _saveClaimedCoupons();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(claimed
                                    ? 'Coupon already saved. Code copied again.'
                                    : 'Coupon saved and copied'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text(claimed ? 'Saved' : 'Claim'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CouponItem {
  const _CouponItem({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.expiry,
  });

  final String code;
  final String title;
  final String subtitle;
  final String expiry;
}
