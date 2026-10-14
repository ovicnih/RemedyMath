# AI_DECLARATION — Deklarasi Transparansi Penggunaan AI

Dokumen ini menyatakan secara terbuka bagaimana kecerdasan buatan (AI)
dipakai dalam pengembangan aplikasi **RemedyMath** (asisten remediasi
matematika SMA berbasis Item Response Theory & Knowledge Graph).

Tujuannya bukan mengklaim karya, melainkan menjelaskan peran tiap alat,
batas kontribusi AI, dan penyesuaian manual yang dilakukan agar kode
berjalan stabil dan dapat dipertanggungjawabkan.

---

## 1. Daftar Alat

| Alat | Peran dalam proyek | Dipakai untuk |
|---|---|---|
| **Google Gemini** | Tanya-jawab pemahaman & penunjuk arah | Menanyakan konsep (Rasch 1PL, Newton-Raphson, knowledge graph, kontras WCAG 2.1), meminta arahan struktur dan keputusan desain. Tidak menghasilkan kode aplikasi langsung. |
| **opencode** (agent Build / "Big Pickle") | Pembuat project | Menghasilkan berkas Dart (model, service, controller, halaman, widget), refactor, redesign UI, serta dokumentasi proyek. |
| **Google Antigravity** | Pencari bug / error | Menjalankan analisis (`flutter analyze`), melacak runtime error, overflow layout, assertion widget, dan kegagalan build APK. |

Tidak ada alat lain yang dipakai. **GitHub Copilot, ChatGPT, dan Claude
tidak digunakan** dalam proyek ini.

Cara kerja: **Gemini** untuk memahami masalah dan menentukan arah →
**opencode** untuk membangun kode → **Antigravity** untuk menemukan dan
memverifikasi error → mahasiswa menyesuaikan logika, memutuskan, dan
memverifikasi akhir.

---

## 2. Pembagian Peran

### Modul yang dibantu AI

| Area | Berkas / modul | Kontribusi AI |
|---|---|---|
| Token desain | `lib/core/*` | Menulis ulang palet, tipografi, ukuran, tema ke gaya neobrutalism |
| Widget reusable | `lib/views/widgets/*` | Membuat `NeoCard`, `NeoButton`, `AnswerOption`, `AppHeader`, dll. |
| Halaman UI | `lib/views/pages/*` | Menyusun layout `Column`/`Row`, redesign 4 halaman referensi |
| Scaffold model | `lib/models/models.dart` | Kerangka kelas data + null-safety |
| Kerangka service | `lib/services/*` | Struktur awal IRT, knowledge graph, penyimpanan lokal, repository |
| Dokumentasi | `docs/project/*`, `README.md` | Menyusun PLANNING, TASK, HISTORY, UI-REFERENCE |
| Kerangka pengujian | `test/*` | Menulis unit test IRT, knowledge graph, kontras, `NeoCard` |

### Modul yang murni ditulis / diputuskan manual (mahasiswa)

| Area | Penyesuaian manual |
|---|---|
| Keputusan produk & desain | Memilih palet final, navigasi bawah, font **Inter**, ejaan `RemedyMath` |
| Logika IRT | Menentukan penanganan skor ekstrem (semua benar → θ `+2.0`, semua salah → θ `−2.0`) dan batas θ |
| Knowledge graph | Menentukan aturan *backward traversal* akar masalah dan urutan prioritas |
| Integrasi & stabilitas | Memperbaiki `clamp`, overflow layout, border tidak seragam, import paket |
| Validasi form | Memastikan input profil tidak `null`/kosong sebelum diproses |
| Verifikasi akhir | Menjalankan `flutter analyze`, `flutter test`, `flutter build apk --debug` |

Prinsip yang dipegang: **AI menghasilkan draf, mahasiswa memverifikasi.**
Tidak ada kode AI yang dipakai sebelum lolos `flutter analyze` bersih dan
`flutter test` hijau.

---

## 3. Studi Kasus Prompting

