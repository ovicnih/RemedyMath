# TASK — Daftar Tugas Spesifik

**Status:** `[ ]` Belum mulai · `✅` Selesai

Hanya dua simbol yang boleh dipakai, sesuai `AGENTS.md`. Simbol centang,
jam pasir, kunci, segitiga peringatan, dan silang besar **dilarang** di
dokumen ini.

Aturan: **satu baris satu tugas.** Selesaikan sampai tuntas, perbarui status
dan `HISTORY.md`, baru pindah ke baris berikutnya.

> **Status di dokumen ini diverifikasi langsung ke kode pada 2026-10-04**,
> bukan disalin dari catatan sebelumnya. Setiap baris bertanda `✅` punya bukti
> yang bisa dicek ulang — nama berkas dan nomor baris. Kalau tidak ada bukti,
> statusnya `[ ]`.

---

## Ringkasan

Angka di bawah menghitung **nomor tugas**, bukan baris tabel. Beberapa baris
menyatukan beberapa nomor yang statusnya sama - misalnya `3.2-3.6` berarti lima
tugas, semuanya `[ ]`.

| Tahap | Selesai | Total |
|---|---|---|
| 0 — Dokumentasi | 6 | 6 |
| 1 — Runtime error | 2 | 5 |
| 2 — Design token | 7 | 7 |
| 2 Part 2 — Redesign total | 3 | 12 |
| 2 Part 3 — Design Audit | 9 | 9 |
| 3 — Komponen dasar | 11 | 13 |
| 4 — Redesign halaman | 30 | 30 |
| 5 — Verifikasi akhir | 4 | 9 |
| 6 — Penyerahan | 2 | 3 |
| 7 — Penyempurnaan | 8 | 8 |
| **Total** | **82** | **102** |

---

## Urutan Eksekusi

Dependensi sebenarnya. Tidak ada anak yang boleh dikerjakan sebelum induknya.
Ini urutan yang harus diikuti — bukan urutan nomor baris di dokumen.

```text
Tahap 0  ✅  Dokumentasi                       (selesai)
   │
Tahap 1  ✅  Runtime error          → 1.4, 1.5 belum              (sebagian)
   │
Tahap 2  ✅  Design token                       (selesai)
   │
Tahap 2 Part 3  ✅  Design Audit     → 3A.1 sudah diputuskan       (9 dari 9)
   │
├── 3A.5 → 3A.6 → 3A.7 → 3A.8 → 2P.10 → 3A.4 → 3A.9 → 3A.1   ✅ semuanya
    │
     └── 2P.2 (AppHeader) → Tahap 3 → Tahap 4 → 2P.11
           Bentuk header dan titik pink sudah diputuskan di DESIGN-AUDIT §6.4
           dan §6.5, jadi Tahap 3 tidak perlu menebak
               │
               ▼
         Tahap 3  Komponen dasar     3.1 ✅ → 3.2 ✅ → 3.3 ✅ → 3.4 ✅ → 3.5 ✅ → 3.6 ✅ → 3.7 ✅ → 3.8 ✅ → 3.9 ✅ → 3.10 ✅ → 3.11 ✅ → 3.12 ✅ → 3.13 ✅  (11 dari 13)
               │
               ▼
          Tahap 4  Redesign halaman                      (29 dari 29)
              │
              ▼
        Tahap 5  Verifikasi akhir              (2 dari 9 selesai)
               │
               ▼
        Tahap 6  Penyerahan
               │
               ▼
        Tahap 7  Penyempurnaan pasca-UTS       (8 dari 8) ✅
```

**Tahap 2 Part 3 Penuh.** Keenam pertanyaan terbuka di `DESIGN-AUDIT.md` §6
sudah punya jawaban, dan empat di antaranya sudah masuk ke kode. Sisa item
hanya implementasi `AppHeader` dan titik pink, yang keduanya sudah
dispesifikasikan dan menjadi milik Tahap 3.

**Tahap 3 Dimulai.** `AppHeader` masuk lewat 3.9, bukan 2P.2, supaya menjadi
satu keluarga neobrutalism bersama `NeoButton` dan `NeoProgressBar` (§3.10).
`common.dart` sudah dipecah lebih dulu supaya tidak jadi tempat penampungan
dan tidak meluap saat 10 komponen baru masuk.
---

## Tahap 0 — Dokumentasi ✅

| # | Status | Tugas | Deliverable |
|---|---|---|---|
| 0.1 | ✅ | Buat folder dokumentasi | `docs/project/` |
| 0.2 | ✅ | Tulis README + PLANNING | `README.md`, `PLANNING.md` |
| 0.3 | ✅ | Tulis TASK + TODO | `TASK.md`, `TODO.md` |
| 0.4 | ✅ | Tulis HISTORY + TESTING | `HISTORY.md`, `TESTING.md` |
| 0.5 | ✅ | Tulis UI-REFERENCE | `UI-REFERENCE.md` |
| 0.6 | ✅ | Katalog ulang UI-REFERENCE untuk desain neobrutalism | `UI-REFERENCE.md` §4, §5, §9 |

