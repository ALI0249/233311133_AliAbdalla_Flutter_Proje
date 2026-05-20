# Müzem — Müze Bilet Takip Sistemi

**Mobil Programlama Final Projesi 2026**

| | |
|---|---|
| **Öğrenci** | Ali ABDALLA |
| **Numara** | 233311133 |
| **Üniversite** | Selçuk Üniversitesi, Teknoloji Fakültesi, Bilgisayar Mühendisliği |



---

## Uygulama Özeti

**Müzem**, **Topkapı Sarayı Müzesi** odaklı geliştirilmiş, ziyaretçilerin müzeye bilet alabildiği, eserlere ait QR'lı bilgi kartlarına ulaşabildiği; personelin girişte/çıkışta QR ile bilet doğrulayabildiği, anlık doluluk oranını izleyebildiği; yöneticinin de personel kadrosunu yönetip sistem loglarını inceleyebildiği üç rollü bir Flutter uygulamasıdır.

### Üç Rol

| Rol | Yapabildikleri |
|---|---|
| **Ziyaretçi (`ziyaretci`)** | Kayıt ol/giriş yap, müze hakkında bilgi al, eserleri kategoriye göre tara, her eserin QR kodunu gör, bilet satın al (5 tip), kendi biletlerini QR ile birlikte gör, profilini düzenle. |
| **Personel (`personel`)** | Anlık doluluk göstergesi, QR ile bilet doğrulama (aynı QR ikinci taramada çıkış olarak işlenir), günlük/haftalık ziyaretçi istatistikleri (fl_chart bar grafik), eser ekle/düzenle/sil. |
| **Yönetici (`admin`)** | Personelin tüm yetkilerine ek olarak personel rollerini değiştirme, tüm sistem loglarını okuma, tam yönetici paneli. |

### Mimari Özet

- **Backend**: Supabase (Postgres + Row Level Security + JWT auth).
- **Veri modelleri**: `profiles`, `museums`, `exhibitions`, `ticket_types`, `tickets`, `visits`, `artifacts`, `logs`.
- **State management**: `provider` (ChangeNotifier `AuthState`).
- **Routing**: `go_router` rol bazlı redirect zinciri (ziyaretçi → `/home`, personel/yönetici → `/staff`).
- **QR**: `qr_flutter` ile üretim, `mobile_scanner` ile kamera tarama.
- **Grafik**: `fl_chart` BarChart.
- **Yerelleştirme**: `intl` tr_TR.

### Loglama

Her önemli işlem `logs` tablosuna yazılır (auth.login, auth.logout, auth.register, ticket.purchase, ticket.scan, admin.role_change, profile.update). Yöneticiler `/admin/logs` ekranından bu kayıtları görüntüleyebilir.

---

## Test Hesapları

Aşağıdaki üç hesabı kayıt ekranından oluşturduktan sonra Supabase Dashboard → **Table Editor → profiles** üzerinden `personel` ve `admin` hesaplarının `role` alanını ilgili değere değiştirin.

| Rol | E-posta | Şifre |
|---|---|---|
| Ziyaretçi | `ziyaretci@muzem.test` | `Ziyaretci123!` |
| Personel | `personel@muzem.test` | `Personel123!` |
| Yönetici | `admin@muzem.test` | `Admin123!` |

> Supabase **Authentication → Providers → Email**'de "Confirm email" seçeneğinin **kapalı** olduğundan emin olun, aksi takdirde kayıt sonrası e-posta onayı beklenir.

---

## Kullanılan Paketler

| Paket | Sürüm | Amaç |
|---|---|---|
| `supabase_flutter` | ^2.8.0 | Auth + Postgres + RLS |
| `provider` | ^6.1.2 | State management |
| `go_router` | ^14.6.2 | Rota yönetimi |
| `qr_flutter` | ^4.1.0 | QR kod üretimi |
| `mobile_scanner` | ^5.2.3 | Kamera ile QR okuma |
| `fl_chart` | ^0.69.0 | İstatistik grafikleri |
| `intl` | ^0.20.1 | Türkçe tarih formatlama |

---

## Kurulum

### 1. Supabase tarafı

1. <https://app.supabase.com> üzerinde yeni bir proje oluştur (`muzem`).
2. Project URL ve `anon` key'i kopyala.
3. **SQL Editor** üzerinden sırasıyla şu üç migration dosyasını çalıştır:
   - [`supabase/migrations/0001_initial_schema.sql`](supabase/migrations/0001_initial_schema.sql)
   - [`supabase/migrations/0002_pivot_single_museum.sql`](supabase/migrations/0002_pivot_single_museum.sql)
   - [`supabase/migrations/0003_admin_rls_and_visit_helper.sql`](supabase/migrations/0003_admin_rls_and_visit_helper.sql)
4. **Authentication → Providers → Email → "Confirm email"** seçeneğini KAPAT.

### 2. Flutter tarafı

1. [`lib/core/supabase_client.dart`](lib/core/supabase_client.dart) içindeki `url` ve `anonKey` değişkenlerini kendi Supabase projeninkilerle değiştir.
2. ```bash
   flutter pub get
   flutter run -d <emulator-id>
   ```

### 3. Test hesaplarını hazırla

Yukarıdaki tabloya göre 3 kullanıcıyı kayıt ekranından oluştur, sonra Supabase Table Editor'da `personel` ve `admin` rollerini ayarla.

---



---

