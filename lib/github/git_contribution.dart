import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GitHubContributionsWidget extends StatefulWidget {
  final String username;
  final String token;
  final double height;
  final List<Color> contributionColors;
  final Color emptyColor;
  final Color backgroundColor;
  final TextStyle? monthLabelStyle;
  final TextStyle? dayLabelStyle;
  final Widget? loadingWidget;
  final Function(Widget)? onSliderReady;

  const GitHubContributionsWidget({
    super.key,
    required this.username,
    required this.token,
    required this.height,
    required this.contributionColors,
    required this.emptyColor,
    required this.backgroundColor,
    this.monthLabelStyle,
    this.dayLabelStyle,
    this.loadingWidget,
    this.onSliderReady,
  });

  @override
  State<GitHubContributionsWidget> createState() =>
      _GitHubContributionsWidgetState();
}

class _GitHubContributionsWidgetState extends State<GitHubContributionsWidget> {
  final ScrollController scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<ContributionDay> _allDays = [];
  bool _isLoading = true;
  String? _error;
  double _scrollPosition = 0.0;
  double _maxScrollExtent = 0.0;
  bool _showScrollbar = false;
  Timer? _scrollbarTimer;

  @override
  void initState() {
    super.initState();
    _fetchAllYears();

    scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollPosition = scrollController.offset;
          _maxScrollExtent = scrollController.position.maxScrollExtent;
          _showScrollbar = true;
        });

        _scrollbarTimer?.cancel();
        _scrollbarTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showScrollbar = false;
            });
          }
        });

        // Notify parent widget about slider state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.onSliderReady != null) {
            widget.onSliderReady!(buildSlider());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _focusNode.dispose();
    _scrollbarTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllYears() async {
    final List<ContributionDay> totalDays = [];

    final result = await _fetchYearlyContributions(2025);
    if (result != null) {
      totalDays.addAll(result);
    }

    if (mounted) {
      setState(() {
        _allDays = totalDays;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToCurrentMonth();
        }
      });
    }
  }

  Future<List<ContributionDay>?> _fetchYearlyContributions(int year) async {
    const url = 'https://api.github.com/graphql';
    final from = DateTime(year, 1, 1).toIso8601String();
    final to = DateTime(year, 12, 31).toIso8601String();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '''
        query {
          user(login: "${widget.username}") {
            contributionsCollection(from: "$from", to: "$to") {
              contributionCalendar {
                weeks {
                  contributionDays {
                    date
                    contributionCount
                  }
                }
              }
            }
          }
        }
        '''
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weeks = data['data']['user']['contributionsCollection']
          ['contributionCalendar']['weeks'];
      final yearDays = <ContributionDay>[];

      for (var week in weeks) {
        for (var day in week['contributionDays']) {
          yearDays.add(
            ContributionDay(
              date: DateTime.parse(day['date']),
              count: day['contributionCount'],
            ),
          );
        }
      }

      return yearDays;
    } else {
      debugPrint('GitHub API error: ${response.body}');
      if (mounted) {
        setState(() {
          _error = 'Failed to load contributions.';
        });
      }
      return null;
    }
  }

  Color _getColor(int count) {
    if (count == 0) return widget.emptyColor;
    final index = (count ~/ 2).clamp(0, widget.contributionColors.length - 1);
    return widget.contributionColors[index];
  }
