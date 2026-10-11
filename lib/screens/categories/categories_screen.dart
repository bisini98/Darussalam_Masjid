// NEW FILE: lib/screens/categories/categories_screen.dart
// Payment categories (Subscription, Kit, Meat, Rice, ...), the Test Mode switch and Sign out.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _addCategory(BuildContext context) async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Kit, Meat, Rice, Zakat'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      context.read<AppProvider>().addCategory(name);
    }
  }

  Future<void> _toggleTestMode(BuildContext context, AppProvider p, bool testOn) async {
    if (testOn) {
      p.setTestMode(true);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Turn off test mode?'),
        content: const Text('From now on, every payment, edit and delete is saved to Firebase for real.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep test mode')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save for real')),
        ],
      ),
    );
    if (ok == true) p.setTestMode(false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Categories & Settings'), backgroundColor: AppColors.primary),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add category', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: p.testMode,
              onChanged: (v) => _toggleTestMode(context, p, v),
              title: const Text('Test mode'),
              subtitle: Text(p.testMode
                  ? 'ON: practice only. Nothing is saved to Firebase and changes vanish when the app restarts.'
                  : 'OFF: everything is saved to Firebase.'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Payment categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...p.categories.map((c) => Card(
            child: ListTile(
              leading: const Icon(Icons.category_rounded, color: AppColors.primary),
              title: Text(c.name),
              subtitle: c.builtIn ? const Text('Built-in (monthly subscription)') : null,
            ),
          )),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}