Dua belas kasus nyata. Prompt ditulis ringkas; sebagian dikutip dari sesi
kerja di folder `Save/`, sebagian direkonstruksi dari riwayat perubahan
proyek. Tiap kasus memuat **hasil awal AI** dan **penyesuaian manual** agar
kode stabil.

### Kasus 1 — Integrasi source AI ke project Flutter (opencode)

**Prompt:** "Gabungkan source aplikasi RemediMath ke dalam project Flutter
ini, nama paket tetap `remedy_math`, lalu pastikan bisa dijalankan."

**Hasil awal AI:** Menyalin 24 berkas Dart ke `lib/`, menggabungkan
`pubspec.yaml`, menambahkan `assets/data/`. Namun import masih memakai path
relatif dan test bawaan template ikut terbawa.

**Penyesuaian manual:**

```dart
// SEBELUM (gagal dikompilasi)
import '../../lib/core/app_colors.dart';

// SESUDAH (benar)
import 'package:remedy_math/core/app_colors.dart';
```

- Menghapus `test/widget_test.dart` bawaan template yang tidak relevan.
- Mencadangkan berkas asal ke `_backup_default/` sebelum mengubah.

### Kasus 2 — Runtime error `ArgumentError: Invalid argument: 0` (Antigravity)

**Prompt:** "Aplikasi melempar `ArgumentError: Invalid argument: 0` di fungsi
`clamp` saat halaman dibuka. Cari penyebab dan perbaiki."

**Hasil awal AI:** Menyarankan `clamp` dibatasi ulang, tetapi belum aman
ketika lebar dari `LayoutBuilder` bernilai `0` atau tidak hingga.

**Penyesuaian manual:**

```dart
// SEBELUM — melempar saat w < 2 (lower > upper)
final double knob = value.clamp(0.0, w - 2);

// SESUDAH — lebar dinormalisasi dulu, batas bawah dijaga >= 0
final double safeW = (w.isFinite && w > 0) ? w : 0.0;
const double markerWidth = 2;
final double upper = (safeW - markerWidth) < 0 ? 0.0 : safeW - markerWidth;
final double knob = value.clamp(0.0, upper);
```

Konstanta `2` dipisah menjadi `const` supaya tidak dihitung ulang dari `w`.

### Kasus 3 — `RenderFlex overflowed by 159 pixels` (Antigravity)

**Prompt:** "Ada `RenderFlex overflowed by 159 pixels on the right`. Cari
widget mana yang meluber lalu perbaiki tanpa mengunci ukuran piksel."

**Hasil awal AI:** Menunjuk empat kandidat lokasi, tetapi perbaikan awal
masih memakai `Text` rigid.

**Penyesuaian manual:** memberi `Flexible` + ellipsis pada kolom sempit.

```dart
// SEBELUM — teks rigid di dalam Row selebar ~1/3 kartu
Row(children: <Widget>[Text(value), const Spacer(), Text(label)]),

// SESUDAH — boleh menyusut, sisanya jadi elipsis
Row(children: <Widget>[
  Flexible(child: Text(value, overflow: TextOverflow.ellipsis)),
  const SizedBox(width: AppSizes.spaceSm),
  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
]),
```

### Kasus 4 — Migrasi token neobrutalism + `RadioThemeData` (opencode/Gemini)

**Prompt:** "Ganti token Material 3 indigo ke palet neobrutalism (border tebal,
bayangan tajam, warna solid). Pastikan tidak ada gradien."

**Hasil awal AI:** Menulis ulang `app_colors.dart`, `app_text_styles.dart`,
dan `app_theme.dart`. Namun mencoba memasang border radio lewat
`RadioThemeData`.

**Penyesuaian manual:** setelah dicek ke sumber SDK Flutter 3.27.4,
`RadioThemeData` **tidak punya** parameter `side`, sehingga border dipasang di
level widget `Radio`:

