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
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _message = '';

  void _onKeyPress(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
        _message = '';
      });

      if (_pin.length == 4) {
        _handlePinComplete();
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
        });
      } else {
        if (_pin == _confirmPin) {
  // Save the PIN
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('pin', _pin);
  });
  widget.onSuccess();
}
        else {
          setState(() {
            _pin = '';
            _confirmPin = '';
            _isConfirming = false;
            _message = 'PINs do not match. Try again!';
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nkap Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isSetup
                  ? _isConfirming
                      ? 'Confirm your PIN'
                      : 'Set up your PIN'
                  : 'Enter your PIN',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Error/info message
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('match') || _message.contains('Wrong')
                    ? Colors.redAccent
                    : Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            // Number pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
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
                      const SizedBox(width: 70),
                      _buildKey('0'),
                      GestureDetector(
                        onTap: _onDelete,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Icon(
                            Icons.backspace_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}