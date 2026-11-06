---
target: lib/features/dashboard/screens/home_screen.dart
total_score: 36
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/home/muzaaqi/Learn/podo/lib/features/dashboard/screens/home_screen.dart"
target_fingerprint: "sha256:dcded9e6b20523af0e418d6fd51ac91362bc680cc7b7e96cf246872d7bac2de5"
target_path: /home/muzaaqi/Learn/podo/lib/features/dashboard/screens/home_screen.dart
timestamp: 2026-11-06T07-42-31Z
slug: lib-features-dashboard-screens-home-screen-dart
---
Method: design review only (detector not applicable, native platform)

### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | n/a (Clear date, greeting, next class chip, and loading indicators) |
| 2 | Match System / Real World | 4 | n/a (Authentic Indonesian academic vernacular: SKS, Lab Komputer, CPMK) |
| 3 | User Control and Freedom | 3 | Bell icon button in header bar has no tap handler or active feedback |
| 4 | Consistency and Standards | 4 | n/a (Strict Forui design system compliance, unified borderless pastels) |
| 5 | Error Prevention | 4 | n/a (Graceful empty states for schedule and announcements prevent layout breaks) |
| 6 | Recognition Rather Than Recall | 4 | n/a (Distinct pastel quick-action tiles with recognizable icons) |
| 7 | Flexibility and Efficiency | 3 | No quick search or filtering on dashboard for high-volume courses |
| 8 | Aesthetic and Minimalist Design | 4 | n/a (Calm `#F8FAFC` canvas, crisp `#FFFFFF` cards, zero border noise on pastels) |
| 9 | Error Recovery | 3 | Data fetch error falls back to empty state without explicit retry mechanism |
| 10 | Help and Documentation | 3 | No empty state hints or onboarding guidance for first-time lecturers |
| **Total** | | **36/40** | **Excellent (Solid, minor polish only)** |

### Design Specificity Verdict

**LLM assessment**: The interface feels authentic to an Indonesian university lecturer's daily workflow rather than a generic administrative template. The visual hierarchy places immediate teaching responsibilities front and center ("Jadwal Berikutnya" with course code, room, and time chip), flanked by high-frequency operational tasks (CPMK grade entry, biodata management). The "Playful Faculty Ledger" aesthetic—pairing calm slate canvas with borderless, solid pastel functional accents—creates a warm yet authoritative academic environment that avoids generic SaaS cliches.

**Deterministic scan**: not applicable (native platform)

### Overall Impression
The recent simplification of `HomeScreen` succeeds decisively: moving from a crowded dashboard to a 3-zone hierarchy (Profile Header → Hero Schedule Island → Quick Action Grid + Announcements) restores breathing room and purpose. The solid, borderless pastel palette (`#DDD6FE`, `#FDE68A`, `#A7F3D0`) provides gentle visual grouping without visual clutter. The remaining opportunities lie in interactivity polish (active states and recovery affordances).

### What's Working
1. **Hero Schedule Island**: Anchors the eye immediately upon launch. Lecturers instantly see their next classroom, start time, and credit load without scrolling.
2. **Compact Profile Header**: Condensing the welcome area into a clean single-row header (`FAvatar` + lecturer title/name + action icon) reclaims over 80px of vertical space.
3. **Borderless Solid Pastel Quick Actions**: Pastel squircles without borders create distinct, clickable tactile targets that feel approachable and cleanly grouped.

### Priority Issues

- **[P2] Notification Bell Affordance**
  - **Why it matters**: The bell icon in the top header is styled as an interactive icon button, but clicking it provides no feedback or navigation, causing minor user frustration.
  - **Fix**: Connect the button to an announcement drawer or bottom sheet, and display an unread notification dot badge when new announcements exist.
  - **Suggested command**: `$impeccable polish`

- **[P2] Error State Recovery Affordance**
  - **Why it matters**: If `_loadData()` encounters a database exception, it resets `_isLoading = false` but renders an empty schedule, which may mislead lecturers into believing they have no classes.
  - **Fix**: Capture query exceptions in an `_errorMessage` state and render an in-situ retry button (`FButton`) to recover gracefully.
  - **Suggested command**: `$impeccable harden`

- **[P3] Hero Schedule Card TalkBack Semantics**
  - **Why it matters**: The hero schedule card uses `FTappable` for quick navigation to the schedule tab, but screen readers encounter multiple disconnected text elements.
  - **Fix**: Wrap the hero container in `Semantics(button: true, label: 'Jadwal mengajar berikutnya: Pemrograman Mobile di Lab Komputer 2, ketuk untuk membuka jadwal lengkap')`.
  - **Suggested command**: `$impeccable adapt`

### Persona Red Flags
- **Alex (Impatient Power User)**: Rapidly scanning for next lecture location. Alex succeeds within 1 second thanks to the high-contrast time badge and room label on the hero card. Red flag: Clicking the notification bell yields no response.
- **Jordan (First-Time Lecturer)**: Appreciates the clear course code and Indonesian terminology. Red flag: If an initial SQLite lock or migration delay occurs, Jordan is shown "Tidak ada jadwal mengajar hari ini" with no hint that a sync/fetch failed.
- **Sam (Accessibility / Screen Reader User)**: High text contrast (`#1E293B` on `#FFFFFF` and `#F8FAFC`) passes WCAG AA comfortably. Red flag: Hero card lacks consolidated semantics, reading out fragments like "Hari Ini", "Kelas IF-3A", "Lab Komputer 2" separately.

### Minor Observations
- The "Lihat Semua" button on the hero card and the announcement section header both use small text buttons; their touch target sizes should be verified for minimum 48x48dp tap ergonomics.
- When there are no announcements, a calm empty illustration or subtle placeholder would reinforce that the lecturer is all caught up.

### Questions to Consider
- Should the notification bell open a filterable list of academic announcements, or a dedicated notification history?
- Would an inline status chip indicating class readiness (e.g. "Dimulai dalam 45 menit") add high utility for on-the-go lecturers?