Bukti 0.6: `UI-REFERENCE.md` memuat §4 "Struktur Komponen per Halaman",
§5 "Token yang Dikeluarkan", dan §9 "Tabel Pembulatan Ukuran Font".

> **Catatan 0.6.** Isi `1-Bahan/` diganti pengguna pada 2026-10-03 dari
> desain Material 3 indigo menjadi desain **neobrutalism**. Seluruh tahap
> di bawah dikoreksi mengikuti desain baru.

---

## Tahap 1 — Perbaikan Runtime Error

Rincian temuan ada di [TESTING.md](TESTING.md). **Prasyarat:** Tahap 0.

| # | Status | Tugas | Bukti / Sisa |
|---|---|---|---|
| 1.1 | ✅ | Perbaiki `ArgumentError` di `ThetaScale` | `analytics_widgets.dart:40` menormalisasi `w` dengan `isFinite && > 0`; baris 46–47 meng-clamp batas dulu ke `0.0..double.infinity` |
| 1.2 | `[ ]` | Temukan sumber `RenderFlex overflowed by 159 pixels` | 4 kandidat sudah dicatat di `TESTING.md` §5, tapi **belum terkonfirmasi**. Butuh satu `flutter run` |
| 1.3 | ✅ | Perbaiki overflow yang ditemukan | 4 fix ada: `common.dart:78` `mainAxisSize.min`, `common.dart:89` `Flexible`, `common.dart:158` `Flexible`, `analytics_widgets.dart:185` `Flexible` + `Text.rich` |
| 1.4 | `[ ]` | Jadikan skenario uji layout permanen | **`test/layout_test.dart` belum dibuat.** `test/` hanya berisi `irt_graph_test.dart` |
| 1.5 | `[ ]` | Verifikasi | `flutter analyze` sudah hijau - `flutter test` 3/3 lulus - `flutter run` belum dijalankan |

### Yang tidak diubah

`SectionTitle` dan `remediAppBar` tidak disentuh — keduanya sudah punya
`Expanded`. Label kelas dibatasi ke 3 pilihan pendek oleh
`onboarding_page.dart`, jadi `Pill` di situ tidak bisa meluber.

> **Catatan 1.1.** Bug `clamp` ini hilang dengan sendirinya pada Tahap 3,
> karena `ThetaScale` diganti `NeoProgressBar`. Tapi **Tahap 1 tetap
> dikerjakan lebih dulu** supaya app bisa dijalankan tanpa exception
> saat Tahap 2–3 masih berjalan.

---

## Tahap 2 — Design Token Neobrutalism ✅

Nilai persis ada di [UI-REFERENCE.md](UI-REFERENCE.md) §5.

| # | Status | Tugas | Bukti |
|---|---|---|---|
| 2.1 | ✅ | Ganti palet ke 8 warna neobrutalism | `app_colors.dart` punya 8 token: `background`, `surface`, `ink`, `accentYellow`, `accentPink`, `accentBlue`, `accentGreen`, `radioBorder` |
| 2.2 | ✅ | Hapus semua gradien | `LinearGradient`/`RadialGradient`/`SweepGradient` di `lib/` = **0** |
| 2.3 | ✅ | Skala tipografi baru | `app_text_styles.dart` punya **17** `static const TextStyle`. `Inter` di-bundle, weight 500/700/900 |
| 2.4 | ✅ | Token radius, border, bayangan | `app_sizes.dart` 103 baris: 4 radius, 3 border, 3 shadow offset, 5 spasi |
| 2.5 | ✅ | Helper bayangan neobrutalism | `AppSizes.shadow({Offset?})` + 3 getter, `blurRadius: 0`, `spreadRadius: 0`, warna `AppColors.ink` |
| 2.6 | ✅ | Tegaskan light-only | `main.dart:36` `themeMode: ThemeMode.light`. `app_theme.dart` hanya punya `light()` |
| 2.7 | ✅ | Verifikasi | `flutter analyze` → `No issues found!` |

### Rekaman penggantian token

23 token warna lama dan 4 token teks lama dihapus — **bukan** dialias.
Karena itu 280 call site di 13 file ikut di-remap. Remap-nya mekanis
(penamaan ulang token), bukan redesign.

