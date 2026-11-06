---
target: lib/features/courses/screens/course_list_screen.dart
total_score: 35
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/home/muzaaqi/Learn/podo/lib/features/courses/screens/course_list_screen.dart"
target_fingerprint: "sha256:67e90c5ab5226d0fdf8694262447d25f89bb83b1705c09a4b18757b926a7bb6e"
target_path: /home/muzaaqi/Learn/podo/lib/features/courses/screens/course_list_screen.dart
timestamp: 2026-11-06T12-26-32Z
slug: s-courses-screens-course-list-screen-dart-49126f07
closed: true
---
Method: design review only (detector not applicable, native platform)

### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Static loading text lacks spinner; live search doesn't show matched result counts |
| 2 | Match System / Real World | 4 | n/a (Authentic academic terms: SKS, Kelas, Mahasiswa, Semester Ganjil/Genap) |
| 3 | User Control and Freedom | 4 | n/a (Clear search reset, intuitive speed dial backdrop dismiss, sheet cancel) |
| 4 | Consistency and Standards | 4 | n/a (Strict Forui design system compliance, unified borderless pastel tokens) |
| 5 | Error Prevention | 3 | SQLite exceptions silently default to empty list without error indicator |
| 6 | Recognition Rather Than Recall | 4 | n/a (Card surfaces all vital metadata; speed dial child buttons use clear text labels) |
| 7 | Flexibility and Efficiency | 3 | Course list does not dismiss keyboard on scroll when search input is focused |
| 8 | Aesthetic and Minimalist Design | 4 | n/a (Clean summary banner, calm background canvas, borderless solid pastels) |
| 9 | Error Recovery | 3 | Instant search reset available, but database exceptions lack a retry affordance |
| 10 | Help and Documentation | 3 | No inline distinction or guidance between "Tambah Mata Kuliah" vs "Tambah Kelas" |
| **Total** | | **35/40** | **Good (Solid foundation, minor polish only)** |

### Design Specificity Verdict

**LLM assessment**: The interface is purpose-built for the daily administrative realities of Indonesian higher education faculty. Rather than presenting a generic CRM or course table, the screen balances quick status overview with immediate curriculum management. The hero summary island foregrounds essential teaching volume (Total Kelas, Total SKS, Total Mahasiswa) before dropping into high-contrast, borderless solid pastel cards (`colors.sky`, `colors.violet`, `colors.amber`, `colors.emerald`). The micro-interaction of the floating action button—a 45° rotation expanding into explicit, labeled child pills for master curriculum vs. semester offerings—addresses the dual workflow of academic planning without cluttering the main navigation.

**Deterministic scan**: not applicable (native platform)

### Overall Impression
`CourseListScreen` has evolved into a focused, highly scannable academic hub. The elimination of redundant badges in favor of a clean 3-metric hero island and authentic pastel cards creates an approachable, high-trust faculty tool. The primary areas for polish center on mobile input ergonomics (keyboard dismissal on list scroll) and robust error handling for local SQLite operations.

### What's Working
1. **Hero Summary Island**: Condensing class metrics into a clean 3-part card (Total Kelas, Total SKS, Total Mahasiswa) provides instant semester workload comprehension without competing with the course list.
2. **Speed Dial Micro-Interaction**: Rotating the FAB from `+` to `×` while presenting labeled child pills ("Tambah Mata Kuliah" and "Tambah Kelas") over a backdrop scrim prevents action ambiguity.
3. **Borderless Solid Pastel Cards**: Rotating muted pastel tones with matched foreground text provides high visual distinction between courses while eliminating bordered visual noise.

### Priority Issues

- **[P2] Keyboard Dismissal on List Scroll**
  - **Why it matters**: When typing in the search box, the software keyboard occupies nearly half the mobile screen. Scrolling through search results keeps the keyboard open, obscuring course cards and forcing lecturers to manually dismiss it.
  - **Fix**: Set `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` on `ListView.builder`.
  - **Suggested command**: `$impeccable polish`

- **[P2] Silent Database Error Masking & Recovery**
  - **Why it matters**: If `CourseRepository` encounters an unexpected SQLite exception, `_loadOfferings()` silently catches it and sets `_offerings = []`, rendering "Belum ada kelas perkuliahan" which can cause lecturers to panic thinking their courses were deleted.
  - **Fix**: Track an `_hasError` state in `_loadOfferings()` and render an in-situ error card with an alert icon and a "Coba Lagi" (`FButton`) retry button.
  - **Suggested command**: `$impeccable harden`

- **[P2] Loading State Visual Feedback**
  - **Why it matters**: Displaying static unstyled text `Text('Memuat mata kuliah...')` gives ambiguous feedback during cold starts or background queries, making it look as though the application might be unresponsive.
  - **Fix**: Replace the static text with a centered circular progress spinner or Forui progress indicator and a subtle caption.
  - **Suggested command**: `$impeccable polish`

- **[P3] Disambiguation Between Mata Kuliah vs Kelas**
  - **Why it matters**: Faculty members—especially newly hired or adjunct lecturers—often confuse creating a master curriculum course with opening a class section for the active semester.
  - **Fix**: Add a short helper microcopy line or subtitle in the speed dial labels and respective sheet headers (e.g. "Mata Kuliah: Master Kurikulum", "Kelas: Offering Semester").
  - **Suggested command**: `$impeccable clarify`

### Persona Red Flags
- **Alex (Impatient Power User)**: Rapidly searches for "Mobile" while walking across campus. Alex locates the course in under 2 seconds, but when scrolling to inspect the student count, the software keyboard stays pinned to the screen, blocking the bottom two cards.
- **Jordan (Confused First-Timer)**: Assigned to input new courses for the semester. Clicks the floating `+` button and pauses at the two choices: "Tambah Mata Kuliah" vs "Tambah Kelas", uncertain whether creating a class will automatically create the course or vice versa.
- **Sam (Accessibility-Dependent User)**: Relies on screen reader feedback. The card's consolidated `Semantics` label functions excellently, reading course name, class, credits, student count, and semester in one fluid announcement. However, upon opening the speed dial, the container scrim does not announce that a modal menu has expanded with 2 actionable choices.

### Minor Observations
- The empty state button currently displays "Kuliah" (`child: const Text('Kuliah')`) with a plus prefix. While compact, clarifying the label to "Tambah Kelas" would be more actionable.
- In `_buildHeroBanner`, the metric values and titles look great on standard devices, but could benefit from `Flexible` or `FittedBox` on very narrow screens (<320dp) to prevent potential text truncation.

### Questions to Consider
- Should scrolling down the list automatically collapse or hide the Speed Dial FAB to maximize reading space?
- Would adding semester filter chips (e.g., "2024/2025 Ganjil" vs "Semua") speed up course access for senior faculty with extensive teaching history?
- Should the course card show a quick indicator for grade submission progress (e.g., "Nilai: 24/30 Mahasiswa")?
