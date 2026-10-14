# HISTORY — Riwayat Perubahan

Format: entri terbaru di atas. Setiap entri menjelaskan apa yang berubah, kenapa,
dan apa yang diverifikasi.

---

## v2.4.1 - 2026-10-14 — README root: ringkasan, tangkapan layar, langkah menjalankan (TASK 6.1)

### Konteks

Menyesuaikan `README.md` root dengan struktur yang diminta dosen:
**Ringkasan aplikasi**, **Tangkapan layar antarmuka**, dan **Langkah
menjalankan proyek**.

### Yang berubah

- `screenshots/` dibuat (folder ter-commit) berisi 5 tangkapan layar yang
  sebelumnya hanya ada di `Save/ScreenShot/` (folder gitignored):
  `beranda.png`, `Diagnostik.png`, `Soal.png`, `Remedial.png`,
  `Progress.png`. File asli tetap di lokasi lama.
- `README.md` ditulis ulang dengan urutan bagian sesuai permintaan;
  bagian Fitur, Struktur, Dokumentasi, dan Catatan desain dipindahkan
  ke bawah. Lima gambar disusun di **satu tabel 2 kolom** agar ukuran
  tampilannya sama (semua PNG identik 800×1654; beda ukuran tampil
  murni karena tabel terpisah).
- Isi usang diperbaiki sekaligus: Fitur 5 tidak lagi menyebut video
  mikro-learning; pernyataan "butuh internet untuk YouTube" diganti
  jadi **100% offline**; baris soal `url_launcher` di Catatan desain dihapus.

### Dampak

`TASK.md` 6.1 → `✅` (Tahap 6 2/3), total `74/94`.

---

## v2.4.0 - 2026-10-14 — Lepas fitur video YouTube + FR-07 (TASK 4.30)

### Konteks

Keputusan produk (opsi B): fitur video penjelasan dilepas sepenuhnya.
Investigasi oEmbed menemukan dua video **404 mati** (`n_operasi_bilangan`,
`n_suku_sejenis`) dan satu **salah topik** (`n_tanda_negatif`), sehingga
tautan eksternal tidak layak dipertahankan. Aplikasi kini sepenuhnya offline.

### 1. Dependensi & komponen

- `url_launcher` dihapus dari `pubspec.yaml`.
- `lib/views/widgets/video_player_card.dart` (207 baris) dihapus; diganti
  `lib/views/widgets/concept_card.dart` (`ConceptCard`, 189 baris) — kartu
  dua lapis biru/kuning dengan badge `Dipahami`, glyph buku `menu_book`,
  tanpa `onTap`.
- `common.dart`: export `video_player_card.dart` → `concept_card.dart`.

### 2. Model & data

- `ConceptNode`: hapus `videoUrl`, `videoDurationLabel`, `videoDurationMinutes`,
  `instructor`, `instructorRole`. Field `videoTitle` → `lessonTitle`.
- `assets/data/knowledge_graph.json`: 6 simpul dibersihkan dari lima key
  video/pengajar; `videoTitle` → `lessonTitle`; dua `summary` di-reword tanpa
  kata "Video".

### 3. Penandaan konsep dipelajari (rename `watched` → `studied`)

- `app_controller.dart`: `watchedVideos` → `studiedNodes`, `isWatched` →
  `isStudied`, `markWatched` → `markStudied`.
- `app_constants.dart`: `keyWatchedVideos` → `keyStudiedNodes`, nilai
  `'remedimath.studied_nodes'` (key lama ter-reset, diterima).
- `local_storage_service.dart`: `loadWatched`/`saveWatched` →
  `loadStudied`/`saveStudied`.
- `remedial_page.dart`: tombol eksplisit `Tandai sudah dipelajari`;
  `_openVideo` dan `_CoachChip` dihapus.

### 4. Halaman lain yang ikut disesuaikan

- `dashboard_page.dart`: kartu rekomendasi pakai `lessonTitle` + jumlah poin
  kunci, ikon `menu_book`.
- `diagnosis_result_page.dart` + `diagnosis_result_sections.dart`: langkah
  rencana belajar `Pelajari konsep inti`; `_EncourageCard` tanpa durasi.
- `remedial_tab_page.dart`: meta node memakai jumlah poin kunci.
- `flows.dart`: dialog mengarahkan `Pelajari ulang konsep`.
- `test/irt_graph_test.dart`: konstruktor `ConceptNode` disesuaikan.

### 5. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus |
| `flutter build apk --debug` | sukses (`app-debug.apk`) |
| Sisa referensi video/instructor | hanya komentar historis di `concept_card.dart` |

Skor Tahap 4 menjadi 30/30; total `TASK.md` 73/94. Fitur FR-07 ditandai
dihapus di `PLANNING.md`.

---

## v2.3.0 - 2026-10-14 — Bersih-bersih: Alias `AppCard` dihapus + perbaikan build AGP

### Konteks

Tutup Tahap 4: sisa enam call site `AppCard` (bukan bagian grup 4.1–4.29)
dikonversi, lalu alias lama dihapus. Sekaligus mencatat perbaikan yang
sebelumnya belum terdokumentasi.

### 1. Enam call site terakhir `AppCard` → `NeoCard`

| Berkas | Jumlah |
|---|---|
| `progress_page.dart` | 3 |
| `diagnostic_page.dart` | 2 |
| `remedial_tab_page.dart` | 1 |

### 2. Alias dihapus

- `lib/views/widgets/app_card.dart` dihapus (`typedef AppCard = NeoCard`).
- `export 'app_card.dart'` dibuang dari `lib/views/widgets/common.dart`.
- `grep AppCard` di `lib/` dan `test/` bersih; `flutter analyze` tetap
  `No issues found!`.

### 3. Perbaikan build APK (belum pernah tercatat)

`flutter build apk --debug` gagal di JDK 21 sampai versi Android Gradle
Plugin dinaikkan di `android/settings.gradle:21`:

```
8.1.0  →  8.2.2
```

AGP < 8.2.1 memiliki bug pada Java 21. Setelah naik, build sukses
(`build/app/outputs/flutter-apk/app-debug.apk`, 86,6 MB). Dicatat juga di
`TASK.md` baris 5.4.

### 4. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus |
| Sisa referensi `AppCard` | tidak ada |

---

## v2.2.0 - 2026-10-14 — Tahap 4 (Grup 4): Redesign Remedial

### Konteks

Grup keempat—dan terakhir—Tahap 4: **Remedial** (4.23–4.29).
`remedial_page.dart` ditulis ulang mengikuti `UI-REFERENCE.md` §4.4. Halaman
tetap satu berkas di bawah 500 baris sehingga tidak perlu dipecah dengan
`part`.

### 1. Struktur baru (§4.4)

| Bagian | Implementasi |
|---|---|
| item 1 | `_StepHeading`: `EyebrowLabel` `Langkah N dari M · Penguatan konsep`, judul `n.shortTitle` bertitik pink `.`, sub `Materi perbaikan · <topik>` 15 w700 |
| item 2 | `VideoPlayerCard` biru (tidak berubah) — rangka kuning, pill `RemedyMath · Mikro-Belajar`, rumus, tombol play |
| item 3 kiri | `_MisconceptionCard` putih: eyebrow pink `Analisis miskonsepsi`, judul `n.videoTitle` 19 w900, ringkasan 15 w500 `height 1.74`, `_CoachChip` biru (`n.instructor · n.instructorRole · n.videoDurationLabel`), tombol `Buka di YouTube` |
| item 3 kanan | `KeyPointList` hijau (tanpa `Pill` trailing) |
| item 4 | `_PostTestCta` pink: judul `Siap uji pemahaman?` 19, deskripsi 15, tombol putih `Mulai post-test` |
| item 5 | `_IrtNote` — catatan `trending_up` di bawah CTA |
| item 6 | Tautan `Lihat kembali hasil diagnosis` 15 w900 bergaris bawah → `DiagnosisResultPage` |
| item 7 | Footer tidak dipasang — §8 |

Kolom item 3 kiri/kanan desain ditumpuk vertikal agar tidak sesak di ponsel.

### 2. Yang dihapus / diubah dari versi lama

