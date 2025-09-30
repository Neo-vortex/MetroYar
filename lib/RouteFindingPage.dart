// route_finding_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Services/api_service.dart' show ApiService, RouteResult;
import 'RouteResultsPage.dart'; // Import the results page

class RouteFindingPage extends StatefulWidget {
  const RouteFindingPage({super.key});

  @override
  State<RouteFindingPage> createState() => _RouteFindingPageState();
}

class _RouteFindingPageState extends State<RouteFindingPage> {
  String? startStation;
  String? endStation;
  String? selectedRouteType;
  List<String> selectedFilters = [];
  List<String> stations = []; // Empty list to be populated from API
  bool isLoadingStations = true;
  bool isSearchingRoute = false;
  String? stationError;

  final TextEditingController startStationController = TextEditingController();
  final TextEditingController endStationController = TextEditingController();
  final TextEditingController filterController = TextEditingController();

  final List<FilterOption> availableFilters = [
    FilterOption(
      title: "کافه‌شاپ",
      subtitle: "نزدیک کافه و قهوه‌خانه",
      icon: Icons.coffee,
      category: "امکانات",
    ),
    FilterOption(
      title: "رستوران",
      subtitle: "امکان غذاخوری",
      icon: Icons.restaurant,
      category: "امکانات",
    ),
    FilterOption(
      title: "پارکینگ",
      subtitle: "پارکینگ اختصاصی",
      icon: Icons.local_parking,
      category: "حمل‌ونقل",
    ),
    FilterOption(
      title: "فروشگاه",
      subtitle: "مراکز خرید و فروشگاه",
      icon: Icons.shopping_bag,
      category: "امکانات",
    ),
    FilterOption(
      title: "بانک و خودپرداز",
      subtitle: "خدمات بانکی",
      icon: Icons.account_balance,
      category: "خدمات",
    ),
    FilterOption(
      title: "بیمارستان",
      subtitle: "مراکز درمانی",
      icon: Icons.local_hospital,
      category: "خدمات",
    ),
    FilterOption(
      title: "آسانسور",
      subtitle: "دسترسی آسان برای معلولان",
      icon: Icons.elevator,
      category: "دسترسی",
    ),
    FilterOption(
      title: "اینترنت رایگان",
      subtitle: "WiFi در ایستگاه",
      icon: Icons.wifi,
      category: "امکانات",
    ),
    FilterOption(
      title: "توالت عمومی",
      subtitle: "سرویس بهداشتی",
      icon: Icons.wc,
      category: "امکانات",
    ),
    FilterOption(
      title: "ایستگاه اتوبوس",
      subtitle: "اتصال به اتوبوس شهری",
      icon: Icons.directions_bus,
      category: "حمل‌ونقل",
    ),
    FilterOption(
      title: "تاکسی",
      subtitle: "ایستگاه تاکسی",
      icon: Icons.local_taxi,
      category: "حمل‌ونقل",
    ),
    FilterOption(
      title: "داروخانه",
      subtitle: "داروخانه شبانه‌روزی",
      icon: Icons.medication,
      category: "خدمات",
    ),
  ];

