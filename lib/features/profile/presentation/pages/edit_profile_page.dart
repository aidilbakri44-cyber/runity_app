import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_helper.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Foto Profil",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(FontAwesomeIcons.image, color: AppColors.primary, size: 20),
                ),
                title: const Text("Galeri Foto", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Pilih dari perpustakaan foto", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(FontAwesomeIcons.camera, color: AppColors.secondary, size: 20),
                ),
                title: const Text("Kamera", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Ambil foto baru", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar with pick button
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showPickerOptions,
              child: Stack(
                children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: AppColors.surface,
                          child: _localImagePath != null
                              ? ImageHelper.imageFromPath(_localImagePath!)
                              : profile.avatarUrl.isEmpty
                                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                                  : ImageHelper.imageFromPath(profile.avatarUrl),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const FaIcon(FontAwesomeIcons.camera, color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ketuk untuk mengganti foto",
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12),
            ),
            const SizedBox(height: 40),

            // Name field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama Tampilan",
                labelStyle: const TextStyle(color: AppColors.primary),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 20),

            // Bio field
            TextField(
              controller: _bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Biodata / Tentang Saya",
                labelStyle: const TextStyle(color: AppColors.primary),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.info_outline, color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 48),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(profileProvider.notifier);
                  notifier.updateProfile(
                    name: _nameController.text,
                    bio: _bioController.text,
                    avatarUrl: _localImagePath,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profil berhasil diperbarui!"),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
