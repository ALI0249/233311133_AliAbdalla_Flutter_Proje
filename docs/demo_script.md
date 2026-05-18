# Demo Recording Script — ≤ 3 dakika

Kayıt için emulator (Medium_Phone_API_36.1) veya gerçek cihaz kullan. Ses zorunlu değil, ekran görüntüleri ve geçişler net olmalı. Toplam süre **3 dakikayı geçmemeli**.

İki cihaz / iki emulator açıksa: bir cihazda ziyaretçi olarak biletini QR ile göster, diğer cihazda personel olarak tara — bu daha gerçekçi görünür. Yalnız tek cihaz varsa, biletin QR ekranını kaydedip görüntüyü yansıt veya yan ekranda göstererek tara.

## 0:00–0:20 — Giriş ve Otomatik Oturum
1. Uygulamayı aç. Splash → otomatik olarak doğru ekrana yönleniyor.
2. Eğer önceki oturum varsa **Çıkış Yap** → Login ekranı görünür.
3. Login ekranında `ziyaretci@muzem.test` / `Ziyaretci123!` yaz, **Giriş Yap** bas.

## 0:20–0:55 — Ziyaretçi Akışı: Eserler
1. Ana sayfa açılır: greeting + Topkapı hero card + **doluluk göstergesi (%X)** + "Bilet Al" CTA + 3 öne çıkan eser.
2. "Tümünü Gör" ile **Eserler** ekranına geç.
3. Kategori chip'lerinden **"Sanat"** seç → liste filtreleniyor.
4. "Kaşıkçı Elması"na tıkla → eser detayı açılır: kategori, dönem, lokasyon, açıklama, **QR kodu** belirgin şekilde.

## 0:55–1:30 — Bilet Satın Alma + QR
1. Geri dön → Ana sayfada **Bilet Al** butonuna bas.
2. Form: Topkapı seçili, **Yetişkin** bilet, tarih bugün, ödeme yöntemi **Kart** seç.
3. **Ödemeyi Onayla** → 1 saniye loading → ✅ "Biletiniz hazır!" + QR kodlu bilet kartı.
4. **Biletlerim** butonuna bas → bilet listesinde yeni biletim, **AKTİF** etiketiyle görünür.

## 1:30–2:00 — Personel: QR Tarama + Doluluk
1. Profil → **Çıkış Yap** → Login.
2. `personel@muzem.test` / `Personel123!` ile giriş yap.
3. **Personel Paneli** açılır: doluluk %0 (henüz kimse içeride değil).
4. **Bilet Tara** → kamera açılır → biletin QR'ını çerçeveye al.
5. ✅ Yeşil **"GİRİŞ ONAYLANDI"** paneli görünür.
6. **Panele Dön** → doluluk şimdi **%X (1/1500)** gösteriyor.

## 2:00–2:25 — İstatistikler ve Eser Yönetimi
1. Personel Panelinde **Bugünkü İstatistikler** → KPI'lar + haftalık bar grafik.
2. Geri dön → **Eser Yönetimi** → mevcut 12 eseri listele.
3. Floating **"Yeni Eser"** butonuna bas → ekleme formu açılır (sadece arayüzü göster, ekleme yapma — süre kısa).
4. İptal, geri dön.

## 2:25–2:55 — Yönetici Paneli
1. Çıkış yap → `admin@muzem.test` / `Admin123!` ile giriş yap.
2. Personel paneli açılır; alt kısmında turuncu **"Yönetici Paneli"** kartı görünür → tıkla.
3. Yönetici panelinde 4 seçenek: **Personel Yönetimi**, **Sistem Logları**, **Eser Yönetimi**, **Detaylı İstatistikler**.
4. **Sistem Logları** → en üstte az önce yaptığım `auth.login`, `ticket.scan`, `ticket.purchase` kayıtları görünüyor.
5. Geri dön → **Personel Yönetimi** → ziyaretçileri/personeli/yöneticileri filtrele.

## 2:55–3:00 — Kapanış
1. Anasayfaya dön → Splash logosu + "Müzem" başlığı son karede.

## Pratik İpuçları

- Ekranlar arası geçişlerde **2 saniyeden fazla durmama** — toplam süre kritik.
- Kaydı **portrait** modda yap (telefon dik).
- Klavye açılırken takılırsa hızlıca dış alana tıklayıp gizle.
- Emülatörde fareyle yapılan etkileşimler ekrana yansır; eğer yansımıyorsa "Show touches" geliştirici seçeneğini aç.
- Kayıt sırasında ekrana gelen Android sistem bildirimlerini "Do not disturb" ile sustur.
