# Product Requirements Document (PRD): CashFlow

*Aplikasi Mobile Pengelolaan Keuangan Pribadi (Flutter) – Versi MVP*

## 1. Document Information

| Item | Keterangan |
| --- | --- |
| Nama Produk | CashFlow |
| Platform | Aplikasi mobile (Android dan iOS) |
| Framework | Flutter (Dart), satu basis kode untuk Android dan iOS |
| Tahap Produk | Minimum Viable Product (MVP) |
| Versi Dokumen | 1.1 (Draft untuk review) |
| Tanggal | 16 November 2026 |
| Penyusun | Product Manager / Business Analyst |
| Pembaca Utama | Tim UI/UX Design, Tim Pengembang (Flutter), QA, Stakeholder |
| Status | Draft – menunggu konfirmasi atas poin pada bagian Assumptions dan Constraints |

**Riwayat perubahan:**

| Versi | Perubahan |
| --- | --- |
| 1.0 | Draft awal dengan platform website. |
| 1.1 | Platform diubah dari website menjadi aplikasi mobile berbasis Flutter. Penyesuaian dilakukan pada platform, kebutuhan non-fungsional (kompatibilitas perangkat, izin, konektivitas, aksesibilitas sentuh), UI/UX, alur pengguna, asumsi, batasan, dan Future Development. Lingkup fungsional MVP (FR-01 s.d. FR-20) tidak berubah. |

**Skala prioritas:** *Must Have* (wajib ada pada MVP), *Should Have* (penting, dikerjakan setelah Must Have bila waktu memungkinkan), *Could Have* (nilai tambah, dikerjakan jika sumber daya tersedia).

## 2. Product Overview

CashFlow adalah aplikasi mobile pengelolaan keuangan pribadi yang membantu pengguna mencatat pemasukan dan pengeluaran, mengelola beberapa wallet, memantau saldo, serta menganalisis kondisi keuangan secara digital langsung dari ponsel mereka. Aplikasi dibangun dengan Flutter sehingga tersedia untuk Android dan iOS dari satu basis kode.

**Target pengguna:** mahasiswa, pekerja, dan masyarakat umum yang ingin mengelola keuangan pribadi.

**Nilai utama produk:**

- **Sederhana:** pencatatan transaksi cepat dan mudah dipahami pengguna non-finansial, dapat dilakukan dalam beberapa ketukan.
- **Terpisah per wallet:** uang dipisahkan sesuai sumber penyimpanan (tunai, bank, e-wallet, tabungan) dengan identitas visual masing-masing.
- **Terkendali:** batas anggaran bulanan dengan indikator peringatan.
- **Informatif:** dashboard, grafik, dan analisis pengeluaran terbesar yang selalu konsisten dengan data transaksi.
- **Selalu di genggaman:** pengguna dapat mencatat transaksi saat itu juga, di mana pun mereka berada.

## 3. Background dan Problem Statement

**Latar belakang.** Banyak orang tidak mengetahui ke mana uangnya pergi karena pencatatan dilakukan secara manual, tidak konsisten, atau tersebar di beberapa tempat (catatan ponsel, buku, spreadsheet). Uang juga tersimpan di banyak tempat sekaligus, misalnya uang tunai, rekening bank, dan dompet digital, sehingga sulit melihat kondisi keuangan secara menyeluruh. Pengeluaran terjadi di mana saja, sehingga pencatatan paling efektif bila dapat dilakukan seketika dari ponsel.

**Problem statement.**

1. Pengguna kesulitan mencatat pemasukan dan pengeluaran secara teratur dan terstruktur.
2. Pengguna tidak memiliki gambaran total saldo dan saldo per sumber penyimpanan dalam satu tempat.
3. Pengguna sering melebihi rencana pengeluaran karena tidak ada batas dan peringatan yang jelas.
4. Pengguna tidak mengetahui kategori yang paling banyak menyerap uangnya.

**Peluang.** Menyediakan aplikasi mobile yang ringan dan fokus pada pencatatan serta pemantauan, tanpa kompleksitas fitur keuangan lanjutan.

## 4. Product Goals dan Objectives

**Tujuan produk (goals):**

- G1: Membantu pengguna membangun kebiasaan mencatat keuangan harian.
- G2: Memberikan gambaran keuangan yang akurat dan real-time dalam satu dashboard.
- G3: Membantu pengguna menjaga pengeluaran sesuai batas anggaran bulanan.
- G4: Memberikan wawasan pola pengeluaran agar pengguna dapat mengambil keputusan lebih baik.

**Objectives (terukur, target awal untuk dikonfirmasi):**

| ID | Objective | Indikator Keberhasilan |
| --- | --- | --- |
| O1 | Pencatatan transaksi cepat | Pengguna baru dapat mencatat transaksi pertama ≤ 3 menit sejak membuat wallet |
| O2 | Akurasi data | 100% saldo, dashboard, grafik, dan analisis sesuai dengan data transaksi (nol selisih perhitungan) |
| O3 | Adopsi fitur inti | ≥ 60% pengguna aktif membuat minimal 1 wallet dan 5 transaksi pada minggu pertama |
| O4 | Pengendalian anggaran | ≥ 40% pengguna aktif menetapkan batas anggaran bulanan |
| O5 | Retensi | ≥ 30% pengguna kembali mencatat transaksi pada minggu ke-4 |

*Catatan: angka target merupakan usulan awal dan perlu dikonfirmasi stakeholder.*

## 5. Target Users dan User Persona

**Segmen pengguna:** mahasiswa, pekerja, dan masyarakat umum.

### Persona 1 – Rani, Mahasiswa (21 tahun)

- **Kondisi:** Uang bulanan dari orang tua dan penghasilan sampingan; menyimpan uang di uang tunai, rekening bank, dan e-wallet. Selalu membawa ponsel.
- **Kebutuhan:** Mengetahui sisa uang sampai akhir bulan dan mengendalikan jajan serta hiburan.
- **Kendala:** Sering lupa mencatat dan tidak punya waktu untuk alat yang rumit.
- **Harapan:** Pencatatan cepat dari ponsel, batas anggaran, dan peringatan sederhana.

### Persona 2 – Dimas, Pekerja Kantoran (28 tahun)

