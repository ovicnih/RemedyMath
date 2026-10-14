/// Barrel re-export untuk widget analitik.
///
/// Diekspor ulang lewat `common.dart` supaya `SessionTile` tetap bisa
/// diambil dari satu import, sama seperti sebelum pemecahan berkas
/// (AGENTS.md §3).
///
/// `ThetaScale` pernah diekspor dari sini. Widget itu dihapus pada Tahap
/// 3.5 karena hanya `Stack` + `Positioned` — dilarang `AGENTS.md`
/// §2 — dan bentuknya tidak sesuai desain. Bar kemampuan theta sekarang
/// memakai `NeoProgressBar`; lihat `diagnosis_result_page.dart` dan
/// `progress_page.dart`.
library;

export 'session_tile.dart';
