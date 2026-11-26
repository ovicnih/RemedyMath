import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/profile_image_service.dart';
import 'crop_page.dart';
import '../widgets/common.dart';

/// Halaman Pengaturan: Profil dan Logout.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final UserProfile? profile = c.profile;

    return Scaffold(
      appBar: remediAppBar(context, 'Pengaturan', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceXl,
          ),
          children: <Widget>[
            _ProfileForm(profile: profile),
            const SizedBox(height: AppSizes.spaceXl),

            // Logout Section
            const SectionTitle(
              'Akun',
              icon: Icons.logout_outlined,
              style: AppTextStyles.titleMd,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            NeoCard(
              color: AppColors.accentPink,
              padding: const EdgeInsets.all(AppSizes.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text('Keluar dari akun', style: AppTextStyles.titleMd),
                  const SizedBox(height: AppSizes.spaceSm),
                  const Text(
                    'Semua data profil, riwayat tes, dan progres remedial '
                        'akan dihapus dari perangkat ini. Tindakan ini tidak '
                        'dapat dibatalkan.',
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  NeoButton(
                    expand: true,
                    color: AppColors.surface,
                    icon: Icons.logout,
                    label: 'Logout',
                    onPressed: () => _confirmLogout(context, c),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AppController c) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Yakin ingin keluar? Semua data lokal akan dihapus dan '
              'kamu akan kembali ke halaman Onboarding.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentPink),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await c.resetAll();
      if (context.mounted) {
        // Audit §9: `resetAll()` membuat `profile == null`, sehingga `home` di
        // `main.dart` berganti ke Onboarding otomatis via `notifyListeners`.
        // Cukup bersihkan halaman yang ditumpuk di atasnya (Pengaturan,
        // kuis, dsb.) — JANGAN mendorong Onboarding baru agar tidak
        // tertumpuk dan navigasi tidak berjalan dua kali.
        Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
      }
    }
  }
}

/// Form profil dengan validasi nama wajib diisi.
class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.profile});
  final UserProfile? profile;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();
  String? _photoPath;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    if (p != null) {
      _nameController.text = p.name;
      _classController.text = p.className;
      _schoolController.text = p.school;
      _photoPath = p.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      // Pra-skala native kecil agar layar crop dan decode lokal ringan;
      // hasil akhir tetap 512x512, cukup untuk avatar tajam.
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image == null || !mounted) return;
    final List<int> raw = await image.readAsBytes();
    if (!mounted) return;
    Uint8List? result;
    try {
      // 8R.2: layar crop interaktif — pengguna memilih area 1:1.
      result = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute<Uint8List>(
          builder: (_) => CropPage(rawBytes: raw),
        ),
      );
    } on ArgumentError {
      // Format tak dikenali → layar crop gagal; jatuh ke gambar mentah.
      result = null;
    }
    if (!mounted) return;
    try {
      final Uint8List square =
          result ?? ProfileImageService.cropSquare(raw);
      if (kIsWeb) {
        setState(() => _photoPath = base64Encode(square));
      } else {
        final String outPath = ProfileImageService.croppedFilePath(image.path);
        final File outFile = File(outPath);
        await outFile.writeAsBytes(square);
        try {
          await FileImage(outFile).evict();
        } catch (_) {}
        setState(() => _photoPath = outPath);
      }
    } on ArgumentError {
      // Format gambar tidak dikenali: pakai hasil picker apa adanya agar
      // pilihan pengguna tidak hilang.
      if (!mounted) return;
      if (kIsWeb) {
        setState(() => _photoPath = base64Encode(raw));
      } else {
        setState(() => _photoPath = image.path);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final AppController c = context.read<AppController>();
    final UserProfile updated = UserProfile(
      name: _nameController.text.trim(),
      className: _classController.text.trim(),
      school: _schoolController.text.trim(),
      photoPath: _photoPath,
    );

    if (_photoPath != null && !kIsWeb) {
      try {
        await FileImage(File(_photoPath!)).evict();
      } catch (_) {}
    }

    await c.saveProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (widget.profile?.name ?? 'Siswa');
    final String displayClass = _classController.text.trim().isNotEmpty
        ? _classController.text.trim()
        : (widget.profile?.className ?? 'SMA Kelas 10');

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Lime Bento Profile Banner
          NeoCard(
            color: AppColors.accentYellow,
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ProfileAvatar(
                      initials: _nameController.text.isNotEmpty
                          ? _nameController.text
                              .trim()
                              .split(RegExp(r'\s+'))
                              .first[0]
                              .toUpperCase()
                          : (widget.profile?.initials ?? '?'),
                      size: 76,
                      photoPath: _photoPath,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ink,
                              width: AppSizes.borderThin,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.spaceLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLg,
                      ),
                      const SizedBox(height: AppSizes.spaceXs),
                      Text(
                        displayClass,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd,
                      ),
                      const SizedBox(height: AppSizes.spaceSm),
                      const Pill(
                        label: 'Tersimpan lokal',
                        icon: Icons.lock_outline,
                        background: AppColors.surface,
                        bordered: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceLg),

          // Form Edit Profil
          NeoCard(
            borderWidth: AppSizes.borderThin,
            padding: const EdgeInsets.all(AppSizes.spaceXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: EyebrowLabel(label: 'Edit Profil'),
                ),
                const SizedBox(height: AppSizes.spaceMd),

                // Nama (wajib)
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    hintText: 'Masukkan nama',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.spaceMd),

                // Kelas
                TextFormField(
                  controller: _classController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    hintText: 'Contoh: SMA Kelas 10',
                    prefixIcon: Icon(Icons.class_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.spaceMd),

                // Sekolah
                TextFormField(
                  controller: _schoolController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveProfile(),
                  decoration: const InputDecoration(
                    labelText: 'Asal Sekolah',
                    hintText: 'Nama sekolah',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.spaceLg),

                // Simpan
                NeoButton(
                  expand: true,
                  icon: Icons.save_outlined,
                  label: 'Simpan Profil',
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}