```dart
// TIDAK BISA: RadioThemeData(side: ...) tidak ada di Flutter 3.27.4
Radio(
  value: option,
  groupValue: selected,
  fillColor: WidgetStatePropertyAll(AppColors.ink),
  // border radio dipasang langsung di widget
)
```

### Kasus 5 — Bundling font Inter + lisensi (Gemini/opencode)

**Prompt:** "Desain memakai font Inter. Arial tidak boleh di-redistribusi di
APK. Bagaimana cara yang benar membundel font?"

**Hasil awal AI:** Menyarankan `fontFamily: 'Inter'` di `pubspec.yaml`, tetapi
belum menyertakan lisensi.

**Penyesuaian manual:** membundel empat weight + lisensi OFL, lalu mengubah
`AppTextStyles.sans`.

```yaml
# pubspec.yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf   # 400
      - asset: assets/fonts/Inter-Medium.ttf    # 500
      - asset: assets/fonts/Inter-Bold.ttf      # 700
      - asset: assets/fonts/Inter-Black.ttf     # 900
```

`Inter-OFL.txt` disertakan karena SIL OFL 1.1 mewajibkannya, dan fallback
diatur ke `Roboto` → `sans-serif`.

### Kasus 6 — Audit kontras WCAG; `Color.r` berupa `double` (Gemini/opencode)

**Prompt:** "Buat pengujian otomatis yang memastikan teks cukup kontras
(minimal AA 4.5) di atas semua latar palet."

**Hasil awal AI:** Menulis `relativeLuminance()` dengan asumsi `Color.r`
bernilai `int` 0–255, sehingga hasilnya salah (rasio 1.01).

**Penyesuaian manual:** di Flutter 3.27, `Color.r/g/b` mengembalikan
`double` 0.0–1.0.

```dart
// SEBELUM — salah (menganggap int 0..255)
double _channel(int c) => c / 255;

// SESUDAH — benar, kanal sudah 0.0..1.0
double _channelLuminance(double normalized) {
  final double c = normalized;
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}
```

Keputusan turunan: aksen dilarang dipakai sebagai warna teks (kontras terhadap
`background` ≤ 3.0), dikunci lewat test.

### Kasus 7 — `NeoCard` & assertion border tidak seragam (Antigravity)

**Prompt:** "Unit test `NeoCard` gagal: 'A borderRadius can only be given on
borders with uniform colors.' Cari akar masalahnya."

**Hasil awal AI:** Menyarankan mengganti `borderRadius`, padahal penyebabnya
adalah border per sisi berwarna berbeda.

**Penyesuaian manual:** referensi desain tidak pernah memakai border per sisi,
jadi dibuat satu `borderColor` seragam.

```dart
// SEBELUM — warna berbeda per sisi + borderRadius -> melempar saat paint()
border: Border(
  top: BorderSide(color: AppColors.accentPink, width: 3),
  left: BorderSide(color: AppColors.ink, width: 3),
),

// SESUDAH — satu warna seragam (app/neo_card.dart)
static Border borderFor(Color color) => Border.all(
      color: color,
      width: AppSizes.borderThick,
    );
```

### Kasus 8 — Redesign Beranda: reflow tiga kartu (opencode)

**Prompt:** "Redesign halaman Beranda mengikuti UI-REFERENCE.md dengan token
neobrutalism. Jangan pakai ukuran piksel mati."

**Hasil awal AI:** Menyalin tata letak tiga kartu sebaris (mengikuti Figma
1920 px).

**Penyesuaian manual:** pada lebar 360 dp tiga kartu tidak muat, sehingga
direflow menjadi satu kolom.

```dart
// SEBELUM — 3 kartu sebaris, sesak / overflow di ponsel
Row(children: <Widget>[cardA, cardB, cardC]),

// SESUDAH — menumpuk vertikal, aman di semua lebar
Column(children: <Widget>[
  cardA,
  const SizedBox(height: AppSizes.spaceMd),
  cardB,
  const SizedBox(height: AppSizes.spaceMd),
  cardC,
]),
```

