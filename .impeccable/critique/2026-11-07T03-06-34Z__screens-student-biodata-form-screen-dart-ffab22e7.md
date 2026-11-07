---
target: lib/features/students/screens/student_biodata_form_screen.dart
total_score: 28
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
target_identity: "file:/home/muzaaqi/Learn/podo/lib/features/students/screens/student_biodata_form_screen.dart"
target_fingerprint: "sha256:d011c076f1e52ad759b6f19d918442bac79b86832aad3af4536c3c8e58b6e34f"
target_path: /home/muzaaqi/Learn/podo/lib/features/students/screens/student_biodata_form_screen.dart
timestamp: 2026-11-07T03-06-34Z
slug: screens-student-biodata-form-screen-dart-ffab22e7
---
# Design Critique: StudentBiodataFormScreen

**Target:** `lib/features/students/screens/student_biodata_form_screen.dart`
**Platform:** Android (Flutter / Forui)
**Mode:** Operate (Academic Data Entry)

Method: design review only (detector not applicable, native platform)

#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Button loading indicator is clear, but silent catch on error provides no status feedback |
| 2 | Match System / Real World | 3 | Natural grouping into Academic & Contact cards, uses standard Indonesian academic terms |
| 3 | User Control and Freedom | 3 | Clear back navigation and confirmation on delete, but no dirty form discard protection |
| 4 | Consistency and Standards | 3 | Consistent Forui components and PoDo palette, but free-text entry for fixed academic taxonomy |
| 5 | Error Prevention | 2 | NIM & Name checked, duplicate NIM blocked, but phone unvalidated and exceptions swallowed silently |
| 6 | Recognition Rather Than Recall | 3 | Contextual prefix icons, clear placeholder examples, and explicit helper note on disabled NIM |
| 7 | Flexibility and Efficiency | 2 | No `TextInputAction.next` keyboard chaining; free text for study program creates high mobile typing friction |
| 8 | Aesthetic and Minimalist Design | 4 | Exemplary minimalism; structured cards, squircle matte pastel icon containers, zero clutter |
| 9 | Error Recovery | 2 | Inline field errors work, but generic `catch (_)` swallows errors with zero diagnostic feedback |
| 10 | Help and Documentation | 3 | Section subtitles and hint examples guide the lecturer; disabled NIM explains why it cannot be changed |
| **Total** | | **28/40** | **Good (Solid foundation, weak error recovery & input acceleration)** |

#### Design Specificity Verdict

**LLM assessment**: The screen feels genuinely authored for PoDo and the Indonesian academic domain rather than being a generic CRUD template. Grouping attributes into "Data Akademik & Identitas" and "Kontak & Domisili" reflects real university student dossier structures. The lock on NIM in edit mode with an explicit explanation (`NIM bersifat tetap dan tidak dapat diubah`) shows deep domain awareness. However, treating "Program Studi" and "Jurusan / Departemen" as arbitrary free-text fields undermines academic data integrity, inviting fragmented spelling variants across SQLite records.

**Deterministic scan**: not applicable (native platform)

**Visual overlays**: not applicable (native platform)

#### Overall Impression

`StudentBiodataFormScreen` achieves high visual craft and layout restraint. It embodies the "Playful Faculty Ledger" North Star through clean white squircle cards, matte pastel icon containers (emerald and indigo), and crisp Forui inputs. The primary shortcomings are operational: missing soft-keyboard action chaining (`TextInputAction.next`), silent database exception handling in `catch (_)`, lack of unsaved changes confirmation on exit, and free-text inputs for standard campus taxonomy.

#### What's Working