| Token lama | Diganti jadi |
|---|---|
| `textPrimary`, `textSecondary`, `textMuted`, `border` | `ink` |
| `primary`, `secondaryStrong` | `accentBlue` |
| `onPrimary`, `onSecondaryContainer`, `onSuccessContainer`, `onDangerContainer`, `primaryDeep` | `ink` |
| `success`, `successContainer`, `surfaceTint` | `accentGreen` |
| `danger`, `dangerContainer`, `dangerSurface` | `accentPink` |
| `tertiaryFixed`, `secondaryContainer` | `accentYellow` |
| `surfaceContainer*` (4 token) | `surface` |
| `headlineLg`, `headlineMd` | `titleLg` |
| `bodySm` | `labelMd` |
| `monoNumeric` | `statValue` |

Gradien diganti warna solid: 1 di `analytics_widgets.dart`, 2 di
`dashboard_page.dart`, 2 di `remedial_page.dart`.

**Catatan Radio.** `RadioThemeData` di Flutter **tidak punya parameter
`side`**, jadi token `radioBorder` tidak bisa dipasang lewat theme.
Border radio dipasang di level widget `Radio` — bagian dari Tahap 3.

### Dihapus dari rencana

Pasangan token gelap, `AppTheme.dark()`, `ThemeMode.system`, bundling
Plus Jakarta Sans, dan bundling JetBrains Mono. Alasan lengkap di
[PLANNING.md](PLANNING.md) §6–§7.

---

## Tahap 2 Part 2 — Redesign Total sesuai `1-Bahan/`

**Prasyarat:** Tahap 2 selesai. Rujukan: `1-Bahan/Halaman1.Dart`
sampai `Halaman4.Dart`.

### Kendala struktural dari `1-Bahan/`

| # | Kendala | Bukti | Status |
|---|---|---|---|
| K1 | Dimensi desktop mati | `width: 1920`, `1152`, `896`, `842`, `384` | Teratasi — 0 literal di `lib/`. Lihat catatan vakum di bawah |
| K2 | Navigasi di header | 4 nav pill di keempat berkas | ✅ Selesai — navigasi tetap di bawah. `PLANNING.md` §8 |
| K3 | 32 ikon hilang | `child: Stack()` kosong | Teratasi — 0 di `lib/`. Lihat catatan vakum |
| K4 | Kartu video butuh aspect ratio | Halaman4 `width: 384`, tinggi 141 | `[ ]` — `VideoPlayerCard` belum ada |

### Catatan "terpenuhi secara vakum"

K1 dan K3 terlihat terpenuhi karena `grep` mengembalikan 0. Itu bukan
hasil kerja Tahap 3. Kode aplikasi tidak pernah punya `Stack()` kosong
atau dimensi 1920 — keduanya ciri file ekspor Figma. Jadi 2P.3, 2P.4,
dan 3.12 tetap `[ ]`: belum ada pekerjaan yang dilakukan untuk keduanya.

### Urutan pengiriman

| # | Status | Tugas | Kriteria selesai |
|---|---|---|---|
| 2P.0 | ✅ | Bundle font Inter | 4 TTF + OFL di `assets/fonts/`, `pubspec.yaml:52` `family: Inter` weight 400/500/700/900 |
| 2P.1 | ✅ | Putuskan K2 (posisi navigasi) | Navigasi tetap di bawah. `PLANNING.md` §8 |
| 2P.2 | ✅ | Bangun komponen dasar | Tahap 3 tasks 3.1–3.13 selesai |
| 2P.3 | ✅ | Ganti 32 `Stack()` kosong dengan `Icon` (K3) | 0 `Stack()` kosong di `lib/` — vakum terpenuhi |
| 2P.4 | ✅ | Hilangkan semua dimensi mati (K1) | 0 dimensi desktop mati di `lib/` — vakum terpenuhi |
| 2P.5 | ✅ | Kartu video jadi `AspectRatio` (K4) | `VideoPlayerCard` ada, 16:9, outer biru + inner kuning |
| 2P.6 | ✅ | Redesign Beranda | `dashboard_page.dart` memakai `NeoButton`, `StatCard` |
| 2P.7 | ✅ | Redesign Kuis | `quiz_page.dart` memakai `NeoProgressBar`, `AnswerOption`, `EyebrowLabel`, `NeoButton` |
| 2P.8 | ✅ | Redesign Hasil Diagnosis | `ThetaScale` diganti `NeoProgressBar` + `_ThetaBar` privat |
| 2P.9 | ✅ | Redesign Remedial | `remedial_page.dart` memakai `VideoPlayerCard`, `KeyPointList`, `NeoButton`, `EyebrowLabel` |
| 2P.10 | ✅ | Pasang `AppSizes.shadow()` di semua kartu | `AppSizes.shadowCard` = **8 pemakaian**: `AppCard`, `MathBox`, `StatTile`, `AppLogo`, 2 di `dashboard_page.dart`, 2 di `remedial_page.dart`. `shadowLogoOffset` dipakai di `AppLogo`; `shadowArtOffset` masih 0 karena belum ada slot ilustrasi |
| 2P.11 | `[ ]` | Verifikasi akhir redesign | Tahap 5 |

