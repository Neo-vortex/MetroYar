import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const int _pageCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await sl<PreferencesService>().setOnboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
  }

  void _next() {
    if (_index == _pageCount - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: AppDurations.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLastPage = _index == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: isLastPage ? null : _finish,
                  child: Opacity(
                    opacity: isLastPage ? 0 : 1,
                    child: const Text('رد کردن'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  OnboardingSlide(
                    icon: Icons.route_rounded,
                    color: AppColors.seed,
                    title: 'سریع‌ترین مسیر را پیدا کنید',
                    description:
                        'ایستگاه مبدا و مقصد را انتخاب کنید تا مترویار '
                        'بهترین مسیر بین آن‌ها را در چند لحظه به شما '
                        'نشان دهد.',
                  ),
                  OnboardingSlide(
                    icon: Icons.tune_rounded,
                    color: AppColors.lineColor(7),
                    title: 'مسیر را مطابق سلیقهٔ خودتان بچینید',
                    description:
                        'از میان چند الگوریتم جست‌وجو انتخاب کنید: '
                        'کم‌ایستگاه‌ترین، کم‌فاصله‌ترین، کم‌تعویض‌ترین یا '
                        'کم‌زمان‌ترین مسیر — هرکدام را که می‌خواهید ببینید.',
                  ),
                  OnboardingSlide(
                    icon: Icons.my_location_rounded,
                    color: AppColors.warning,
                    title: 'با موقعیت مکانی یا روی نقشه انتخاب کنید',
                    description:
                        'نزدیک‌ترین ایستگاه به موقعیت فعلی‌تان را به‌صورت '
                        'خودکار پیدا کنید یا مبدا و مقصد را مستقیماً روی '
                        'نقشهٔ شهر لمس کنید.',
                  ),
                  OnboardingSlide(
                    icon: Icons.schedule_rounded,
                    color: AppColors.danger,
                    title: 'زمان دقیق حرکت قطارها',
                    description:
                        'برنامهٔ حرکت قطار هر ایستگاه و زمان تقریبی رسیدن '
                        'به مقصد را ببینید تا هیچ‌وقت منتظر قطار بعدی '
                        'نمانید.',
                  ),
                  OnboardingSlide(
                    icon: Icons.map_rounded,
                    color: AppColors.success,
                    title: 'نقشهٔ کامل مترو، در جیب شما',
                    description:
                        'نقشهٔ تمام خطوط متروی تهران را به‌صورت تعاملی '
                        'مرور کنید و امکانات هر ایستگاه را با یک لمس '
                        'ببینید — کاملاً آفلاین.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (i) {
                  final isActive = i == _index;
                  return AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? colors.primary : colors.outlineVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(isLastPage ? 'شروع کنیم' : 'بعدی'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
