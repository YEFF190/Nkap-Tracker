import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color accentBlue = Color(0xFF2D6A9F);
  static const Color accentGold = Color(0xFFF0A500);

  bool _pinEnabled = false;
  bool _budgetAlerts = true;
  double _monthlyBudget = 100000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getBool('pin_enabled') ?? false;
      _budgetAlerts = prefs.getBool('budget_alerts') ?? true;
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? 100000;
    });
  }

  Future<void> _togglePin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            isSetup: true,
            onSuccess: () async {
              await prefs.setBool('pin_enabled', true);
              setState(() => _pinEnabled = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PIN enabled successfully!'),
                  backgroundColor: const Color(0xFF00C48C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ),
      );
    } else {
      await prefs.setBool('pin_enabled', false);
      await prefs.remove('pin');
      setState(() => _pinEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN disabled!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryDark, primaryBlue, accentBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Profile card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accentGold,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nkap Tracker',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Personal Finance Manager 🇨🇲',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget section
                  _buildSectionTitle('Budget'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Budget',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: primaryDark,
                                  ),
                                ),
                                Text(
                                  'Set your spending limit',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(_monthlyBudget / 1000).toStringAsFixed(0)}K FCFA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: primaryDark,
                            inactiveTrackColor:
                                Colors.grey.withOpacity(0.2),
                            thumbColor: accentGold,
                            overlayColor: accentGold.withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _monthlyBudget,
                            min: 10000,
                            max: 1000000,
                            divisions: 99,
                            onChanged: (val) async {
                              setState(() => _monthlyBudget = val);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setDouble('monthly_budget', val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security section
                  _buildSectionTitle('Security'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: _buildToggleTile(
                      icon: Icons.lock_outline,
                      title: 'PIN Lock',
                      subtitle: 'Protect your app with a PIN',
                      value: _pinEnabled,
                      onChanged: _togglePin,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences section
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: _buildToggleTile(
                      icon: Icons.notifications_outlined,
                      title: 'Budget Alerts',
                      subtitle: 'Notify when near budget limit',
                      value: _budgetAlerts,
                      onChanged: (val) async {
                        setState(() => _budgetAlerts = val);
                        final prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('budget_alerts', val);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About section
                  _buildSectionTitle('About'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildAboutTile(
                            Icons.info_outline, 'Version', '1.0.0'),
                        const Divider(height: 1),
                        _buildAboutTile(
                            Icons.flag_outlined, 'Made in', 'Cameroon 🇨🇲'),
                        const Divider(height: 1),
                        _buildAboutTile(
                            Icons.monetization_on_outlined,
                            'Currency',
                            'XAF / FCFA'),
                        const Divider(height: 1),
                        _buildAboutTile(
                            Icons.phone_android,
                            'Supports',
                            'MTN MoMo & Orange Money'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: value,
          activeColor: accentGold,
          activeTrackColor: primaryDark,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAboutTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: primaryDark,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}