### Kasus 9 — Redesign Kuis: `PopScope` dan tombol lanjut (opencode)

**Prompt:** "Redesign halaman Kuis. Pastikan keluar di tengah tes tetap
memunculkan dialog konfirmasi, dan soal boleh dilewati."

**Hasil awal AI:** Menambahkan tombol tutup di dalam kartu, sehingga
konfirmasi muncul dua kali dan `PopScope` tidak dihormati.

**Penyesuaian manual:** tombol tutup dihapus, kembali lewat AppBar +
`Navigator.maybePop`.

```dart
// SEBELUM — langsung pop, mengabaikan PopScope
onPressed: () => Navigator.of(context).pop(),

// SESUDAH — menghormati canPop = false sehingga dialog tetap tampil
onPressed: () => Navigator.of(context).maybePop(),
```

Tombol "Soal berikutnya" sengaja tetap aktif agar soal boleh dilewati
(perilaku lama dipertahankan).

### Kasus 10 — Redesign Hasil Diagnosis: pecah berkas <500 baris (opencode)

**Prompt:** "Redesign halaman Hasil Diagnosis. Ikuti batas 500 baris per
berkas di AGENTS.md."

**Hasil awal AI:** Menaruh seluruh seksi desain dalam satu berkas, sehingga
melewati 500 baris.

**Penyesuaian manual:** seksi berat dipindah ke berkas `part of` agar tiap
berkas tetap di bawah 500 baris sambil mempertahankan kelas privat.

```dart
// diagnosis_result_page.dart (217 baris)
part 'diagnosis_result_sections.dart';

// diagnosis_result_sections.dart (357 baris)
part of 'diagnosis_result_page.dart';
```

### Kasus 11 — Build APK gagal di JDK 21 → AGP (Antigravity)

**Prompt:** "`flutter build apk --debug` gagal di JDK 21. Cari penyebab dan
solusinya."

**Hasil awal AI:** Menyarankan menurunkan versi JDK.

**Penyesuaian manual:** akarnya adalah bug Android Gradle Plugin < 8.2.1 pada
Java 21, jadi AGP dinaikkan, bukan JDK diturunkan.

```groovy
// android/settings.gradle
id "com.android.application" version "8.1.0" apply false   // SEBELUM
id "com.android.application" version "8.2.2" apply false   // SESUDAH
```

Setelah itu `build/app/outputs/flutter-apk/app-debug.apk` berhasil dibuat.

### Kasus 12 — README bergambar + `Save/` di `.gitignore` (opencode)

Prompt asli dari sesi di folder `Save/`:

**Prompt:** "di readme bisa dikasih gambar?" → "progress disini besar sendiri
bisa tidak di samakan semua ukuran gambarnya?" → "folder Save jangan masukkan
ke github" → "cukup ganti saja gitignore saya akan push sendiri".

**Hasil awal AI:** Menyisipkan lima gambar dalam tabel terpisah sehingga
ukurannya tampak tidak seragam, lalu sempat mencoba melakukan commit sendiri.

**Penyesuaian manual:**

- Gambar disatukan dalam **satu tabel 2 kolom** agar semua tampil sama besar.
- `.gitignore` ditambah `Save/`, tanpa melakukan `git push` (mahasiswa push
  sendiri).
- Memastikan `git status` bersih (0 changed files) setelah `Save/`
  di-untrack.

```gitignore
# Internal project documentation, planning, and testing notes
/docs/
/Save/
```

---

## 4. Pernyataan

Seluruh keputusan produk, logika inti IRT dan knowledge graph, penyesuaian
agar kode stabil, serta verifikasi akhir (`flutter analyze` bersih,
`flutter test` hijau, APK terbangun) dilakukan dan dipertanggungjawabkan oleh
penulis. AI dipakai sebagai alat bantu berpikir dan mempercepat penulisan
draf, bukan sebagai pengganti pemahaman.

---

*Dokumen ini dibuat sebagai bagian dari transparansi pengerjaan tugas
Mobile Programming.*
