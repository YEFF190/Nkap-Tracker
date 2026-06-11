import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final String? correctPin;
  final VoidCallback onSuccess;

  const PinScreen({
    super.key,
    required this.isSetup,
    this.correctPin,
    required this.onSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color accentGold = Color(0xFFF0A500);

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _message = '';
  bool _hasError = false;

  void _onKeyPress(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
        _message = '';
        _hasError = false;
      });
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 100), _handlePinComplete);
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _handlePinComplete() {
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
          _message = 'Confirm your PIN';
          _hasError = false;
        });
      } else {
        if (_pin == _confirmPin) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('pin', _pin);
          });
          widget.onSuccess();
        } else {
          setState(() {
            _pin = '';
            _confirmPin = '';
            _isConfirming = false;
            _message = 'PINs do not match. Try again!';
            _hasError = true;
          });
        }
      }
    } else {
      if (_pin == widget.correctPin) {
        widget.onSuccess();
      } else {
        setState(() {
          _pin = '';
          _message = 'Wrong PIN. Try again!';
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryDark, primaryBlue, Color(0xFF2D6A9F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentGold,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentGold.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'N',
                    style: TextStyle(
                      color: primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nkap Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSetup
                    ? _isConfirming
                        ? 'Confirm your PIN'
                        : 'Set up a PIN to secure your app'
                    : 'Enter your PIN to continue',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: filled ? 20 : 18,
                    height: filled ? 20 : 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? _hasError
                              ? Colors.red
                              : accentGold
                          : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? _hasError
                                ? Colors.red
                                : accentGold
                            : Colors.white38,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Message
              AnimatedOpacity(
                opacity: _message.isEmpty ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _hasError ? Colors.redAccent : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Number pad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 72),
                        _buildKey('0'),
                        _buildDeleteKey(),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((k) => _buildKey(k)).toList(),
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}