- Judul `Materi Perbaikan: <shortTitle>` diganti `_StepHeading` §4.4 item 1
  (judul bertitik pink + sub materi + eyebrow langkah).
- Kartu analisis miskonsepsi lama (pill `Analisis Miskonsepsi`, prioritas
  remedial, `CircleAvatar` pengajar) diganti judul video + ringkasan +
  `_CoachChip` biru sesuai §4.4 item 3.
- Satu call site `AppCard` → `NeoCard`.
- Indentasi rusak di sekitar baris 140–145 versi lama hilang karena berkas
  ditulis ulang.

### 3. Fitur lama yang dipertahankan (§7)

- Membuka video di YouTube (`launchUrl`, `externalApplication`).
- Tombol `Saya sudah menonton video ini` (`markWatched`).
- Penandaan ditonton hanya bila video benar-benar terbuka (menutup item
  `TODO.md` "Perbaiki penandaan video yang terlalu optimistis").
- Catatan IRT dan gate post-test.

### 4. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus (14 NeoCard + 3 IRT + 9 contrast) |

---

## v2.1.0 - 2026-10-14 — Tahap 4 (Grup 3): Redesign Hasil Diagnosis

### Konteks

Grup ketiga Tahap 4: **Hasil Diagnosis** (4.16–4.22).
`diagnosis_result_page.dart` ditulis ulang mengikuti `UI-REFERENCE.md`
§4.3. Karena seluruh seksi desain ditambah, hasilnya melewati batas 500
baris sehingga seksi berat dipisah ke berkas `part`.

### 1. Berkas dipecah dua (§5)

| Berkas | Isi | Baris |
|---|---|---|
| `diagnosis_result_page.dart` | `DiagnosisResultPage`, `_Heading`, `_ThetaCard`, `_StatusChip` | 217 |
| `diagnosis_result_sections.dart` | `part of` — `_StatsRow`, `_RootCauseCard`, `_PatternPanel`, `_StudyPlanCard`, `_StepTile`, `_RouteCard`, `_EncourageCard` | 357 |

`part` dipakai supaya kelas privat tetap privat tapi tiap berkas di bawah
500 baris.

### 2. Struktur baru (§4.3)

| Bagian | Implementasi |
|---|---|
| item 1–2 | `EyebrowLabel` + judul `Peta kemampuanmu.` (pink `!`) |
| item 3 | `_ThetaCard` biru: chip status pink/hijau 11 w900, `Skor kemampuan (θ)` 22 w900, topik + jumlah soal, θ `displayNum` 40 rata kanan, `levelLabel`, `NeoProgressBar` tinggi 20, label skala `Perlu pendampingan`/`Mandiri` 11 w900 |
| item 4 | `_StatsRow` tiga `StatCard` kuning/pink/hijau, angka `statValue` 24, label `labelMd` 14 |
| item 5 | `_RootCauseCard`: `SectionTitle` 19, callout kuning `KONSEP SPESIFIK` + teks 19, sub-judul 17, paragraf 15, panel `Pola keliru` pink / `Solusi tepat` hijau tanpa bayangan |
| item 6 | `_StudyPlanCard` kuning: `SectionTitle` 19, dua `_StepTile` putih tanpa bayangan (`LANGKAH 01/02`), CTA `Mulai belajar` putih |
| item 7 | Footer tidak dipasang — §8 |

### 3. Yang dihapus / diubah dari versi lama

- Kartu pembuka "HASIL ANALISIS DIAGNOSTIK" + pill "Metode IRT" diganti
  eyebrow + judul §4.3 item 1–2.
- Tombol "Tonton Video Penjelasan" dihapus — aksinya sama dengan CTA
  `Mulai belajar` (§4.3 item 6) dan langkah 1.
- Label skala tengah "Batas tuntas (θ ≥ …)" dihapus; §4.3 item 3 hanya
  menyebut dua label (`Perlu pendampingan`/`Mandiri`). Status tuntas tetap
  terbaca dari chip "Tuntas".
- Warna panel pola diperbaiki: solusi tepat kini hijau (dulu putih),
  sesuai §4.3 item 5.
- Enam call site `AppCard` → `NeoCard`.

### 4. Fitur lama yang dipertahankan (§7)

- Rute belajar lengkap (`_RouteCard`).
- Kartu penguatan "Normal & wajar!" (`_EncourageCard`).
- Tombol menuju halaman pembahasan (`review_page.dart`).

### 5. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus (14 NeoCard + 3 IRT + 9 contrast) |
| Batas file | 217 + 357 baris (< 500) |

---

## v2.0.0 - 2026-10-14 — Tahap 4 (Grup 2): Redesign Kuis

### Konteks

Grup kedua Tahap 4: **Kuis** (4.9–4.15). `quiz_page.dart` ditulis ulang
mengikuti `UI-REFERENCE.md` §4.2. Dua perubahan widget pendukung:
`HintBox` baru dibuat dan `MathBox` disesuaikan ke spesifikasi §4.2 item 3.

### 1. `hint_box.dart` — widget baru

Panel petunjuk §4.2 item 4: bg `#A3F3B6`, radius 10, border 3 px,
**tanpa bayangan**, padding 16, ikon 22 px, teks 14 w700. Dipisah sebagai
widget karena dipakai lintas halaman (kuis, dan nanti review). Diekspor
lewat `common.dart`.

### 2. `math_box.dart` — disesuaikan §4.2 item 3

Dari kartu putih tanpa border menjadi bg `#E2F16D`, radius 10, border 3 px,
bayangan `Offset(4, 4)`, teks `mathFormula` (26 w700) di tengah.

### 3. `quiz_page.dart` ditulis ulang (380 → 478 baris)

Mengikuti §4.2. Widget privat baru: `_QuizHeading`, `_TimerChip`,
`_ProgressCard`, `_QuestionCard`, `_FooterPanel`, `_QuestionNavigator`.

| Bagian | Implementasi |
|---|---|
| 4.2 item 1 | `EyebrowLabel` topik + judul `displayLg` bertitik pink + `_TimerChip` hijau (pink saat ≤ 1 menit) |
| 4.2 item 2 | `_ProgressCard` biru: "Soal X dari N" + persen + `NeoProgressBar` |
| 4.2 item 3 | `_QuestionCard` putih: `EyebrowLabel` kategori + stem `titleLg` + `MathBox` + tombol `Coretan` |
| 4.2 item 4 | `HintBox` hijau (bila `showHints` dan hint terisi) |
| 4.2 item 5 | `AnswerOption` per opsi |
| 4.2 item 6 | `_FooterPanel`: caption + `NeoButton` `Soal berikutnya`/`Selesai` + ragu-ragu + `Soal sebelumnya` |
| — Navigator | `_QuestionNavigator` dalam `NeoCard` (fitur lama dipertahankan) |

Empat call site `AppCard` → `NeoCard`.

### 4. Keputusan sadar

- Tombol `Soal berikutnya` **tetap aktif** walau belum ada jawaban terpilih,
  supaya soal boleh dilewati (perilaku lama). Mockup §4.2 item 6 hanya
  memperlihatkan state nonaktif, bukan aturan wajib menjawab.
- Keluar dari tes lewat tombol kembali AppBar (`remediAppBar(..., showBack:
  true)`) + `PopScope`; tombol tutup di dalam kartu dihapus agar tidak
  duplikat. `Navigator.maybePop` menghormati `PopScope.canPop = false`
  sehingga dialog konfirmasi tetap muncul.
- `Pill` timer lama (kuning) diganti `_TimerChip` hijau agar sesuai §4.2,
  tapi `Pill` tetap dipakai di AppBar.
- Label `q.moduleLabel` yang lama tidak dipasang; §4.2 item 6 hanya
  menyebut caption dan tombol.

### 5. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus (14 NeoCard + 3 IRT + 9 contrast) |
| Batas file | `quiz_page.dart` 478 baris (< 500) |

---

## v1.9.0 - 2026-10-14 — Tahap 4 (Grup 1): Redesign Beranda

### Konteks

Tahap 4 (Redesign Halaman) dimulai dari grup pertama: **Beranda**
(4.1–4.8). `dashboard_page.dart` ditulis ulang mengikuti
`UI-REFERENCE.md` §4.1 dengan token neobrutalism yang sudah dibangun di
Tahap 3. Satu perubahan kecil dibutuhkan di `section_title.dart`.