- **Kondisi:** Gaji tetap bulanan, cicilan dan tagihan rutin, ingin menabung.
- **Kebutuhan:** Memisahkan wallet gaji, tabungan, dan dana harian; melihat kategori pengeluaran terbesar.
- **Kendala:** Pengeluaran kecil berulang tidak terpantau.
- **Harapan:** Grafik bulanan dan analisis persentase per kategori yang nyaman dibaca di layar ponsel.

### Persona 3 – Ibu Sari, Masyarakat Umum (40 tahun)

- **Kondisi:** Mengatur keuangan rumah tangga, banyak transaksi tunai.
- **Kebutuhan:** Antarmuka jelas dan bahasa sederhana; riwayat yang mudah dicari.
- **Kendala:** Kurang familiar dengan aplikasi keuangan; membutuhkan teks dan tombol yang cukup besar.
- **Harapan:** Alur pencatatan sedikit langkah dan tampilan mudah dibaca.

## 6. Product Scope (MVP dan Out of Scope)

### 6.1 In Scope (MVP)

1. Pencatatan pemasukan dan pengeluaran (tambah, ubah, hapus).
2. Pengelompokan kategori transaksi (default dan kategori buatan pengguna).
3. Dashboard saldo keuangan.
4. Grafik pemasukan dan pengeluaran (harian, mingguan, bulanan).
5. Batas anggaran bulanan.
6. Riwayat, filter, dan pencarian transaksi.
7. Analisis pengeluaran terbesar.
8. Widget dashboard (kartu ringkasan di dalam aplikasi).
9. Manajemen multiple wallet beserta gambar/ikon wallet.
10. Aturan perhitungan keuangan yang konsisten.
11. Aplikasi mobile untuk Android dan iOS yang dibangun dengan Flutter.

### 6.2 Out of Scope (tidak termasuk MVP)

- Integrasi langsung dengan rekening bank.
- Payment gateway.
- Transfer antar pengguna.
- Investasi.
- Pinjaman.
- Fitur keuangan kompleks lainnya (misalnya pajak, pembukuan bisnis, dan multi-mata uang).
- Versi website atau desktop.
- Widget layar utama (home screen widget) milik sistem operasi Android/iOS. Istilah "widget dashboard" pada dokumen ini hanya merujuk pada kartu ringkasan di dalam aplikasi.
- Notifikasi push dan pengingat.
- Tata letak khusus tablet dan mode lanskap yang dioptimalkan.

Ide tambahan dicatat pada bagian **15. Future Development**.

## 7. Functional Requirements

### 7.1 Hubungan antara Wallet, Transaksi, Kategori, dan Anggaran

- **Wallet** adalah wadah sumber penyimpanan uang. Setiap wallet memiliki nama, saldo awal, dan gambar/ikon.
- **Transaksi** adalah catatan pemasukan atau pengeluaran. Setiap transaksi **wajib terhubung dengan tepat satu wallet** dan **tepat satu kategori**. Transaksi hanya memengaruhi saldo wallet yang dipilih.
- **Kategori** mengelompokkan transaksi. Kategori memiliki jenis (pemasukan atau pengeluaran); transaksi pemasukan hanya memakai kategori pemasukan, dan transaksi pengeluaran hanya memakai kategori pengeluaran.
- **Anggaran bulanan** dihitung dari **total pengeluaran dalam bulan berjalan pada seluruh wallet**. Hanya transaksi berjenis pengeluaran yang mengurangi anggaran; pemasukan tidak menambah sisa anggaran.
- **Dashboard, grafik, analisis, dan widget** hanya membaca (menurunkan) data dari wallet dan transaksi sehingga tidak menyimpan angka sendiri yang dapat berbeda.

Relasi ringkas: Pengguna 1–N Wallet; Wallet 1–N Transaksi; Kategori 1–N Transaksi; Pengguna 1–N Anggaran bulanan (satu per bulan).

### 7.2 Daftar Functional Requirements

| ID | Modul | Kebutuhan Singkat | Prioritas |
| --- | --- | --- | --- |
| FR-01 | Wallet | Membuat wallet | Must Have |
| FR-02 | Wallet | Gambar/ikon wallet | Must Have |
| FR-03 | Wallet | Mengedit wallet | Must Have |
| FR-04 | Wallet | Menghapus wallet | Must Have |
| FR-05 | Transaksi | Menambah transaksi | Must Have |
| FR-06 | Transaksi | Mengedit transaksi | Must Have |
| FR-07 | Transaksi | Menghapus transaksi | Must Have |
| FR-08 | Kategori | Kategori default | Must Have |
| FR-09 | Kategori | Kategori buatan pengguna | Should Have |
| FR-10 | Dashboard | Ringkasan saldo | Must Have |
| FR-11 | Grafik | Grafik pemasukan vs pengeluaran | Must Have |
| FR-12 | Anggaran | Menetapkan batas anggaran bulanan | Must Have |
| FR-13 | Anggaran | Penggunaan, sisa, dan indikator anggaran | Must Have |
| FR-14 | Riwayat | Riwayat transaksi | Must Have |
| FR-15 | Riwayat | Filter transaksi | Must Have |
| FR-16 | Riwayat | Pencarian transaksi | Should Have |
| FR-17 | Analisis | Analisis pengeluaran terbesar | Should Have |
| FR-18 | Widget | Widget dashboard | Must Have |
| FR-19 | Perhitungan | Aturan perhitungan dan konsistensi | Must Have |
| FR-20 | Wallet | Memilih gambar wallet milik sendiri dari galeri/kamera | Could Have |

### 7.3 Detail Functional Requirements

#### Wallet Management

**FR-01 – Membuat Wallet (Must Have)**

- *Tujuan:* Memisahkan uang berdasarkan sumber penyimpanan.
- *Fungsi dan cara kerja:* Pengguna dapat membuat lebih dari satu wallet. Setiap wallet memiliki nama dan saldo awal. Pengguna mengisi nama, saldo awal (boleh 0), dan memilih gambar/ikon, lalu menyimpan. Wallet baru langsung tampil di dashboard dan pada pilihan wallet saat mencatat transaksi. Kolom saldo awal menampilkan keyboard numerik.
- *Contoh wallet:* Cash (uang tunai), Bank BCA (rekening bank), E-Wallet (dompet digital), Savings (tabungan pribadi).

**FR-02 – Gambar/Ikon Wallet (Must Have)**