  final List<RouteOption> routeOptions = [
    RouteOption(
      title: "کمترین ایستگاه",
      subtitle: "کوتاه‌ترین مسیر از نظر تعداد ایستگاه",
      icon: Icons.location_on_outlined,
    ),
    RouteOption(
      title: "کمترین فاصله",
      subtitle: "کوتاه‌ترین مسافت جغرافیایی",
      icon: Icons.straighten,
    ),
    RouteOption(
      title: "کمترین تعویض خط",
      subtitle: "کمترین تغییر خط مترو",
      icon: Icons.swap_horiz,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  void dispose() {
    startStationController.dispose();
    endStationController.dispose();
    filterController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    setState(() {
      isLoadingStations = true;
      stationError = null;
    });

    try {
      final loadedStations = await ApiService.getAvailableStations();
      setState(() {
        stations = loadedStations;
        isLoadingStations = false;
      });
    } catch (e) {
      setState(() {
        isLoadingStations = false;
        stationError = "خطا در بارگذاری ایستگاه‌ها";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "یافتن مسیر مترو",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ),
        body: isLoadingStations
            ? _buildLoadingIndicator()
            : stationError != null
            ? _buildErrorWidget()
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue[100]!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.route,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "برنامه‌ریزی سفر",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "بهترین مسیر را برای سفرتان انتخاب کنید",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Station Selection Section
                Text(
                  "انتخاب ایستگاه‌ها",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Start Station
                _buildStationSelector(
                  label: "ایستگاه مبدا",
                  icon: Icons.trip_origin,
                  controller: startStationController,
                  onStationSelected: (station) {
                    setState(() {
                      startStation = station;
                    });
                  },
                  iconColor: Colors.green,
                ),

                const SizedBox(height: 16),

                // Swap Button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _swapStations,
                      icon: const Icon(Icons.swap_vert),
                      color: Colors.blue[600],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // End Station
                _buildStationSelector(
                  label: "ایستگاه مقصد",
                  icon: Icons.location_on,
                  controller: endStationController,
                  onStationSelected: (station) {
                    setState(() {
                      endStation = station;
                    });
                  },
                  iconColor: Colors.red,
                ),

                const SizedBox(height: 32),

                // Route Options Section
                Text(
                  "نوع مسیر مورد نظر",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                ...routeOptions.map((option) => _buildRouteOptionCard(option)),

                const SizedBox(height: 32),

                // Filters Section
                Text(
                  "فیلترهای مسیر",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "امکانات و خدمات مورد نیاز خود را انتخاب کنید",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFilterSelector(),

                const SizedBox(height: 32),

                // Find Route Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSearchingRoute ? null : _findRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: isSearchingRoute
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "در حال جستجو...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "یافتن مسیر",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("در حال بارگذاری ایستگاه‌ها..."),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            stationError!,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStations,
            child: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSelector({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onStationSelected,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return stations;
            }
            return stations.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: onStationSelected,
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        title: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => onSelected(option),
                        dense: true,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteOptionCard(RouteOption option) {
    final isSelected = selectedRouteType == option.title;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedRouteType = option.title;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue[700] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: option.title,
                groupValue: selectedRouteType,
                onChanged: (value) {
                  setState(() {
                    selectedRouteType = value;
                  });
                },
                activeColor: Colors.blue[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          // Filter Search Field with Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selected Filters (Chips)
                if (selectedFilters.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedFilters.map((filter) {
                        final filterOption = availableFilters.firstWhere(
                              (option) => option.title == filter,
                        );
                        return _buildFilterChip(filterOption);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Search Field
                Autocomplete<FilterOption>(
                  displayStringForOption: (FilterOption option) => option.title,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return availableFilters.where((option) =>
                      !selectedFilters.contains(option.title));
                    }
                    return availableFilters.where((FilterOption option) {
                      return option.title.toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()) &&
                          !selectedFilters.contains(option.title);
                    });
                  },
                  onSelected: (FilterOption selection) {
                    setState(() {
                      if (!selectedFilters.contains(selection.title)) {
                        selectedFilters.add(selection.title);
                      }
                    });
                    filterController.clear();
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        labelText: "جستجوی فیلتر...",
                        hintText: "مثل: کافه‌شاپ، پارکینگ، رستوران",
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: Colors.purple[600],
                            size: 20,
                          ),
                        ),
                        suffixIcon: selectedFilters.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            Icons.clear_all,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedFilters.clear();
                            });
                          },
                          tooltip: "پاک کردن همه فیلترها",
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    option.icon,
                                    color: Colors.purple[600],
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  option.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    option.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                onTap: () => onSelected(option),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Popular Filters
          if (selectedFilters.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "فیلترهای پرکاربرد:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: availableFilters
                        .take(4)
                        .map((filter) => _buildSuggestedFilterChip(filter))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(FilterOption filter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[100]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple[200]!, width: 1),
      ),
      child: Chip(
        avatar: Icon(
          filter.icon,
          size: 16,
          color: Colors.purple[700],
        ),
        label: Text(
          filter.title,
          style: TextStyle(
            color: Colors.purple[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: Colors.purple[600],
        ),
        onDeleted: () {
          setState(() {
            selectedFilters.remove(filter.title);
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSuggestedFilterChip(FilterOption filter) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!selectedFilters.contains(filter.title)) {
            selectedFilters.add(filter.title);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              filter.title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swapStations() {
    setState(() {
      final tempStation = startStation;
      final tempController = startStationController.text;

      startStation = endStation;
      endStation = tempStation;

      startStationController.text = endStationController.text;
      endStationController.text = tempController;
    });
  }

  Future<void> _findRoute() async {
    if (startStation == null || startStation!.isEmpty ||
        endStation == null || endStation!.isEmpty ||
        selectedRouteType == null) {
      _showSnackBar(
        "لطفا همه فیلدها را پر کنید.",
        Colors.orange[600]!,
        Icons.warning_amber_rounded,
      );
      return;
    }

    if (startStation == endStation) {
      _showSnackBar(
        "ایستگاه مبدا و مقصد نمی‌توانند یکسان باشند.",
        Colors.orange[600]!,
        Icons.error_outline,
      );
      return;
    }

    setState(() {
      isSearchingRoute = true;
    });

    try {
      final result = await ApiService.findRoute(
        startStation: startStation!,
        endStation: endStation!,
        routeType: selectedRouteType!,
        filters: selectedFilters,
      );

      setState(() {
        isSearchingRoute = false;
      });

      // Navigate to results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteResultsPage(routeResult: result),
        ),
      );

    } catch (e) {
      setState(() {
        isSearchingRoute = false;
      });

      _showSnackBar(
        "خطا در جستجوی مسیر: ${e.toString()}",
        Colors.red[600]!,
        Icons.error,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class RouteOption {
  final String title;
  final String subtitle;
  final IconData icon;

  RouteOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class FilterOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String category;

  FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
  });
}