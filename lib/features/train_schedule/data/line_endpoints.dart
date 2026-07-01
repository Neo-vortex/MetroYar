class _Endpoint {
  final String en;
  final String fa;

  const _Endpoint(this.en, this.fa);
}

class _LineBranches {
  final _Endpoint mainFirst;
  final _Endpoint mainSecond;
  final _Endpoint? branchFirst;
  final _Endpoint? branchSecond;

  const _LineBranches({
    required this.mainFirst,
    required this.mainSecond,
    this.branchFirst,
    this.branchSecond,
  });
}

/// The two terminus stations of each metro line (and branch, where one
/// exists), in both languages. Used to normalize the destination names
/// found inside the raw timetable JSON — which are just prefixes of the
/// schedule key and don't always exactly match a display name.
///
/// Source: the rival Kotlin app's `LineEndpoints` table.
class LineEndpoints {
  static final Map<int, _LineBranches> _table = {
    1: const _LineBranches(
      mainFirst: _Endpoint('Tajrish', 'تجریش'),
      mainSecond: _Endpoint('Kahrizak', 'کهریزک'),
      branchFirst: _Endpoint('Tajrish', 'تجریش'),
      branchSecond: _Endpoint('Shahr-e Parand', 'شهر پرند'),
    ),
    2: const _LineBranches(
      mainFirst: _Endpoint('Farhangsara', 'فرهنگسرا'),
      mainSecond: _Endpoint('Tehran (Sadeghiyeh)', 'صادقیه'),
    ),
    3: const _LineBranches(
      mainFirst: _Endpoint("Qa'em", 'قائم'),
      mainSecond: _Endpoint('Azadegan', 'آزادگان'),
    ),
    4: const _LineBranches(
      mainFirst: _Endpoint('Kolahdooz', 'کلاهدوز'),
      mainSecond: _Endpoint('Allameh Jafari', 'علامه جعفری'),
      branchFirst: _Endpoint('Kolahdooz', 'کلاهدوز'),
      branchSecond:
          _Endpoint('Mehrabad Airport Terminal 4&6', 'ترمینال ۴و۶ فرودگاه مهرآباد'),
    ),
    5: const _LineBranches(
      mainFirst: _Endpoint('Tehran (Sadeghiyeh)', 'صادقیه'),
      mainSecond: _Endpoint('Golshahr', 'گلشهر'),
      branchFirst: _Endpoint('Tehran (Sadeghiyeh)', 'صادقیه'),
      branchSecond: _Endpoint(
          'Shahid Sepahbod Qasem Soleimani', 'شهید سپهبد قاسم سلیمانی'),
    ),
    6: const _LineBranches(
      mainFirst: _Endpoint('Haram-e Abdol Azim', 'حرم عبدالعظیم'),
      mainSecond: _Endpoint('Kouhsar', 'کوهسار'),
    ),
    7: const _LineBranches(
      mainFirst: _Endpoint('Varzeshgah-e Takhti', 'ورزشگاه تختی'),
      mainSecond: _Endpoint('Meydan-e Ketab', 'میدان کتاب'),
    ),
  };

  /// Returns (first, second) English terminus names for [line], falling
  /// back to the main branch if [useBranch] was requested but the line
  /// has no branch.
  static (String, String)? getEn(int line, {bool useBranch = false}) {
    final branches = _table[line];
    if (branches == null) return null;
    if (useBranch && branches.branchFirst != null && branches.branchSecond != null) {
      return (branches.branchFirst!.en, branches.branchSecond!.en);
    }
    return (branches.mainFirst.en, branches.mainSecond.en);
  }

  static (String, String)? getFa(int line, {bool useBranch = false}) {
    final branches = _table[line];
    if (branches == null) return null;
    if (useBranch && branches.branchFirst != null && branches.branchSecond != null) {
      return (branches.branchFirst!.fa, branches.branchSecond!.fa);
    }
    return (branches.mainFirst.fa, branches.mainSecond.fa);
  }
}