- *Tujuan:* Memberi identitas visual agar wallet mudah dikenali.
- *Fungsi:* Sistem menyediakan pilihan gambar/ikon bawaan yang dikemas di dalam aplikasi. Setiap wallet dapat memiliki gambar yang berbeda. Gambar hanya berfungsi sebagai identitas visual wallet dan **bukan** gambar transaksi. Gambar wallet tampil pada daftar wallet, kartu saldo dashboard, dan pemilih wallet saat membuat transaksi.

**FR-20 – Memilih Gambar Wallet Milik Sendiri (Could Have)**

- *Tujuan:* Memberi kebebasan personalisasi.
- *Fungsi:* Jika memungkinkan, pengguna dapat memilih gambar sendiri dari galeri atau mengambilnya dengan kamera sebagai gambar wallet. Izin akses galeri/kamera hanya diminta saat pengguna memilih opsi ini. Jika izin ditolak atau fitur ini belum tersedia, pengguna tetap dapat memakai gambar/ikon bawaan. Format dan ukuran maksimum perlu dikonfirmasi (lihat Assumptions).

**FR-03 – Mengedit Wallet (Must Have)**

- Pengguna dapat mengubah nama dan gambar/ikon wallet. Perubahan saldo awal diperbolehkan dan menghitung ulang saldo wallet serta total saldo secara otomatis. Perubahan nama atau gambar langsung tercermin di seluruh layar, termasuk riwayat transaksi lama.

**FR-04 – Menghapus Wallet (Must Have)**

- Pengguna dapat menghapus wallet setelah dialog konfirmasi yang menjelaskan dampaknya. Perilaku terhadap transaksi milik wallet tersebut *perlu dikonfirmasi*. Usulan default: wallet yang masih memiliki transaksi tidak dapat dihapus sebelum transaksinya dihapus atau wallet diarsipkan; wallet tanpa transaksi dapat dihapus langsung. Pengguna tidak dapat menghapus wallet terakhir yang dimilikinya.

#### Pencatatan Transaksi

**FR-05 – Menambah Transaksi (Must Have)**

- *Tujuan:* Mencatat arus uang masuk dan keluar.
- *Fungsi dan cara kerja:* Pengguna mengetuk tombol "Tambah Transaksi", memilih jenis transaksi (pemasukan atau pengeluaran), lalu mengisi:
  - Nominal (wajib, angka lebih dari 0; memakai keyboard numerik).
  - Tanggal (wajib, default hari ini; tanggal lampau diperbolehkan; dipilih melalui pemilih tanggal).
  - Kategori (wajib; daftar menyesuaikan jenis transaksi).
  - Wallet (wajib).
  - Deskripsi (opsional, batas panjang perlu dikonfirmasi).
- Setelah disimpan, saldo wallet, total saldo, total pemasukan/pengeluaran, grafik, anggaran, dan analisis diperbarui.

**FR-06 – Mengedit Transaksi (Must Have)**

- Pengguna dapat mengubah seluruh field transaksi, termasuk wallet, kategori, nominal, dan tanggal. Setelah perubahan, seluruh angka turunan dihitung ulang. Jika wallet diubah, transaksi berpindah dari wallet lama ke wallet baru (saldo lama pulih, saldo baru berubah).

**FR-07 – Menghapus Transaksi (Must Have)**

- Pengguna dapat menghapus transaksi setelah konfirmasi. Efek transaksi pada saldo dan statistik dibatalkan sepenuhnya.

#### Kategori

**FR-08 – Kategori Default (Must Have)**

- Sistem menyediakan kategori bawaan untuk pemasukan dan pengeluaran.
- *Usulan pemasukan:* Gaji, Uang Saku, Bonus, Hasil Usaha, Lainnya.
- *Usulan pengeluaran:* Makanan & Minuman, Transportasi, Belanja, Tagihan & Utilitas, Pendidikan, Kesehatan, Hiburan, Lainnya.
- Daftar final perlu dikonfirmasi. Kategori default tidak dapat dihapus.

**FR-09 – Kategori Buatan Pengguna (Should Have)**

- Pengguna dapat menambahkan kategori sendiri dengan nama unik per jenis (pemasukan/pengeluaran). Pengguna dapat mengubah nama dan menghapus kategori buatannya. Kategori yang sudah dipakai transaksi tidak dapat dihapus sebelum transaksinya dipindahkan ke kategori lain (usulan, perlu dikonfirmasi).

#### Dashboard dan Grafik

**FR-10 – Dashboard Saldo Keuangan (Must Have)**

- *Tujuan:* Memberi gambaran keuangan dalam sekali lihat.
- *Fungsi:* Dashboard menampilkan (a) total saldo keseluruhan, (b) total pemasukan, (c) total pengeluaran, dan (d) saldo masing-masing wallet beserta gambarnya. Total pemasukan dan pengeluaran mengikuti periode yang dipilih (default: bulan berjalan; perlu dikonfirmasi). Dashboard dapat digulir secara vertikal dan dapat disegarkan dengan tarik-untuk-menyegarkan (pull-to-refresh).

**FR-11 – Grafik Pemasukan dan Pengeluaran (Must Have)**

- Menampilkan perbandingan pemasukan dan pengeluaran dengan visualisasi periode **harian, mingguan, dan bulanan**. Pengguna dapat berpindah periode dan rentang waktu melalui kontrol yang mudah dijangkau dengan jempol (misalnya tab periode dan tombol geser rentang). Nilai detail ditampilkan saat grafik disentuh. Jika tidak ada data, ditampilkan keadaan kosong beserta ajakan mencatat transaksi.

#### Anggaran

**FR-12 – Menetapkan Batas Anggaran Bulanan (Must Have)**

- Pengguna dapat menetapkan, mengubah, dan menghapus nominal batas anggaran untuk suatu bulan. Pada MVP, anggaran bersifat **total pengeluaran per bulan** (bukan per kategori; lihat Future Development). Perilaku bulan baru (apakah anggaran otomatis berlanjut dari bulan sebelumnya) perlu dikonfirmasi; usulan: otomatis berlanjut dan dapat diubah.

**FR-13 – Penggunaan, Sisa, dan Indikator Anggaran (Must Have)**

- Sistem menampilkan jumlah anggaran terpakai, sisa anggaran, dan persentase penggunaan. Indikator status:
  - **Aman:** penggunaan di bawah 80% (ambang usulan).
  - **Mendekati batas:** penggunaan 80% sampai 100% (ambang usulan).
  - **Melewati batas:** penggunaan lebih dari 100%; sisa ditampilkan sebagai nilai terlampaui.
