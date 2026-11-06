import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/app/routes.dart';
import 'package:podo/core/theme/app_colors.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';
import 'package:podo/features/courses/models/course_offering.dart';
import 'package:podo/features/courses/repositories/course_repository.dart';
import 'package:podo/features/courses/widgets/add_class_offering_sheet.dart';
import 'package:podo/features/courses/widgets/add_course_sheet.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final AnimationController _fabAnimController;
  late final Animation<double> _fabAnimation;

  List<CourseOffering> _offerings = [];
  bool _isLoading = true;
  bool _showAppbarTitle = false;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOut,
    );

    _loadOfferings();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 40;
    if (show != _showAppbarTitle) {
      setState(() => _showAppbarTitle = show);
    }
  }

  void _onSearchChanged() {
    _loadOfferings(query: _searchController.text);
  }

  void _toggleFab() {
    if (_isFabExpanded) {
      _fabAnimController.reverse();
      setState(() => _isFabExpanded = false);
    } else {
      _fabAnimController.forward();
      setState(() => _isFabExpanded = true);
    }
  }

  void _collapseFab() {
    if (_isFabExpanded) {
      _fabAnimController.reverse();
      setState(() => _isFabExpanded = false);
    }
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

  int get _totalStudents =>
      _offerings.fold<int>(0, (sum, item) => sum + item.enrolledCount);

  void _navigateToDetail(CourseOffering offering) {
    _collapseFab();
    Navigator.of(context).pushNamed(
      AppRoutes.courseDetail,
      arguments: offering,
    );
  }

  Future<void> _showAddClassSheet() async {
    _collapseFab();
    final created = await showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      builder: (context) => const AddClassOfferingSheet(),
    );

    if (created == true) {
      await _loadOfferings();
      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Kelas perkuliahan berhasil ditambahkan'),
        );
      }
    }
  }

  Future<void> _showAddCourseSheet() async {
    _collapseFab();
    final created = await showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      builder: (context) => const AddCourseSheet(),
    );

    if (created == true) {
      await _loadOfferings();
      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Mata kuliah berhasil ditambahkan'),
        );
      }
    }
  }

  Widget _buildHeroBanner(BuildContext context) {
    final colors = context.appColors;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Total Kelas',
                value: '${_offerings.length}',
                icon: FLucideIcons.bookOpen,
                iconBg: colors.sky.background,
                iconColor: colors.sky.foreground,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: context.theme.colors.border,
            ),
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Total SKS',
                value: '$_totalCredits',
                icon: FLucideIcons.award,
                iconBg: colors.amber.background,
                iconColor: colors.amber.foreground,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: context.theme.colors.border,
            ),
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Total Mahasiswa',
                value: '$_totalStudents',
                icon: FLucideIcons.users,
                iconBg: colors.emerald.background,
                iconColor: colors.emerald.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    final theme = context.theme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.typography.display.sm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final isSearching = _searchController.text.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.violet.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isSearching ? FLucideIcons.searchX : FLucideIcons.bookOpen,
                    size: 26,
                    color: colors.violet.foreground,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isSearching
                      ? 'Mata kuliah tidak ditemukan'
                      : 'Belum ada kelas perkuliahan',
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  isSearching
                      ? 'Coba ubah kata kunci pencarian Anda.'
                      : 'Tambahkan kelas perkuliahan baru untuk memulai.',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (isSearching)
                  FButton(
                    size: FButtonSizeVariant.sm,
                    variant: FButtonVariant.outline,
                    onPress: () => _searchController.clear(),
                    child: const Text('Reset Pencarian'),
                  )
                else
                  FButton(
                    size: FButtonSizeVariant.sm,
                    prefix: const Icon(FLucideIcons.plus),
                    onPress: _showAddClassSheet,
                    child: const Text('Kuliah'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    CourseOffering offering,
    int index,
  ) {
    final theme = context.theme;
    final colors = context.appColors;

    final pastelTokens = [
      colors.sky,
      colors.violet,
      colors.amber,
      colors.emerald,
    ];
    final cardToken = pastelTokens[index % pastelTokens.length];

    final semanticsLabel =
        'Mata kuliah: ${offering.courseName}, Kelas ${offering.className}, '
        '${offering.credits} SKS, ${offering.enrolledCount} Mahasiswa, '
        '${offering.academicYear} ${offering.term}. Ketuk untuk membuka detail mata kuliah.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        excludeSemantics: true,
        child: FTappable(
          onPress: () => _navigateToDetail(offering),
          child: Container(
            decoration: BoxDecoration(
              color: cardToken.background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.bookOpen,
                        size: 20,
                        color: cardToken.foreground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.courseName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: cardToken.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.card,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Kelas ${offering.className}',
                                  style: TextStyle(
                                    color: cardToken.foreground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colors.card,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${offering.credits} SKS',
                                  style: TextStyle(
                                    color: cardToken.foreground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colors.card,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FLucideIcons.chevronRight,
                        size: 14,
                        color: cardToken.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FLucideIcons.users,
                          size: 13,
                          color: cardToken.foreground.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${offering.enrolledCount} Mahasiswa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cardToken.foreground.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FLucideIcons.calendar,
                          size: 13,
                          color: cardToken.foreground.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${offering.academicYear} (${offering.term})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cardToken.foreground.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
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
    final theme = context.theme;

    return FScaffold(
      header: FHeader.nested(
        titleAlignment: Alignment.center,
        style: const FHeaderStyleDelta.delta(
          constraints: BoxConstraints(minHeight: 40, maxHeight: 40),
          padding: EdgeInsetsGeometryDelta.value(
            EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        title: _showAppbarTitle
            ? Text(
                'Mata Kuliah',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox.shrink(),
      ),
      child: Stack(
        children: [
          // Main scrollable list and headers
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mata Kuliah',
                      style: theme.typography.display.lg.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildHeroBanner(context),
                    const SizedBox(height: 12),
                    FTextField(
                      hint: 'Cari mata kuliah atau kelas...',
                      clearable: (value) => value.text.isNotEmpty,
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
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: _offerings.length,
                            itemBuilder: (context, index) => _buildCourseCard(
                              context,
                              _offerings[index],
                              index,
                            ),
                          ),
              ),
            ],
          ),

          // Dismiss barrier when speed dial is open
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _collapseFab,
                child: FadeTransition(
                  opacity: _fabAnimation,
                  child: Container(
                    color: const Color(0x33000000),
                  ),
                ),
              ),
            ),

          // Floating Action Button with Speed Dial items
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isFabExpanded) ...[
                  // Action 1: Tambah Mata Kuliah
                  FadeTransition(
                    opacity: _fabAnimation,
                    child: ScaleTransition(
                      scale: _fabAnimation,
                      alignment: Alignment.bottomRight,
                      child: FTappable(
                        onPress: _showAddCourseSheet,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.card,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Tambah Mata Kuliah',
                                style: theme.typography.body.xs.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colors.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colors.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                FLucideIcons.bookPlus,
                                size: 18,
                                color: theme.colors.primaryForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action 2: Tambah Kelas
                  FadeTransition(
                    opacity: _fabAnimation,
                    child: ScaleTransition(
                      scale: _fabAnimation,
                      alignment: Alignment.bottomRight,
                      child: FTappable(
                        onPress: _showAddClassSheet,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.card,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Tambah Kelas',
                                style: theme.typography.body.xs.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colors.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colors.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                FLucideIcons.school,
                                size: 18,
                                color: theme.colors.primaryForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Main FAB Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FButton.icon(
                      variant: FButtonVariant.primary,
                      size: FButtonSizeVariant.lg,
                      semanticsLabel:
                          _isFabExpanded ? 'Tutup menu aksi' : 'Buka menu tambah',
                      onPress: _toggleFab,
                      child: RotationTransition(
                        turns: _fabAnimation.drive(
                          Tween<double>(begin: 0.0, end: 0.125),
                        ),
                        child: const Icon(FLucideIcons.plus),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
