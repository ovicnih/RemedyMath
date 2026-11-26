
# HISTORY - Riwayat Perubahan

Format: entri terbaru di atas. Setiap entri menjelaskan apa yang berubah, kenapa,
dan apa yang diverifikasi.

---

## v3.0.0 - 2026-11-26 - Tahap 8 Part 4 & Tahap 9 (Polish UI/UX, Performa & Penuntasan)

### Konteks

Menuntaskan sisa Tahap 8 Part 4 (`8S.1`, `8S.4`), verifikasi responsif (`5.8`),
redesain halaman Login/Onboarding sesuai panduan `ui-ux-pro-max`, serta optimasi
performa surgical (`flutter-performance`) dengan pendekatan minimal-diff
(Ponytail).

### 9.1 / 8S.1 Perbaikan `AppLogo` tanpa double border

- `lib/views/widgets/brand.dart`: `AppLogo` merender `assets/logo/logo.png`
  (rounded-square lime `#E2F16D` + charcoal `#1A1A1A`) penuh tanpa border ganda,
  dilengkapi `cacheWidth` berbasis `devicePixelRatioOf(context)`. Kotak kuning
  berborder dengan glyph `'Σ'` dipertahankan di `errorBuilder`.
- `lib/core/app_assets.dart` & `test/app_logo_test.dart`: komentar dan test
  diperbarui untuk memverifikasi `ResizeImage` (`cacheWidth`) dan fallback `'Σ'`.

### 9.2 Redesain halaman Login/Onboarding

- `lib/views/pages/onboarding_page.dart`: hero header dengan `AppLogo(size: 76)`,
  tagline ramah siswa, dan 3 `Pill` keunggulan (`15 Soal Adaptif`,
  `Peta Akar Masalah`, `Rute Remedial`). Form dibungkus `NeoCard` +
  `EyebrowLabel('Profil Siswa')`, ditambah `TextInputAction.next`/`done`,
  `onFieldSubmitted`, `AutovalidateMode.onUserInteraction` pasca-submit pertama,
  `_submitting` guard anti double-tap, dan catatan privasi berikon gembok.

### 9.3–9.4 Optimasi performa UI

- `lib/views/pages/quiz_page.dart`: mengganti `Duration _left` + `setState()`
  tiap detik menjadi `ValueNotifier<Duration>` (di-dispose di `dispose()`) dengan
  `ValueListenableBuilder` khusus pada `_TimerChip` sehingga halaman kuis tidak
  rebuild seluruhnya tiap detik.
- `lib/views/pages/root_shell.dart`: mengganti `context.watch<AppController>()`
  menjadi `context.select<AppController, int>((c) => c.tabIndex)`.
- `lib/views/widgets/brand.dart`: menambahkan `cacheWidth` pada `ProfileAvatar`
  (`Image.file` & `Image.memory`).
- `lib/views/pages/crop_page.dart`: memindahkan 3 `Paint()` pada `_CropMask` ke
  `static final Paint` field (zero-allocation per frame repaint).

### 9.5 / 5.8 Verifikasi layout responsif 360×640 & 412×915

- `test/responsive_layout_test.dart` (baru): menguji 7 halaman utama
  (`OnboardingPage`, `DashboardPage`, `DiagnosticPage`, `RemedialTabPage`,
  `ProgressPage`, `SettingsPage`, `CropPage`) pada `360×640` dan `412×915` —
  0 `RenderFlex overflow`.

### 9.6 Kebersihan repo & klarifikasi `README.md`

- `.gitignore`: menambahkan `/.agents/` dan `/skills-lock.json`.
- `README.md`: memperjelas arsitektur **offline-first** untuk inti aplikasi dan
  kebutuhan koneksi internet khusus pemutar video YouTube remedial.

### 9.7 / 8S.4 Verifikasi akhir

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | **67/67 lulus** (65 eksisting + 2 test responsif baru) |

---

## v2.9.0 - 2026-11-01 - Tahap 8 Part 3 Perbaikan Lanjutan Vol.2 (8R.1-8R.5)