- Peringatan ditampilkan di dalam aplikasi (pada widget dan layar Anggaran); notifikasi push tidak termasuk MVP.
- Indikator tidak boleh hanya mengandalkan warna (tambahkan teks/ikon).

#### Riwayat, Filter, dan Pencarian

**FR-14 – Riwayat Transaksi (Must Have)**

- Menampilkan seluruh transaksi, terbaru di atas, berisi tanggal, jenis, kategori, deskripsi, wallet (dengan gambar), dan nominal. Daftar dimuat bertahap saat pengguna menggulir. Tindakan ubah dan hapus dapat diakses dari item transaksi (misalnya melalui ketuk item atau geser item; bentuk final ditentukan tim UI/UX).

**FR-15 – Filter Transaksi (Must Have)**

- Filter berdasarkan rentang tanggal, kategori, jenis transaksi, dan wallet. Filter dapat dikombinasikan, ditampilkan sebagai chip aktif, dan dapat direset. Ringkasan jumlah hasil dan total nominal hasil filter ditampilkan. Panel filter dapat ditampilkan sebagai bottom sheet (usulan).

**FR-16 – Pencarian Transaksi (Should Have)**

- Pencarian kata kunci pada deskripsi (dan nama kategori). Tidak membedakan huruf besar/kecil dan dapat dikombinasikan dengan filter.

#### Analisis

**FR-17 – Analisis Pengeluaran Terbesar (Should Have)**

- Menampilkan kategori dengan pengeluaran terbesar, persentase pengeluaran per kategori terhadap total pengeluaran periode, dan ringkasan pola pengeluaran berbentuk teks sederhana (misalnya: "Pengeluaran terbesar bulan ini adalah Makanan & Minuman sebesar 38% dari total pengeluaran"). Ringkasan dihasilkan dari aturan sederhana atas data transaksi, bukan saran keuangan.

#### Widget Dashboard

**FR-18 – Widget Dashboard (Must Have)**

- Dashboard menyajikan widget (kartu ringkasan di dalam aplikasi) berikut: Total Saldo, Pemasukan, Pengeluaran, Sisa Anggaran, Pengeluaran Terbesar, dan Transaksi Terbaru (usulan 5 transaksi terakhir, dengan tautan ke riwayat lengkap). Widget Pengeluaran Terbesar dan Sisa Anggaran menampilkan keadaan kosong yang informatif jika data belum ada. Kemampuan pengguna mengatur ulang/menyembunyikan widget **tidak** termasuk MVP. Widget layar utama sistem operasi (home screen widget) **tidak** termasuk MVP.

#### Aturan Perhitungan

**FR-19 – Aturan Perhitungan dan Konsistensi Data (Must Have)**

- **Saldo wallet = Saldo Awal + Total Pemasukan − Total Pengeluaran** (seluruh transaksi wallet tersebut).
- Setiap transaksi hanya tercatat pada wallet yang dipilih.
- **Total saldo keseluruhan = jumlah saldo seluruh wallet.**
- Dashboard, grafik, anggaran, dan analisis harus selalu konsisten dengan data transaksi.
- Tidak boleh ada perhitungan ganda: saldo awal tidak dihitung sebagai pemasukan, dan tidak dicatat sebagai transaksi terpisah pada total pemasukan. Total saldo tidak boleh dijumlahkan ulang dengan total transaksi.
- Seluruh angka diperbarui segera setelah transaksi/wallet ditambah, diubah, atau dihapus.

## 8. Non-Functional Requirements

| ID | Kategori | Kebutuhan |
| --- | --- | --- |
| NFR-01 | Kinerja | Dashboard tampil dalam ≤ 3 detik sejak aplikasi dibuka (setelah proses mulai dingin/cold start) pada perangkat kelas menengah, untuk pengguna dengan hingga 5.000 transaksi (angka usulan). |
| NFR-02 | Kinerja | Simpan/ubah/hapus transaksi memperbarui tampilan dalam ≤ 2 detik. |
| NFR-03 | Akurasi | Seluruh perhitungan keuangan akurat tanpa kesalahan pembulatan; konsisten di seluruh layar. |
| NFR-04 | Keamanan dan privasi | Data keuangan hanya dapat diakses oleh pemiliknya; data pribadi dilindungi sesuai standar keamanan platform. Jika data dikirim ke server, pengiriman melalui koneksi terenkripsi. Mekanisme perlindungan final mengikuti keputusan penyimpanan data (lihat Assumptions). |
| NFR-05 | Keandalan | Data tidak boleh hilang setelah penyimpanan berhasil, termasuk bila aplikasi ditutup paksa atau perangkat mati mendadak; pesan jelas ditampilkan saat penyimpanan gagal. |
| NFR-06 | Kompatibilitas | Berjalan pada Android dan iOS. Versi minimum usulan: Android 8.0 (API 26) ke atas dan iOS 14 ke atas (daftar final perlu dikonfirmasi berdasarkan data perangkat target pengguna). |
| NFR-07 | Adaptif | Tampilan nyaman pada berbagai ukuran layar ponsel dan kepadatan piksel, dengan orientasi potret sebagai orientasi utama. Tidak ada konten terpotong oleh notch, status bar, atau gesture bar (safe area). |
| NFR-08 | Kegunaan | Pengguna baru dapat mencatat transaksi pertama tanpa panduan tambahan. Tindakan utama dapat dijangkau dengan satu tangan. |
| NFR-09 | Aksesibilitas | Kontras warna memadai, ukuran area sentuh memadai (usulan minimal 48 × 48 dp), dukungan pembaca layar (TalkBack/VoiceOver) dengan label yang jelas, dukungan pengaturan ukuran teks sistem tanpa merusak tata letak, dan informasi tidak hanya disampaikan melalui warna. |
| NFR-10 | Lokalisasi | Bahasa antarmuka Bahasa Indonesia; mata uang Rupiah (IDR) dengan format ribuan Indonesia (contoh: Rp1.500.000); format tanggal DD/MM/YYYY. |
| NFR-11 | Validasi | Input divalidasi dengan pesan kesalahan yang jelas dan spesifik. |
| NFR-12 | Skalabilitas data | Riwayat, filter, dan grafik tetap berfungsi baik saat jumlah transaksi bertambah; guliran daftar tetap mulus. |
| NFR-13 | Konektivitas | Perilaku saat tidak ada koneksi internet harus jelas. Usulan: fitur inti pencatatan dan pemantauan tetap dapat dipakai tanpa koneksi. Keputusan final bergantung pada arsitektur penyimpanan data (perlu dikonfirmasi). |
| NFR-14 | Izin perangkat | Aplikasi hanya meminta izin perangkat yang benar-benar diperlukan (misalnya galeri/kamera untuk FR-20), pada saat fitur terkait digunakan, disertai penjelasan singkat. Fitur inti tidak boleh bergantung pada izin tersebut. |
| NFR-15 | Siklus hidup aplikasi | Aplikasi mempertahankan data dan konteks input dengan baik saat berpindah ke latar belakang, kembali ke latar depan, atau diinterupsi (misalnya panggilan masuk). |
| NFR-16 | Distribusi | Aplikasi memenuhi kebijakan toko aplikasi yang dituju (Google Play dan App Store), termasuk kebijakan privasi dan deklarasi penggunaan data. |