### 1. `section_title.dart` — parameter `style`

`SectionTitle` mendapat parameter opsional `style` (default
`AppTextStyles.titleLg` 22 w900). Judul bagian "Riwayat belajar" di
Beranda memakai `titleMd` (19 w900) sesuai §4.1 item 6, bukan 22.

### 2. `dashboard_page.dart` ditulis ulang (408 → 496 baris)

Struktur baru: `Column[AppHeader, Expanded(SafeArea(top:false, ListView))]`.
`AppHeader` bukan `PreferredSizeWidget`, jadi header tetap di atas lalu
konten bergulir di bawahnya.

| Bagian | Implementasi |
|---|---|
| 4.1 Header | `AppHeader` (identitas: logo, wordmark, badge kelas, avatar) |
| 4.2 Hero | `EyebrowLabel` + sapaan `Text.rich` (tanda `!` pink) + deskripsi `bodyLg` + `NeoButton` kuning |
| 4.3 Kartu IRT biru | `NeoCard(accentBlue)`: `displayNum` θ + `/ 3.00 θ`, `irt.proficiencyLabel`, `NeoProgressBar`, caption persentil, `_RootCauseCallout` putih |
| 4.4 Diagnosis adaptif | `NeoCard(accentYellow)`: judul, deskripsi, meta jam+checklist, `NeoButton` putih |
| — Rekomendasi | `_RecommendationCard` (fitur lama dipertahankan, distyle ulang) |
| 4.5 Tiga stat | `StatCard` hijau/pink/putih |
| 4.6–4.7 Riwayat | `SectionTitle(titleMd)` + trailing `Lihat hasil →` underline + `SessionTile` |
| 4.8 Footer | **Tidak dipasang** — §8 memutuskan footer dihapus di mobile |

Widget privat: `_Hero`, `_MetricCard`, `_RootCauseCallout`, `_DiagnosticCta`,
`_Meta`, `_RecommendationCard`, `_StatsRow`, `_HistorySection`.

### 3. Yang dihapus / diubah dari versi lama

- Kartu kutipan lama dihapus — §7 menyebutnya satu-satunya elemen yang boleh dibuang.
- `Wrap` pill kelas/semester dan baris sapaan duplikat diganti struktur hero baru.
- Progres kelas memakai `irt.classPercentile(theta)` (0..1) untuk `NeoProgressBar`.
- Label skala "Perlu pendampingan" tetap sebagai endpoint statis.

### 4. Keputusan sadar

- Tanda seru pink pada sapaan adalah logotype, sama seperti titik pink
  wordmark. `test/contrast_test.dart` hanya memeriksa token
  `AppTextStyles`, bukan `TextStyle` inline, jadi keputusan ini tidak
  menggagalkan test.
- Tiga kartu riwayat desain direflow jadi satu kolom; pada 360 dp tiga
  kartu sebaris tidak muat (`AGENTS.md` §2).
- `_RootCauseCallout` tetap berbayang (default `NeoCard`), mengikuti
  §5.3 "semua kartu berbayangan".

### 5. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus (14 NeoCard + 3 IRT + 9 contrast) |
| Batas file | `dashboard_page.dart` 496 baris (< 500) |

---

## v1.8.0 - 2026-10-05 — Tahap 3 Selesai: 9 Komponen Neobrutalism + Integrasi

### Konteks

Tahap 3 (Komponen Dasar) dimulai setelah 3.1 (`common.dart` dipecah) dan 3.2
(`NeoCard`). Sembilan komponen neobrutalism baru dibangun, diintegrasikan ke
halaman yang relevan, dan dua berkas legacy (`StatTile`, `ThetaScale`)
dihapus. Semua keputusan Design Audit §6 dan §11 sudah diputuskan dan
diimplementasikan.

### 1. Sembilan komponen baru

| Berkas | Baris | Deskripsi |
|---|---|---|
| `neo_button.dart` | 140 | Tombol utama: min-height 48, press-shadow, disabled opacity 0.5 (bayangan tetap). Dipakai di kuis, dashboard, diagnosis, remedial, onboarding. |
| `eyebrow_label.dart` | 73 | Label kecil uppercase (`labelMd` 14 w700). Dipakai di `remedial_page.dart`. |
| `neo_progress_bar.dart` | 84 | Track border 3 + fill border 3 + inset 3. Ganti `ThetaScale` + 3 `LinearProgressIndicator`. |
| `stat_card.dart` | 97 | Angka 28/24, label `labelSm` 13. Ganti `StatTile` di dashboard + diagnostik. |
| `answer_option.dart` | 145 | Opsi kuis: terpilih = border/badge `accentBlue` + radio terisi `ink` + teks w900. Ganti `_OptionTile`. |
| `app_bottom_nav.dart` | 164 | Pill `radiusPill`, label w700, bg `accentYellow` + border 3 aktif. Ganti `NavigationBar`. |
| `app_header.dart` | 138 | Identitas: logo 40×40 kuning+border, wordmark `RemedyMath.` + pink dot, badge kelas, avatar pink 36. |
| `video_player_card.dart` | 207 | Outer biru + inner kuning 16:9. Pink pill `RemedyMath · Mikro-Belajar` radius 8 border 2. Hint default `Buka di YouTube`. Seluruh kartu `onTap`. Ganti `_VideoCard`. |
| `key_point_list.dart` | 106 | Hijau luar + putih dalam. Ganti loop manual di `remedial_page.dart`. |

Total 1.158 baris baru, rata-rata 129 baris/komponen — jauh di bawah batas 500.

### 2. Integrasi ke halaman

| Halaman | Komponen yang dipakai |
|---|---|
| `root_shell.dart` | `AppBottomNav` (ganti `NavigationBar`) |
| `quiz_page.dart` | `NeoProgressBar`, `AnswerOption`, `EyebrowLabel`, `NeoButton` (ganti `_OptionTile`, `FilledButton`) |
| `remedial_page.dart` | `VideoPlayerCard`, `KeyPointList`, `NeoButton` (post-test), `EyebrowLabel`, `_openVideo` fix |
| `diagnosis_result_page.dart` | `NeoProgressBar` (ganti `ThetaScale` + `_ThetaBar` privat), `NeoButton` ×2 |
| `progress_page.dart` | `NeoProgressBar` (ganti `LinearProgressIndicator` mastery + history) |
| `dashboard_page.dart` | `StatCard` ×3, `NeoButton` (hero CTA) |
| `diagnostic_page.dart` | `StatCard` ×3, `NeoButton` (mulai tes) |
| `remedial_tab_page.dart` | `NeoProgressBar` (mastery), `NeoButton` (empty state action) |
| `onboarding_page.dart` | `NeoButton` (mulai belajar) |

### 3. Legacy dihapus

| Berkas | Alasan |
|---|---|
| `theta_scale.dart` | Tidak ada call site nyata; bar kemampuan theta pakai `NeoProgressBar` |
| `stat_tile.dart` | Semua 6 call site bermigrasi ke `StatCard` |
| `analytics_widgets.dart` | Export `ThetaScale` dihapus, hanya `SessionTile` tersisa |

### 4. Keputusan Design Audit & Wordmark diimplementasikan

| Keputusan | Implementasi |
|---|---|
| §6.1 `--primary` = `#E2F16D` | `app_colors.dart` |
| §6.2 Border = 3 | `AppSizes.borderThick` |
| §6.3 Shadow = `Offset(4,4)` | `AppSizes.shadowCard` |
| §6.4 `AppHeader` identitas + nav tetapkan | `app_header.dart`, `AppBottomNav` |
| §6.5 Titik pink wordmark | `AppHeader` + `AppLogo` via `Text.rich` |
| §6.6 `radioBorder` pertahankan | `app_colors.dart` tidak berubah |
| §11 Ejaan `RemedyMath` | Wordmark `RemedyMath.` + pink dot, `AppLogo` glyph `Σ` kuning |

### 5. Perbaikan logika