1. **Card Hierarchy & Sectioning**: Dividing the form into two distinct semantic cards (`Data Akademik & Identitas` and `Kontak & Domisili`) creates clear visual rhythm and prevents the 6 fields from feeling like an overwhelming wall of inputs.
2. **Contextual Prefix Icons & Placeholder Guidance**: Every input field includes a relevant Lucide icon (hash, user, book-open, building, phone) and realistic Indonesian academic examples (`Contoh: 2101001`, `Contoh: Ahmad Fauzi`), drastically reducing cognitive recall.
3. **Safe Destructive Flow**: In edit mode, "Hapus Mahasiswa" requires a secondary confirmation dialog with clear destructive action hierarchy and cancellation safety.

#### Priority Issues

- **[P1] Silent Failure on Database Exception**:
  - **Why it matters**: In `_saveStudent()`, the `catch (_)` block silently resets `_isLoading = false` without any visual feedback. If SQLite throws a constraint violation or disk IO error, the lecturer sees the button revert to "Simpan Mahasiswa" without any explanation of why save failed.
  - **Fix**: Surface an inline error banner or display an error toast via `showFToast` with the actual exception message so the user can diagnose and recover.
  - **Suggested command**: `$impeccable harden`

- **[P1] Missing Soft Keyboard Action Chaining (`TextInputAction.next`)**:
  - **Why it matters**: On mobile touchscreens, users expect the software keyboard "Next" key to automatically advance focus to the subsequent input field. Currently, fields have default keyboard actions, forcing lecturers to manually tap each of the 6 fields individually.
  - **Fix**: Add `textInputAction: TextInputAction.next` to NIM, Nama, Program Studi, Jurusan, and Telepon, and `textInputAction: TextInputAction.done` on Alamat.
  - **Suggested command**: `$impeccable polish`

- **[P2] No Unsaved Changes / Dirty Form Discard Protection**:
  - **Why it matters**: If a lecturer fills in multiple fields and accidentally swipes the Android back gesture or taps the header back button, all entered data is immediately lost without warning.
  - **Fix**: Wrap the view in a `PopScope` that detects modified controller text and displays a quick "Buang perubahan?" confirmation dialog before popping.
  - **Suggested command**: `$impeccable harden`

- **[P2] Free-Text Entry for Fixed Academic Taxonomy (Program Studi & Jurusan)**:
  - **Why it matters**: Allowing free-form typing for Program Studi and Jurusan forces redundant typing and results in inconsistent data ("Teknik Informatika", "TI", "Informatika").
  - **Fix**: Provide pre-populated selection chips or an `FSelect` dropdown based on existing campus departments, with an optional custom entry fallback.
  - **Suggested command**: `$impeccable clarify`

#### Persona Red Flags

- **Alex (Impatient Power User)**: Entering multiple students sequentially. Extremely frustrated by the lack of keyboard focus chaining (having to tap into all 6 fields manually per student) and having to type "Teknik Informatika" and "Teknologi Informasi" repeatedly.
- **Riley (Deliberate Stress Tester)**: Enters a 40-digit phone number or special characters (no phone format or length validation). If SQLite fails during write, the app silently resets the button without telling Riley what happened.
- **Dr. Hartono (Busy Lecturer)**: Filling student biodata on a phone while walking between lecture halls. An accidental Android back swipe immediately closes the screen, wiping out freshly collected contact details without a confirmation prompt.

#### Minor Observations

- The phone input uses `TextInputType.phone`, but lacks auto-formatting (e.g. `0812-3456-7890`).
- The multiline address field (`FTextField.multiline`) has no `maxLines` or `minLines` set, causing subtle height jumps when typing long multi-line text.
- In edit mode, the destructive "Hapus Mahasiswa" button sits directly adjacent to "Simpan Perubahan"; introducing a small divider or more breathing room reinforces safety.

#### Questions to Consider

- What if Program Studi and Jurusan were selectable from quick-tap chips or an `FSelect` based on recognized faculty departments, eliminating repetitive mobile typing?
- Would a "Simpan & Tambah Lagi" action accelerate workflow for lecturers registering several new advisees in one sitting?
- How should unexpected SQLite database failures communicate recovery steps to the lecturer?
