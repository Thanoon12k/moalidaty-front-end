# مولداتنا — Moalidatna

Flutter app for managing electricity-generator subscriptions: subscribers, monthly
amber prices (budgets), payment receipts and collection workers. Arabic, RTL,
light & dark themes. Backend: **Supabase** (Postgres + Auth), replacing the old
Django REST server.

## Features

- **Dashboard** — this month's collection with a live line chart, collected /
  remaining / paid counters, quick actions, monthly budget progress, who hasn't
  paid yet (one tap to record a payment), subscriptions-by-amber donut.
- **Reports** — collected vs expected trend (3M / 6M / 1Y / all), collection gauge
  with per-collector breakdown, paid vs unpaid per month, collector share, top
  payers and most-late subscribers.
- **Subscribers** — search, paid/unpaid filter, add / edit / archive, payment
  history chart, month timeline, QR code.
- **Receipts** — new receipt sheet (subscriber picker or QR scan, month chips,
  computed or custom amount), share as image, print (Arabic PDF, 80 mm thermal
  or A-sizes), save PDF.
- **Budgets** — amber price per month, collection progress, month detail with
  "today" marker and paid / unpaid lists.
- **Workers** (manager) — add, edit, reset password, deactivate; month stats.
- **Offline** — lists fall back to the last copy on the device; receipts recorded
  without internet go to *قائمة الانتظار* and are sent automatically.
- **Roles** — managers manage everything; workers record subscribers and
  receipts (always in their own name) and cannot delete or change prices.
- **Demo mode** — "جرّب التطبيق" on the login screen runs on built-in sample data.

## Run

```bash
flutter pub get
cp env/supabase.example.json env/supabase.json   # fill in URL + publishable key
flutter run --dart-define-from-file=env/supabase.json
```

Without defines the app connects to the hosted **demo** project
(`axncazensmjdqpczvzwf` — temporarily shared with the `clinic_queue` Supabase
project, for showing the app to customers). Demo logins: `مولدة الكرخ` /
`test1234`, worker `07720000001` / `worker123`. For real customers, create a
dedicated project and pass its URL/key with `--dart-define-from-file`.

## Backend (Supabase)

Everything lives in [`supabase/`](supabase):

| Path | What |
|---|---|
| `migrations/20261017120000_init_moalidatna.sql` | Tables, row level security, auth helpers, RPCs |
| `seed.sql` | Demo data (same logins as the old `seed_data.py`) |
| `scripts/migrate_from_django.py` | Copies an existing Django `db.sqlite3` into Supabase |
| `tests/api_smoke_test.sh` | 33 end-to-end checks of logins and permissions |

### Create the project

```bash
supabase login
supabase link --project-ref <project-ref>
supabase db push                      # applies the migration
psql "$DB_URL" -f supabase/seed.sql   # optional demo data
```

In the dashboard: **Authentication → Sign In / Providers** — keep *Email* enabled
and turn **off** *Allow new users to sign up* (accounts are created below).

### Accounts and logins

Managers sign in with the generator name, workers with their phone. Each has a
Supabase Auth user with an internal e-mail; the app resolves it through
`login_email()`.

Create a generator account (SQL editor):

```sql
select private.admin_create_account('مولدة الكرخ', '07701111111', 'a-strong-password');
```

Workers are added by their manager from the app (العمال).

Demo logins from `seed.sql`: `مولدة الكرخ` / `test1234`, worker `07720000001` / `worker123`.

### Moving the old Django data

```bash
python3 supabase/scripts/migrate_from_django.py path/to/db.sqlite3 \
    --credentials credentials.csv > django_data.sql
psql "$DB_URL" -v ON_ERROR_STOP=1 -f django_data.sql   # on a project without seed data
```

Ids are kept. Django password hashes can't be reused by Supabase Auth, so every
manager and worker gets a new password, listed in `credentials.csv` — hand them
out and delete the file.

### Local development

```bash
supabase start && supabase db reset
bash supabase/tests/api_smoke_test.sh
flutter run --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=<from supabase status>
```

## Checks

```bash
flutter analyze
flutter test
```
