import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
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
  bool _submitting = false;
  bool _submittedOnce = false;

  @override
  void dispose() {
    _name.dispose();
    _school.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_submittedOnce) setState(() => _submittedOnce = true);
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await context.read<AppController>().saveProfile(UserProfile(
            name: _name.text.trim(),
            className: _kelas,
            school: _school.text.trim(),
          ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceLg,
              vertical: AppSizes.spaceXl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Center(child: AppLogo(size: 76)),
                  const SizedBox(height: AppSizes.spaceMd),
                  const Text(
                    AppLogo.brandName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLg,
                  ),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(
                    'Temukan akar kelemahan matematikamu dan tuntaskan lewat rute belajar personal.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  ),
                  const SizedBox(height: AppSizes.spaceMd),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSizes.spaceSm,
                    runSpacing: AppSizes.spaceSm,
                    children: <Widget>[
                      Pill(
                        label: '15 Soal Adaptif',
                        icon: Icons.quiz_outlined,
                        background: AppColors.accentYellow,
                      ),
                      Pill(
                        label: 'Peta Akar Masalah',
                        icon: Icons.hub_outlined,
                        background: AppColors.accentBlue,
                      ),
                      Pill(
                        label: 'Rute Remedial',
                        icon: Icons.route_outlined,
                        background: AppColors.accentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  NeoCard(
                    padding: const EdgeInsets.all(AppSizes.spaceXl),
                    child: Form(
                      key: _form,
                      autovalidateMode: _submittedOnce
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: EyebrowLabel(label: 'Profil Siswa'),
                          ),
                          const SizedBox(height: AppSizes.spaceSm),
                          const Text(
                            'Siapkan profil belajarmu',
                            style: AppTextStyles.titleMd,
                          ),
                          const SizedBox(height: AppSizes.spaceLg),
                          TextFormField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const <String>[AutofillHints.name],
                            decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              hintText: 'Contoh: Nadia Putri',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Nama wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: AppSizes.spaceMd),
                          DropdownButtonFormField<String>(
                            value: _kelas,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                            items: const <String>[
                              'SMA Kelas 10',
                              'SMA Kelas 11',
                              'SMA Kelas 12',
                            ]
                                .map((String k) => DropdownMenuItem<String>(
                                    value: k, child: Text(k)))
                                .toList(),
                            onChanged: _submitting
                                ? null
                                : (String? v) =>
                                    setState(() => _kelas = v ?? _kelas),
                          ),
                          const SizedBox(height: AppSizes.spaceMd),
                          TextFormField(
                            controller: _school,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'Asal sekolah (opsional)',
                              hintText: 'Contoh: SMAN 1 Bandung',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSizes.spaceXl),
                          NeoButton(
                            expand: true,
                            icon: _submitting ? null : Icons.arrow_forward,
                            label:
                                _submitting ? 'Menyimpan...' : 'Mulai Belajar',
                            onPressed: _submitting ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: AppSizes.spaceXs),
                      Flexible(
                        child: Text(
                          'Data tersimpan lokal hanya di perangkat ini.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.ink),
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
    );
  }
}