- `_openVideo` di `remedial_page.dart`: `markWatched` **hanya** kalau `launchUrl` sukses. Kalau gagal, hanya SnackBar.
- `NeoButton` disabled: opacity 0.5, **bayangan tetap** (ikuti desain `Opacity(0.50)` wrapper).
- `AppBottomNav` active label w700 (bukan w900), pill `radiusPill` (bukan `radiusCard`).
- `VideoPlayerCard` hint default `Buka di YouTube`, pink pill atas, seluruh kartu target sentuh.

### 6. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 26/26 lulus (14 NeoCard + 3 IRT + 9 contrast) |
| `dart format --set-exit-if-changed` | clean (46 file diformat) |
| Ukuran file < 500 baris | Ya, terbesar `diagnosis_result_page.dart` 481 |
| Encoding scan (`U+FFFD`, CJK, Cyrillic, fullwidth) | 0 hit di `lib/` & `docs/` |
| `flutter build apk --debug` | Akan dijalankan di Tahap 5 |

Tidak ada dependensi baru.

---

### Konteks

Tahap 3 dimulai setelah 3.1. `NeoCard` adalah kartu dasar neobrutalism dan
dipakai 28 call site, jadi kontraknya jadi terlalu panjang kalau rapuh.

### 1. Temuan: border per sisi tidak pernah bisa dirender

Unit test pertama untuk `NeoCard` gagal dengan assertion Flutter:

```text
A borderRadius can only be given on borders with uniform colors.
```

Penyebabnya bukan `NeoCard`. `AppCard` lama punya parameter `border` berupa
`BoxBorder` mentah, dan tiga pemanggilnya memakai warna berbeda per sisi:

| Call site | Border lama |
|---|---|
| `diagnosis_result_page.dart:260` | atas pink, tiga sisi lain tinta |
| `review_page.dart:38` | kiri hijau atau pink, tiga sisi lain tinta |
| `quiz_page.dart:413` | `Border.all` biru kalau terpilih |

Flutter melarang `borderRadius` bukan nol pada `Border` yang warna sisinya
berbeda. Karena `AppCard` selalu memasang `borderRadius: 10`, ketiga kartu itu
melempar saat `paint()`. Ini sudah rusak sebelum 3.2 dan tidak ketahuan karena
aplikasi belum pernah diverifikasi visual sejak redesign — build web terakhir
 masih bertanggal 29 Sep 2026, sebelum neobrutalism.

`quiz_page.dart` termasuk aman karena `Border.all` menghasilkan border
seragam, jadi tidak melanggar aturan itu.

### 2. Stripes per sisi tidak ada di desain

Dicheck langsung ke `UI-REFERENCE.md` §4.1 sampai §4.4: tidak satu pun kartu
didesain dengan stripe per sisi. Semuanya ditulis "radius 10, border 3 px"
seragam. Satu-satunya border tak seragam di referensi adalah Header
(bawah dan samping) dan itu memang tanpa radius.

Artinya stripe itu karangan implementasi sebelumnya, bukan spesifikasi. Jadi
`NeoAccent` yang sempat dirancang untuk memodelkannya dibuang, diganti satu
parameter `borderColor` yang selalu seragam.

Dua kartu yang tadinya stripe satu sisi sekarang memakai border seragam
warna yang sama. Warnanya tidak berubah, hanya sisi yang berubah. Keduanya
termasuk halaman yang akan ditulis ulang di Tahap 4 (4.9-4.15 dan
4.16-4.22).

### 3. `NeoCard`

Berkas `neo_card.dart`, 77 baris.

| Parameter | Bawaan | Alasan |
|---|---|---|
| `child` | wajib | isi kartu |
| `color` | `AppColors.surface` | semua kartu putih kecuali yang berwarna aksen |
| `padding` | `EdgeInsets.all(spaceLg)` | 16 px, dipakai kartu sedang |
| `onTap` | `null` | opsional; tanpa ini tidak ada clip dan tidak ada ripple |
| `borderColor` | `AppColors.ink` | tinta default, aksen hanya untuk state terpilih |
| `elevated` | `true` | referensi punya panel "tanpa bayangan" |

`elevated` bukan tambahan spekulatif. `UI-REFERENCE.md` §4.2 L193 dan §4.3
L249 menyebut dua panel tanpa bayangan, jadi tanpa parameter ini dua panel
itu tidak bisa dibuat sesuai desain.

Struktur `DecoratedBox` di luar `Material` di dalam dipertahankan dari 3A.6.
Kalau `Material` yang memegang clip membungkus `boxShadow`, bayangan terpotong
persis di sisi yang di-clip.

### 4. `AppCard` jadi alias

```dart
typedef AppCard = NeoCard;
```

25 call site di delapan halaman tidak ikut tersentuh. Alias ini dihapus
bersama pemakaian terakhirnya di Tahap 4. `EmptyState` dan `SessionTile` sudah
dipakai ke `NeoCard` karena keduanya bagian dari paket widget, bukan halaman.

Tiga call site yang memakai `border` dikonversi ke `borderColor`, dan import
`app_sizes.dart` yang jadi tidak terpakai dihapus dari ketiganya.

### 5. Dead code yang ikut dibersihkan

`quiz_page.dart:415` menulis:

```dart
color: selected ? AppColors.surface : AppColors.surface,
```

Kedua cabang bernilai sama, jadi `selected` tidak pernah mengubah apa pun.
Diganti `color: AppColors.surface`. State terpilih tetap terlihat lewat
`borderColor`.

### 6. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | `All tests passed!` 26 dari 26, naik 14 dari 12 |
| Test `NeoCard` baru | 14 test |
| Bukti test bukan kosong | border per sisi sengaja dimunculkan lagi, 4 test gagal, lalu dipulihkan |
| Ukuran `neo_card.dart` | 77 baris, di bawah 200 |

Dua belas test baru itu dibagi dua kelompok. `borderFor` diuji langsung
sebagai fungsi murni: warna default, warna kustom, dan syarat `isUniform`
untuk kelima warna palet. Sisanya menguji widget: radius, bayangan,
penghapusan bayangan saat `elevated` false, warna latar, `borderColor`,
padding bawaan, `onTap`, dan keadaan tanpa `onTap`. Satu di antaranya adalah
regression test yang memanggil `tester.takeException()`, jadi assertion
`borderRadius` langsung terdeteksi kalau aturan seragam suatu hari dilanggar
lagi.

Tidak ada dependensi baru.

---

## v1.6.0 - 2026-10-04 — Tahap 3 Task 3.1: Pemecahan `common.dart`

### Konteks

Tahap 2 Part 3 selesai, jadi Tahap 3 dimulai. Urutan kerjanya: `3.1` lebih
dulu dari `3.2`–`3.11`, bukan sesudahnya. Alasannya ada di ukuran berkas,
bukan di nomor task.

`AGENTS.md` §3 mewajibkan tiap komponen reusable punya berkas sendiri, dan
§5 membatasi 500 baris. Kalau 10 komponen neobrutalism baru langsung
dituangkan ke `common.dart`, berkas itu pasti meluap. `TASK.md` sendiri
menaruh 3.1 di baris pertama antrean dengan catatan "setelah komponen baru
masuk", yang kalau dibaca sebagai urutan tambahan justru memperburuk.

### 1. Angka awal yang salah

`TASK.md` mencatat `common.dart` 312 baris dan `analytics_widgets.dart` 209.
Keduanya salah. Angka sebenarnya:

| Berkas | Tercatat | Sebenarnya |
|---|---|---|
| `common.dart` | 312 | 349 |
| `analytics_widgets.dart` | 209 | 216 |

Keduanya sudah di bawah 500 (§5 aman), tapi keduanya juga di atas 200, jadi
kriteria "tiap berkas di bawah 200 baris" tetap gagal.

### 2. Dua berkas dipecah jadi sembilan

| Berkas baru | Isi | Baris |
|---|---|---|
| `app_card.dart` | `AppCard` | 78 |
| `brand.dart` | `AppLogo`, `ProfileAvatar`, `remediAppBar` | 85 |
| `empty_state.dart` | `EmptyState` | 40 |
| `math_box.dart` | `MathBox` | 29 |
| `pill.dart` | `Pill` | 55 |
| `section_title.dart` | `SectionTitle` | 33 |
| `session_tile.dart` | `SessionTile` | 113 |
| `stat_tile.dart` | `StatTile` | 63 |
| `theta_scale.dart` | `ThetaScale` | 112 |

