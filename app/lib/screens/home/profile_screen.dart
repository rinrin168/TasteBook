import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/navigation/add_recipe_popup.dart';
import '../../widgets/navigation/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recipeCountController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.instance.currentProfile();
    final user = AuthService.instance.currentUser;

    if (!mounted) return;

    _usernameController.text =
        profile?['displayName'] as String? ?? user?.displayName ?? '';
    _emailController.text = profile?['email'] as String? ?? user?.email ?? '';
    _recipeCountController.text =
        (profile?['recipeCount'] as num?)?.toInt().toString() ?? '0';
    _passwordController.text = '';

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _recipeCountController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/auth/get-started', (route) => false);
  }

  void _saveChanges() {
    AuthService.instance
        .updateProfile(
          displayName: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim().isEmpty
              ? null
              : _passwordController.text.trim(),
        )
        .then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile changes saved.')),
          );
        })
        .catchError((error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tan,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFA590),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              color: AppColors.text,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Spacer(),
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 122,
                                height: 122,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE4585C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Color(0xFF24141F),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 56,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                                label: const Text(
                                  'Edit Photos',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Personal Details',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Username'),
                        const SizedBox(height: 6),
                        _ProfileInput(controller: _usernameController),
                        const SizedBox(height: 12),
                        _FieldLabel('Email Address'),
                        const SizedBox(height: 6),
                        _ProfileInput(controller: _emailController),
                        const SizedBox(height: 12),
                        _FieldLabel('Password'),
                        const SizedBox(height: 6),
                        _ProfileInput(
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.text,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Change Password',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _FieldLabel('Add Recipes'),
                        const SizedBox(height: 6),
                        _ProfileInput(
                          controller: _recipeCountController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: _signOut,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.white,
                                    side: BorderSide(
                                      color: AppColors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: _saveChanges,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    foregroundColor: AppColors.text,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavbar(
          currentIndex: 4,
          onAddTap: () => showAddRecipePopup(context),
          onHomeTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          onLibraryTap: () =>
              Navigator.of(context).pushReplacementNamed('/library'),
          onSearchTap: () =>
              Navigator.of(context).pushReplacementNamed('/search'),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  const _ProfileInput({
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
