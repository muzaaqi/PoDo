import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/widgets/stat_card.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late final TextEditingController _searchController;
  List<CourseOffering> _offerings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadOfferings();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadOfferings(query: _searchController.text);
  }

  Future<void> _loadOfferings({String? query}) async {
    final lecturerId = AuthRepository.instance.activeLecturerId;
    if (lecturerId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final offerings = await CourseRepository.instance.getOfferingsByLecturer(
        lecturerId,
        query: query,
      );
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _offerings = [];
          _isLoading = false;
        });
      }
    }
  }

  int get _totalCredits =>
      _offerings.fold<int>(0, (sum, item) => sum + item.credits);

  void _navigateToDetail(CourseOffering offering) {
    Navigator.of(context).pushNamed(
      '/courses/detail',
      arguments: offering,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.bookOpen,
                  size: 48,
                  color: theme.colors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mata kuliah tidak ditemukan',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Coba ubah kata kunci pencarian Anda.',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseOffering offering) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FTappable(
        onPress: () => _navigateToDetail(offering),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.courseCode,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offering.courseName,
                            style: theme.typography.body.md.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text('${offering.credits} SKS'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Kelas ${offering.className} • ${offering.academicYear} (${offering.term})',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      FLucideIcons.users,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${offering.enrolledCount} Mahasiswa',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Mata Kuliah'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Kelas',
                        value: '${_offerings.length}',
                        icon: FLucideIcons.bookOpen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Total SKS',
                        value: '$_totalCredits',
                        icon: FLucideIcons.award,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FTextField(
                  hint: 'Cari mata kuliah atau kelas...',
                  prefixBuilder: (context, style, variants) =>
                      FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const Icon(FLucideIcons.search),
                  ),
                  control: FTextFieldControl.managed(
                    controller: _searchController,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: Text('Memuat mata kuliah...'))
                : _offerings.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _offerings.length,
                        itemBuilder: (context, index) =>
                            _buildCourseCard(context, _offerings[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
