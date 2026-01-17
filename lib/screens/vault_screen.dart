import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calculator_vault/services/panic_service.dart';
import 'package:calculator_vault/services/background_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<String> _contacts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final PanicService _panicService = PanicService();
  
  // States
  bool _isRecording = false;
  String _statusMessage = "";
  bool _isBackgroundActive = false;
  String? _sosCode;
  String? _dummyCode;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _checkServiceStatus();
    _loadSecrets();
  }

  void _loadSecrets() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sosCode = prefs.getString('sos_code');
      _dummyCode = prefs.getString('dummy_code');
    });
  }

  Future<void> _setSosCode() async {
    String input = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Set Instant SOS Code", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Entering this code in the calculator will INSTANTLY trigger Panic Mode (No countdown).",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Enter Code (e.g. 999)",
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => input = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
               if(input.isNotEmpty) {
                 final prefs = await SharedPreferences.getInstance();
                 await prefs.setString('sos_code', input);
                 setState(() => _sosCode = input);
                 if(mounted) Navigator.pop(context);
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _setDummyCode() async {
    String input = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Set Decoy Vault Code", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Entering this code will open a FAKE photo album to fool abusers.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Enter Code (e.g. 4321)", labelStyle: TextStyle(color: Colors.grey)),
              onChanged: (v) => input = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
               if(input.isNotEmpty) {
                 final prefs = await SharedPreferences.getInstance();
                 await prefs.setString('dummy_code', input);
                 setState(() => _dummyCode = input);
                 if(mounted) Navigator.pop(context);
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchI4C() async {
    final Uri url = Uri.parse('https://cybercrime.gov.in');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch 1930 Portal")));
      }
    }
  }

  void _checkServiceStatus() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    setState(() => _isBackgroundActive = isRunning);
  }

  void _toggleBackgroundService(bool value) async {
    final service = FlutterBackgroundService();
    if (value) {
      await BackgroundServiceHelper.initializeService();
      await service.startService();
    } else {
      service.invoke("stopService");
    }
    setState(() => _isBackgroundActive = value);
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contacts = prefs.getStringList('contacts') ?? [];
    });
  }

  Future<void> _addContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    
    final newContact = "${_nameController.text}:${_phoneController.text}";
    setState(() {
      _contacts.add(newContact);
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('contacts', _contacts);
    
    _nameController.clear();
    _phoneController.clear();
    if(mounted) Navigator.pop(context);
  }

  Future<void> _removeContact(int index) async {
    setState(() {
      _contacts.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('contacts', _contacts);
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Add Trusted Contact", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number", labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addContact,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            child: const Text("Add", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerPanic() async {
    await _panicService.triggerPanic(
      context: context,
      onStatusChange: (status) {
        if (mounted) setState(() => _statusMessage = status);
      },
      onRecordingStateChange: (isRecording) {
        if (mounted) setState(() => _isRecording = isRecording);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Safehouse Vault"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFF00E5FF)),
            onPressed: _showAddContactDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_statusMessage, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                GestureDetector(
                  onTap: _isRecording ? null : _triggerPanic,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.grey[800] : const Color(0xFFFF007A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.grey : const Color(0xFFFF007A)).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isRecording ? "SENDING..." : "PANIC",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Tap to Send Location + Audio", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          const Divider(color: Colors.grey),

          SwitchListTile(
            title: const Text("Background Protection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Shake to Panic even when app is closed", style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: _isBackgroundActive,
            activeColor: const Color(0xFF00E5FF),
            onChanged: _toggleBackgroundService,
          ),

          const Divider(color: Colors.grey),
          
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            title: const Text("Instant SOS Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(_sosCode == null ? "Not Set" : "Active Code: $_sosCode", style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.edit, color: Colors.grey),
            onTap: _setSosCode,
          ),
          
          const Divider(color: Colors.grey),

          ListTile(
            leading: const Icon(Icons.theater_comedy, color: Colors.blueGrey),
            title: const Text("Set Decoy Vault Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(_dummyCode == null ? "Not Set" : "Active Code: $_dummyCode", style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.edit, color: Colors.grey),
            onTap: _setDummyCode,
          ),

          const Divider(color: Colors.grey),

          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.cyanAccent),
            title: const Text("Report to I4C (1930)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Upload evidence to National Cyber Crime Portal", style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.open_in_new, color: Colors.grey),
            onTap: _launchI4C,
          ),
          
          const Divider(color: Colors.grey),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Trusted Contacts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: _contacts.isEmpty 
            ? const Center(child: Text("No contacts added.", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final parts = _contacts[index].split(':');
                  final name = parts[0];
                  final phone = parts.length > 1 ? parts[1] : '';
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFF334155), child: Icon(Icons.person, color: Colors.white)),
                    title: Text(name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(phone, style: const TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeContact(index),
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    );
  }
}