Berkas terbesar sekarang `session_tile.dart` 113 baris, jauh di bawah batas
200. `analytics_widgets.dart` ikut dipecah karena 216 baris, bukan hanya
`common.dart`.

### 3. Dua barrel, nol call site tersentuh

Sembilan halaman mengimpor `widgets/common.dart` dan memakai sepuluh simbol
dari sana. Memecah tanpa barrel berarti menyentuh sembilan file halaman
tanpa alasan. Solusinya: `common.dart` dan `analytics_widgets.dart` jadi
barrel `export` saja, jadi identitas "satu import" tetap utuh.

Perubahan ini murni struktural. Tidak ada satu pun `build` method, parameter,
atau nilai token yang berubah.

### 4. `stripeOverInk` jadi private

Fungsi ini hanya dipakai di dalam `common.dart` (dipanggil `AppCard` pada
satu tempat), tapi ditulis tanpa underscore sehingga terekspos sebagai API
publik. Sekarang `_stripeOverInk`. Karena dipindah ke `app_card.dart`,
underscore-nya otomatis menutup akses dari luar berkas.

### 5. Dua angka hardcoded yang belum diganti token

Dua angka hardcoded berikut berada di luar batas 3.1, jadi tidak dikerjakan.
Dicatat untuk 3.5:

- `theta_scale.dart` masih memakai `width: 2` untuk garis penanda dan
  `width: 3` untuk cincin knob. `borderThick` bernilai 2 dan `borderMedium`
  bernilai 3, jadi keduanya punya token yang tepat.
- `theta_scale.dart` masih memakai `BorderRadius.circular(999)` untuk track.
  `radiusPill` sudah ada dan dipakai `Pill`.

Keduanya baru diganti saat `ThetaScale` digantikan `NeoProgressBar` (3.5),
supaya tidak ada dua kali sentuh pada berkas yang sama.

### 6. Ditemukan, belum diputuskan

Nama aplikasi masih hardcoded sebagai literal `'RemedyMath'` di
`brand.dart:60`. Ini satu-satunya sumber kode untuk nama itu, sementara
`UI-REFERENCE.md` dan `AGENTS.md` menulis `RemediMath` (lihat
`DESIGN-AUDIT.md` §11). Literal ini ikut pindah ke `brand.dart` tanpa
diubah — pemecahan berkas bukan tempat memutuskan ejaan. Wordmark akan
dibangun di 3.9, jadi di situ ejaan cukup diputuskan sekali.

### 7. Verifikasi

| Yang dicek | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` (2.6 d) |
| `flutter test` | `All tests passed!` 12 dari 12 |
| Ukuran berkas `lib/views/widgets/` | 11 berkas, terbesar 113 baris |
| Scan `U+FFFD` / CJK / Cyrillic | bersih di 11 berkas |

Non-ASCII yang tersisa di `lib/views/widgets/` semuanya disengaja:
`U+03A3` (`Σ` pada `AppLogo`), `U+03B8` (`θ` pada `ThetaScale`), `U+2265`
(`≥`), `U+2022` (bullet pemisah), `U+2014` (em dash), `U+00A7` (`§`).

### Catatan

`HISTORY.md` versi ini tidak menambah dependensi apa pun.

---

## v1.5.0 - 2026-10-04 — Design Audit 3A: Palet, Kartu, Shadow, Kontras

### Konteks

Audit 93 task di `TASK.md` terhadap kode aktual menemukan dua masalah.
Status 3A.2 sudah ditandai selesai padahal belum tuntas, dan 3A.4 s.d.
3A.9 belum dijalankan sama sekali. Palet neobrutalism masih warna lama
`#FDE300` dan `#070707`, dan tidak satu pun `BoxDecoration` punya
`shadows:`.

### 1. Palet 3A.4 diterapkan

Enam token berubah di `lib/core/app_colors.dart`:

| Token | Lama | Baru |
|---|---|---|
| `background` | `#F7F2EA` | `#F6F5F1` |
| `ink` | `#070707` | `#1A1A1A` |
| `accentYellow` | `#FDE300` | `#E2F16D` |
| `accentBlue` | `#69A9FE` | `#70B2FF` |
| `accentPink` | `#F77ACF` | `#FF69B4` |
| `accentGreen` | `#00E990` | `#A3F3B6` |

`surface` (`#FFFFFF`) dan `radioBorder` (`#767676`) sudah sesuai
spesifikasi, jadi tidak disentuh.

### 2. 3A.2: temuan sebenarnya lebih besar dari yang tercatat

Audit awal mencatat `copyWith(color: AppColors.accent*)` = 0 hit dan
menandai 3A.2 selesai. Angka itu benar, tapi kelengkapannya salah.
`copyWith` bukan satu-satunya cara warna aksen masuk ke teks. Pola
ternary seperti `AppColors.ink : AppColors.accentPink` lolos dari
pencarian pola.

Lima situs tambahan ditemukan dan diperbaiki:

| Berkas | Yang salah |
|---|---|
| `diagnosis_result_page.dart` | Nilai `_stat` dan label pola |
| `review_page.dart` | Warna jawaban |
| `analytics_widgets.dart` | `scoreColor` post-test |
| `flows.dart` | Skor sesi |

Sekarang tidak ada warna aksen yang dipakai sebagai warna teks. Di
lokasi mana pun penanda aksen tetap ada, tapi lewat ikon atau `Pill`
berwarna latar.

### 3. AppCard dirombak (3A.5, 3A.6)

`AppCard` sebelumnya memasang `clipBehavior: Clip.antiAlias` langsung di
`Material`. Begitu `shadows:` ditambahkan, bayangan terpotong seluruhnya.
Struktur barunya:

```text
DecoratedBox          ← border + bayangan, tanpa clip
  └─ Material         ← ripple, clip hanya saat onTap != null
      └─ InkWell
```

`clipBehavior` yang selalu aktif dihapus. Ripple tetap terkopotong saat
kartu ditekan, bayangan tetap utuh saat tidak.

Semua 26 call site sekarang punya border tinta `AppSizes.borderThick`
dan `AppSizes.shadowCard` sebagai bawaan. Corak aksen digabung lewat
`stripeOverInk()` dan tidak menimpa seluruh border.

### 4. Token border, radius, dan shadow dirapikan

| Task | Perubahan |
|---|---|
| 3A.7 | 4 lebar border liar diganti token: 5 dan 4 menjadi `borderThick`, 1.5 menjadi `borderThick`, 1.4 menjadi `borderThin` |
| 3A.8 | 4 radius di `common.dart` diganti `radiusCard`, `radiusChip`, dan `radiusPill` |
| 2P.10 | `AppSizes.shadowCard` dipakai di 8 permukaan elevated |

### 5. Fungsi kontras ditambahkan (3A.9)

`test/contrast_test.dart` berisi `relativeLuminance()` dan
`contrastRatio()` rumus WCAG 2.1, ditambah 9 test.

Test ini langsung menangkap bug di helper-nya sendiri: `Color.r` di
Flutter 3.27 mengembalikan `double` 0.0 sampai 1.0, bukan `int` 0 sampai
255. Versi pertama salah menerima `int`, membandingkan tinta dengan
latar hitam, dan gagal di angka 1.01.

### Angka terverifikasi

| Pasangan | Rasio | Status |
|---|---|---|
| `ink` di atas `surface` | 17.40 | AAA |
| `ink` di atas `background` | 15.95 | AAA |
| `ink` di atas `accentYellow` | 14.12 | AAA |
| `ink` di atas `accentGreen` | 13.30 | AAA |
| `ink` di atas `accentBlue` | 7.87 | AA |
| `ink` di atas `accentPink` | 6.57 | AA |
| `ink` di atas `radioBorder` | 3.83 | AA batas bentuk, bukan teks |

Aksen terhadap `background` semuanya di bawah 3.0, yaitu 1.13, 1.20,
2.03, dan 2.43, sehingga tidak aman sebagai teks. Inilah yang mengunci
3A.2 secara otomatis.

