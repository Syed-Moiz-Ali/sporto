# Partner workflow test results — 6 October 2026

Account: 8977904104, OTP 1234. Tokens are deliberately omitted.

Created tournament: **351**, `testing 6 oct workflow`, code `4XXWUPWYL5`.
Venue: **455**, Workflow QA Ground, Hyderabad, Turf, capacity 8 matches/day, primary.
Match configuration: duration 90 minutes, gap 15 minutes; lunch break omitted.
Minimum teams 4, maximum teams 8. Registration closes 10 October; tournament starts 12 October.

| Actual live check | Result |
| --- | --- |
| Send OTP / verify OTP | Successful |
| Create draft with physical venue | Successful |
| Update tournament details and match configuration | Successful, persisted in review |
| Review | `can_submit: true` |
| Submit | Successful; awaiting admin approval |
| Registrations | Successful, `data: []` |
| Rounds | Successful, `data.rounds: []` |
| Schedule | Successful, `data: null`, no schedule generated |
| Generate rounds | 422, `ROUND_GENERATION_REQUIRES_REGISTRATIONS` |
| Generate schedule | 422, eligible registrations missing or insufficient |
| List account tournaments | Only tournament 351 returned |

Registration detail/approval/rejection, allocation CRUD, and schedule publishing **were not live-verified**: this account has no real registrations or generated rounds/version IDs. Inventing IDs would not test a valid workflow. Admin approval and user team registrations are needed before continuing those checks.

Typed parsing tests cover the observed empty response shapes and documented roster, allocation and schedule shapes. These tests are not a substitute for live nonempty responses or device UI testing.
