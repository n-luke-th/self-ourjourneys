/// lib/views/settings_page.dart
///
/// setting page
///
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isBiometricEnabled = false;
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _toggleBiometric(bool value) {
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Account Profile Section
            Text('Account Profile',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),
            SizedBox(height: 20),
            Divider(),

            // Dark Mode Section
            SwitchListTile(
              title: Text('Enable Dark Mode'),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
            SizedBox(height: 20),
            Divider(),

            // Local Authentication Section
            ListTile(
              title: Text('Local Authentication'),
              subtitle: Text(_isBiometricEnabled
                  ? 'Biometric Authentication Enabled'
                  : 'Passcode Authentication Enabled'),
              trailing: Switch(
                value: _isBiometricEnabled,
                onChanged: _toggleBiometric,
              ),
            ),
            SizedBox(height: 20),
            Divider(),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save settings logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings Saved')),
                );
              },
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