## 9. User Stories

| ID | User Story | FR Terkait |
| --- | --- | --- |
| US-01 | Sebagai pengguna, saya ingin membuat beberapa wallet, sehingga uang saya terpisah sesuai sumber penyimpanannya. | FR-01 |
| US-02 | Sebagai pengguna, saya ingin memberi gambar berbeda pada setiap wallet, sehingga saya mudah mengenali wallet dengan cepat. | FR-02, FR-20 |
| US-03 | Sebagai pengguna, saya ingin mengedit atau menghapus wallet, sehingga data wallet saya selalu sesuai kondisi sebenarnya. | FR-03, FR-04 |
| US-04 | Sebagai pengguna, saya ingin mencatat pemasukan dan pengeluaran beserta nominal, tanggal, kategori, deskripsi, dan wallet dari ponsel saya, sehingga semua arus uang saya terdokumentasi. | FR-05 |
| US-05 | Sebagai pengguna, saya ingin mengedit dan menghapus transaksi, sehingga saya dapat memperbaiki kesalahan pencatatan. | FR-06, FR-07 |
| US-06 | Sebagai pengguna, saya ingin memilih kategori default atau membuat kategori sendiri, sehingga transaksi saya terkelompok sesuai kebutuhan. | FR-08, FR-09 |
| US-07 | Sebagai pengguna, saya ingin melihat total saldo dan saldo setiap wallet, sehingga saya tahu kondisi keuangan saya saat ini. | FR-10 |
| US-08 | Sebagai pengguna, saya ingin melihat grafik pemasukan dan pengeluaran harian, mingguan, dan bulanan, sehingga saya memahami tren keuangan saya. | FR-11 |
| US-09 | Sebagai pengguna, saya ingin menetapkan batas anggaran bulanan, sehingga pengeluaran saya terkendali. | FR-12 |
| US-10 | Sebagai pengguna, saya ingin melihat anggaran terpakai, sisa anggaran, dan peringatan ketika mendekati atau melewati batas, sehingga saya dapat segera mengurangi pengeluaran. | FR-13 |
| US-11 | Sebagai pengguna, saya ingin melihat riwayat transaksi dan memfilternya, sehingga saya dapat menelusuri transaksi tertentu. | FR-14, FR-15 |
| US-12 | Sebagai pengguna, saya ingin mencari transaksi dengan kata kunci, sehingga saya cepat menemukan transaksi yang dimaksud. | FR-16 |
| US-13 | Sebagai pengguna, saya ingin melihat kategori pengeluaran terbesar beserta persentasenya, sehingga saya tahu pos yang perlu dihemat. | FR-17 |
| US-14 | Sebagai pengguna, saya ingin dashboard berisi widget ringkasan penting, sehingga saya memahami kondisi keuangan tanpa berpindah layar. | FR-18 |
| US-15 | Sebagai pengguna, saya ingin angka saldo, grafik, dan analisis selalu konsisten dengan transaksi saya, sehingga saya dapat memercayai data di CashFlow. | FR-19 |

## 10. User Flow

**Alur 1 – Onboarding dan wallet pertama**

1. Pengguna membuka aplikasi CashFlow untuk pertama kali (mekanisme akun perlu dikonfirmasi).
2. Sistem mengarahkan pengguna membuat wallet pertama jika belum ada.
3. Pengguna mengisi nama, saldo awal, dan memilih gambar/ikon.
4. Sistem menyimpan wallet dan menampilkan dashboard dengan saldo wallet.

**Alur 2 – Mencatat transaksi**

1. Pengguna mengetuk "Tambah Transaksi".
2. Pengguna memilih jenis (pemasukan/pengeluaran).
3. Pengguna mengisi nominal, tanggal, kategori, wallet, dan deskripsi.
4. Sistem memvalidasi input; jika tidak valid, pesan kesalahan ditampilkan.
5. Sistem menyimpan transaksi lalu memperbarui saldo wallet, total saldo, anggaran, grafik, dan analisis.
6. Pengguna kembali ke dashboard/riwayat dengan transaksi baru terlihat.

**Alur 3 – Mengedit atau menghapus transaksi**

1. Pengguna membuka riwayat dan memilih transaksi.
2. Pengguna memilih "Edit" atau "Hapus".
3. Untuk edit: ubah data lalu simpan. Untuk hapus: konfirmasi penghapusan.
4. Sistem menghitung ulang seluruh angka terkait.

**Alur 4 – Menetapkan dan memantau anggaran**

1. Pengguna membuka layar anggaran dan memasukkan batas bulanan.
2. Sistem menyimpan dan menampilkan widget Sisa Anggaran.
3. Setiap pengeluaran baru memperbarui penggunaan anggaran.
4. Saat penggunaan mencapai ambang, sistem menampilkan indikator "Mendekati batas"; saat melewati batas, "Melewati batas".

**Alur 5 – Menelusuri riwayat**

1. Pengguna membuka Riwayat Transaksi.
2. Pengguna mengisi pencarian dan/atau memilih filter tanggal, kategori, jenis, wallet.
3. Sistem menampilkan hasil yang sesuai; pengguna dapat mereset filter.

**Alur 6 – Menganalisis keuangan**

