# PROJECT_PLAN — Mobil Programlama Final Projesi (Flutter + Supabase)

> **Status:** Locked in. Design pivoted at commit 4 — see § Design Evolution.
> **Last updated:** 2026-05-18 (pivot day)
> **Deadline:** 22 Mayıs 2026, 23:59 (hard cutoff)

## Design Evolution (commit 4 pivot)

The initial plan (commits 1-3) described a **multi-museum ticketing app** with 2 roles (Ziyaretçi + Personel). After commit 3 we discussed the original vision and pivoted to a **single-museum management app** that's a better fit for the project name "Müze Bilet Takip Sistemi" and a stronger sözlü-defense story.

**Changes from commit 4 onward:**
- The system manages **one museum: Topkapı Sarayı Müzesi** (multi-museum data model retained for scalability, demo focuses on one).
- **Three roles**: Ziyaretçi (visitor) + Personel (staff) + Admin (staff manager + super-stats).
- New **artifacts (eserler)** entity: 12 seeded pieces (Topkapı Hancer-i, Kaşıkçı Elması, Hırka-i Saadet, etc.) each with category (Sanat/Tarih/Heykel/Arkeoloji/Etnografya/El Yazması), era, description, location in museum, and QR code.
- New **occupancy** view: real-time "% full" gauge visible on the visitor home AND staff/admin dashboards.
- New **visits** entity: tracks who entered the museum today; occupancy = count of visits with `exited_at is null`.
- Admin = personel + staff CRUD + global stats + system logs view.
- Paid tickets retained — 5 types: Yetişkin/Öğrenci/Çocuk/Grup/Müzekart.
- Soft occupancy cap (display only, never blocks ticket purchase).

The §s below (roles, features, screens, schema) reflect the **pivoted** design.

---

## 1. Submission identity

| Field | Value |
|---|---|
| Student name | Ali ABDALLA |
| Student number | 233311133 |
| Repo name | `233311133_AliAbdalla_Flutter_Proje` |
| Repo visibility | **public** |
| App display name | **Müzem** (short, memorable, fits the museum scenario) |
| App package id (Android) | `com.aliabdalla.muzem` |
| App package id (iOS bundle) | `com.aliabdalla.muzem` (not deploying to App Store, just for build) |

---

## 2. The two roles

| Role | Turkish label | Permissions | Test account |
|---|---|---|---|
| **Visitor** | Ziyaretçi | Register, log in, browse museums + exhibitions, buy tickets, view own ticket history with QR, write reviews, edit own profile. | `ziyaretci@muzem.test` / `Ziyaretci123!` |
| **Museum staff / Admin** | Personel | Log in (no public register — staff accounts are seeded manually), add/edit/delete exhibitions, scan/validate tickets at the gate, view daily/weekly visitor stats, view system log. | `personel@muzem.test` / `Personel123!` |

**Why exactly two:** the rubric says minimum two; adding a third role (e.g. "kasiyer") gives no extra credit and inflates the screen count. Lean.

---

## 3. Feature scope — MVP vs stretch

### MVP (must-have, blocks submission)
- [ ] Email/password auth (register, login, logout, **session persists across restart**).
- [ ] Role-based routing: after login, visitor → visitor home; staff → staff home.
- [ ] Visitor: browse museum list, tap into detail, see exhibitions of that museum.
- [ ] Visitor: buy ticket form (museum, date, ticket type) → confirmation screen with **QR code**.
- [ ] Visitor: ticket history list with QR per ticket.
- [ ] Visitor: profile screen (view + edit own info).
- [ ] Staff: dashboard with today's visitor count, this-week chart.
- [ ] Staff: exhibition CRUD (add / edit / delete) tied to a museum.
- [ ] Staff: ticket scan screen (QR scan → mark as used → log the check-in).
- [ ] **Action log:** every important user action (login, logout, purchase, scan, CRUD) writes a row to the `logs` table in Supabase.

### Stretch (only if time allows on Day 4 buffer)
- Push notification for "exhibition starting tomorrow" (Supabase Edge Function trigger).
- Visitor reviews / star rating on a museum.
- Dark mode toggle.
- Localization scaffold (TR + EN) — UI is already Turkish, so this is just structural.