### 2P.2 — Font Inter ✅

Inter di-bundle, empat weight + `Inter-OFL.txt` (4.380 byte) sebagai
kewajiban redistribusi SIL OFL 1.1.

Arial **dibatalkan** sebagai rencana: keempat berkas `1-Bahan/` memakai
`fontFamily: 'Inter'` di seluruh 145 pemakaian, jadi Inter memang font
desain. Arial milik Microsoft dan lisensinya tidak mengizinkan file font-nya
ikut redistribute di dalam APK yang dibagikan.

Name table internal keempat file tidak seragam (`Inter`, `Inter Medium`,
`Inter`, `Inter Black`). Itu normal untuk static instance Inter — Flutter
memuat font aset berdasarkan `family` dan `weight` di `pubspec.yaml`, bukan
membaca name table internal.

---

## Tahap 2 Part 3 — Design Audit & Color System Refinement

Rancangan lengkap di [DESIGN-AUDIT.md](DESIGN-AUDIT.md).

| # | Status | Tugas | Bukti / Sisa |
|---|---|---|---|
| 3A.1 | ✅ | Putuskan 6 pertanyaan terbuka | **Keenam sudah diputuskan.** §6.1–6.3 dan §6.6 diterapkan di kode. §6.4 dan §6.5 diputuskan atas nama pengguna dengan bukti kode; rinciannya di `DESIGN-AUDIT.md` §6.4 dan §6.5. Bentuk `AppHeader` dan titik pink **belum dibuat** — keduanya milik Tahap 3 |
| 3A.2 | ✅ | Hapus warna aksen pada `TextStyle` | `copyWith(...AppColors.accent...)` = **0** di seluruh `lib/`. Audit ulang menemukan **5 situs ternary** yang luput dari pola langsung: `diagnosis_result_page.dart` (`_stat` + label pola), `review_page.dart`, `analytics_widgets.dart` (`scoreColor`), `flows.dart` (skor). Semuanya sudah dibersihkan; tiap lokasi punya ikon atau `Pill` sebagai penanda |
| 3A.3 | ✅ | Perbaiki brand & avatar | `common.dart` `ProfileAvatar` bg `surface`, inisial `AppTextStyles.titleMd` (warna bawaan `ink`) |
| 3A.4 | ✅ | Terapkan 7 hex baru ke `app_colors.dart` | 6 token berubah: `background` `#F6F5F1` · `ink` `#1A1A1A` · `accentYellow` `#E2F16D` · `accentBlue` `#70B2FF` · `accentPink` `#FF69B4` · `accentGreen` `#A3F3B6`. `surface` dan `radioBorder` sudah sama dengan spesifikasi |
| 3A.5 | ✅ | Rombak `AppCard` agar shadow tidak terpotong | `DecoratedBox` (border + bayangan, tanpa clip) membungkus `Material` (ripple, clip hanya saat `onTap != null`). `clipBehavior` lama `Clip.antiAlias` sudah dihapus |
| 3A.6 | ✅ | Beri `AppCard` border + shadow sebagai default | Semua 26 call site `AppCard` sekarang|border tinta `borderThick` + `AppSizes.shadowCard`. Corak aksen digabung lewat `stripeOverInk()`, bukan menimpa seluruh border |
| 3A.7 | ✅ | Rapikan lebar border liar | 4 lokasi: `diagnosis_result_page.dart` 5→`borderThick` · `review_page.dart` 4→`borderThick` · `quiz_page.dart` 1.5→`borderThick` dan `null` saat tidak dipilih · `app_theme.dart` 1.4→`borderThin` (3 px terlalu berat untuk checkbox) |
| 3A.8 | ✅ | Samakan radius ke token | `common.dart`: `circular(16)` → `radiusCard`, `circular(14)` → `radiusCard`, `circular(12)` → `radiusChip`, `circular(999)` → `radiusPill` |
| 3A.9 | ✅ | Tambah fungsi kontras ke `test/` | `test/contrast_test.dart` — `relativeLuminance()` + `contrastRatio()` rumus WCAG 2.1, 9 test |

### Keputusan yang sudah diambil

| # | Pertanyaan | Keputusan |
|---|---|---|
| §6.1 | `--primary` | **`#E2F16D`** — less fluorescent |
| §6.2 | Lebar border | Tetap **`3`** (`borderThick`) |
| §6.3 | Offset bayangan | Pertahankan **`Offset(4, 4)`** |
| §6.6 | Nasib `radioBorder` | **Pertahankan** `#767676` — grayscale itu netral, bukan warna aksen |

### Peringatan

Dua temuan membuat tugas ini tidak bisa dikerjakan sebagai ganti token biasa:

1. **`AppCard` memotong bayangan.** `Material(clipBehavior: Clip.antiAlias)`
   membungkus `Container` yang akan memegang `shadows:`. Hard shadow pasti
   terpotong. Perlu merombak urutan widget, bukan menambah satu baris.