void _scrollToCurrentMonth() {
  final monthGroups = _groupByMonth();
  if (monthGroups.isEmpty) return;

  const targetMonth = '2025-07'; // Target June 2025
  double offset = 0;
  bool foundTarget = false;

  // Calculate the offset to the start of June
  for (final entry in monthGroups.entries) {
    if (entry.key == targetMonth) {
      foundTarget = true;
      break;
    }
    offset += (entry.value.length / 7).ceil() * 18 + 12; // Width of each month
  }

  if (!foundTarget) return; // Exit if June 2025 is not found

  // Get the width of June
  final juneDays = monthGroups[targetMonth]!;
  final juneWidth = (juneDays.length / 7).ceil() * 18 + 12;

  // Get the viewport width (approximated as widget width minus padding)
  final viewportWidth = MediaQuery.of(context).size.width - 80; // 40 padding on each side

  // Calculate the offset to center June
  final centerOffset = offset + (juneWidth / 2) - (viewportWidth / 2);

  // Ensure the offset is within valid bounds
  final finalOffset = centerOffset.clamp(0.0, scrollController.position.maxScrollExtent);

  scrollController.animateTo(
    finalOffset,
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
  );
}


  void _onScrollbarDrag(double value) {
    final newOffset = value * _maxScrollExtent;
    scrollController.jumpTo(newOffset);
  }

  Map<String, List<ContributionDay>> _groupByMonth() {
    final Map<String, List<ContributionDay>> monthGroups = {};
    for (var day in _allDays) {
      if (day.date.year == 2025 && day.date.month >= 4 && day.date.month <= 12) {
        final key = DateFormat('yyyy-MM').format(day.date);
        monthGroups.putIfAbsent(key, () => []).add(day);
      }
    }
    return monthGroups;
  }

@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return widget.loadingWidget ??
        const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent));
  }

  if (_error != null) {
    return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)));
  }

  final cellSize = 14.0;
  final cellSpacing = 4.0;
  final monthGroups = _groupByMonth();

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
      gradient: const LinearGradient(
        colors: [Color(0xFF0B1020), Color(0xFF101828), Color(0xFF0B1020)],
        stops: [0.0, 0.6, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: widget.height + 50,
        child: Stack(
          children: [
            // 🔹 Scrollable graph
            Positioned.fill(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: monthGroups.entries.map((entry) {
                      final days = entry.value;
                      days.sort((a, b) => a.date.compareTo(b.date));

                      final List<List<ContributionDay?>> weeks = [];
                      List<ContributionDay?> currentWeek = List.filled(7, null);
                      for (var day in days) {
                        final weekday = day.date.weekday % 7;
                        currentWeek[weekday] = day;
                        if (weekday == 6) {
                          weeks.add(currentWeek);
                          currentWeek = List.filled(7, null);
                        }
                      }
                      if (currentWeek.any((d) => d != null)) {
                        weeks.add(currentWeek);
                      }

                      final monthLabel =
                          DateFormat.MMM().format(days.first.date);

                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  monthLabel,
                                  style: widget.monthLabelStyle ??
                                      const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Row(
                              children: weeks.map((week) {
                                return Column(
                                  children: List.generate(7, (i) {
                                    final day = week[i];
                                    return Tooltip(
                                      message: day != null
                                          ? "${day.count} contributions on ${DateFormat('MMM d, yyyy').format(day.date)}"
                                          : "No contributions",
                                      textStyle: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      waitDuration:
                                          const Duration(milliseconds: 300),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: cellSpacing,
                                            right: cellSpacing),
                                        width: cellSize,
                                        height: cellSize,
                                        decoration: BoxDecoration(
                                          color: day != null
                                              ? _getColor(day.count)
                                              : widget.emptyColor
                                                  .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

           // 🔹 Left button
Positioned(
  left: 8,
  top: 0,
  bottom: 0,
  child: Center(
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B1020),
            Color(0xFF101828),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8), // Square with slightly rounded edges
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          final newOffset =
              (scrollController.offset - 150).clamp(0.0, _maxScrollExtent);
          scrollController.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        },
      ),
    ),
  ),
),

// 🔹 Right button
Positioned(
  right: 8,
  top: 0,
  bottom: 0,
  child: Center(
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF101828),
            Color(0xFF0B1020),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(-2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        onPressed: () {
          final newOffset =
              (scrollController.offset + 150).clamp(0.0, _maxScrollExtent);
          scrollController.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        },
      ),
    ),
  ),
),
          ],
        ),
      ),
    ),
  );
}

  // Method to get the slider widget separately
  Widget buildSlider() {
    if (_maxScrollExtent > 0 && _showScrollbar) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.cyanAccent.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: Colors.cyanAccent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 6,
          ),
          child: Slider(
            value: _maxScrollExtent > 0
                ? (_scrollPosition / _maxScrollExtent).clamp(0.0, 1.0)
                : 0.0,
            onChanged: _onScrollbarDrag,
            min: 0.0,
            max: 1.0,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class ContributionDay {
  final DateTime date;
  final int count;
  ContributionDay({required this.date, required this.count});
}