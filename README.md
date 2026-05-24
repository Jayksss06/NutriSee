# 🥗 Nutrisee — Flutter App

Aplikasi pelacak nutrisi harian berbasis Flutter, dibangun dari prototype desain Anda.

---

## 📁 Struktur Proyek

```
nutrisee/
├── lib/
│   ├── main.dart                          # Entry point + routing
│   ├── models/
│   │   └── user_model.dart               # UserModel, FoodEntry, WeightEntry
│   ├── providers/
│   │   └── app_provider.dart             # State management (ChangeNotifier)
│   ├── utils/
│   │   └── app_theme.dart               # Warna, tema, font (Poppins)
│   ├── screens/
│   │   ├── splash_screen.dart            # Splash dengan animasi + tombol MULAI
│   │   ├── login_screen.dart             # Login (email + password)
│   │   ├── signup_screen.dart            # Daftar akun baru
│   │   ├── otp_screen.dart              # Verifikasi kode 4-digit
│   │   ├── profile_setup_screen.dart    # Isi data profil (BB, TB, target)
│   │   ├── home_screen.dart             # Dashboard utama
│   │   ├── add_food_screen.dart         # Tambah makanan (bottom sheet)
│   │   └── profile_screen.dart          # Halaman profil user
│   └── widgets/
│       ├── calorie_gauge_widget.dart    # Gauge kalori (eaten/burned/remaining)
│       ├── bmi_widget.dart             # BMI bar + kategori
│       ├── macro_card.dart             # Card Karbo / Protein / Lemak
│       ├── weight_tracker_widget.dart  # Line chart berat badan
│       └── nutrition_chart_widget.dart # Bar chart nutrisi mingguan
└── pubspec.yaml
```

---

## 🚀 Cara Setup

### 1. Prasyarat
- Flutter SDK 3.x ke atas
- Dart SDK 3.0+
- Android Studio / VS Code + Flutter extension

### 2. Install dependensi
```bash
cd nutrisee
flutter pub get
```

### 3. Buat folder assets
```bash
mkdir -p assets/images
```

### 4. Jalankan aplikasi
```bash
flutter run
```

---

## 📦 Dependencies Utama

| Package | Kegunaan |
|---------|---------|
| `provider` | State management |
| `fl_chart` | Line chart & bar chart |
| `google_fonts` | Font Poppins |
| `shared_preferences` | Simpan data lokal |
| `intl` | Format tanggal |

---

## 🔐 Alur Navigasi

```
Splash → Login → Sign Up → OTP → Profil Setup → Home (Dashboard)
```

- **Splash**: Animasi fade-in + tombol MULAI, auto-navigate ke Login
- **Login**: Email + Password, langsung ke Home (dengan demo data)
- **Sign Up**: Nama, Email, Password, Konfirmasi → OTP
- **OTP**: 4 digit, countdown 29 detik, auto-submit saat digit terakhir diisi
- **Profil Setup**: Nama, Jenis Kelamin, Tanggal Lahir, BB, TB, Target BB
- **Home**: Dashboard lengkap + navigasi bawah + FAB tambah makanan

---

## 🎯 Fitur Dashboard

### Kalori Gauge
- Visual arc/gauge menampilkan kalori tersisa
- Kalori dimakan (eaten) vs terbakar (burned)
- Dihitung otomatis dari data makanan yang ditambahkan

### Makro Nutrisi
- 3 card: Karbo, Protein, Lemak
- Progress bar dengan persentase terhadap target harian

### BMI
- Nilai BMI dihitung dari data profil
- Bar gradient warna (biru → merah)
- Kategori: Kekurangan / Normal / Kelebihan / Obesitas

### Pelacak Berat Badan
- Line chart 7 hari
- Tab period: Minggu / Bulan / 6 Bulan / 1 Tahun

### Chart Nutrisi
- Bar chart bertumpuk (stacked) per hari
- Menampilkan Kalori, Protein, Karbo, Lemak
- Total kalori + rata-rata harian

### Tambah Makanan
- Bottom sheet dengan 17+ makanan Indonesia
- Search/filter makanan
- Pilih jenis makan: Sarapan / Makan Siang / Makan Malam / Camilan

---

## 🔧 Kalkulasi Otomatis

```dart
// Target kalori (Harris-Benedict)
// Pria: 88.362 + (13.397 × BB) + (4.799 × TB) - (5.677 × umur)
// Wanita: 447.593 + (9.247 × BB) + (3.098 × TB) - (4.330 × umur)
// × 1.2 (sedentary activity factor)

// BMI
bmi = weight / ((height / 100) * (height / 100))

// Distribusi makro
targetCarbs   = (targetCalories × 0.5)  / 4   // g
targetProtein = (targetCalories × 0.25) / 4   // g
targetFat     = (targetCalories × 0.25) / 9   // g
```

---

## 🎨 Design System

- **Primary**: `#1B6B3A` (Hijau tua)
- **Accent**: `#4ADE80` (Hijau muda)
- **Background**: `#EFF5F0` (Hijau sangat pucat)
- **Font**: Poppins (Google Fonts)

---

## 📝 Pengembangan Selanjutnya

- [ ] Integrasi backend/API (autentikasi nyata)
- [ ] Kamera scan makanan (image recognition)
- [ ] Notifikasi pengingat makan
- [ ] Export laporan PDF
- [ ] Sync dengan Google Fit / Apple Health
- [ ] Database makanan Indonesia yang lebih lengkap
- [ ] Mode gelap (dark mode)
