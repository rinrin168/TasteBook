import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FocusNode _passwordFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String _selectedAvatar = '🧑‍🍳';

  static const _avatars = [
    '🧑‍🍳', '👩‍🍳', '🍳', '🍕',
    '🍔', '🍰', '🍓', '🥑',
    '🧁', '🍩', '🍣', '🌮'
  ];

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
    _selectedAvatar = profile?['avatar'] as String? ?? '🧑‍🍳';

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
    _passwordFocusNode.dispose();
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
    final email = _emailController.text.trim();
    
    // Simple email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address (e.g., example@gmail.com).')),
      );
      return;
    }

    AuthService.instance
        .updateProfile(
          displayName: _usernameController.text.trim(),
          email: email,
          password: _passwordController.text.trim().isEmpty
              ? null
              : _passwordController.text.trim(),
          avatar: _selectedAvatar,
        )
        .then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile changes saved.')),
          );
          _passwordController.clear();
        })
        .catchError((error) {
          if (!mounted) return;
          String errorMessage = error.toString();
          if (error is FirebaseAuthException) {
            if (error.code == 'email-already-in-use') {
              errorMessage = 'This email address is already in use by another account.';
            } else {
              errorMessage = error.message ?? errorMessage;
            }
          } else if (errorMessage.contains('email-already-in-use')) {
             errorMessage = 'This email address is already in use by another account.';
          } else if (errorMessage.contains('INVALID_NEW_EMAIL')) {
             errorMessage = 'Please enter a valid new email address.';
          }
          
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 150,
        maxHeight: 150,
        imageQuality: 60, // Compress to optimize Firestore storage sizes
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _selectedAvatar = 'data:image/jpeg;base64,$base64String';
      });

      _saveChanges();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _editAvatar() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true, // Allow custom height constraint without clipping
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75, // Cap height to 75%
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Chef Avatar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Image selection/upload button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _pickAndUploadImage();
                    },
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Upload Custom Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: AppColors.text, width: 1.5),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Avatar Emojis Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final avatarEmoji = _avatars[index];
                      final isSelected = _selectedAvatar == avatarEmoji;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = avatarEmoji;
                          });
                          Navigator.of(sheetContext).pop();
                          _saveChanges(); // Auto-save on selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            avatarEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget() {
    if (_selectedAvatar.startsWith('data:image') || _selectedAvatar.length > 30) {
      try {
        final base64Data = _selectedAvatar.split(',').last;
        final decodedBytes = base64Decode(base64Data);
        return ClipOval(
          child: Image.memory(
            decodedBytes,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return const Icon(Icons.person_rounded, size: 56, color: Colors.white);
      }
    } else {
      return Text(
        _selectedAvatar,
        style: const TextStyle(fontSize: 44),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.4), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.text.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              color: AppColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Spacer(),
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                  ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accent, width: 2.5),
                                ),
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppColors.background,
                                    child: _buildAvatarWidget(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: _editAvatar,
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                                label: const Text(
                                  'Change Avatar',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Personal Details',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Username'),
                        const SizedBox(height: 6),
                        _ProfileInput(controller: _usernameController),
                        const SizedBox(height: 12),
                        const _FieldLabel('Email Address'),
                        const SizedBox(height: 6),
                        _ProfileInput(controller: _emailController),
                        const SizedBox(height: 12),
                        const _FieldLabel('New Password'),
                        const SizedBox(height: 6),
                        _ProfileInput(
                          controller: _passwordController,
                          obscureText: true,
                          focusNode: _passwordFocusNode,
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _passwordFocusNode.requestFocus();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Change Password',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _FieldLabel('Posted Recipes Count'),
                        const SizedBox(height: 6),
                        _ProfileInput(
                          controller: _recipeCountController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: _signOut,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: _saveChanges,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    shape: const StadiumBorder(),
                                    elevation: 2,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.25),
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
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  const _ProfileInput({
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      focusNode: focusNode,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.45), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
