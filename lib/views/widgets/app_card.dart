import 'neo_card.dart';

/// Alias lama untuk [NeoCard].
///
/// `AppCard` dipakai 25 call site di delapan halaman. Mulai 3.2 nama
/// kanoniknya adalah `NeoCard`, tapi alias ini sengaja dipertahankan supaya
/// halaman yang belum masuk Tahap 4 tidak ikut rusak. Hapus bersama
/// pemakaian terakhirnya di Tahap 4.
///
/// Catatan migrasi: `AppCard` lama punya parameter `border` berupa
/// [BoxBorder] mentah, dan tiga pemanggilnya memakai warna berbeda per sisi.
/// Flutter menolak `borderRadius` pada border tak seragam, jadi itu tidak
/// pernah bisa dirender. `NeoCard` menggantinya dengan `borderColor` tunggal
/// yang selalu seragam. Tiga call site itu sudah dikonversi pada 3.2.
typedef AppCard = NeoCard;
