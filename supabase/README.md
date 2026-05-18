# Supabase Backend Setup

Tek seferlik kurulum talimatları. Bu adımlar tamamlandıktan sonra `lib/core/supabase_client.dart` dosyasındaki anahtarları güncelleyerek uygulamayı çalıştırabilirsiniz.

## 1. Supabase projesini oluşturun

1. <https://app.supabase.com> adresinde oturum açın.
2. **New project** ile yeni bir proje oluşturun:
   - Name: `muzem`
   - Database password: güçlü bir şifre seçin ve saklayın.
   - Region: en yakın bölge (örn. `Frankfurt`).
3. Proje hazır olduğunda **Project Settings → API** sekmesine gidin ve şu iki değeri kopyalayın:
   - **Project URL** — `https://xxxxxxxxxxxxxxxx.supabase.co`
   - **anon / public key** — uzun bir JWT

## 2. Şemayı kurun

1. Supabase Dashboard üzerinde **SQL Editor → New query** açın.
2. Bu repodaki [`migrations/0001_initial_schema.sql`](migrations/0001_initial_schema.sql) dosyasının tüm içeriğini kopyalayıp yapıştırın.
3. **Run** butonuna basın. Tablolar, RLS politikaları, trigger ve seed veriler bir kerede yüklenir.
4. **Table Editor**'dan tabloları doğrulayın: `museums` (7 kayıt), `ticket_types` (5 kayıt), `exhibitions` (6 kayıt) görülmelidir.

## 3. Uygulamayı bağlayın

[`../lib/core/supabase_client.dart`](../lib/core/supabase_client.dart) dosyasındaki iki sabiti güncelleyin:

```dart
static const String url = 'https://xxxxxxxxxxxxxxxx.supabase.co';
static const String anonKey = 'eyJhbGciOiJI...';
```

Ardından `flutter run` ile uygulamayı başlatın.

## 4. Test hesaplarını oluşturun

Personel ve ziyaretçi test hesaplarını uygulamanın **Kayıt Ol** ekranı üzerinden oluşturun:

| Rol | E-posta | Şifre |
|---|---|---|
| Ziyaretçi | `ziyaretci@muzem.test` | `Ziyaretci123!` |
| Personel  | `personel@muzem.test`  | `Personel123!`  |

Personel hesabını oluşturduktan sonra Supabase Dashboard → **Table Editor → profiles** içinde ilgili kaydı bularak `role` alanını `personel` olarak güncelleyin. (Varsayılan olarak `ziyaretci` olarak oluşturulur.)

## 5. Doğrulama

- Ziyaretçi hesabıyla giriş yapıp ana ekrandaki müze listesini görmek.
- Personel hesabıyla giriş yapıp personel paneline yönlendirilmek.
- Supabase Dashboard → **logs** tablosunda `auth.login` kayıtlarını görmek.

Sorun olursa Supabase loglarını **Logs → Database** üzerinden inceleyin.
