import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart'; 
import 'dart:async';
import 'package:calculator_vault/services/panic_service.dart';
import 'vault_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
import 'package:calculator_vault/screens/dummy_vault_screen.dart'; // Import Dummy Vault

// ...

  String _expression = '';
  String _result = '0';
  String? _secretCode;
  String? _sosCode;
  String? _dummyCode; // New State
  
  // ...

  void _loadSecrets() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _secretCode = prefs.getString('secret_code');
      _sosCode = prefs.getString('sos_code');
      _dummyCode = prefs.getString('dummy_code');
    });
  }

  // ...

  void _checkSecretAndSolve() {
    // 1. Check for Instant SOS
    if (_sosCode != null && _expression == _sosCode) {
       _expression = '';
       _result = 'SOS TRIGGERED';
       _triggerPanic(); // Instant trigger (No countdown)
       return;
    }

    // 2. Check for Dummy Vault (Decoy)
    if (_dummyCode != null && _expression == _dummyCode) {
       _expression = '';
       _result = '';
       Navigator.of(context).push(
         MaterialPageRoute(builder: (_) => const DummyVaultScreen()),
       );
       return;
    }

    // 3. Check for Real Vault Code
    if (_secretCode != null && _expression == _secretCode) {
       _unlockVault();
       return;
    }

    // 4. Logic to solve equation
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      setState(() {
        _result = eval.toString();
        // Remove .0 for integers
        if (_result.endsWith('.0')) {
          _result = _result.substring(0, _result.length - 2);
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _unlockVault() {
    _expression = '';
    _result = '';
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VaultScreen()),
    );
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: () => _onPressed(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: const TextStyle(fontSize: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 56, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            // Buttons
            Column(
              children: [
                Row(children: [
                   _buildButton('C', color: Colors.red.withOpacity(0.2), textColor: Colors.redAccent),
                   _buildButton('(', color: const Color(0xFF0F172A)),
                   _buildButton(')', color: const Color(0xFF0F172A)),
                   _buildButton('÷', color: const Color(0xFF00E5FF), textColor: Colors.black),
                ]),
                Row(children: [
                   _buildButton('7'), _buildButton('8'), _buildButton('9'),
                   _buildButton('×', color: const Color(0xFF00E5FF), textColor: Colors.black),
                ]),
                Row(children: [
                   _buildButton('4'), _buildButton('5'), _buildButton('6'),
                   _buildButton('-', color: const Color(0xFF00E5FF), textColor: Colors.black),
                ]),
                Row(children: [
                   _buildButton('1'), _buildButton('2'), _buildButton('3'),
                   _buildButton('+', color: const Color(0xFF00E5FF), textColor: Colors.black),
                ]),
                Row(children: [
                   _buildButton('0'), 
                   _buildButton('.'),
                   _buildButton('⌫'),
                   _buildButton('=', color: const Color(0xFFFF007A)),
                ]),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