1. Pengguna membuka dashboard dan memilih periode grafik (harian/mingguan/bulanan).
2. Pengguna melihat widget Pengeluaran Terbesar dan layar analisis untuk persentase per kategori serta ringkasan pola.

## 11. Acceptance Criteria

**AC-FR-01 s.d. FR-04 (Wallet)**

- Pengguna dapat membuat lebih dari satu wallet; nama wallet kosong ditolak dengan pesan kesalahan.
- Saldo awal menerima angka ≥ 0 (nilai negatif perlu dikonfirmasi) dan tampil pada saldo wallet segera setelah dibuat.
- Kolom saldo awal menampilkan keyboard numerik pada perangkat.
- Setiap wallet dapat memiliki gambar berbeda dari yang lain; gambar tampil di dashboard, daftar wallet, dan pemilih wallet.
- Gambar wallet tidak tampil sebagai gambar pada transaksi.
- Setelah wallet diedit, nama/gambar baru tampil di seluruh layar termasuk riwayat.
- Penghapusan wallet menampilkan dialog konfirmasi; saldo total diperbarui setelah wallet dihapus.
- Wallet terakhir tidak dapat dihapus.

**AC-FR-20 (Gambar Wallet Milik Sendiri)**

- Izin galeri/kamera hanya diminta ketika pengguna memilih opsi gambar sendiri.
- Jika izin ditolak, pengguna tetap dapat memilih gambar/ikon bawaan dan fitur lain tidak terganggu.
- Gambar pilihan pengguna tampil pada dashboard, daftar wallet, dan pemilih wallet seperti gambar bawaan.

**AC-FR-05 s.d. FR-07 (Transaksi)**

- Transaksi tidak dapat disimpan jika nominal kosong, nol, atau negatif; atau jika tanggal, kategori, atau wallet belum dipilih.
- Kolom nominal menampilkan keyboard numerik dan tidak menerima karakter non-angka.
- Transaksi pemasukan menambah saldo wallet terpilih sebesar nominal; transaksi pengeluaran menguranginya sebesar nominal.
- Transaksi tidak memengaruhi saldo wallet lain.
- Daftar kategori yang muncul sesuai jenis transaksi.
- Setelah transaksi diedit (termasuk pergantian wallet), saldo wallet lama dan baru sesuai rumus pada FR-19.
- Setelah transaksi dihapus, transaksi tidak muncul di riwayat dan saldo, grafik, anggaran, serta analisis kembali seperti sebelum transaksi dicatat.
- Data yang sedang diisi pada form tidak hilang ketika aplikasi sementara berpindah ke latar belakang lalu kembali.

**AC-FR-08 dan FR-09 (Kategori)**

- Kategori default pemasukan dan pengeluaran tersedia pada pengguna baru.
- Kategori default tidak dapat dihapus.
- Kategori baru dengan nama yang sama pada jenis yang sama ditolak.
- Kategori buatan pengguna muncul pada pilihan kategori setelah disimpan.
- Kategori yang masih dipakai transaksi tidak dapat dihapus tanpa pemindahan transaksi.

**AC-FR-10 dan FR-18 (Dashboard dan Widget)**

- Total saldo sama dengan jumlah saldo seluruh wallet.
- Total pemasukan dan pengeluaran sama dengan jumlah transaksi sesuai jenis pada periode terpilih.
- Saldo setiap wallet tampil bersama nama dan gambar wallet.
- Keenam widget (Total Saldo, Pemasukan, Pengeluaran, Sisa Anggaran, Pengeluaran Terbesar, Transaksi Terbaru) tampil di dashboard dan dapat dijangkau dengan menggulir secara vertikal.
- Widget Transaksi Terbaru menampilkan transaksi dengan tanggal terbaru terlebih dahulu.
- Widget tanpa data menampilkan keadaan kosong, bukan angka salah atau pesan galat.
- Tarik-untuk-menyegarkan pada dashboard memuat ulang seluruh angka dan menampilkan hasil yang konsisten.

**AC-FR-11 (Grafik)**

- Tersedia opsi periode harian, mingguan, dan bulanan.
- Nilai pemasukan dan pengeluaran pada grafik sama dengan jumlah transaksi pada periode tersebut.
- Menyentuh bagian grafik menampilkan nilai detail pada bagian tersebut.
- Grafik diperbarui setelah transaksi ditambah, diubah, atau dihapus tanpa pengguna menyegarkan manual.

**AC-FR-12 dan FR-13 (Anggaran)**

- Batas anggaran hanya menerima angka lebih dari 0.
- Anggaran terpakai = total pengeluaran bulan berjalan seluruh wallet; sisa = batas − terpakai.
- Pemasukan tidak memengaruhi anggaran terpakai.
- Indikator "Mendekati batas" muncul saat penggunaan mencapai 80% dan "Melewati batas" saat lebih dari 100% (ambang final dikonfirmasi).
- Contoh uji: batas Rp2.000.000 dan pengeluaran Rp1.700.000 menghasilkan sisa Rp300.000, penggunaan 85%, status "Mendekati batas".
- Contoh uji: pengeluaran Rp2.150.000 menghasilkan status "Melewati batas" dan kelebihan Rp150.000.

**AC-FR-14 s.d. FR-16 (Riwayat, Filter, Pencarian)**

- Seluruh transaksi pengguna tampil pada riwayat dengan urutan terbaru lebih dulu, dimuat bertahap saat daftar digulir.
- Filter tanggal, kategori, jenis, dan wallet berfungsi tunggal maupun kombinasi (logika DAN).
- Tombol reset mengembalikan daftar ke kondisi tanpa filter.
- Pencarian menemukan transaksi berdasarkan sebagian kata deskripsi, tanpa membedakan huruf besar/kecil.
- Hasil kosong menampilkan pesan "tidak ada transaksi ditemukan".

**AC-FR-17 (Analisis)**

- Kategori teratas adalah kategori dengan total pengeluaran terbesar pada periode terpilih.
- Jumlah seluruh persentase kategori adalah 100% (dengan toleransi pembulatan yang dijelaskan).
- Ringkasan teks sesuai dengan data aktual.
- Tanpa data pengeluaran, ditampilkan keadaan kosong.

**AC-FR-19 (Perhitungan)**