### Verifikasi

| Yang dijalankan | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `flutter test` | 12/12 lulus |
| Pencarian `copyWith(color: AppColors.accent*)` | 0 hit |
| Pencarian simbol terlarang di dokumen | 0 hit |
| Pemeriksaan `U+FFFD` dan karakter CJK | 0 hit |

### Yang belum diverifikasi

Perhitungan kontras benar secara aritmetika, tapi belum membuktikan
tampilan nyata. Belum ada `layout_test.dart`, belum ada
`flutter build apk --debug`, dan belum ada pemeriksaan visual di
perangkat. Kecepatan menggambar 26 kartu berbayang di perangkat
entry-level juga belum diukur.

### 6. Keputusan 3A.1 diambil atas nama pengguna

Pengguna menugaskan keputusan diambil sendiri. Enam pertanyaan terbuka di
`DESIGN-AUDIT.md` §6 ditutup, dan hanya dokumentasi yang berubah — tidak
ada satu baris `lib/` pun yang disentuh.

**§6.4a Bentuk `AppHeader`.** Header hanya memuat identitas: logo,
wordmark, badge kelas, avatar. Empat nav pill tidak masuk ke header karena
butuh sekitar 630 dp dan tidak muat di 360 dp. Semua nilai punya token
yang sudah ada, jadi tidak ada token baru.

**§6.4b Daftar navigasi.** Desain menyebut `Beranda`, `Diagnostik`,
`Hasil`, `Remedial`. Kode punya `Beranda`, `Diagnostik`, `Remedial`,
`Progres`. Diputuskan mempertahankan yang di kode, dengan tiga alasan
yang bisa diuji:

1. `DiagnosisResultPage` hanya dicapai lewat `Navigator.push` di tiga
   tempat dan tidak pernah masuk daftar `pages` di `RootShell`, jadi
   `Hasil` bukan tujuan persisten.
2. `ProgressPage` justru tujuan persisten dan sudah terhubung.
3. Referensi desain bersifat desktop-first. Footer bar sudah dibuang
   karena alasan yang sama.

**§6.5 Titik pink.** Dipakai. Pink adalah satu-satunya warna yang oleh
spesifikasi dicadangkan untuk brand mark. Kontrasnya hanya 2.43, dan itu
aman karena WCAG 1.4.3 mengecualikan logotype.

Konsekuensi yang langsung ditulis: `DESIGN-AUDIT.md` §10.2 sekarang
memuat pengecualian logotype secara eksplisit. Tanpa itu, aturan "aksen
tidak boleh jadi warna teks" akan bertentangan dengan keputusan §6.5
saat Tahap 3 membangun wordmark.

**Temuan yang tidak diputuskan.** Ejaan nama wordmark berbeda antara
sumber: `UI-REFERENCE.md` dan `AGENTS.md` menulis `RemediMath`, sedangkan
kode dan nama folder menulis `RemedyMath`. Bukan salah satu dari enam
pertanyaan, jadi dicatat di `DESIGN-AUDIT.md` §11 dan tidak ditebak.
Menebaknya berarti memilih nama aplikasi.

### Status

Tahap 2 Part 3 **9 dari 9**. `TASK.md`total 30 dari 93. Tidak ada
keputusan produk terbuka dari §6.

Yang tersisa bukan keputusan, melainkan implementasi `AppHeader` dan
titik pink — keduanya milik Tahap 3 dan sudah punya spesifikasi lengkap.
Tidak ada perubahan kode pada entri ini, jadi `flutter analyze` dan
`flutter test` tidak perlu dijalankan ulang; hasilnya tetap seperti
diposisi di atas.

---

## v1.4.0 - 2026-10-03 — Bundle Font Inter + Keputusan Navigasi

### Konteks
Dua keputusan yang masih terbuka sejak v1.2.0 akhirnya ditutup: penanganan
font, dan posisi navigasi.

### 1. Font Inter di-bundle

Rencana lama memakai **Arial tanpa bundling**. Rencana itu dibatalkan.

| Alasan | Penjelasan |
|---|---|
| Font desain sebenarnya | Keempat berkas `1-Bahan/` memakai `fontFamily: 'Inter'` di **seluruh 145 pemakaian**. Arial tidak pernah muncul di sana |
| Lisensi | Arial milik Microsoft; file font-nya tidak boleh ikut redistribute di dalam APK yang dibagikan. Inter berlisensi SIL OFL 1.1 yang mengizinkan itu |
| Konsistensi | Dengan bundling, Android dan iOS menampilkan font yang sama. Tanpa bundling, Android jatuh ke Roboto dan berbeda dari desain |

Berkas baru di `assets/fonts/`:

| Berkas | Weight | Ukuran |
|---|---|---|
| `Inter-Regular.ttf` | 400 | 407.056 byte |
| `Inter-Medium.ttf` | 500 | 411.500 byte |
| `Inter-Bold.ttf` | 700 | 415.072 byte |
| `Inter-Black.ttf` | 900 | 414.140 byte |
| `Inter-OFL.txt` | — | 4.380 byte |

Regular (400) serves sebagai jaring pengaman untuk weight bawaan
Material. Tidak ada italic karena desain tidak memakainya. Teks lisensi
OFL disertakan karena itu kewajiban redistribusi.

`pubspec.yaml` sekarang punya blok `fonts:` dengan `family: Inter`.
`AppTextStyles.sans` diubah dari `Arial` ke `Inter`, fallback dari
`Helvetica Neue` ke `Roboto`. `AppTheme.light()` ditambahkan
`fontFamily` dan `fontFamilyFallback` supaya widget Material yang tidak
diberi style eksplisit ikut memakai Inter.

**Catatan teknis.** Name table internal keempat TTF tidak seragam:
`Inter`, `Inter Medium`, `Inter`, `Inter Black`. Itu normal untuk static
instance Inter. Flutter memuat font aset berdasarkan `family` dan `weight`
yang dideklarasikan di `pubspec.yaml`, bukan membaca name table internal,
jadi pemetaannya tetap benar.

### 2. Navigasi tetap di bawah

Desain Figma menaruh 4 nav pill di bar atas, tapi desain itu lebar
1920 px. Empat pill itu butuh sekitar 630 dp — tidak muat di 360 dp tanpa
scroll horizontal, dan pola seperti itu buruk untuk navigasi utama.

`root_shell.dart` sudah memakai `NavigationBar` di bawah, jadi tidak ada
yang perlu dimigrasi — hanya direstyle di Tahap 3.

Konsekuensi: `AppHeader` **tidak** memuat nav pill, hanya logo, wordmark,
badge kelas, dan avatar. Footer bar desain dihapus di mobile karena
bentrok dengan system navigation bar Android.

Daftar item navigasi masih berbeda antara kode dan desain — itu keputusan
produk dan masih terbuka di `TODO.md`.

### Diverifikasi

| Pemeriksaan | Hasil |
|---|---|
| `flutter pub get` | ✅ Got dependencies |
| `flutter analyze` | ✅ No issues found |
| Keempat TTF terbaca valid | ✅ Name table terbaca: `Inter`, `Inter Medium`, `Inter`, `Inter Black` |
| Encoding dokumen | ✅ CJK 0, FFFD 0 |

### Belum diverifikasi

- **Belum pernah dijalankan di device.** Belum ada bukti visual bahwa
  Inter benar-benar terpakai, bukan Roboto. Kalau teks di Android terlihat
  seperti Roboto, berarti TTF gagal dimuat — jalankan `flutter clean`
  lalu `flutter run`.
- Ukuran token belum diuji dengan Inter. `lineHeight` hanya satu angka
  desimal per token, sementara Figma punya rentang (mis. `1.41–1.43`).

### Dokumen yang diperbarui

`PLANNING.md` §3 dan §7 · `TASK.md` Tahap 2 Part 2 · `TODO.md` item font
dan navigasi · `UI-REFERENCE.md` §1, §5.2, §8 · `TESTING.md` §6.2 dan
§6.4 · `README.md` tabel status.

---

## v1.3.0 — 2026-10-03 · Tahap 2: Design Token Neobrutalism

