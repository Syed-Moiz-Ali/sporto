# Referee API — Remaining Backend Gaps

**Rechecked:** 19 Nov 2026  
**Evidence:** tournament `433` / `YENUBO79C5`, matches `4207`, `4208`, `4209`

Only current missing keys / backend issues are listed.

---

## 1. Tournament rows — missing fields

`GET /v1/referee/tournaments` and `GET /v1/referee/tournaments/433`

Still null:

```json
{
  "city": null,
  "level": null,
  "referee_fee": null
}
```

### Required
| Field | Action |
|---|---|
| `city` | Populate `"Hyderabad"` or derive from `location` |
| `level` | Populate `"Local"` / `"State"` / `"National"` if supported, otherwise confirm unsupported |
| `referee_fee` | Populate the tournament referee fee, or confirm intentionally null |

---

## 2. Match rows — missing fields

`GET /v1/referee/matches`, `GET /v1/referee/matches/{id}`, `GET /v1/referee/match-requests`

Still null on matches `4204`–`4209`:

```json
{
  "customer_name": null,
  "fee": null,
  "distance_km": null
}
```

### Required
| Field | Action |
|---|---|
| `customer_name` | Add tournament organiser / customer name, or confirm null is intended |
| `fee` | Add referee fee / expected earning, or confirm null is intended |
| `distance_km` | Add real referee ↔ venue distance, or confirm null is permanent |

Current UI shows static `Rahul Kumar`, `₹1500`, and `8.4 km` because these keys are null.

---

## 3. Short list

1. Populate `city` in referee tournament rows.
2. Populate `level` or confirm it is unsupported.
3. Populate `referee_fee` or confirm intentional null.
4. Populate match `customer_name` / `fee` / `distance_km`, or confirm all three are intentionally null for tournament matches.

---

## 4. Acceptance checks

```http
GET /v1/referee/tournaments/433
→ city, level, referee_fee resolved or explicitly confirmed as null

GET /v1/referee/matches/4208
→ customer_name, fee, distance_km resolved or explicitly confirmed as null

GET /v1/referee/match-requests
→ same three fields resolved or explicitly confirmed as null
```