**YAGNI ruthlessly.** If Day 3 evening is shaky, freeze stretch list entirely and spend Day 4 on polish + README + recording.

---

## 4. Screens (target: 9 screens, well above the 5-screen rubric minimum)

| # | Screen | Visible to | Notes |
|---|---|---|---|
| 1 | Splash / session-restore | Both | Reads Supabase session, routes accordingly. |
| 2 | Login | Logged-out | Email + password + "Hesabım yok, kayıt ol" link. |
| 3 | Register (Ziyaretçi only) | Logged-out | Visitor self-register. Staff cannot self-register. |
| 4 | Visitor Home — museum list | Ziyaretçi | List of museums, search bar, card per museum. |
| 5 | Museum Detail | Ziyaretçi | Museum info + list of its exhibitions + "Bilet Al" CTA. |
| 6 | Ticket Purchase form | Ziyaretçi | Form: museum (preselected), date, ticket type, quantity → confirmation. |
| 7 | My Tickets | Ziyaretçi | List of purchased tickets with QR code per ticket, status. |
| 8 | Profile | Both | View + edit own info, logout button. |
| 9 | Staff Dashboard | Personel | Today's count, weekly chart (`fl_chart`), shortcuts to scan and exhibition management. |
| 10 | Exhibition Management (Add/Edit) | Personel | CRUD form, list of all exhibitions with edit/delete. |
| 11 | Ticket Scan | Personel | Camera QR scan → result panel (valid / already used / invalid) → log. |

11 screens total, all reachable. The visit detail and ticket detail are reached via taps, not separate tab entries.

---

## 5. Tech choices

| Concern | Choice | Reason |
|---|---|---|
| Flutter SDK | latest stable (`flutter --version` at scaffold) | Tested defaults. |
| State management | `provider` | Simplest mainstream choice, defensible in oral exam. Rejected: Riverpod (steeper learning curve), Bloc (over-engineered for this scope). |
| Backend | Supabase (auth + Postgres + RLS) | Per top-level PLAN. |
| Supabase Flutter client | `supabase_flutter` (official) | One package for auth + DB + realtime. |
| QR generation | `qr_flutter` | Tickets carry a QR code with the ticket UUID. |
| QR scanning | `mobile_scanner` | Modern, maintained, less battery hungry than older `qr_code_scanner`. |
| Charts (staff dashboard) | `fl_chart` | Lightweight, no native deps. |
| Routing | `go_router` | Type-safe, role-aware redirects, simpler than nested Navigator 2.0. |
| Forms / validation | built-in `Form` + `FormField` | Avoid heavy form packages — keep oral-exam defendable. |
| Local persistence (session) | Supabase client handles it automatically | No `shared_preferences` needed for auth. |

---

## 6. Folder layout (`lib/`)

Feature-first, with a thin core layer:

```
lib/
├── main.dart                          ← Supabase init, runApp, routing
├── core/
│   ├── supabase_client.dart           ← single Supabase init point
│   ├── logger.dart                    ← inserts log rows into Supabase `logs`
│   ├── theme.dart                     ← single ThemeData
│   └── role_guard.dart                ← redirect logic for go_router
├── features/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── museums/
│   │   ├── museum_model.dart
│   │   ├── museum_service.dart
│   │   ├── museum_list_screen.dart    ← visitor home
│   │   └── museum_detail_screen.dart
│   ├── tickets/
│   │   ├── ticket_model.dart
│   │   ├── ticket_service.dart
│   │   ├── ticket_purchase_screen.dart
│   │   ├── my_tickets_screen.dart
│   │   └── ticket_qr_widget.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── staff/
│   │   ├── staff_dashboard_screen.dart
│   │   ├── exhibition_management_screen.dart
│   │   └── ticket_scan_screen.dart
│   └── splash/
│       └── splash_screen.dart
└── shared/
    ├── widgets/                        ← buttons, cards reused across features
    └── extensions/
```

