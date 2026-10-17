-- ════════════════════════════════════════════════════════════════════════════
--  Demo data — ported from the Django seed_data.py (same logins), extended
--  with more subscribers and 8 months of history ending in the current month.
--
--  LOGIN CREDENTIALS
--    Manager 1 : مولدة الكرخ      / test1234
--    Manager 2 : مولدة الرصافة    / test1234
--    Worker 1  : 07720000001      / worker123   (مولدة الكرخ)
--    Worker 2  : 07720000002      / worker123   (مولدة الكرخ)
--    Worker 3  : 07720000003      / worker123   (مولدة الرصافة)
--
--  The Flutter demo mode (lib/core/data/demo_data.dart) generates the same data.
-- ════════════════════════════════════════════════════════════════════════════

do $$
declare
  v_gen1 bigint;
  v_gen2 bigint;
  v_w1   bigint;
  v_w2   bigint;
  v_w3   bigint;

  -- name, circuit, ambers, phone
  v_people text[][] := array[
    ['أحمد علي محمد',    'A-01', '5',  '07710000001'],
    ['محمد حسن عبدالله', 'A-02', '3',  '07710000002'],
    ['علي كريم جاسم',    'A-03', '7',  '07710000003'],
    ['زهراء حسين عبيد',  'A-04', '5',  '07710000004'],
    ['عمر خالد رشيد',    'A-05', '10', '07710000005'],
    ['سارة محمود جابر',  'A-06', '5',  '07710000006'],
    ['حيدر عباس كاظم',   'A-07', '4',  '07710000007'],
    ['مريم سعد ناصر',    'A-08', '6',  '07710000008'],
    ['يوسف طارق حميد',   'A-09', '8',  '07710000009'],
    ['نور الهدى فاضل',   'A-10', '2',  '07710000010'],
    ['مصطفى جواد علوان', 'A-11', '15', '07710000011'],
    ['فاطمة رحيم صالح',  'A-12', '3',  '']
  ];
  -- amber price per month, oldest → current
  v_prices_gen1 numeric[] := array[11000, 11500, 12000, 13500, 14000, 15000, 14500, 13000];
  v_prices_gen2 numeric[] := array[10000, 10500, 11000, 12500, 13000, 14000, 13500, 12000];

  v_subs1 bigint[] := '{}';
  v_subs2 bigint[] := '{}';
  v_month_start date;
  v_k int;
  v_i int;
  v_id bigint;
  v_today date := current_date;
begin
  -- ── Accounts (auth users + rows) ──────────────────────────────────────────
  v_gen1 := private.admin_create_account('مولدة الكرخ',   '07701111111', 'test1234');
  v_gen2 := private.admin_create_account('مولدة الرصافة', '07702222222', 'test1234');

  -- ── Workers ───────────────────────────────────────────────────────────────
  insert into public.workers (generator_id, user_id, name, phone)
  values (v_gen1, private.create_auth_user('worker123'), 'خالد محمد الجبوري', '07720000001')
  returning id into v_w1;
  insert into public.workers (generator_id, user_id, name, phone)
  values (v_gen1, private.create_auth_user('worker123'), 'سامر علي السعيدي', '07720000002')
  returning id into v_w2;
  insert into public.workers (generator_id, user_id, name, phone)
  values (v_gen2, private.create_auth_user('worker123'), 'حسن قاسم النجاشي', '07720000003')
  returning id into v_w3;

  -- ── Subscribers ───────────────────────────────────────────────────────────
  for v_i in 1 .. array_length(v_people, 1) loop
    insert into public.subscribers (generator_id, name, circuit_number, ambers, phone, date_subscribed)
    values (v_gen1, v_people[v_i][1], v_people[v_i][2], v_people[v_i][3]::int, v_people[v_i][4],
            (date_trunc('month', v_today) - interval '9 months')::date + (v_i * 2))
    returning id into v_id;
    v_subs1 := v_subs1 || v_id;
  end loop;

  for v_i in 1 .. 6 loop
    insert into public.subscribers (generator_id, name, circuit_number, ambers, phone, date_subscribed)
    values (v_gen2, v_people[v_i][1], replace(v_people[v_i][2], 'A', 'B'), v_people[v_i][3]::int,
            '0771100000' || v_i,
            (date_trunc('month', v_today) - interval '9 months')::date + v_i)
    returning id into v_id;
    v_subs2 := v_subs2 || v_id;
  end loop;

  -- ── Budgets + receipts for the last 8 months (k = 1 oldest … 8 current) ───
  for v_k in 1 .. 8 loop
    v_month_start := (date_trunc('month', v_today) - make_interval(months => 8 - v_k))::date;

    insert into public.budgets (generator_id, year, month, amber_price)
    values (v_gen1, extract(year from v_month_start), extract(month from v_month_start), v_prices_gen1[v_k]),
           (v_gen2, extract(year from v_month_start), extract(month from v_month_start), v_prices_gen2[v_k]);

    for v_i in 1 .. array_length(v_subs1, 1) loop
      -- past months: ~1 in 11 unpaid; current month: every 3rd still unpaid
      if (v_k < 8 and (v_i * 7 + v_k * 3) % 11 <> 0)
         or (v_k = 8 and v_i % 3 <> 0) then
        insert into public.receipts (generator_id, subscriber_id, worker_id, year, month,
                                     amber_price, amount_paid, notes, date_received)
        select v_gen1, s.id,
               case when v_i % 5 = 0 then null when v_i % 2 = 0 then v_w2 else v_w1 end,
               extract(year from v_month_start), extract(month from v_month_start),
               v_prices_gen1[v_k], v_prices_gen1[v_k] * s.ambers,
               case when v_i % 4 = 0 then 'تم الدفع نقداً' else '' end,
               least(v_month_start
                       + ((v_i * 3 + v_k) % (case when v_k = 8 then greatest(extract(day from v_today)::int, 1) else 25 end))
                       + interval '9 hours' + make_interval(mins => v_i * 7),
                     now() - interval '1 hour')
          from public.subscribers s where s.id = v_subs1[v_i];
      end if;
    end loop;

    for v_i in 1 .. array_length(v_subs2, 1) loop
      if v_i <> array_length(v_subs2, 1) and (v_k < 8 or v_i % 2 = 1) then
        insert into public.receipts (generator_id, subscriber_id, worker_id, year, month,
                                     amber_price, amount_paid, notes, date_received)
        select v_gen2, s.id, v_w3,
               extract(year from v_month_start), extract(month from v_month_start),
               v_prices_gen2[v_k], v_prices_gen2[v_k] * s.ambers, 'تم الدفع نقداً',
               least(v_month_start
                       + ((v_i * 4 + v_k) % (case when v_k = 8 then greatest(extract(day from v_today)::int, 1) else 25 end))
                       + interval '10 hours',
                     now() - interval '1 hour')
          from public.subscribers s where s.id = v_subs2[v_i];
      end if;
    end loop;
  end loop;
end;
$$;