### Konteks
Token desain Material 3 indigo diganti ke neobrutalism, dari palet warna
sampai token bentuk. Semuanya ditulis ulang sesuai
[UI-REFERENCE.md](UI-REFERENCE.md) §5.

### Berkas

| Berkas | Aksi | Baris |
|---|---|---|
| `lib/core/app_colors.dart` | Ditulis ulang | 56 → 44 |
| `lib/core/app_text_styles.dart` | Ditulis ulang | 111 → 218 |
| `lib/core/app_sizes.dart` | **Baru** | 103 |
| `lib/core/app_theme.dart` | Ditulis ulang | 131 → 179 |
| `lib/main.dart` | `themeMode` ditambahkan | +5 |

### Perubahan

**Warna.** Dari 28 token menjadi 8. Tidak ada token Material 3 yang
tersisa dan tidak ada gradien.

**Tipografi.** Dari 12 token menjadi 17. Font `Arial` dengan fallback
`Helvetica Neue` lalu `sans-serif`. Hanya weight 500, 700, dan 900.
Token `monoNumeric` dihapus; ekspresi matematika sekarang memakai weight
700 dari font yang sama, bukan font monospace terpisah.

**Bentuk dan spasi.** Berkas baru `app_sizes.dart` berisi radius, lebar
border, offset bayangan, dan skala spasi, plus `AppSizes.shadow()` sebagai
satu-satunya sumber bayangan neobrutalism.

**Tema.** `app_theme.dart` sekarang memetakan seluruh slot `TextTheme`
Material ke token kita, memakai `AppSizes` untuk radius dan border, dan
tidak punya warna literal.

### Call site

Karena TASK 2.1 melarang alias, 280 call site di 13 file harus di-remap.
Remap-nya murni penamaan ulang token — layout dan struktur widget tidak
berubah. Pemetaan lengkap ada di [TASK.md](TASK.md) §Tahap 2.

### Temuan teknis

`RadioThemeData` di Flutter 3.27.4 **tidak punya parameter `side`**
(sudah diverifikasi ke sumber SDK). Jadi token `radioBorder` tidak bisa
dipasang lewat `RadioThemeData`; border-nya harus dipasang di level
widget `Radio` pada Tahap 3.

### Diverifikasi

```
flutter analyze → No issues found! (ran in 1.4s)
```

| Kriteria TASK 2.7 | Hasil |
|---|---|
| `flutter analyze` bersih | ✅ |
| Tidak ada `Color(0x...)` di luar `app_colors.dart` | ✅ |
| Tidak ada `TextStyle` inline di widget | ✅ |
| Tidak ada gradien visual | ✅ |
| Tidak ada token lama yang dirujuk | ✅ |
| Semua file di bawah 500 baris | ✅ |

### Belum dikerjakan

- Belum ada verifikasi visual. Semua pemeriksaan di atas statis.
- Nilai radius di widget belum dipetakan ke `AppSizes` — itu Tahap 3.
- `AppSizes.shadow()` sudah ada tapi belum dipakai widget apa pun —
  pemasangan nyata juga Tahap 3.

---

## v1.2.1 — 2026-10-03 · Tahap 1: Perbaikan Runtime Error

### Konteks
`flutter run -d edge` melempar dua exception, keduanya tercatat di
[TESTING.md](TESTING.md) §5. Entri ini menutup keduanya.

### Yang diperbaiki

**1. `ArgumentError: Invalid argument: 0` di `ThetaScale`**

`clamp(0.0, w - 2)` melempar exception kalau `w < 2`, karena `lower > upper`.
Lebar dari `LayoutBuilder` sekarang dinormalisasi dulu (`isFinite && > 0`),
lalu tiap batas `clamp` dipaksa `>= 0.0`. Konstanta `2` (garis marker) dan
`28` (knob) dipisah jadi `const` supaya tidak dihitung ulang dari `w`.

**2. `RenderFlex overflowed by 159 pixels`**

Penyebab tunggal belum terkonfirmasi — log tidak menyebut widget mana yang
overflow. Empat titik yang memang bisa meluber diperbaiki lewat analisis
statis:

| Lokasi | Masalah | Perbaikan |
|---|---|---|
| `StatTile` | `Text(value)` rigid di `Row` selebar ~1/3 kartu | `Flexible` + ellipsis |
| `Pill` | `overflow: ellipsis` tidak pernah aktif, `Container` tanpa batas lebar | `Row(mainAxisSize: min)` + `Flexible` |
| `SessionTile` | 4 `Text` rigid sebelum `Spacer` | `Text.rich` di dalam `Flexible` |
| `_HeroCta` eyebrow | `Text('DIAGNOSIS ADAPTIF')` rigid | `Expanded` + ellipsis |

`remediAppBar`, `SectionTitle`, baris tombol `_HeroCta`, dan baris label
`ThetaScale` diperiksa dan dinyatakan aman karena sudah memakai
`Expanded`.

**3. Kebersihan analyzer**

- `quiz_page.dart:153`: `onPopInvoked` → `onPopInvokedWithResult`
- `test/_diag_test.dart`: dihapus (sumber 2 `unused_import`)
- `analytics_widgets.dart:187`: `TextSpan` diberi `const`

**4. Pemecahan berkas (`AGENTS.md` §5)**

`common.dart` melewati 525 baris setelah fix overflow. Dipecah menjadi:

| Berkas | Baris | Isi |
|---|---|---|
| `lib/views/widgets/common.dart` | 318 | 8 widget + `remediAppBar` |
| `lib/views/widgets/analytics_widgets.dart` | 216 | `ThetaScale`, `SessionTile` |

`common.dart` mengekspor ulang `analytics_widgets.dart`, jadi tidak ada
import yang rusak.

### Diverifikasi

```
flutter analyze → No issues found! (ran in 1.7s)
```

### Belum dikerjakan

- `test/layout_test.dart` belum dibuat, jadi regresi overflow belum dikunci
  oleh uji otomatis.
- `flutter test` belum dijalankan ulang setelah perubahan.
- `flutter run -d edge` belum dijalankan ulang. **Perbaikan overflow belum
  diverifikasi di device nyata** — masih perlu satu kali run untuk memastikan.

---

## v1.2.0 — 2026-10-03 · Ganti Desain ke Neobrutalism

### Konteks
Pengguna mengganti referensi desain di `1-Bahan/`. Isi folder tersebut kini
berupa desain **neobrutalism** — border tebal, bayangan tajam tanpa blur, warna
solid saturasi tinggi, tipografi sans-serif tebal — menggantikan desain
Material 3 indigo yang sebelumnya menjadi acuan.

Tidak ada kode aplikasi yang disentuh pada entri ini. Semua perubahan
berada di `docs/project/`.

### Keputusan
- **Target: APK Android.** Seluruh keputusan desain disesuaikan untuk lebar
  ponsel, bukan 1920 px seperti file Figma.
- **Palet: 8 warna neobrutalism.** `background #F7F2EA`, `surface #FFFFFF`,
  `ink #070707`, `accentYellow #FDE300`, `accentPink #F77ACF`,
  `accentBlue #69A9FE`, `accentGreen #00E990`, `radioBorder #767676`.
  Palet indigo lama dan semua gradien **dihapus**.
- **Light-only.** Dark mode dibatalkan. Alasannya teknis: warna aksen sangat
  saturasi sementara tinta `#070707` hampir hitam, sehingga pada latar gelap
  bayangan tajam hilang dan kartu kehilangan bentuknya.
- **Font: Arial**, fallback `Helvetica Neue`, lalu `sans-serif`. Hanya tiga
  weight: 500, 700, 900. Font `Inter` yang tertulis di file Figma diabaikan.
  **Catatan:** Arial tidak ada di Android stock — Android memakai Roboto.
  Kalau `fontFamily: 'Arial'` tidak di-bundle, APK akan dirender dengan
  Roboto. Tiga opsi penanganan ada di `PLANNING.md` §7; belum diputuskan.
  `fontFamilyFallback` diverifikasi ada di SDK ini dan bersifat per-glyph.
- **Ukuran font dibulatkan** ke scale bersih. Angka desimal seperti 22.90,
  13.80, dan 11.60 adalah artefak auto-fit Figma, bukan niat desain.
