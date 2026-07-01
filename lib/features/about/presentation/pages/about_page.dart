import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_dimens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.train_rounded,
                size: 42,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'MetroYar',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version;
              return Center(
                child: Text(
                  version != null ? 'نسخهٔ $version' : ' ',
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'مترویار، همراه روزانهٔ شما در متروی تهران است. سریع‌ترین، '
                'کم‌تعویض‌ترین یا کوتاه‌ترین مسیر بین دو ایستگاه را پیدا کنید، '
                'امکانات هر ایستگاه (سرویس بهداشتی، آسانسور، دسترسی ویژه و '
                'موارد دیگر) را ببینید و نقشهٔ کامل خطوط مترو را به‌صورت '
                'تعاملی مرور کنید — همه به‌صورت آفلاین و بدون نیاز به اینترنت.',
                style: TextStyle(height: 1.8, fontSize: 13.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bolt_rounded),
                  title: const Text('ساخته‌شده با Flutter و معماری BLoC'),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('داده‌های ایستگاه‌ها و نقشهٔ خطوط مترو تهران'),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_fix_high_sharp),
                  title: const Text('محمدرضا نخله'),
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              '© ${DateTime.now().year} MetroYar',
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