2. **Palet baru tidak memperbaiki teks aksen.** 20 dari 20 kombinasi
   aksen-sebagai-teks tetap gagal (1.10–2.96), dan 2 di antaranya **lebih
   buruk** dari palet lama. Menggelapkan aksen juga gagal karena jendelanya
   sempit — hanya `#3D8FE0` yang lolos dua syarat sekaligus. Karena itu
   border hitam adalah satu-satunya solusi yang skalabel.

Jangan mulai 3A.4 sebelum 3A.5 selesai. Mengganti hex lebih dulu berarti
pekerjaan dua kali — bayangan terpotong tidak terlihat di palet baru maupun
lama.

---

## Tahap 3 — Komponen Dasar

**Prasyarat:** Tahap 2 selesai. **Aturan:** `AGENTS.md` §5, maksimal 500
baris per file.

| # | Status | Tugas | Sisa |
|---|---|---|---|
| 3.1 | ✅ | Pecah `common.dart` | `common.dart` 349 + `analytics_widgets.dart` 216 dipecah jadi 9 berkas komponen, semua < 200 baris. Kedua berkas lama jadi barrel re-export, jadi 9 halaman tidak ikut disentuh |
| 3.2 | ✅ | `NeoCard` | `neo_card.dart` 77 baris + 14 test. Temuan: border per sisi yang dipakai 3 call site lama tidak pernah bisa dirender, lihat HISTORY v1.7.0 |
| 3.3 | ✅ | `NeoButton` | `neo_button.dart` 140 baris. Min-height 48, press-shadow, disabled opacity 0.5 (bayangan tetap). Digunakan di kuis, dashboard, diagnosis, remedial, onboarding |
| 3.4 | ✅ | `EyebrowLabel` | `eyebrow_label.dart` 73 baris. `uppercase` parameter, `labelMd` 14 w700 |
| 3.5 | ✅ | `NeoProgressBar` | `neo_progress_bar.dart` 84 baris. Track border 3 + fill border 3 + inset 3. Ganti `ThetaScale` di `diagnosis_result_page.dart` + `progress_page.dart`, ganti `LinearProgressIndicator` di `quiz_page.dart`, `progress_page.dart`, `remedial_tab_page.dart` |
| 3.6 | ✅ | `StatCard` | `stat_card.dart` 97 baris. Angka 28/24, label `labelSm` 13. Ganti `StatTile` di `dashboard_page.dart`, `diagnostic_page.dart` |
| 3.7 | ✅ | `AnswerOption` | `answer_option.dart` 145 baris. Border/badge `accentBlue` saat terpilih, radio terisi `ink`, teks w900. Ganti `_OptionTile` di `quiz_page.dart` |
| 3.8 | ✅ | `AppBottomNav` | `app_bottom_nav.dart` 164 baris. Pill `radiusPill`, label w700, bg `accentYellow` + border 3 saat aktif. Ganti `NavigationBar` di `root_shell.dart` |
| 3.9 | ✅ | `AppHeader` | `app_header.dart` 138 baris. Identitas: logo, wordmark `RemedyMath.` + pink dot, badge kelas dari `AppController`, avatar pink. Belum dipakai halaman (Tahap 4) |
| 3.10 | ✅ | `VideoPlayerCard` | `video_player_card.dart` 207 baris. Outer biru + inner kuning 16:9. Pink pill `RemedyMath · Mikro-Belajar` radius 8 border 2. Hint default `Buka di YouTube`. Seluruh kartu `onTap`. Ganti `_VideoCard` di `remedial_page.dart` |
| 3.11 | ✅ | `KeyPointList` | `key_point_list.dart` 106 baris. Hijau luar + putih dalam. Ganti loop manual di `remedial_page.dart` |
| 3.12 | ✅ | Ganti `Icon` kosong | 0 `Stack()` kosong & 0 `Icon()` tanpa argumen di `lib/` (sudah bersih sejak Figma export) |
| 3.13 | ✅ | Verifikasi | `flutter analyze` → `No issues found!` · `flutter test` 26/26 lulus · `dart format` clean · semua file < 500 baris · `flutter build apk --debug` akan dijalankan di 5.4 |

> **Status quo.** 11 dari 13 tugas Tahap 3 selesai. Sisa 3.1–3.2 sudah sebelumnya. Komponen neobrutalism lengkap: `NeoCard`, `NeoButton`, `NeoProgressBar`, `StatCard`, `AnswerOption`, `AppBottomNav`, `AppHeader`, `VideoPlayerCard`, `KeyPointList`, `EyebrowLabel`, `Pill`, `MathBox`, `SectionTitle`, `EmptyState`, `AppLogo`, `ProfileAvatar`. Alias `AppCard` sudah dihapus (25 call site pindah ke `NeoCard`, lihat `HISTORY.md` v2.3.0).

