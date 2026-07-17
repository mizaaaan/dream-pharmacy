import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import '../../../core/theme/app_theme.dart';

class InviteAdminScreen extends ConsumerStatefulWidget {
  const InviteAdminScreen({super.key});

  @override
  ConsumerState<InviteAdminScreen> createState() => _InviteAdminScreenState();
}

class _InviteAdminScreenState extends ConsumerState<InviteAdminScreen> {
  final _emailController = TextEditingController();
  bool _submitting = false;

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await ref.read(adminRepositoryProvider).inviteAdmin(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invite sent to $email. They will become admin when they sign up.')),
        );
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Invite Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the email of the person you want to make an admin. '
              'They will automatically be granted admin access when they sign up with this email.',
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
              onPressed: _submitting ? null : _sendInvite,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }
}
