import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// Profile / account screen.
/// Endpoints: GET /auth/me, logout clears token locally.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user;
  bool _loading = true;
  bool _savingName = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final user = await AuthService.instance.getCurrentUser();
      if (mounted) setState(() => _user = user);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load your profile.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: _user?.displayName ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Edit display name', style: AppText.sans(color: AppColors.text)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          style: AppText.sans(color: AppColors.text),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: AppText.sans(color: AppColors.textMuted),
            counterStyle: AppText.sans(size: 11, color: AppColors.textDim),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppText.sans(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Save', style: AppText.sans(color: AppColors.purpleLight)),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    final name = controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _savingName = true);
    try {
      final updated = await AuthService.instance.updateDisplayName(name);
      if (mounted) setState(() => _user = updated);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save name. Is the backend running?')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Account', style: AppText.label(size: 14, spacing: 2.5)),
      ),
      body: _loading
          ? const Center(child: LoadingDots())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error, style: AppText.sans(color: AppColors.textDim)),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Retry',
                        secondary: true,
                        onPressed: _load,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.purple, Color(0xFF5B3CC4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purpleGlow,
                              blurRadius: 20,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (_user?.displayName?.isNotEmpty == true
                                    ? _user!.displayName![0]
                                    : _user?.email[0] ?? '?')
                                .toUpperCase(),
                            style: AppText.sans(
                              size: 32,
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          ),
                      const SizedBox(height: 20),
                      Text(
                        _user?.displayName?.isNotEmpty == true
                            ? _user!.displayName!
                            : 'Journaler',
                        style: AppText.sans(size: 20, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user?.email ?? '',
                        style: AppText.sans(size: 14, color: AppColors.textDim),
                      ),
                      const SizedBox(height: 28),
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: _user?.email ?? '—',
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Display name',
                              value: _user?.displayName?.isNotEmpty == true
                                  ? _user!.displayName!
                                  : 'Not set',
                              onEdit: _savingName ? null : _editDisplayName,
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Member since',
                              value: _formatDate(_user?.createdAt ?? ''),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => AuthService.instance.logout(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.red.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Log out',
                                  style: AppText.label(
                                    size: 11,
                                    color: AppColors.red,
                                    spacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.purpleDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.purpleLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.label(size: 9, spacing: 0.5)),
                const SizedBox(height: 2),
                Text(value, style: AppText.sans(size: 14, color: AppColors.text)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textDim),
              tooltip: 'Edit',
            ),
        ],
      );
}