Each feature owns its model + service + screens. Services talk to Supabase; screens talk to services through Provider.

---

## 7. Supabase data model (PostgreSQL)

```
profiles                                  -- 1:1 with auth.users
  id              uuid (PK, = auth.users.id)
  full_name       text
  phone           text
  role            text check in ('ziyaretci','personel')
  created_at      timestamptz

museums
  id              uuid (PK)
  name            text not null
  city            text
  address         text
  opening_hours   text
  description     text
  created_at      timestamptz

exhibitions
  id              uuid (PK)
  museum_id       uuid (FK -> museums.id)
  title           text not null
  start_date      date
  end_date        date
  description     text

ticket_types
  id              serial (PK)
  name            text  -- 'Yetiskin','Ogrenci','Cocuk','Grup','Muzekart'
  price           numeric(10,2)

tickets
  id              uuid (PK)
  visitor_id      uuid (FK -> profiles.id)
  museum_id       uuid (FK -> museums.id)
  ticket_type_id  int  (FK -> ticket_types.id)
  visit_date      date
  status          text check in ('aktif','kullanildi','iptal')
  qr_payload      text   -- = id, encoded into QR
  created_at      timestamptz
  used_at         timestamptz null

logs
  id              bigserial (PK)
  user_id         uuid null  -- nullable for failed-login logs
  action          text   -- 'login','logout','purchase','scan','exhibition_create','exhibition_update','exhibition_delete'
  metadata        jsonb null
  created_at      timestamptz default now()
```

**Row Level Security (RLS) policies** — drafted now, applied in Phase 2:

- `profiles`: a user can `SELECT/UPDATE` only their own row. `personel` can `SELECT` everyone.
- `museums`, `exhibitions`, `ticket_types`: `SELECT` for all authenticated users. `INSERT/UPDATE/DELETE` only when `auth.uid()`'s `profiles.role = 'personel'`.
- `tickets`: a visitor can `SELECT/INSERT` their own tickets. `personel` can `SELECT` all and `UPDATE` (to mark as used).
- `logs`: every authenticated user can `INSERT` (their own user_id auto-filled). Only `personel` can `SELECT`.

---

## 8. Logging strategy

A single `Logger` class in `core/logger.dart` exposes:

```dart
Future<void> log(String action, {Map<String, dynamic>? metadata});
```

It writes to the `logs` table. Every service method (login, register, ticket purchase, exhibition CRUD, scan) calls it. Failures of the log write are themselves logged to console (never block the user action).

**What gets logged:**
- `auth.login` (with success/failure flag), `auth.logout`, `auth.register`
- `ticket.purchase` (ticket id, museum, type, price)
- `ticket.scan` (ticket id, result: valid / already_used / not_found)
- `exhibition.create`, `exhibition.update`, `exhibition.delete` (with id)
- `profile.update`

This satisfies the rubric's "Yapılan her işlemde log kaydı tutulmalıdır."

---

## 9. Commit plan (target: ≥8 meaningful commits, no "update / son" messages)

| # | Commit subject | What lands |
|---|---|---|
| 1 | `chore: scaffold Flutter project, configure Supabase client` | `main.dart`, `pubspec.yaml`, `.gitignore` (excludes `build/`, `.dart_tool/`), supabase client init, theme. |
| 2 | `feat(auth): email/password login + register + session restore` | login, register, splash, AuthService, RLS-aware profile creation on register. |
| 3 | `feat(museums): museum list and detail screens for visitors` | MuseumService, list + detail screens, navigation. |
| 4 | `feat(tickets): ticket purchase flow with QR generation` | TicketService, purchase screen, my-tickets list, QR widget. |
| 5 | `feat(staff): dashboard with daily/weekly visitor stats` | role-based routing in go_router, staff dashboard with fl_chart. |
| 6 | `feat(staff): exhibition CRUD and QR scan with mobile_scanner` | exhibition management screen, ticket scan screen. |
| 7 | `feat(profile,logging): profile edit + action log on every operation` | profile screen, Logger wired into every service. |
| 8 | `docs: README with screenshots, test accounts, packages` | README.md per rubric, screenshots in `docs/screenshots/`. |
| 9 *(buffer)* | `polish: lint, error-state handling, tighten copy` | dart fix, fixes, stretch items if any time. |