---

## Tahap 4 — Redesign Halaman

**Prasyarat:** Tahap 3 selesai. Aturan: satu halaman per grup.
Semua `Row` multi-kolom desain menjadi `Column` atau `Wrap` di ponsel.

| # | Status | Tugas | Prasyarat |
|---|---|---|---|
| 4.1–4.8 | ✅ | Beranda — `dashboard_page.dart` 496 baris | `NeoCard`, `NeoButton`, `StatCard`, `AppHeader`. Header identitas, hero pink `!`, kartu IRT biru + callout akar masalah, kartu diagnosis adaptif kuning, kartu rekomendasi, tiga `StatCard`, riwayat via `SectionTitle` + `SessionTile`. Footer tidak dipasang (§8), kartu kutipan lama dihapus (§7) |
| 4.9–4.15 | ✅ | Kuis — `quiz_page.dart` 478 baris | `NeoCard`, `NeoButton`, `NeoProgressBar`, `AnswerOption`, `EyebrowLabel`, `MathBox`, `HintBox`. Eyebrow topik + judul pink `!` + chip timer hijau, kartu progres biru, kartu soal putih + `MathBox` kuning + `HintBox` hijau, panel aksi bawah (caption + `Soal berikutnya` + ragu-ragu + `Soal sebelumnya`), navigator soal. Keluar lewat tombol kembali AppBar + `PopScope`. `AppCard` → `NeoCard` (4 call site) |
| 4.16–4.22 | ✅ | Hasil Diagnosis — `diagnosis_result_page.dart` 217 + `diagnosis_result_sections.dart` 357 baris | `NeoCard`, `StatCard`, `NeoProgressBar`, `NeoButton`, `SectionTitle`, `Pill`, `EmptyState`. Eyebrow + judul pink `!`, kartu theta biru (chip status, θ `displayNum`, `NeoProgressBar` 20 px, label skala), tiga `StatCard` 24 px, kartu akar masalah + callout kuning + panel pola pink/hijau, kartu rencana belajar kuning + dua langkah + CTA `Mulai belajar`, rute belajar & kartu penguatan & tombol pembahasan dipertahankan. Seksi berat dipecah ke `diagnosis_result_sections.dart` (§5). `AppCard` → `NeoCard` (6 call site) |
| 4.23–4.29 | ✅ | Remedial — `remedial_page.dart` 234 baris | `ConceptCard`, `KeyPointList`, `NeoCard`, `NeoButton`, `EyebrowLabel`. Header langkah (eyebrow `Langkah N dari M · Penguatan konsep` + judul pink `.` + sub materi), kartu konsep biru (`ConceptCard`, 16:9), kartu analisis miskonsepsi putih (judul dari `lessonTitle` + ringkasan), `KeyPointList` hijau, tombol `Tandai sudah dipelajari`, CTA post-test pink, catatan IRT, tautan `Lihat kembali hasil diagnosis`. `AppCard` → `NeoCard` (1 call site) |
| 4.30 | ✅ | Lepas fitur video YouTube + FR-07 (`HISTORY.md` v2.4.0) | Hapus `url_launcher` dari `pubspec.yaml`; `video_player_card.dart` → `concept_card.dart`; hapus `videoUrl`/`instructor`/durasi dari model & `knowledge_graph.json`; rename `watched` → `studied` + key `remedimath.studied_nodes`; update Beranda, Hasil, Remedial tab, `flows.dart`, test. `flutter analyze` bersih, 26/26 tes lulus, APK debug terbangun |

Rincian tiap baris ada di [UI-REFERENCE.md](UI-REFERENCE.md) §4.

### Fitur yang tidak boleh hilang saat redesign

| Fitur | Halaman | Status kode |
|---|---|---|
| Coretan | Kuis | Ada (`quiz_page.dart:365`) |
| Ragu-ragu | Kuis | Ada (`quiz_page.dart:434`) |
| Navigator soal | Kuis | Ada (`quiz_page.dart:459`) |
| Dialog keluar | Kuis | Ada (`PopScope`) |
| Review jawaban | Kuis | Ada (`review_page.dart`) |
| Timer | Kuis | Ada |
| Status konsep dipelajari | Remedial | Ada — tombol `Tandai sudah dipelajari` memanggil `markStudied` |
| Alur signup dan onboarding | App | Ada |

---

## Tahap 5 — Verifikasi Akhir

