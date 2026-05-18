# Müzem — Müze Bilet Takip Sistemi

**Mobil Programlama Final Projesi 2026**

**Öğrenci:** Ali ABDALLA — **233311133**
**Üniversite:** Selçuk Üniversitesi, Teknoloji Fakültesi, Bilgisayar Mühendisliği

> Bu doküman geliştirme sürecinde adım adım güncellenecektir. Final teslim öncesi ekran görüntüleri ve test hesabı bilgileri eklenecektir.

## Açıklama

Müzem, Türkiye'deki müzelere bilet alma, biletleri QR kod ile takip etme ve müze yetkililerinin günlük ziyaretçi istatistiklerini izleyebilmesi için geliştirilen bir Flutter mobil uygulamasıdır.

İki rol bulunmaktadır:
- **Ziyaretçi**: müze ve sergileri görüntüler, bilet satın alır, QR kodlu biletlerini görür.
- **Personel**: günlük/haftalık ziyaretçi istatistiklerini izler, sergi yönetimini yapar, biletleri QR ile doğrular.

## Teknoloji

- **Flutter** (stable channel)
- **Supabase** (Auth + PostgreSQL + Row Level Security)
- **Provider** (state management)
- **go_router** (rota yönetimi, rol bazlı yönlendirme)
- **qr_flutter** (QR oluşturma) + **mobile_scanner** (QR okuma)
- **fl_chart** (personel dashboard grafikleri)

## Kurulum

1. `flutter pub get`
2. `lib/core/supabase_client.dart` dosyasındaki `url` ve `anonKey` alanlarını kendi Supabase projenizin değerleriyle değiştirin.
3. `flutter run`

## Test Hesapları

*Teslim öncesinde doldurulacaktır.*

| Rol | E-posta | Şifre |
|---|---|---|
| Ziyaretçi | `ziyaretci@muzem.test` | `Ziyaretci123!` |
| Personel  | `personel@muzem.test`  | `Personel123!`  |

## Ekran Görüntüleri

*Teslim öncesinde eklenecektir (en az 3 ekran görüntüsü).*