I will **not** batch these — each commit lands its scope and runs `flutter analyze` clean before being made.

---

## 10. README.md content (skeleton, written at commit 8)

Per the mobile rubric:

```markdown
# Müzem — Museum Ticket Tracking App

**Course:** Mobil Programlama Final Projesi 2026
**Student:** Ali ABDALLA — 233311133
**University:** Selçuk Üniversitesi, Teknoloji Fakültesi, Bilgisayar Mühendisliği

## Açıklama
Müzem, Türkiye'deki müzelere bilet alma ve müze yetkililerinin günlük ziyaretçi takibi yapması için geliştirilmiş bir mobil uygulamadır...

## Test hesapları
| Rol | E-posta | Şifre |
|---|---|---|
| Ziyaretçi | ziyaretci@muzem.test | Ziyaretci123! |
| Personel  | personel@muzem.test  | Personel123!  |

## Kullanılan paketler
- supabase_flutter ^x.y.z
- provider ^x.y.z
- go_router ^x.y.z
- qr_flutter ^x.y.z
- mobile_scanner ^x.y.z
- fl_chart ^x.y.z

## Ekran görüntüleri
(≥3 screenshots — to be captured during demo recording day)

## Çalıştırma
1. `flutter pub get`
2. `lib/core/supabase_client.dart` dosyasındaki anahtarları kendi Supabase projenizle değiştirin
3. `flutter run`
```

---

## 11. Demo recording (≤3 minutes) — pre-written script

Saved in `docs/demo_script.md` and followed during capture:

1. **0:00–0:20** — App opens on splash, logs in as visitor (live).
2. **0:20–1:00** — Browse museums, open Topkapı detail, see exhibitions list.
3. **1:00–1:30** — Buy a ticket → see QR confirmation → open My Tickets.
4. **1:30–1:45** — Logout, login as staff.
5. **1:45–2:15** — Staff dashboard: today's count + weekly chart.
6. **2:15–2:40** — Open Ticket Scan, scan the QR shown on a second device (or recorded screen), see "Bilet doğrulandı".
7. **2:40–2:55** — Exhibition management: add an exhibition, see it appear.
8. **2:55–3:00** — Show logs in Supabase table editor briefly to prove logging works.

Recorded on real Android device via screen mirroring or on emulator. No audio required.

---

## 12. Rubric checklist

- [ ] At least 2 roles defined — Ziyaretçi, Personel ✓ (above)
- [ ] Supabase used for **both** auth AND data — ✓
- [ ] Register, login, logout — ✓ (screens 2-3, profile logout)
- [ ] **Session persists across app restart** — ✓ via Supabase auto-restore (verified in splash screen)
- [ ] At least 5 screens — ✓ (11 planned)
- [ ] Action log on every operation — ✓ via Logger
- [ ] README has: app name, student name + number, packages, test accounts, ≥3 screenshots — ✓ (commit 8)
- [ ] Repo name `233311133_AliAbdalla_Flutter_Proje` — ✓
- [ ] Repo public — must remember to flip visibility before submission
- [ ] `.gitignore` excludes `build/` and `.dart_tool/` — ✓ (commit 1)
- [ ] ≥8 meaningful commits — ✓ (9 planned)
- [ ] Screen recording ≤3 min, actions clearly visible — ✓ (script ready)
- [ ] GitHub commit history screenshot for submission — captured after final commit

---

## 13. Open questions for Ali

1. Do you have a Supabase account already, or should the plan include "create Supabase project" as the first step?
2. Are you OK with the app name "**Müzem**"? Alternatives: "MüzeBileti", "Sergim", "Müze+". (Pure cosmetic; doesn't affect grade.)
3. Do you want me to use an Android emulator on your machine, or a real device? (Real device gives slightly more credible demo recording.)
4. Any classes/exams between today (May 18) and the May 22 deadline that would shrink the working days?
