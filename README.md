# RemediMath

Aplikasi mobile Flutter: **Asisten Remediasi Matematika SMA berbasis Item
Response Theory (IRT) & Knowledge Graph**.

## Fitur

1. **Profil lokal** — nama, kelas, asal sekolah (disimpan di perangkat).
2. **Tes diagnostik** 15 soal pilihan ganda dengan batas waktu.
3. **Estimasi kemampuan (θ)** memakai Model Rasch 1PL + Newton-Raphson,
   termasuk penanganan skor ekstrem (semua benar → +2.0, semua salah → −2.0).
4. **Knowledge Graph prasyarat materi** — penelusuran mundur (backward
   traversal) untuk menemukan akar masalah, bukan sekadar soal yang salah.
5. **Rute belajar personal** — video mikro-learning + post-test ketuntasan.
6. **Riwayat sesi remedial & progres** tersimpan lokal.

Seluruh alur utama berjalan **offline**. Satu-satunya fitur yang butuh
internet adalah membuka video di aplikasi/peramban YouTube.

## Menjalankan proyek

```bash
flutter pub get
flutter run
```

Lalu jalankan pemeriksaan:

```bash
flutter analyze
flutter test
```

## Struktur

```
lib/
  core/            tema, warna, tipografi, konstanta, util format
  models/          UserProfile, Question, ConceptNode, DiagnosticResult, ...
  services/        IrtService, KnowledgeGraphService, ContentRepository,
                   LocalStorageService
  controllers/     AppController (state global)
  views/pages/     Onboarding, RootShell, Dashboard, Diagnostik, Kuis,
                   Hasil Diagnosis, Remedial, Progres, Pembahasan
  views/widgets/   komponen UI yang dipakai ulang
assets/data/       questions.json, knowledge_graph.json
test/              unit test IRT & Knowledge Graph
```

## Dokumentasi

Dokumentasi internal proyek (perencanaan, daftar tugas, riwayat perubahan,
hasil pengujian, dan katalog referensi desain) disimpan secara lokal dan
sengaja **tidak** dipublikasikan ke repositori ini. Ringkasan arsitektur
tercantum di bagian [Struktur](#struktur) dan
[Catatan desain](#catatan-desain).

## Catatan desain

- Semua layout memakai `Column`, `Row`, `Expanded`, `Wrap`,
  `ListView`/`SingleChildScrollView`, dan `LayoutBuilder` — tanpa lebar/tinggi
  besar yang dipaku, tanpa `Positioned` kaku.
- Target sentuh minimal 48dp. Palet dan tipografi terpusat di `lib/core/`.
- Ikon vektor dari desain diganti ikon bawaan Flutter (`Icons...`).
- Ambang ketuntasan default: **θ ≥ 0.0** (lihat `AppConstants.masteryTheta`)
  dan penguasaan sub-konsep **≥ 60%** (`AppConstants.masteryRatio`).
- Video penjelasan dibuka di aplikasi/peramban eksternal via `url_launcher`.
  Tidak ada player embedded di dalam aplikasi.
