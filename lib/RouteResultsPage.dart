import 'package:flutter/material.dart';
import 'Services/api_service.dart';

class RouteResultsPage extends StatefulWidget {
  final RouteResult routeResult;

  const RouteResultsPage({
    super.key,
    required this.routeResult,
  });

  @override
  State<RouteResultsPage> createState() => _RouteResultsPageState();
}

class _RouteResultsPageState extends State<RouteResultsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedRouteIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.routeResult.routes.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getLineColor(int lineNumber) {
    switch (lineNumber) {
      case 1: return Colors.red;
      case 2: return Colors.blue;
      case 3: return Colors.green;
      case 4: return Colors.orange;
      case 5: return Colors.purple;
      case 6: return Colors.brown;
      case 7: return Colors.pink;
      default: return Colors.grey;
    }
  }

  String _getStepDescription(RouteStep step, RouteStep? nextStep) {
    switch (step.type) {
      case RouteStepType.start:
        return "شروع مسیر";
      case RouteStepType.goToNextStation:
        if (step.lineNumber != null) {
          return "خط ${step.lineNumber} - ادامه مسیر";
        }
        return "ادامه مسیر";
      case RouteStepType.changeLine:
        return "تعویض خط از خط ${step.fromLine} به خط ${step.toLine}";
      case RouteStepType.end:
        return "پایان مسیر";
      default:
        return "حرکت";
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
            "نتایج مسیر",
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
        body: Column(
          children: [
            // Route Summary Card
            _buildRouteSummaryCard(),

            // Route Options Tabs (if multiple routes)
            if (widget.routeResult.routes.length > 1)
              _buildRouteTabBar(),

            // Route Details
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.routeResult.routes.map((route) =>
                    _buildRouteDetailView(route)).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  Widget _buildRouteSummaryCard() {
    final primaryRoute = widget.routeResult.primaryRoute;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Route Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.route,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.routeResult.startStation} ← ${widget.routeResult.endStation}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.routeResult.routeType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Route Statistics
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.location_on,
                      label: "ایستگاه",
                      value: "${widget.routeResult.totalStations}",
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.swap_horiz,
                      label: "تعویض خط",
                      value: "${widget.routeResult.lineChanges}",
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.train,
                      label: "خط مترو",
                      value: "${widget.routeResult.linesUsed.length}",
                      color: Colors.purple,
                    ),
                  ],
                ),

                // Active Filters
                if (widget.routeResult.filters.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "فیلترهای اعمال شده:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: widget.routeResult.filters.map((filter) =>
                              Chip(
                                label: Text(
                                  filter,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.purple[100],
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: List.generate(widget.routeResult.routes.length, (index) =>
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    index == 0 ? Icons.star : Icons.alt_route,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(index == 0 ? "پیشنهادی" : "مسیر ${index + 1}"),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildRouteDetailView(List<RouteStep> route) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            // Route Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "مسیر کامل سفر",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${route.length} ایستگاه",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Route Steps with Enhanced Details
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: route.length,
                itemBuilder: (context, index) {
                  final step = route[index];
                  final nextStep = index < route.length - 1 ? route[index + 1] : null;
                  final previousStep = index > 0 ? route[index - 1] : null;
                  final isLast = index == route.length - 1;

                  return _buildEnhancedRouteStepItem(
                    step,
                    nextStep,
                    previousStep,
                    isLast,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRouteStepItem(
      RouteStep step,
      RouteStep? nextStep,
      RouteStep? previousStep,
      bool isLast,
      int index,
      ) {
    Color stepColor;
    IconData stepIcon;

    switch (step.type) {
      case RouteStepType.start:
        stepColor = Colors.green;
        stepIcon = Icons.trip_origin;
        break;
      case RouteStepType.end:
        stepColor = Colors.red;
        stepIcon = Icons.location_on;
        break;
      case RouteStepType.changeLine:
        stepColor = Colors.orange;
        stepIcon = Icons.swap_horiz;
        break;
      default:
        stepColor = Colors.blue;
        stepIcon = Icons.train;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Indicator Column
            Column(
              children: [
                // Main Step Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: stepColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: stepColor, width: 2.5),
                  ),
                  child: Icon(
                    stepIcon,
                    color: stepColor,
                    size: 22,
                  ),
                ),

                // Connection Line
                if (!isLast)
                  Container(
                    width: 3,
                    height: _getStepHeight(step, nextStep),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [stepColor.withOpacity(0.6), Colors.grey[300]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Step Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station Name with Enhanced Display
                    _buildStationNameCard(step, stepColor),

                    const SizedBox(height: 8),

                    // Step Instructions
                    _buildStepInstructions(step, nextStep, previousStep),

                    // Line Information
                    if (step.station.lines.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildLineInformation(step),
                    ],

                    // Special Information for Line Changes
                    if (step.type == RouteStepType.changeLine) ...[
                      const SizedBox(height: 12),
                      _buildLineChangeInfo(step),
                    ],

                    // Travel Information (for intermediate stations)
                    if (step.type == RouteStepType.goToNextStation && nextStep != null) ...[
                      const SizedBox(height: 12),
                      _buildTravelInfo(step, nextStep),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _getStepHeight(RouteStep currentStep, RouteStep? nextStep) {
    // Adjust height based on step type and content
    if (currentStep.type == RouteStepType.changeLine) {
      return 80.0;
    } else if (currentStep.type == RouteStepType.start || currentStep.type == RouteStepType.end) {
      return 60.0;
    } else {
      return 70.0;
    }
  }

  Widget _buildStationNameCard(RouteStep step, Color stepColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stepColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: stepColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Station Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: stepColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: stepColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Station Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.station.properties["translationsFa"].isNotEmpty
                      ? step.station.properties["translationsFa"]
                      : "ایستگاه",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (step.station.properties["translationsEn"].isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.station.translationsEn,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Step Type Badge
          _buildStepTypeBadge(step.type, stepColor),
        ],
      ),
    );
  }

  Widget _buildStepTypeBadge(RouteStepType type, Color color) {
    String text;
    switch (type) {
      case RouteStepType.start:
        text = "شروع";
        break;
      case RouteStepType.end:
        text = "پایان";
        break;
      case RouteStepType.changeLine:
        text = "تعویض";
        break;
      default:
        text = "ایستگاه";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStepInstructions(RouteStep step, RouteStep? nextStep, RouteStep? previousStep) {
    String instruction = _getDetailedStepDescription(step, nextStep, previousStep);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedStepDescription(RouteStep step, RouteStep? nextStep, RouteStep? previousStep) {
    switch (step.type) {
      case RouteStepType.start:
        if (nextStep != null) {
          final nextStationName = nextStep.station.properties["translationsFa"].isNotEmpty
              ? nextStep.station.properties["translationsFa"]
              : "ایستگاه بعدی";
          if (step.lineNumber != null) {
            return "سوار خط ${step.lineNumber} شوید و به سمت $nextStationName حرکت کنید";
          }
          return "سفر خود را از اینجا شروع کنید و به سمت $nextStationName حرکت کنید";
        }
        return "نقطه شروع سفر شما";

      case RouteStepType.goToNextStation:
        if (nextStep != null && previousStep != null) {
          final nextStationName = nextStep.station.properties["translationsFa"].isNotEmpty
              ? nextStep.station.properties["translationsFa"]
              : "ایستگاه بعدی";
          if (step.lineNumber != null) {
            return "در خط ${step.lineNumber} ادامه دهید - ایستگاه بعدی: $nextStationName";
          }
          return "ادامه مسیر به سمت $nextStationName";
        } else if (step.lineNumber != null) {
          return "در خط ${step.lineNumber} حرکت کنید";
        }
        return "در مسیر ادامه دهید";

      case RouteStepType.changeLine:
        if (step.fromLine != null && step.toLine != null) {
          if (nextStep != null) {
            final nextStationName = nextStep.station.properties["translationsFa"].isNotEmpty
                ? nextStep.station.properties["translationsFa"]
                : "ایستگاه بعدی";
            return "از خط ${step.fromLine} پیاده شده و سوار خط ${step.toLine} شوید\nایستگاه بعدی: $nextStationName";
          }
          return "از خط ${step.fromLine} به خط ${step.toLine} تعویض کنید";
        }
        return "در این ایستگاه خط تعویض کنید";

      case RouteStepType.end:
        return "مقصد نهایی شما - در این ایستگاه پیاده شوید";

      default:
        return "ادامه مسیر";
    }
  }

  Widget _buildLineInformation(RouteStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.train,
              color: Colors.grey[600],
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              "خطوط در دسترس:",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: step.station.lines.map((line) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLineColor(line).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getLineColor(line).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getLineColor(line),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "خط $line",
                      style: TextStyle(
                        fontSize: 11,
                        color: _getLineColor(line),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildLineChangeInfo(RouteStep step) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [?Colors.orange[1], ?Colors.orange[2]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.transfer_within_a_station,
                color: Colors.orange[700],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "راهنمای تعویض خط",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (step.fromLine != null && step.toLine != null) ...[
            Row(
              children: [
                _buildLineChangeChip(step.fromLine!, Colors.red[400]!, "خروج از"),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                _buildLineChangeChip(step.toLine!, Colors.green[400]!, "ورود به"),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            "از پلکان یا آسانسور برای رسیدن به خط جدید استفاده کنید",
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChangeChip(int lineNumber, Color color, String prefix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        "$prefix خط $lineNumber",
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTravelInfo(RouteStep currentStep, RouteStep nextStep) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_transit,
            color: Colors.blue[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "ایستگاه بعدی: ${nextStep.station.properties["translationsFa"]}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (currentStep.lineNumber != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getLineColor(currentStep.lineNumber!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "خط ${currentStep.lineNumber}",
                style: TextStyle(
                  fontSize: 9,
                  color: _getLineColor(currentStep.lineNumber!),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search),
              label: const Text("جستجوی جدید"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement save route functionality
                _showSnackBar("مسیر ذخیره شد!", Colors.green[600]!);
              },
              icon: const Icon(Icons.bookmark),
              label: const Text("ذخیره مسیر"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}