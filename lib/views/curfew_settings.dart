import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class CurfewSettingsPage extends StatefulWidget {
  final AccountManager accountManager;

  const CurfewSettingsPage({Key? key, required this.accountManager}) : super(key: key);

  @override
  State<CurfewSettingsPage> createState() => _CurfewSettingsPageState();
}

class _CurfewSettingsPageState extends State<CurfewSettingsPage> {
  late TimeOfDay start;
  late TimeOfDay end;

  @override
  void initState() {
    super.initState();
    start = widget.accountManager.curfewStart;
    end = widget.accountManager.curfewEnd;
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: start);
    if (picked != null) setState(() => start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: end);
    if (picked != null) setState(() => end = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Screen Time Limits')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: const Text('Curfew Start Time'),
              trailing: Text(start.format(context)),
              onTap: _pickStart,
            ),
            ListTile(
              title: const Text('Curfew End Time'),
              trailing: Text(end.format(context)),
              onTap: _pickEnd,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                widget.accountManager.setCurfew(start, end);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Curfew times updated!')));
                Navigator.pop(context);
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