### Konteks

Umpan balik pasca v2.7.0: kartu "Mikro-Belajar" di halaman rute belajar
kurang perlu, crop foto profil otomatis-tengah diganti pilihan area sendiri
melalui border geser gaya PC, logo aplikasinya diganti menjadi putih saja,
dan video di rute belajar tidak boleh hilang setelah selesai.

### 8R.1 Hapus kartu mikro-belajar

- `remedial_page.dart`: `ConceptCard` (biru+kuning "RemedyMath ·
  Mikro-Belajar" + badge Dipahami) dihapus dari halaman rute belajar.
  Poin kunci, video, dan CTA post-test tetap.
- `views/widgets/concept_card.dart` dan export di `common.dart` dihapus
  (tanpa pemakai lain).

### 8R.2 Crop foto profil: border geser gaya PC

- `views/pages/crop_page.dart`: satu `GestureDetector` (`HitTestBehavior.opaque`) meliputi seluruh viewport menggunakan `DragUpdateDetails.delta` (inkremental) agar jari tetap menempel pada handle. 8 handle geser (4 sudut + 4 tepi) dan geser seluruh border (interior), semua dengan clamp ke batas gambar; `CustomPaint` melipat di luar border dengan panduan tengah. Assist snap: bila pusat area crop dekat tengah layar (44 px), rata kanan-kiri dan/atau atas-bawah otomatis (gaya panduan Canva). Tombol Simpan memotong area border via `ProfileImageService.cropRect` → JPEG 512x512; Batal kembali `null`. Tanpa dependensi baru.

### 8R.3 Logo aplikasi warna putih saja

- `Save/Logo.png` (1254x1254, 681 KB) ditulis ulang jadi siluet putih
  (512x512, 7.4 KB) via package `image` — setiap piksel non-transparan
  di-set putih, alpha dipertahankan — lalu didaftarkan di `pubspec.yaml`.
- `lib/core/app_assets.dart` konstanta terpusat `AppAssets.logo`.
- `AppLogo` (brand.dart) menampilkan `Image.asset(AppAssets.logo)` murni
  tanpa blend mode; fallback glyph 'Σ' saat asset gagal. Semua pemakai
  (onboarding, appbar) tidak berubah.

### 8R.4 Video rute belajar tetap tampil setelah selesai

- `views/widgets/video_lesson.dart`: pemutar tidak lagi disembunyikan
  setelah `completed` — `YoutubePlayer` tetap ditampilkan dan dapat
  ditonton ulang kapan saja. Ketika pemutar belum ada (selesai saat
  memuat ulang halaman), tombol "Ulangi video" muncul untuk membuat
  pemutar baru; `markStudied` tetap dipanggil saat video selesai dan
  idempoten.

### 8R.5 Verifikasi 8 Part 3

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 63/63 lulus |

---

## v2.8.0 - 2026-11-01 - Tahap 8 Part 2 Perbaikan Lanjutan (8P.1-8P.6)

### Konteks

Menindaklanjuti umpan balik pengujian manual setelah v2.6.0: pembahasan soal
masih menampilkan kotak merah/hijau, video yang dilewati ke ujung tidak
membuka post-test, dan foto profil upload bermasalah (ukuran, latar pink,
avatar header tidak menampilkan foto).

### 8P.1 Pembahasan soal tanpa kotak 2 warna

- `review_page.dart`: kartu pembahasan kini netral (NeoCard tanpa border
  warna); ikon check/cancel dan panel pola Berperingkat dihapus;
  status Benar/Salah cukup di baris jawaban siswa.
- Test `review_page_test.dart`: halaman review menampilkan soal dan TIDAK
  lagi menampilkan teks "Yang benar"/"Yang salah".

### 8P.2 Video selesai walau di-skip

- `video_lesson.dart`: `_evaluateCompletion()` menandai video selesai ketika
  `playerState == ended` ATAU posisi sudah dekat durasi akhir
  (`_endTolerance` 2 detik, via bridge `currentTime`/`duration`), jadi
  pengguna yang langsung menyentuh persentase terakhir tetap membuka
  post-test. Flag `_completedNotified` mencegah notifikasi ganda.
- Test `post_test_gate_test.dart`: materi yang sudah dipelajari menampilkan
  tombol "Mulai post-test" aktif, diketuk membuka QuizPage.

### 8P.3 Crop foto profil saat upload

- Dependensi baru `image ^4.2.0` (resolved 4.12.0, pure Dart — tanpa
  konfigurasi native).
- `profile_image_service.dart`: `cropSquare()` crop persegi pusat
  `copyResizeCropSquare(size: 512, interpolation: nearest)` lalu encode JPEG
  q85; `croppedFilePath()` menghasilkan `<nama>_crop.jpg` melekat sejenis
  asli dari picker.
- `settings_page.dart`: `_pickImage()` memproses byte picker melalui
  `ProfileImageService.cropSquare`; sinkron web menyimpan base64 hasil
  persegi, non-web menulis file `_crop.jpg`. Fallback memakai foto asli
  secara utuh bila format gambar tidak dikenali (ArgumentError).
- Test `profile_image_service_test.dart` 5 kasus: landscape 512x512, band
  tengah terjaga, potret penuh, ArgumentError, suffix path.

### 8P.4/8P.5 Avatar tampil benar

- `brand.dart` `ProfileAvatar`: latar `Colors.transparent` saat foto
  ditampilkan (pink hanya untuk inisial) sehingga tidak ada cincin pink
  di belakang foto.
- `brand.dart` `remediAppBar`: mengambil `c.profile?.photoPath` via
  `context.select` dan meneruskannya ke avatar header; halaman lain otomatis
  memperbarui setelah `saveProfile` tanpa restart.
- Test `profile_avatar_test.dart`: satu testWidgets tiga skenario (inisial
  pink, foto transparan, appbar photoPath). Satu `init()` per file karena
  dua init beruntun membuat test harness menggantung.

### Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 53/53 lulus (47 baseline Tahap 8, +5 crop, +1 avatar) |
| Test baru 8 Part 2 | review bebas kotak warna, gating post-test pasca video, crop persegi 512x512, avatar foto/latar/appbar |

---

## v2.6.0 - 2026-10-29 - Tahap 8 Perbaikan Berdasarkan Audit (TASK 8.1-8.12)

### Konteks

Menyelesaikan seluruh 12 tugas Tahap 8 dari dokumen audit
`Save/Audit/1_Audit, Perbaikan Bug, dan Penyempurnaan Alur Pembelajaran
RemediMath.md`: validasi pengumpulan kuis, penguncian rute belajar berurutan,
penyederhanaan hasil diagnostik, konsistensi/logout profil, dan serangkaian
test otomatis untuk tiap kriteria audit.

### 8.1 Validasi penyelesaian kuis

- `quiz_page.dart`: getter `_unansweredCount` dan `_firstUnansweredIndex()`.
  `_confirmFinish` menolak mengumpulkan saat ada soal kosong: SnackBar
  "Masih ada N soal yang belum dijawab. Lengkapi semua jawaban sebelum
  mengumpulkan tes." plus lompat otomatis ke soal kosong pertama. Timer habis
  saat ada jawaban: dialog "Waktu habis" dan jawaban tetap tersimpan (tidak
  dihitung salah). Submit berulang diblokir lewat `_finished`.

### 8.2 Pembahasan per soal

- Verifikasi: `review_page.dart` menampilkan teks soal, jawaban siswa, status
  Benar/Salah; baris "Kunci: ..." tidak ada; `_PatternPanel`
  wrongPattern/correctPattern hanya info pola konsep.

### 8.3 Aktifkan tombol post-test

- `remedial_page.dart`: `_PostTestCta` aktif hanya jika materi ditandai
  dipelajari (`studied`) dan bank post-test tersedia (`count > 0`); selain itu
  tampil tombol nonaktif dengan keterangan gating.

### 8.4 Konsistensi akses profil

- `brand.dart`: `remediAppBar` bertambah parameter `profileLocked`; avatar
  menampilkan SnackBar "Profil tidak dapat diakses selama kuis berlangsung..."
  saat terkunci, selain itu membuka SettingsPage. `quiz_page.dart` mengunci
  profil selama kuis aktif; timer dan jawaban tidak terganggu.

### 8.5 Video masuk satu bagian rute belajar

- `diagnosis_result_page.dart`: kartu video terpisah (_VideoLessonCard) dan
  _StatsRow dihapus; hanya satu `_RouteCard` "Rute Belajar Lengkap" dengan item
  menuju halaman materi yang benar.
- Widget baru `video_lesson.dart`: `VideoLessonPlayer` (YouTube player plus
  deteksi video selesai) dan `NeoLessonShell`.

### 8.6 Penguncian rute berurutan

- `app_controller.dart`: helper `sessionFor`, `isPassed`, `isFinished`,
  `isRouteUnlocked`, `routeBlockerTitle` (post-test gagal berarti belum
  tuntas; sesi terbaru menimpa yang lama).
- `flows.dart`: `openRemedial` menegakkan kunci dari satu tempat (AlertDialog
  "Materi masih terkunci") sehingga seluruh jalur akses (rute hasil diagnosa,
  tab remedial, riwayat) memakai aturan yang sama.
- `remedial_tab_page.dart` dan `diagnosis_result_sections.dart`: status
  berlabel terkunci / belum dimulai / video selesai (menunggu post-test) /
  belum tuntas / tuntas.

### 8.7 Persentase penguasaan jelas

- Sumber persentase item rute: hasil post-test sesi terakhir saat lulus;
  jika belum, penguasaan awal diagnostik; jika kosong, "Belum dinilai".

### 8.8 Sederhanakan hasil diagnostik

- `diagnosis_result_page.dart` dan `diagnosis_result_sections.dart` ditulis
  ulang: `_ScoreCard` (skor 0-100, jumlah benar, chip kesimpulan), tombol
  pembahasan, `_ThetaNoteCard` (theta sebagai info tambahan), `_RootCauseCard`,
  `_RouteCard`, dan `_EncourageCard`. Duplikat kartu akurasi/skor dihapus.

### 8.9 Logout dan profil baru

- `settings_page.dart`: logout memanggil `resetAll()` lalu
  `Navigator.popUntil(r.isFirst)`; sebelumnya pushAndRemoveUntil ke
  OnboardingPage membuat rute onboarding duplikat dan perpindahan home
  membutuhkan refresh. Profil baru disimpan lewat `saveProfile` dan
  `notifyListeners`; `main.dart` langsung pindah ke RootShell tanpa refresh;
  test widget membuktikan Onboarding - Beranda tanpa perantara.

### 8.10 Audit tambahan alur dan data

- Penguncian dipindah ke `Flows.openRemedial` sebagai sumber tunggal,
  back stack aman dengan push biasa, timer tidak pernah direset saat kuis
  aktif, status video diambil dari state player (bukan asumsi pengguna),
  dan `learningPath` dipakai untuk seluruh perhitungan status.

### 8.11 Kriteria pengujian

- `flutter analyze`: No issues found.
- `flutter test`: 45 test lulus, termasuk empat berkas baru
  `diagnostic_score_test.dart`, `route_lock_test.dart`,
  `profile_reset_test.dart`, dan `quiz_validation_test.dart`.

### 8.12 Laporan akhir

- Laporan lengkap per tugas: `docs/project/LAPORAN-AUDIT.md` yang memuat
  daftar file diubah, akar penyebab, sebelum dan sesudah, aturan akhir,
  dan hasil test.

### Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 45/45 lulus |
| route_lock_test | 7 skenario status rute lulus |
| quiz_validation_test | tolak kumpul, timer habis, jawaban dipertahankan |
| profile_reset_test | profil baru ke Beranda tanpa refresh; logout ke Onboarding |
| diagnostic_score_test | skor 0-100 konsisten (2/15=13, 8/15=53, batas aman) |

---