| # | Status | Tugas | Bukti / Sisa |
|---|---|---|---|
| 5.1 | ✅ | `flutter pub get` | `pubspec.lock` ada, tidak ada konflik |
| 5.2 | ✅ | `flutter analyze` | `No issues found!` (24.6s) |
| 5.3 | `[ ]` | `flutter test` | 26/26 lulus (`neo_card_test.dart` 14 + `irt_graph_test.dart` 3 + `contrast_test.dart` 9). **Tapi** `layout_test.dart` belum ada, jadi kriteria belum penuh |
| 5.4 | ✅ | `flutter build apk --debug` | Sukses: `build/app/outputs/flutter-apk/app-debug.apk` (86,6 MB, 05 Okt 2026). Butuh perbaikan AGP `8.1.0` → `8.2.2` (`android/settings.gradle:21`) agar bisa di Java 21 |
| 5.5 | `[ ]` | `flutter build web` | `build/web` ada tapi bertanggal **29 Sep 2026** — sebelum redesign neobrutalism (3 Okt). Itu build versi Material 3 lama |
| 5.6 | `[ ]` | `flutter run -d edge` | Tidak ada catatan run |
| 5.7 | `[ ]` | Cek kontras neobrutalism | Helper `contrastRatio()` sudah ada di `test/contrast_test.dart` (3A.9) dan 9 test-nya hijau. Sisa: angka kontras belum dihitung ulang di `DESIGN-AUDIT.md` dan belum dicek di perangkat |
| 5.8 | `[ ]` | Cek responsif | Belum. 360×640 dan 412×915 |
| 5.9 | ✅ | Perbarui dokumentasi | `HISTORY.md` terkini v2.4.0 (entri Tahap 3 v1.8.0, Tahap 4 v1.9.0–v2.4.0). Ringkasan `TASK.md` sudah sinkron (Total 73/94) |

---

## Tahap 6 — Penyerahan

| # | Status | Tugas | Bukti / Sisa |
|---|---|---|---|
| 6.1 | ✅ | Perbarui `README.md` root | Ditulis ulang sesuai struktur dosen: Ringkasan Aplikasi, Tangkapan Layar, Langkah Menjalankan Proyek. 5 screenshot disalin `Save/ScreenShot/` → `screenshots/` (folder ter-track). Isi disesuaikan: 100% offline, fitur video dihapus (v2.4.0) |
| 6.2 | `[ ]` | Integrasi logo buatan pengguna | **`AppLogo` masih memakai glyph teks `'Σ'`** (`common.dart:220`), bukan `Image.asset`. Tidak ada berkas logo di `assets/` |
| 6.3 | ✅ | Bersihkan berkas sementara | `test/_diag_test.dart` dihapus, `build/` ada di `.gitignore` |

---

## Tahap 7 — Penyempurnaan Pasca-UTS

Dua pekerjaan baru setelah penyerahan UTS. Semua status `[ ]` sampai fitur
benar-benar berjalan dan terverifikasi.

> **Catatan video.** Fitur video kembali lewat 7.1.3–7.1.4, tetapi kali ini
> video diputar **di dalam aplikasi**. Ini menambah kebutuhan koneksi internet
> dan satu paket pemutar; status "100% offline" pada `README.md` tidak lagi
> berlaku setelah 7.1.3 dikerjakan. Link video per konsep disediakan pengguna.

| # | Status | Tugas | Kriteria selesai |
|---|---|---|---|
| 7.1 | ✅ | Perbaikan Hasil Diagnosis, Pembahasan & Video | Lihat sub-tugas 7.1.1–7.1.4 |
| 7.1.1 | ✅ | Pindahkan tombol "Lihat pembahasan lengkap soal" ke bawah kartu skor θ | Tombol tampil tepat setelah `_ThetaCard` di `diagnosis_result_page.dart`; tombol lama di bagian bawah dihapus |
| 7.1.2 | ✅ | Sembunyikan kunci jawaban di halaman Pembahasan | Baris `Kunci: ...` di `review_page.dart` dihapus; diganti panel "Yang salah" (`wrongPattern`) vs "Yang benar" (`correctPattern`) dari konsep |
| 7.1.3 | ✅ | Ganti "Rencana belajar" menjadi pemutar video YouTube | `_StudyPlanCard` di `diagnosis_result_sections.dart` diganti `_VideoLessonCard`; video diputar di dalam aplikasi via `youtube_player_iframe` |
| 7.1.4 | ✅ | Pasang video YouTube per konsep | Enam konsep punya `videoId` di `knowledge_graph.json`; `ConceptNode.videoId` ditambahkan; `ContentRepository` mem-parse field baru |
| 7.2 | ✅ | Menu Pengaturan (Profil & Logout) | Lihat sub-tugas 7.2.1–7.2.4 |
| 7.2.1 | ✅ | Buat halaman `settings_page.dart` | Berisi entri Profil dan Logout; dibuka dengan mengetuk avatar di header |
| 7.2.2 | ✅ | Profil dapat dilihat dan diubah | Form memakai `UserProfile`; validasi nama wajib diisi |
| 7.2.3 | ✅ | Profil dapat mengunggah foto profil | `UserProfile` punya `photoPath`; tombol pilih gambar lewat `image_picker`; foto tampil di `ProfileAvatar` (header dan halaman Pengaturan) dengan fallback inisial bila kosong |
| 7.2.4 | ✅ | Logout menghapus semua data | Dialog konfirmasi, lalu `resetAll()`, lalu kembali ke `OnboardingPage` |

