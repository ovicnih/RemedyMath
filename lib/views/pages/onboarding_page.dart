import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _school = TextEditingController();
  String _kelas = 'SMA Kelas 10';

  @override
  void dispose() {
    _name.dispose();
    _school.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AppController>().saveProfile(UserProfile(
          name: _name.text.trim(),
          className: _kelas,
          school: _school.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: AppLogo(size: 72)),
                    const SizedBox(height: 20),
                    Text('RemedyMath',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLg.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text(
                      'Asisten remediasi matematika SMA berbasis Item Response Theory & Knowledge Graph.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _kelas,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      items: const <String>['SMA Kelas 10', 'SMA Kelas 11', 'SMA Kelas 12']
                          .map((k) => DropdownMenuItem<String>(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (v) => setState(() => _kelas = v ?? _kelas),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _school,
                      decoration: const InputDecoration(
                        labelText: 'Asal sekolah (opsional)',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Mulai Belajar'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data disimpan hanya di perangkat ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