- **Navigasi pindah ke bawah.** Empat nav pill di bar atas membutuhkan
  sekitar 630 dp dan tidak muat di 360 dp. Angka 630 dp adalah perkiraan
  dari lebar pill yang terukur di desain — belum diverifikasi lewat widget
  nyata. Badge kelas `SMA Kelas 10` dipertahankan di dalam pill `Hasil`.
- **Footer bar desain dihapus di mobile** karena bentrok dengan system
  navigation bar Android.

### Diperbarui
- `UI-REFERENCE.md` — ditulis ulang. Token warna per halaman, struktur tiap
  komponen, tabel pembulatan angka desimal, tabel token, dan daftar elemen
  yang harus dirancang dari nol.
- `PLANNING.md` — §3 tech stack, §6 palet, §7 tipografi, §8 bentuk dan
  spasi, §9 batasan, §10 tahap kerja.
- `TASK.md` — Tahap 2, 3, dan 4 ditulis ulang; 6 tahap dengan 48 tugas.
  Ditambahkan daftar keputusan yang **dihapus** dari rencana.
- `TODO.md` — 8 pertanyaan lama ditutup ke bagian "Sudah Diputuskan",
  3 pertanyaan baru muncul dari celah di desain baru.
- `README.md` — status proyek dan struktur proyek dikoreksi.
- `TESTING.md` — ditambahkan kriteria ukuran Android.

### Diverifikasi
- Fakta teknis `1-Bahan/` dihitung ulang dengan pembacaan langsung:
  0 `import`, keempat file bernama `Frame`, `width: 1920` di keempat file,
  `ShapeDecoration(shadows:)` 36 kali, 0 `ListView`, 32 `child: Stack()`
  kosong (11 / 5 / 8 / 8).
- Semua dokumen `docs/project/` diperiksa bebas karakter CJK dan byte
  pengganti `\uFFFD`.
- Tidak ada perubahan pada kode aplikasi.

### Catatan
Tanggal entri ini mengikuti urutan hari pada `HISTORY.md`, bukan tanggal
terverifikasi dari sistem. Konfirmasi tanggal bila diperlukan untuk changelog
resmi.

---

## v1.1.0 — 2026-10-02 · Dokumentasi Proyek

### Ditambahkan
- Folder `docs/project/` beserta enam dokumen:
  - `README.md` — indeks dokumentasi, struktur proyek, aturan penggunaan
  - `PLANNING.md` — visi, fitur inti, tech stack, arsitektur, keputusan desain
  - `TASK.md` — 6 tahap, 48 tugas spesifik dengan status dan kriteria selesai
  - `TODO.md` — backlog prioritas tinggi sampai rendah, plus 14 pertanyaan terbuka
  - `HISTORY.md` — dokumen ini
  - `TESTING.md` — hasil testing dan SOP verifikasi
  - `UI-REFERENCE.md` — katalog 4 file referensi desain

### Keputusan
- Palet warna: **pakai palet `1-Bahan/` + tambahkan mode gelap** (light
  tetap tersedia sebagai default lewat `ThemeMode.system`).
  *Dibatalkan pada v1.2.0 — lihat entri terbaru.*
- Font: **bundle Plus Jakarta Sans + JetBrains Mono**. Font `Arial` dan
  `Georgia` dari mockup tidak tersedia di device dan tidak dipakai.
  *Dibatalkan pada v1.2.0 — diganti Arial tanpa bundling.*
- Cakupan redesign: **hanya 4 halaman** yang punya referensi, yaitu Beranda,
  Kuis, Hasil Diagnosis, dan Remedial. Enam halaman lain hanya mengikuti
  pergantian token global.
- Dokumentasi tidak boleh menyalin kode dari `1-Bahan/` karena file tersebut
  hasil ekspor Figma dan tidak bisa dikompilasi.

### Verifikasi
- Kelengkapan format Markdown diperiksa. `docs/project/` berisi 7 berkas.
- Tidak ada perubahan pada kode aplikasi.

---

## v1.0.0 — 2026-10-02 · Integrasi Source AI ke Project

### Konteks
Source aplikasi RemediMath di dalam ZIP dari AI. Proyek Flutter di lokasi ini
masih berupa template default. Tujuan: menyatukan kode aplikasi ke dalam
project Flutter yang bisa dijalankan, dengan nama paket tetap
`mp_musyaffailhamaka`.

### Ditambahkan
- **24 berkas Dart** disalin ke `lib/`:
  - `main.dart`, `core/` (6 berkas), `models/` (1), `services/` (4),
    `controllers/` (1), `views/` (pages 10 + widgets 1 + flows 1)
  - Aset data: `assets/data/questions.json` dan
    `assets/data/knowledge_graph.json`
- Test integrasi: `test/irt_graph_test.dart`

### Diubah
- `pubspec.yaml` — digabung dengan konfigurasi project: nama paket, deskripsi,
  `version`, plus dependensi `provider ^6.1.2`, `shared_preferences ^2.3.2`,
  `url_launcher ^6.3.0`, `intl ^0.19.0`, `cupertino_icons ^1.0.8`.
  Ditambahkan blok `assets: - assets/data/`.
- `analysis_options.yaml` — `include: package:flutter_lints/flutter.yaml`.
- `test/irt_graph_test.dart` — semua import diubah dari path relatif
  (`../../lib/...`) ke `package:mp_musyaffailhamaka/...`.
- Branding Android dan web diubah menjadi **RemediMath**.

### Dihapus
- `test/widget_test.dart` — test bawaan template default yang tidak relevan
  dengan aplikasi.

### Cadangan
`_backup_default/` menyimpan salinan file project sebelum perubahan:
`pubspec.yaml`, `README.md`, `analysis_options.yaml`, `lib/main.dart`,
`test/widget_test.dart`, `web/manifest.json`.

### Verifikasi
| Perintah | Hasil |
|---|---|
| `flutter pub get` | Berhasil |
| `flutter analyze` | 0 error, 0 warning, 15 lint info |
| `flutter test` | 3 dari 3 lulus |
| `flutter build web` | Berhasil dalam 46,8 detik |
| `flutter devices` | Edge, Chrome, Windows terdeteksi |

### Temuan (belum diperbaiki)
Lihat [TESTING.md](TESTING.md) §5. Ringkasnya:
1. `ArgumentError: Invalid argument: 0` di `common.dart:342` (fungsi `clamp`)
2. `RenderFlex overflowed by 159 pixels on the right`, sumber belum diketahui

Kedua temuan ini menjadi Tahap 1 pada `TASK.md`.

### Catatan
- Font `JetBrains Mono` dirujuk di `app_text_styles.dart` tapi **tidak
  di-bundle** sebagai asset, sehingga semua ekspresi matematika jatuh ke
  font fallback platform. Tidak ada blok `fonts:` di `pubspec.yaml`.
  *Dibatalkan pada v1.2.0 — token mono dihapus, ekspresi matematika memakai
  Arial weight 700.*
- Video penjelasan menggunakan `url_launcher` untuk membuka YouTube di
  aplikasi eksternal. Tidak ada player embedded di dalam aplikasi.
- Video penjelasan menggunakan `url_launcher` untuk membuka YouTube di
  aplikasi eksternal. Tidak ada player embedded di dalam aplikasi.

---

## Riwayat Singkat Sumber AI

Dari `Bahan Awal/Bahan Prompt AI/`:

| Entri | Isi |
|---|---|
| `Hasil AI 1.txt` | Iterasi pertama. Credit workspace habis di tengah proses. Yang berhasil: `pubspec.yaml`, `analysis_options.yaml`, `README.md`, bank soal, peta materi, dan fondasi tampilan. Yang belum: seluruh kode Dart, service, controller, komponen, 9 halaman, `main.dart`, pengujian, dan pengemasan ZIP. Proyek tidak bisa dijalankan. |
| `Hasil AI 2.txt` | Lanjutan yang berhasil di-thread sebelumnya, dengan sandaran credit tambahan. |
| `File Hasil AI 1/README.md` | Dokumentasi hasil integrasi. |

Tidak ada entri untuk "sebelum" versi ini karena dokumentasi baru dibuat pada
v1.1.0.