- Contoh uji: wallet dengan saldo awal Rp500.000, pemasukan Rp1.000.000, dan pengeluaran Rp300.000 memiliki saldo Rp1.200.000.
- Contoh uji: dua wallet dengan saldo Rp1.200.000 dan Rp800.000 menghasilkan total saldo Rp2.000.000.
- Saldo awal tidak muncul pada total pemasukan.
- Tidak ada selisih antara angka dashboard, grafik, dan riwayat untuk periode dan filter yang sama.

**AC-NFR (Kebutuhan Khusus Mobile)**

- Aplikasi dapat dipasang dan dijalankan pada versi Android dan iOS minimum yang ditetapkan pada NFR-06.
- Tampilan tidak terpotong atau tertutup oleh notch, status bar, atau gesture bar pada perangkat uji dengan ukuran layar berbeda.
- Pada ukuran teks sistem yang diperbesar, seluruh teks dan tombol tetap terbaca dan dapat dioperasikan.
- Tombol dan elemen interaktif utama dapat dibaca oleh TalkBack dan VoiceOver dengan label yang bermakna.
- Tombol kembali sistem Android dan gestur kembali iOS berperilaku wajar pada setiap layar (tidak keluar aplikasi secara tidak terduga saat pengguna sedang mengisi form tanpa konfirmasi).

## 12. Data Requirements

### 12.1 Entitas dan Atribut

**Pengguna** (kebutuhan autentikasi perlu dikonfirmasi; bila aplikasi menyimpan data lokal tanpa akun, entitas ini dapat disederhanakan menjadi profil lokal): ID pengguna, identitas akun, tanggal dibuat.

**Wallet**

| Atribut | Keterangan |
| --- | --- |
| ID wallet | Pengenal unik |
| ID pengguna | Pemilik wallet |
| Nama | Wajib, unik per pengguna (usulan) |
| Saldo awal | Angka, default 0 |
| Gambar/ikon | Referensi ikon bawaan atau gambar pilihan pengguna |
| Tanggal dibuat/diubah | Penanda waktu |

**Transaksi**

| Atribut | Keterangan |
| --- | --- |
| ID transaksi | Pengenal unik |
| ID wallet | Wajib, satu wallet |
| ID kategori | Wajib, satu kategori |
| Jenis | Pemasukan atau Pengeluaran |
| Nominal | Angka > 0 |
| Tanggal | Tanggal transaksi |
| Deskripsi | Teks opsional |
| Tanggal dibuat/diubah | Penanda waktu |

**Kategori**

| Atribut | Keterangan |
| --- | --- |
| ID kategori | Pengenal unik |
| Nama | Wajib, unik per jenis |
| Jenis | Pemasukan atau Pengeluaran |
| Asal | Default atau buatan pengguna |
| ID pengguna | Terisi untuk kategori buatan pengguna |

**Anggaran Bulanan**

| Atribut | Keterangan |
| --- | --- |
| ID anggaran | Pengenal unik |
| ID pengguna | Pemilik |
| Bulan dan tahun | Periode berlaku |
| Nominal batas | Angka > 0 |

### 12.2 Aturan Data

- Saldo wallet, total saldo, anggaran terpakai, dan agregat analisis adalah **data turunan** dari transaksi dan saldo awal; tidak disimpan sebagai angka terpisah yang dapat tidak sinkron (keputusan implementasi diserahkan kepada tim teknis, selama konsistensi terjamin).
- Nominal memakai satu mata uang (IDR) dan satu aturan pembulatan yang jelas.
- Seluruh data bersifat pribadi per pengguna dan tidak dibagikan ke pengguna lain.
- Lokasi penyimpanan data (lokal di perangkat, server, atau keduanya) perlu diputuskan; keputusan ini menentukan kebutuhan akun, sinkronisasi antar perangkat, pencadangan, dan risiko kehilangan data saat aplikasi dihapus atau perangkat diganti.
- Kebijakan retensi dan penghapusan data akun perlu dikonfirmasi.

## 13. UI/UX Requirements

**Prinsip umum:** sederhana, bersih, mudah dibaca, dan fokus pada tindakan utama (mencatat transaksi). Bahasa Indonesia yang ramah dan tidak teknis. Desain mengutamakan penggunaan satu tangan pada layar ponsel.

**Layar utama (MVP):**

1. **Dashboard** – widget ringkasan, saldo per wallet, grafik, dan akses cepat "Tambah Transaksi".
2. **Wallet** – daftar wallet, tambah/edit/hapus, pemilih gambar/ikon.
3. **Transaksi/Riwayat** – daftar, pencarian, filter, tambah/edit/hapus.
4. **Anggaran** – pengaturan batas dan status penggunaan.
5. **Analisis** – kategori terbesar, persentase, ringkasan pola.
6. **Kategori** – kelola kategori default dan buatan pengguna.

**Navigasi (usulan, final oleh tim UI/UX):** bottom navigation bar untuk tujuan utama (Dashboard, Riwayat, Anggaran, Analisis, dan Lainnya yang memuat Wallet dan Kategori), ditambah tombol aksi mengambang (floating action button) "Tambah Transaksi" yang mudah dijangkau jempol.

**Kebutuhan UI/UX:**

- Tombol "Tambah Transaksi" selalu mudah diakses dari layar utama.
- Form transaksi singkat, dengan default cerdas (tanggal hari ini, wallet terakhir dipakai – usulan), pemilih jenis yang jelas, keyboard numerik untuk nominal, dan pemilih tanggal serta pemilih kategori/wallet yang ramah sentuhan (misalnya bottom sheet).
- Form menangani keyboard layar dengan baik: kolom aktif tidak tertutup keyboard dan tombol simpan tetap terjangkau.
- Pemasukan dan pengeluaran dibedakan secara konsisten (warna **dan** label/ikon/tanda).
- Gambar wallet tampil konsisten pada kartu saldo, daftar, dan pemilih wallet; wallet berbeda terlihat jelas berbeda.
- Indikator anggaran memakai bar progres dengan label status teks.
- Keadaan kosong (empty state), pemuatan (loading), dan galat (error) dirancang untuk setiap layar.
- Dialog konfirmasi untuk tindakan menghapus (transaksi, wallet, kategori).
- Format Rupiah dan tanggal Indonesia di seluruh tampilan; nominal rata kanan pada daftar.
- Tampilan adaptif pada berbagai ukuran layar ponsel dalam orientasi potret, memperhatikan safe area, dan memenuhi kebutuhan aksesibilitas pada NFR-09.
- Gestur umum didukung secara konsisten: menggulir, tarik-untuk-menyegarkan pada dashboard dan riwayat, serta tombol/gestur kembali sesuai konvensi Android dan iOS.
- Gaya visual konsisten di Android dan iOS; penyesuaian perilaku khusus platform (misalnya pemilih tanggal, navigasi kembali) mengikuti konvensi platform masing-masing bila memungkinkan.
- Grafik dilengkapi legenda, label sumbu, dan tooltip nilai yang muncul saat disentuh, serta tetap terbaca pada layar sempit.
- Navigasi utama konsisten dan mudah dipahami pengguna non-teknis.