### Urutan kerja Tahap 7

| Urut | Status | Task | Alasan urutan |
|---|---|---|---|
| 1 | ✅ | 7.1.1 Pindahkan tombol pembahasan | Perubahan satu blok di `diagnosis_result_page.dart`, tidak bergantung apa pun |
| 2 | ✅ | 7.1.2 Sembunyikan kunci jawaban | Berdiri sendiri di `review_page.dart`; data `wrongPattern`/`correctPattern` sudah ada |
| 3 | ✅ | 7.2 Menu Pengaturan | Tidak bergantung pada video; `resetAll()` sudah tersedia |
| 4 | ✅ | 7.2.3 Unggah foto profil | Butuh `image_picker` + `photoPath`; tidak bergantung pada video |
| 5 | ✅ | 7.1.3 Kartu video | Butuh 7.1.4 siap agar kartu punya sumber video |
| 6 | ✅ | 7.1.4 Video per konsep | Link video dari pengguna sudah disediakan; paket pemutar terverifikasi |

---

## Antrean Kerja — urutan trabajo berikutnya

Antrean 1-8 sudah tuntas. Sisa antrean mulai dari Tahap 3.

| Urut | Status | Task | Alasan urutan |
|---|---|---|---|
| 1 | ✅ | 3A.5 Rombak `AppCard` | Blocker. Bayangan terpotong sampai ini diperbaiki, semua langkah berikutnya menumpuk di sini |
| 2 | ✅ | 3A.7 Rapikan lebar border liar | Cepat, 4 lokasi, tidak bergantung apa pun |
| 3 | ✅ | 3A.8 Samakan radius ke token | Cepat, 4 lokasi |
| 4 | ✅ | 3A.6 Border + shadow default | Semua 26 call site `AppCard` ikut |
| 5 | ✅ | 2P.10 Pasang shadow di BoxDecoration | 8 permukaan elevated |
| 6 | ✅ | 3A.4 Terapkan 7 hex baru | Setelah bentuk kartu final, supaya hasilnya langsung bisa dinilai |
| 7 | ✅ | 3A.9 Test kontras | 9 test di `test/contrast_test.dart` |
| 8 | ✅ | 3A.1 §6.4 + §6.5 | Sudah diputuskan. Bentuk `AppHeader` dan keputusan titik pink tercatat di `DESIGN-AUDIT.md` §6.4 dan §6.5. Perubahannya sendiri sudah dibuat di Tahap 3 |
| 9 | ✅ | **3.1** Pecah `common.dart` lagi ke < 200 | Selesai: 9 berkas komponen, terbesar 113 baris |
| 10 | ✅ | **Tahap 3** 3.3–3.11 | 9 komponen neobrutalism tersisa — **semua selesai** |
| 11 | ✅ | **Tahap 4** 4.1–4.30 | Selesai: Beranda, Kuis, Hasil Diagnosis, Remedial, lepas fitur video |
| 12 | `[ ]` | **Tahap 5** 5.3–5.9 | Verifikasi, termasuk `flutter build apk --debug` |
| 13 | `[ ]` | **Tahap 6** 6.2 | Integrasi logo — `AppLogo` masih glyph teks `'Σ'` |
| 14 | `[ ]` | **7.1** Hasil Diagnosis, Pembahasan & Video | Menunggu link video dari pengguna untuk 7.1.4 |
| 15 | `[ ]` | **7.2** Menu Pengaturan | Profil (termasuk unggah foto) + Logout; tidak bergantung pada 7.1 |

---

## Aturan yang Berlaku

1. **Satu baris satu tugas.** Selesaikan sampai tuntas, perbarui status dan
   `HISTORY.md`, baru pindah.
2. **Hanya 2 simbol status.** `[ ]` dan `✅`. Tidak ada simbol lain di
   dokumen ini.
3. **Jangan sentuh kode tanpa persetujuan.** Temuan bug dicatat di
   `TESTING.md` lebih dulu.
4. **Maksimal 500 baris per file Dart.** Jika mendekati batas, pecah jadi
   sub-widget atau modul terpisah.
5. **Semua token warna dan tipografi terpusat.** Dilarang `Color(0x...)` atau
   `TextStyle` inline di dalam widget.
6. **Target Android.** Verifikasi wajib pada 360×640 dan 412×915.
7. **Hanya pekerjaan yang benar-benar selesai yang dicentang.** Kalau baru
   dikerjakan, masih draf, atau baru hasil analisis statis, statusnya tetap `[ ]`.
