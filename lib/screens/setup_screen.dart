import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _code = '';
  String _confirmCode = '';
  bool _isConfirming = false;

  void _onDigitPress(String digit) {
    setState(() {
      if (_isConfirming) {
        if (_confirmCode.length < 4) _confirmCode += digit;
      } else {
        if (_code.length < 4) _code += digit;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming) {
        if (_confirmCode.isNotEmpty) _confirmCode = _confirmCode.substring(0, _confirmCode.length - 1);
      } else {
        if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
      }
    });
  }

  void _onSubmit() async {
    if (!_isConfirming) {
      if (_code.length == 4) {
        setState(() {
          _isConfirming = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a 4-digit code')),
        );
      }
    } else {
      if (_confirmCode == _code) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('secret_code', _code);
        await prefs.setBool('isFirstRun', false);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CalculatorScreen()),
          );
        }
      } else {
        setState(() {
          _confirmCode = '';
          _isConfirming = false;
          _code = ''; // Reset to ensure they know what they typed
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Codes do not match. Try again.')),
        );
      }
    }
  }

  Widget _buildKeypadButton(String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: const Color(0xFF334155),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              _isConfirming ? "Confirm Secret Code" : "Set Secret Code",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter a 4-digit passcode for the vault.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            Text(
              _isConfirming ? _confirmCode.padRight(4, '•') : _code.padRight(4, '•'),
              style: const TextStyle(fontSize: 48, letterSpacing: 10, color: Color(0xFF00E5FF)),
            ),
            const Spacer(),
            Column(
              children: [
                for (var row in [['1','2','3'], ['4','5','6'], ['7','8','9']])
                  Row(
                    children: row.map((d) => _buildKeypadButton(d, () => _onDigitPress(d))).toList(),
                  ),
                Row(
                  children: [
                    Expanded(child: SizedBox()), // Placeholder for alignment
                    _buildKeypadButton('0', () => _onDigitPress('0')),
                     Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.backspace_outlined, color: Colors.redAccent, size: 32),
                          onPressed: _onDelete,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: (_isConfirming ? _confirmCode.length == 4 : _code.length == 4) 
                          ? _onSubmit 
                          : null,
                      child: Text(
                        _isConfirming ? "CONFIRM" : "NEXT",
                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