## 14. Assumptions dan Constraints

### 14.1 Assumptions (perlu dikonfirmasi)

1. Aplikasi menargetkan Android dan iOS sekaligus dari satu basis kode Flutter.
2. Mekanisme akun dan penyimpanan data belum ditentukan: (a) data tersimpan lokal di perangkat tanpa akun, atau (b) pengguna memiliki akun dan data tersimpan di server agar dapat dipulihkan dan disinkronkan antar perangkat. Pilihan ini memengaruhi NFR-04, NFR-13, dan risiko kehilangan data.
3. Mata uang tunggal Rupiah (IDR); tidak ada multi-mata uang.
4. Pencatatan transaksi dilakukan manual oleh pengguna.
5. Anggaran bulanan bersifat total pengeluaran, bukan per kategori atau per wallet.
6. Periode bulan mengikuti bulan kalender (tanggal 1 sampai akhir bulan).
7. Ambang peringatan anggaran 80% dan 100%.
8. Gambar wallet bawaan disediakan oleh tim desain dan dikemas di dalam aplikasi; pemilihan gambar sendiri dari galeri/kamera bersifat opsional (batas ukuran/format ditentukan kemudian).
9. Perilaku penghapusan wallet atau kategori yang masih memiliki transaksi mengikuti usulan pada FR-04 dan FR-09.
10. Zona waktu pengguna mengikuti zona waktu perangkat.
11. Saldo wallet boleh bernilai negatif akibat pencatatan pengeluaran yang melebihi saldo (perlu dikonfirmasi apakah perlu peringatan atau pencegahan).
12. Orientasi potret adalah orientasi utama; tablet dapat menjalankan aplikasi tetapi tanpa tata letak khusus pada MVP.
13. Peringatan anggaran hanya ditampilkan di dalam aplikasi saat aplikasi dibuka (tanpa notifikasi push).

### 14.2 Constraints

1. Pengembangan terbatas pada fitur MVP pada dokumen ini.
2. Tidak ada integrasi bank, payment gateway, transfer antar pengguna, investasi, pinjaman, atau fitur keuangan kompleks.
3. Framework yang digunakan adalah Flutter (Dart). Arsitektur aplikasi, backend (jika ada), dan penyimpanan data belum ditentukan; PRD ini tidak mengasumsikan implementasi teknis tertentu selain Flutter.
4. Tim pengembang perlu memiliki kompetensi Flutter; kebutuhan kode khusus platform (native) diminimalkan.
5. Aplikasi harus memenuhi persyaratan dan proses peninjauan Google Play dan App Store, termasuk kebijakan privasi. Build iOS memerlukan akun pengembang Apple dan perangkat/lingkungan build macOS.
6. Jadwal, anggaran, dan ukuran tim belum tersedia dan perlu ditetapkan.
7. Kepatuhan terhadap regulasi pelindungan data pribadi yang berlaku perlu ditinjau oleh pihak yang berwenang.

### 14.3 Hal yang Perlu Dikonfirmasi

- Mekanisme akun dan autentikasi, serta lokasi penyimpanan data (lokal atau server).
- Perilaku aplikasi tanpa koneksi internet.
- Versi minimum Android dan iOS yang didukung.
- Daftar final kategori default.
- Periode default dashboard.
- Perilaku bulan baru pada anggaran.
- Aturan penghapusan wallet dan kategori yang telah dipakai.
- Batas ukuran dan format gambar wallet dari galeri/kamera.
- Batas panjang deskripsi transaksi.
- Target metrik keberhasilan.
- Boleh atau tidaknya saldo awal dan saldo wallet bernilai negatif.
- Kebutuhan perlindungan akses aplikasi (PIN/biometrik) dan pencadangan data pada rilis awal atau rilis berikutnya.
- Strategi distribusi (Google Play, App Store, atau keduanya pada rilis pertama).

## 15. Future Development

Ide berikut **tidak** termasuk MVP dan dapat dipertimbangkan pada rilis berikutnya setelah validasi pengguna:

| Ide | Deskripsi Singkat |
| --- | --- |
| Transfer antar wallet milik sendiri | Memindahkan saldo antar wallet pengguna tanpa dihitung sebagai pemasukan/pengeluaran |
| Anggaran per kategori | Batas anggaran terpisah untuk tiap kategori |
| Transaksi berulang | Pencatatan otomatis tagihan atau gaji rutin |
| Pengingat dan notifikasi push | Pengingat mencatat transaksi dan peringatan anggaran melalui notifikasi |
| Kunci aplikasi | Perlindungan akses dengan PIN atau biometrik (sidik jari/wajah) |
| Pencadangan dan pemulihan data | Cadangan data ke cloud atau berkas agar data tidak hilang saat berganti perangkat |
| Ekspor data | Unduh riwayat ke CSV/PDF |
| Impor data | Impor catatan dari file |
| Target tabungan | Tujuan menabung dengan progres |
| Lampiran struk | Foto bukti transaksi dari kamera/galeri (terpisah dari gambar wallet) |
| Widget layar utama | Widget Android/iOS untuk melihat saldo atau mencatat cepat tanpa membuka aplikasi |
| Tema dan personalisasi widget | Mengatur susunan dan tampilan widget dashboard |
| Mode gelap | Pilihan tampilan gelap |
| Multi-bahasa dan multi-mata uang | Dukungan bahasa dan mata uang lain |
| Laporan bulanan otomatis | Ringkasan bulanan yang dapat dibagikan |
| Tata letak tablet dan lanskap | Antarmuka yang dioptimalkan untuk layar besar |
| Versi web | Akses CashFlow melalui peramban |

---

*Akhir dokumen. Perubahan lingkup pada MVP harus melalui peninjauan dan persetujuan Product Manager.*
