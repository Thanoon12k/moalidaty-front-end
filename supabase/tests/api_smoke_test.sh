#!/usr/bin/env bash
# End-to-end checks of auth + RLS through the real Supabase APIs.
#
#   supabase start && supabase db reset
#   bash supabase/tests/api_smoke_test.sh
#
# Override SUPABASE_URL / SUPABASE_ANON_KEY to run against another project
# that was seeded with supabase/seed.sql.
set -uo pipefail

URL="${SUPABASE_URL:-http://127.0.0.1:54321}"
KEY="${SUPABASE_ANON_KEY:-$(supabase status -o json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["ANON_KEY"])')}"

pass=0; fail=0
check() { # name, expected, actual
  if [[ "$2" == "$3" ]]; then pass=$((pass+1)); echo "  ✓ $1";
  else fail=$((fail+1)); echo "  ✗ $1 — expected [$2] got [$3]"; fi
}
json() { python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

rpc_anon() { curl -s "$URL/rest/v1/rpc/$1" -H "apikey: $KEY" -H "Content-Type: application/json" -d "$2"; }
login() { # kind identifier password -> access token (or empty)
  local email
  email=$(rpc_anon login_email "{\"p_kind\":\"$1\",\"p_identifier\":\"$2\"}" | tr -d '"')
  curl -s "$URL/auth/v1/token?grant_type=password" -H "apikey: $KEY" -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"password\":\"$3\"}" | json 'd.get("access_token","")'
}
api() { # token method path [body]
  curl -s -X "$2" "$URL/rest/v1/$3" -H "apikey: $KEY" -H "Authorization: Bearer $1" \
    -H "Content-Type: application/json" -H "Prefer: return=representation" ${4:+-d "$4"}
}
status() { # token method path [body] -> HTTP status
  curl -s -o /dev/null -w '%{http_code}' -X "$2" "$URL/rest/v1/$3" -H "apikey: $KEY" \
    -H "Authorization: Bearer $1" -H "Content-Type: application/json" ${4:+-d "$4"}
}

echo "Login"
M1=$(login account 'مولدة الكرخ' test1234)
M2=$(login account 'مولدة الرصافة' test1234)
W1=$(login worker 07720000001 worker123)
check "manager 1 signs in" yes "$([[ -n $M1 ]] && echo yes || echo no)"
check "manager 2 signs in" yes "$([[ -n $M2 ]] && echo yes || echo no)"
check "worker 1 signs in"  yes "$([[ -n $W1 ]] && echo yes || echo no)"
check "wrong password rejected" "" "$(login account 'مولدة الكرخ' nope12345)"
check "unknown generator rejected" "" "$(login account 'لا توجد' test1234)"
check "decoy e-mail has the real shape" 1 "$(rpc_anon login_email '{"p_kind":"account","p_identifier":"لا توجد"}' | grep -cE '^"u[0-9a-f]{32}@moalidatna.app"$')"

echo "Profile"
check "manager profile type" account "$(api "$M1" POST rpc/my_profile '{}' | json 'd["type"]')"
check "worker profile type"  worker  "$(api "$W1" POST rpc/my_profile '{}' | json 'd["type"]')"
check "worker profile generator" "مولدة الكرخ" "$(api "$W1" POST rpc/my_profile '{}' | json 'd["generator_name"]')"

echo "Isolation between generators"
check "anon sees no subscribers" 401 "$(status "$KEY" GET subscribers)"
G1=$(api "$M1" POST rpc/my_profile '{}' | json 'd["generator_id"]')
check "manager 1 sees only own subscribers" 12 "$(api "$M1" GET "subscribers?select=id&generator_id=eq.$G1" | json 'len(d)')"
check "manager 2 sees none of generator 1" 0 "$(api "$M2" GET "subscribers?select=id&generator_id=eq.$G1" | json 'len(d)')"
check "manager 2 sees own subscribers" 6 "$(api "$M2" GET 'subscribers?select=id' | json 'len(d)')"
check "worker reads budgets (was 403 in Django)" 8 "$(api "$W1" GET 'budgets?select=id' | json 'len(d)')"
check "worker reads colleagues" 2 "$(api "$W1" GET 'workers?select=id' | json 'len(d)')"

echo "Writes"
SUB=$(api "$M1" POST subscribers '{"name":"مشترك اختبار","circuit_number":"T-1","ambers":4,"phone":"07799999999"}')
SUB_ID=$(echo "$SUB" | json 'd[0]["id"]')
check "new subscriber stamped with caller generator" "$G1" "$(echo "$SUB" | json 'd[0]["generator_id"]')"
check "cannot spoof generator_id" 403 "$(status "$M2" POST subscribers "{\"generator_id\":$G1,\"name\":\"x y\",\"circuit_number\":\"1\",\"ambers\":1}")"
Y=$(date +%Y); MO=$((10#$(date +%m)))
REC=$(api "$W1" POST receipts "{\"subscriber_id\":$SUB_ID,\"year\":$Y,\"month\":$MO,\"worker_id\":null}")
check "worker receipt stamped with own worker id" 1 "$(echo "$REC" | json 'int(d[0]["worker_id"] is not None)')"
check "amount computed from budget price × ambers" 1 "$(echo "$REC" | json 'int(float(d[0]["amount_paid"]) == float(d[0]["amber_price"]) * 4)')"
REC_ID=$(echo "$REC" | json 'd[0]["id"]')
check "duplicate receipt for the month rejected" 409 "$(status "$W1" POST receipts "{\"subscriber_id\":$SUB_ID,\"year\":$Y,\"month\":$MO}")"
check "manager 2 cannot receipt generator 1 subscriber" 400 "$(status "$M2" POST receipts "{\"subscriber_id\":$SUB_ID,\"year\":$Y,\"month\":$MO}")"
check "worker cannot delete receipts" 0 "$(api "$W1" DELETE "receipts?id=eq.$REC_ID" | json 'len(d)')"
check "worker cannot add budgets" 403 "$(status "$W1" POST budgets '{"year":2030,"month":1,"amber_price":1}')"
check "worker cannot archive subscribers" 0 "$(api "$W1" PATCH "subscribers?id=eq.$SUB_ID" '{"is_active":false}' | json 'len(d)')"
check "manager deletes receipt" 1 "$(api "$M1" DELETE "receipts?id=eq.$REC_ID" | json 'len(d)')"
check "manager archives subscriber" False "$(api "$M1" PATCH "subscribers?id=eq.$SUB_ID" '{"is_active":false}' | json 'd[0]["is_active"]')"

echo "Worker management"
NEWW=$(api "$M1" POST rpc/create_worker '{"p_name":"عامل جديد","p_phone":"07730000009","p_password":"secret99"}')
NEWW_ID=$(echo "$NEWW" | json 'd["id"]')
check "manager creates worker" "عامل جديد" "$(echo "$NEWW" | json 'd["name"]')"
check "worker cannot create workers" 403 "$(status "$W1" POST rpc/create_worker '{"p_name":"x y","p_phone":"07730000008","p_password":"secret99"}')"
check "short password rejected" 400 "$(status "$M1" POST rpc/create_worker '{"p_name":"x y","p_phone":"07730000007","p_password":"123"}')"
NW=$(login worker 07730000009 secret99)
check "new worker signs in" yes "$([[ -n $NW ]] && echo yes || echo no)"
api "$M1" POST rpc/set_worker_password "{\"p_worker_id\":$NEWW_ID,\"p_password\":\"changed99\"}" >/dev/null
check "password reset works" yes "$([[ -n $(login worker 07730000009 changed99) ]] && echo yes || echo no)"
api "$M1" POST rpc/set_worker_active "{\"p_worker_id\":$NEWW_ID,\"p_active\":false}" >/dev/null
check "deactivated worker cannot sign in" "" "$(login worker 07730000009 changed99)"
check "deactivated worker token sees nothing" 0 "$(api "$NW" GET 'subscribers?select=id' | json 'len(d)')"

echo
echo "passed: $pass  failed: $fail"
[[ $fail -eq 0 ]]
