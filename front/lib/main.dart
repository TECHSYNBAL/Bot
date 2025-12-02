import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:js' as js;
import 'analytics.dart';
import 'telegram_platform.dart';

class DiagonalLinePainter extends CustomPainter {
  final List<double>? dataPoints; // Optional: for real data later

  DiagonalLinePainter({this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = const Color(0xFFE4E4E4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Use real data if provided, otherwise use sample points
    final points = dataPoints ?? _getSamplePoints(size);

    if (points.isEmpty) return;

    // Calculate step size to ensure all points are distributed across full width
    // Always use full width regardless of number of points
    final pointCount = points.length;
    final stepSize = pointCount > 1 ? size.width / (pointCount - 1) : 0.0;

    // Start the path at the first point (x=0, always)
    // Y coordinate: higher normalized values (maxPrice = 1.0) should be at top (y=0)
    // Lower normalized values (minPrice = 0.0) should be at bottom (y=height)
    // So we invert: y = height - (normalizedValue * height)
    final startY = size.height - (points[0] * size.height);
    path.moveTo(0, startY);

    // Handle single point case - draw a horizontal line
    if (pointCount == 1) {
      path.lineTo(size.width, startY);
    } else {
      // Create smooth curve through all points using cubic bezier
      // Always distribute all points across the full width
      for (int i = 1; i < pointCount; i++) {
        // Calculate x position: always span from 0 to full width
        final x = i * stepSize;
        // Invert Y so higher values appear at top
        final y = size.height - (points[i] * size.height);

        if (i == 1) {
          // First segment: use quadratic curve
          final controlX = x * 0.5;
          final controlY = size.height -
              (points[0] * size.height) * 0.7 -
              (points[i] * size.height) * 0.3;
          path.quadraticBezierTo(controlX, controlY, x, y);
        } else {
          // Subsequent segments: use cubic bezier for smooth transitions
          final prevX = (i - 1) * stepSize;
          final prevY = size.height - (points[i - 1] * size.height);

          // Control points for smooth curve
          final cp1X = prevX + (x - prevX) * 0.3;
          final cp1Y = prevY;
          final cp2X = prevX + (x - prevX) * 0.7;
          final cp2Y = y;

          path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, x, y);
        }
      }

      // Ensure the last point reaches the full width
      if (pointCount > 1) {
        final lastX = (pointCount - 1) * stepSize;
        if (lastX < size.width) {
          final lastY = size.height - (points[pointCount - 1] * size.height);
          path.lineTo(size.width, lastY);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  // Sample data points for demonstration (normalized 0.0 to 1.0)
  List<double> _getSamplePoints(Size size) {
    return [
      0.1, // Start low
      0.6, // First peak
      0.3, // First valley
      0.2, // Deep dip
      0.7, // Second peak
      0.5, // Descent
      0.9, // Final ascent
    ];
  }

  @override
  bool shouldRepaint(DiagonalLinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Vercel Analytics after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VercelAnalytics.init();
      // Track initial page view
      VercelAnalytics.trackPageView(path: '/', title: 'Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Mini App',
      // Use default theme without Material fonts to avoid loading errors
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Aeroport',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          bodyMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          bodySmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displayLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displayMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displaySmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          hintStyle: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  bool _isFocused = false;
  bool _isTappingSuggestion = false;

  // Chart data
  List<double>? _chartDataPoints;
  bool _isLoadingChart = true;
  String _selectedResolution = 'min1'; // Default: min1 (m)
  double? _chartMinPrice;
  double? _chartMaxPrice;
  DateTime? _chartFirstTimestamp;
  DateTime? _chartLastTimestamp;

  // TON address for default pair
  static const String _tonAddress =
      '0:0000000000000000000000000000000000000000000000000000000000000000';
  static const String _chartApiUrl = 'https://api.dyor.io';

  // Resolution mapping: button -> API value
  static const Map<String, String> _resolutionMap = {
    'd': 'day1',
    'h': 'hour1',
    'q': 'min15',
    'm': 'min1',
  };

  // Maximum time ranges for each resolution (in days)
  static const Map<String, int> _maxTimeRanges = {
    'day1': 365, // 365 days
    'hour1': 30, // 30 days
    'min15': 7, // 7 days
    'min1': 1, // 24 hours = 1 day
  };

  /// Calculate the time range for the selected resolution
  /// Returns a map with 'from' and 'to' as ISO 8601 strings
  Map<String, String> _getTimeRange() {
    final now = DateTime.now().toUtc();
    final maxDays = _maxTimeRanges[_selectedResolution] ?? 30;

    // Calculate 'from' date: maxDays ago
    final from = now.subtract(Duration(days: maxDays));

    return {
      'from': from.toIso8601String(),
      'to': now.toIso8601String(),
    };
  }

  /// Format price value for display (up to 5 decimal places, removing trailing zeros)
  String _formatPrice(double price) {
    // Format to 5 decimal places
    final formatted = price.toStringAsFixed(5);
    // Remove trailing zeros
    if (formatted.contains('.')) {
      return formatted
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  /// Format timestamp based on resolution
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final timestampDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    switch (_selectedResolution) {
      case 'day1': // d: DD/MM/YY
        return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year.toString().substring(2)}';

      case 'hour1': // h: DD/MM
        return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';

      case 'min15': // q: MM/YY 22:19
        return '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year.toString().substring(2)} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

      case 'min1': // m: 22:19, yesterday or 22:19, today
        final timeStr =
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
        if (timestampDate == today) {
          return '$timeStr, today';
        } else if (timestampDate == yesterday) {
          return '$timeStr, yesterday';
        } else {
          // Fallback to date if not today or yesterday
          return '$timeStr, ${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';
        }

      default:
        return timestamp.toString();
    }
  }

  /// Build timestamp widget with proper styling for min1 resolution
  Widget _buildTimestampWidget(DateTime? timestamp) {
    if (timestamp == null) {
      return const Text(
        "--/--",
        style: TextStyle(
          fontSize: 10,
          color: Color(0xFF818181),
        ),
      );
    }

    // For min1 resolution, use RichText to style "Today"/"Yesterday" with regular font weight
    if (_selectedResolution == 'min1') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final timestampDate =
          DateTime(timestamp.year, timestamp.month, timestamp.day);
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

      if (timestampDate == today) {
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF818181),
            ),
            children: [
              TextSpan(text: timeStr),
              const TextSpan(
                text: ', today',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        );
      } else if (timestampDate == yesterday) {
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF818181),
            ),
            children: [
              TextSpan(text: timeStr),
              const TextSpan(
                text: ', yesterday',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        );
      }
    }

    // For other resolutions, use regular Text
    return Text(
      _formatTimestamp(timestamp),
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF818181),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      // If we're tapping a suggestion, don't update _isFocused state
      // This prevents the UI from hiding suggestions when focus temporarily changes
      if (_isTappingSuggestion) {
        return;
      }
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _controller.addListener(() {
      // Check if text contains newline (Enter was pressed)
      if (_controller.text.contains('\n')) {
        print('Newline detected in text field'); // Debug
        // Remove the newline
        final textWithoutNewline = _controller.text.replaceAll('\n', '');
        _controller.value = TextEditingValue(
          text: textWithoutNewline,
          selection: TextSelection.collapsed(offset: textWithoutNewline.length),
        );
        // Trigger navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToNewPage();
        });
      }
      setState(() {});
    });

    // Fetch chart data on page load
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    setState(() {
      _isLoadingChart = true;
    });

    try {
      // Get time range for the selected resolution
      final timeRange = _getTimeRange();

      // Build API URL with query parameters
      // Using selected resolution, USD currency, and max time range
      final uri = Uri.parse('$_chartApiUrl/v1/jettons/$_tonAddress/price/chart')
          .replace(queryParameters: {
        'resolution': _selectedResolution,
        'currency': 'usd',
        'from': timeRange['from']!,
        'to': timeRange['to']!,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final points = data['points'] as List<dynamic>?;

        if (points != null && points.isNotEmpty) {
          // Extract timestamp from the first point (oldest after reversal)
          // API returns newest-first, so last point is oldest, first point is newest
          final firstPoint = points[points.length - 1];
          final lastPoint = points[0];

          final firstTimeStr = firstPoint['time'] as String?;
          final lastTimeStr = lastPoint['time'] as String?;

          DateTime? firstTimestamp;
          DateTime? lastTimestamp;

          if (firstTimeStr != null) {
            try {
              firstTimestamp = DateTime.parse(firstTimeStr).toLocal();
            } catch (e) {
              print('Error parsing first timestamp: $e');
            }
          }

          if (lastTimeStr != null) {
            try {
              lastTimestamp = DateTime.parse(lastTimeStr).toLocal();
            } catch (e) {
              print('Error parsing last timestamp: $e');
            }
          }

          // Extract and convert price values
          var prices = points.map((point) {
            final valueObj = point['value'];
            final valueStr = valueObj['value'] as String;
            final decimals = valueObj['decimals'] as int;

            // Convert to real value: value * 10^(-decimals)
            final value = int.parse(valueStr);
            final realValue = value * math.pow(10, -decimals);
            return realValue.toDouble();
          }).toList();

          // Reverse the array - API likely returns newest-first, but we need oldest-first for chart
          prices = prices.reversed.toList();

          // Normalize prices to 0.0-1.0 range for chart display
          if (prices.isNotEmpty) {
            final minPrice = prices.reduce(math.min);
            final maxPrice = prices.reduce(math.max);
            final range = maxPrice - minPrice;

            if (range > 0) {
              // Normalize prices to 0.0-1.0 range for chart display
              // minPrice -> 0.0, maxPrice -> 1.0
              final normalizedPoints = prices.map((price) {
                return (price - minPrice) / range;
              }).toList();

              setState(() {
                _chartDataPoints = normalizedPoints;
                _chartMinPrice = minPrice;
                _chartMaxPrice = maxPrice;
                _chartFirstTimestamp = firstTimestamp;
                _chartLastTimestamp = lastTimestamp;
                _isLoadingChart = false;
              });
            } else {
              // All prices are the same, set to middle
              setState(() {
                _chartDataPoints = List.filled(prices.length, 0.5);
                _chartMinPrice = minPrice;
                _chartMaxPrice = maxPrice;
                _chartFirstTimestamp = firstTimestamp;
                _chartLastTimestamp = lastTimestamp;
                _isLoadingChart = false;
              });
            }
          } else {
            setState(() {
              _chartDataPoints = null;
              _chartMinPrice = null;
              _chartMaxPrice = null;
              _chartFirstTimestamp = null;
              _chartLastTimestamp = null;
              _isLoadingChart = false;
            });
          }
        } else {
          setState(() {
            _chartDataPoints = null;
            _chartMinPrice = null;
            _chartMaxPrice = null;
            _chartFirstTimestamp = null;
            _chartLastTimestamp = null;
            _isLoadingChart = false;
          });
        }
      } else {
        setState(() {
          _chartDataPoints = null;
          _chartMinPrice = null;
          _chartMaxPrice = null;
          _chartFirstTimestamp = null;
          _chartLastTimestamp = null;
          _isLoadingChart = false;
        });
        print('Chart fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _chartDataPoints = null;
        _chartMinPrice = null;
        _chartMaxPrice = null;
        _chartFirstTimestamp = null;
        _chartLastTimestamp = null;
        _isLoadingChart = false;
      });
      print('Chart fetch error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Get top padding for TMA logo alignment using Telegram platform detection
  /// Uses Telegram Web App SDK to detect platform, then calculates appropriate padding
  /// Uses Telegram.WebApp.safeAreaInsets for accurate safe area values
  double _getTmaLogoTopPadding(BuildContext context) {
    // Get safe area from Telegram API (more reliable than MediaQuery in web)
    final telegramSafeArea = TelegramPlatform.getSafeAreaInsets();
    final safeAreaTop = telegramSafeArea['top'] ?? 0.0;

    final isIOS = TelegramPlatform.isIOS();
    final isAndroid = TelegramPlatform.isAndroid();

    if (isIOS) {
      // iOS: TMA elements respect safe area
      // For iPhone SE (no notch): safe area ~20px + 30px = 50px
      // For iPhone X-13 (notch): safe area ~44-47px + 40px = 84-87px
      // For iPhone 14+ (larger notch): safe area ~47-59px + 50px = 97-109px
      double offset;
      if (safeAreaTop < 30.0) {
        // iPhone SE or older (no notch) - use 30px offset
        offset = 30.0;
      } else if (safeAreaTop < 45.0) {
        // iPhone X - 13 (notch) - use 40px offset
        offset = 40.0;
      } else {
        // iPhone 14+ (larger notch/Dynamic Island, safe area >= 45px) - use 50px offset
        offset = 50.0;
      }
      return safeAreaTop + offset;
    } else if (isAndroid) {
      // Android: TMA header positioning can vary
      // On some devices, TMA header is at a fixed position from top
      // On others, it's status bar + header bar height
      // For OnePlus and similar: TMA header is typically around 48-56px from top
      if (safeAreaTop < 20.0) {
        // Very small status bar - TMA likely uses fixed ~48px positioning
        return 48.0;
      } else {
        // Normal status bar - TMA header is status bar + ~24px
        return safeAreaTop + 24.0;
      }
    } else {
      // Not in Telegram or platform unknown - use safe area + 30px as fallback
      return safeAreaTop + 30.0;
    }
  }

  void _navigateToNewPage() {
    final text = _controller.text.trim();
    print('_navigateToNewPage called with text: "$text"'); // Debug
    if (text.isNotEmpty) {
      print('Navigating to NewPage with title: "$text"'); // Debug

      // Track question submission event
      VercelAnalytics.trackEvent('question_submitted', properties: {
        'question_length': text.length.toString(),
      });

      // Track page view for response page
      VercelAnalytics.trackPageView(path: '/response', title: 'Response');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPage(title: text),
        ),
      ).then((_) {
        // Clear the text field after navigation
        _controller.clear();
        // Track return to home page
        VercelAnalytics.trackPageView(path: '/', title: 'Home');
      });
    } else {
      print('Text is empty, not navigating'); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                // padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: _getTmaLogoTopPadding(context),
                        bottom: 15,
                        left: 15,
                        right: 15,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    if (_isFocused)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Listener(
                                onPointerDown: (event) {
                                  print('Suggestion 1 pointer down'); // Debug
                                  // Set flag immediately to prevent unfocus
                                  _isTappingSuggestion = true;
                                  // Request focus immediately
                                  FocusScope.of(context)
                                      .requestFocus(_focusNode);
                                  // Set text and navigate
                                  _controller.text =
                                      'What is my all wallet\'s last month profit';
                                  print(
                                      'Text set to: ${_controller.text}'); // Debug
                                  // Navigate after a short delay
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      _isTappingSuggestion = false;
                                      _navigateToNewPage();
                                    }
                                  });
                                },
                                child: const MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 15.0),
                                    child: Text(
                                      'What is my all wallet\'s last month profit',
                                      style: TextStyle(
                                        fontFamily: 'Aeroport',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Listener(
                                onPointerDown: (event) {
                                  print('Suggestion 2 pointer down'); // Debug
                                  // Set flag immediately to prevent unfocus
                                  _isTappingSuggestion = true;
                                  // Request focus immediately
                                  FocusScope.of(context)
                                      .requestFocus(_focusNode);
                                  // Set text and navigate
                                  _controller.text = 'Advise me a token to buy';
                                  print(
                                      'Text set to: ${_controller.text}'); // Debug
                                  // Navigate after a short delay
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      _isTappingSuggestion = false;
                                      _navigateToNewPage();
                                    }
                                  });
                                },
                                child: const MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 15.0),
                                    child: Text(
                                      'Advise me a token to buy',
                                      style: TextStyle(
                                        fontFamily: 'Aeroport',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!_isFocused)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('ton/usdt',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Color(0xFF818181),
                                                    fontSize: 20,
                                                  )),
                                              SizedBox.shrink(),
                                              Text(
                                                '+300.70%',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedResolution =
                                                        _resolutionMap['m']!;
                                                  });
                                                  _fetchChartData();
                                                },
                                                child: Text(
                                                  "m",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'm']
                                                            ? FontWeight.normal
                                                            : FontWeight.w500,
                                                    color:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'm']
                                                            ? const Color(
                                                                0xFF818181)
                                                            : const Color(
                                                                0xFFE4E4E4),
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedResolution =
                                                        _resolutionMap['q']!;
                                                  });
                                                  _fetchChartData();
                                                },
                                                child: Text(
                                                  "q",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'q']
                                                            ? FontWeight.normal
                                                            : FontWeight.w500,
                                                    color:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'q']
                                                            ? const Color
                                                                .fromARGB(255,
                                                                255, 255, 255)
                                                            : const Color(
                                                                0xFFE4E4E4),
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedResolution =
                                                        _resolutionMap['h']!;
                                                  });
                                                  _fetchChartData();
                                                },
                                                child: Text(
                                                  "h",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'h']
                                                            ? FontWeight.normal
                                                            : FontWeight.w500,
                                                    color:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'h']
                                                            ? const Color(
                                                                0xFF818181)
                                                            : const Color(
                                                                0xFFE4E4E4),
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedResolution =
                                                        _resolutionMap['d']!;
                                                  });
                                                  _fetchChartData();
                                                },
                                                child: Text(
                                                  "d",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'd']
                                                            ? FontWeight.normal
                                                            : FontWeight.w500,
                                                    color:
                                                        _selectedResolution ==
                                                                _resolutionMap[
                                                                    'd']
                                                            ? const Color(
                                                                0xFF818181)
                                                            : const Color(
                                                                0xFFE4E4E4),
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'FDV',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '\$3.1K',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'LIQ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '\$1.1K',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'VOL',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '\$3.1K',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'TXNS',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '\$7K',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '1 H',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '+208.13%',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '6 H',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '+208.13%',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xFF818181),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox.expand(
                                                      child: _isLoadingChart
                                                          ? const Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    Color(
                                                                        0xFF818181),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : CustomPaint(
                                                              painter:
                                                                  DiagonalLinePainter(
                                                                dataPoints:
                                                                    _chartDataPoints,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildTimestampWidget(
                                                          _chartFirstTimestamp),
                                                      _buildTimestampWidget(
                                                          _chartLastTimestamp),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _chartMaxPrice != null
                                                      ? _formatPrice(
                                                          _chartMaxPrice!)
                                                      : "0.00000",
                                                  style: const TextStyle(
                                                      color: Color(0xFF818181),
                                                      fontSize: 10),
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      _chartMinPrice != null
                                                          ? _formatPrice(
                                                              _chartMinPrice!)
                                                          : "0.00000",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF818181),
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                  top: 15, bottom: 0, left: 15, right: 15),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Buy',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF818181),
                                          fontSize: 20,
                                        )),
                                    SizedBox(
                                      height: 20,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Image.asset('assets/sample/1.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/2.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/3.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/4.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/5.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('1',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: Color(0xFFE4E4E4),
                                        )),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/sample/ton.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 8),
                                        const Text('ton',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFFE4E4E4),
                                              fontSize: 20,
                                            )),
                                        const SizedBox(width: 8),
                                        SvgPicture.asset(
                                          'assets/icons/select.svg',
                                          width: 5,
                                          height: 10,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFFE4E4E4),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('now 11 ton on ton',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Color(0xFF818181),
                                          )),
                                      Text(r'$1',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Color(0xFF818181),
                                          )),
                                    ]),
                              ]),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 15),
                              child: SvgPicture.asset(
                                'assets/icons/rotate.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                  top: 15, bottom: 15, left: 15, right: 15),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Sell',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF818181),
                                          fontSize: 20,
                                        )),
                                    SizedBox(
                                      height: 20,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Image.asset('assets/sample/1.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/2.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/3.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/4.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                            const SizedBox(width: 5),
                                            Image.asset('assets/sample/5.png',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.contain),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('1',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: Color(0xFFE4E4E4),
                                        )),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/sample/usdt.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 8),
                                        const Text('usdt',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFFE4E4E4),
                                              fontSize: 20,
                                            )),
                                        const SizedBox(width: 8),
                                        SvgPicture.asset(
                                          'assets/icons/select.svg',
                                          width: 5,
                                          height: 10,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFFE4E4E4),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('of 300.67 usdt on ton',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Color(0xFF818181),
                                          )),
                                      Text(r'$1',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Color(0xFF818181),
                                          )),
                                    ]),
                              ]),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 15, bottom: 0, left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      'wallet',
                                      style: TextStyle(
                                        color: Color(0xFF818181),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 30, left: 15, right: 15),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 30),
                              child: _controller.text.isEmpty
                                  ? SizedBox(
                                      height: 30,
                                      child: TextField(
                                        key: _textFieldKey,
                                        controller: _controller,
                                        focusNode: _focusNode,
                                        enabled: true,
                                        readOnly: false,
                                        cursorColor: const Color(0xFFE4E4E4),
                                        cursorHeight: 15,
                                        maxLines: 11,
                                        minLines: 1,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: const TextStyle(
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            height: 2.0,
                                            color: Color(0xFFE4E4E4)),
                                        onSubmitted: (value) {
                                          print(
                                              'TextField onSubmitted called with: "$value"'); // Debug
                                          _navigateToNewPage();
                                        },
                                        onChanged: (value) {
                                          print(
                                              'TextField onChanged called with: "$value"'); // Debug
                                        },
                                        decoration: InputDecoration(
                                          hintText: (_isFocused ||
                                                  _controller.text.isNotEmpty)
                                              ? null
                                              : 'Ask anything',
                                          hintStyle: const TextStyle(
                                              color: Color(0xFFE4E4E4),
                                              fontFamily: 'Aeroport',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 2.0),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: !_isFocused
                                              ? const EdgeInsets.only(
                                                  left: 0,
                                                  right: 0,
                                                  top: 5,
                                                  bottom: 5)
                                              : const EdgeInsets.only(right: 0),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: TextField(
                                        key: _textFieldKey,
                                        controller: _controller,
                                        focusNode: _focusNode,
                                        enabled: true,
                                        readOnly: false,
                                        cursorColor: const Color(0xFFE4E4E4),
                                        cursorHeight: 15,
                                        maxLines: 11,
                                        minLines: 1,
                                        textAlignVertical: _controller.text
                                                    .split('\n')
                                                    .length ==
                                                1
                                            ? TextAlignVertical.center
                                            : TextAlignVertical.bottom,
                                        style: const TextStyle(
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            height: 2,
                                            color: Color(0xFFE4E4E4)),
                                        onSubmitted: (value) {
                                          print(
                                              'TextField onSubmitted called with: "$value"'); // Debug
                                          _navigateToNewPage();
                                        },
                                        onChanged: (value) {
                                          print(
                                              'TextField onChanged called with: "$value"'); // Debug
                                        },
                                        decoration: InputDecoration(
                                          hintText: (_isFocused ||
                                                  _controller.text.isNotEmpty)
                                              ? null
                                              : 'Ask anything',
                                          hintStyle: const TextStyle(
                                              color: Color(0xFFE4E4E4),
                                              fontFamily: 'Aeroport',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 2),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: _controller.text
                                                      .split('\n')
                                                      .length >
                                                  1
                                              ? const EdgeInsets.only(
                                                  left: 0, right: 0, top: 11)
                                              : const EdgeInsets.only(right: 0),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              print('Apply button tapped'); // Debug
                              _navigateToNewPage();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/apply.svg',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Debug panel overlay - positioned at top left
          Positioned(
            top: 0,
            left: 0,
            child: _buildDebugPanel(context),
          ),
        ],
      ),
    );
  }

  /// Temporary debug panel to display safe area and platform info
  Widget _buildDebugPanel(BuildContext context) {
    // Get safe area from JavaScript (more reliable in web)
    final jsSafeArea = TelegramPlatform.getSafeAreaInsets();
    final safeAreaTop = jsSafeArea['top'] ?? 0.0;
    final safeAreaBottom = jsSafeArea['bottom'] ?? 0.0;
    final safeAreaLeft = jsSafeArea['left'] ?? 0.0;
    final safeAreaRight = jsSafeArea['right'] ?? 0.0;

    // Also get from MediaQuery for comparison
    final mediaQueryTop = MediaQuery.of(context).padding.top;
    final mediaQueryBottom = MediaQuery.of(context).padding.bottom;

    final platform = TelegramPlatform.getPlatform();
    final deviceModel = TelegramPlatform.getDeviceModel();
    final isIOS = TelegramPlatform.isIOS();
    final isAndroid = TelegramPlatform.isAndroid();
    final isInTelegram = TelegramPlatform.isInTelegram();
    final calculatedPadding = _getTmaLogoTopPadding(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.95), // Red background for visibility
        border: Border.all(color: Colors.yellow, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DEBUG PANEL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _buildDebugRow('Platform (TMA):', platform ?? 'null'),
          _buildDebugRow('Device Model:', deviceModel ?? 'unknown'),
          _buildDebugRow('Screen Size:', _getScreenSize()),
          _buildDebugRow('In Telegram:', isInTelegram.toString()),
          _buildDebugRow('Detected iOS:', isIOS.toString()),
          _buildDebugRow('Detected Android:', isAndroid.toString()),
          const Divider(color: Colors.white54, height: 16),
          const Text(
            'Telegram SafeAreaInset:',
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          _buildDebugRow('Top:', '${safeAreaTop.toStringAsFixed(1)}px'),
          _buildDebugRow('Bottom:', '${safeAreaBottom.toStringAsFixed(1)}px'),
          _buildDebugRow('Left:', '${safeAreaLeft.toStringAsFixed(1)}px'),
          _buildDebugRow('Right:', '${safeAreaRight.toStringAsFixed(1)}px'),
          const Divider(color: Colors.white54, height: 16),
          _buildDebugRow(
              'MediaQuery Top:', '${mediaQueryTop.toStringAsFixed(1)}px'),
          _buildDebugRow(
              'MediaQuery Bottom:', '${mediaQueryBottom.toStringAsFixed(1)}px'),
          const Divider(color: Colors.white54, height: 16),
          _buildDebugRow(
              'Logo Padding:', '${calculatedPadding.toStringAsFixed(1)}px'),
        ],
      ),
    );
  }

  String _getScreenSize() {
    try {
      final window = js.context['window'];
      if (window != null) {
        final screen = window['screen'];
        final innerWidth = window['innerWidth'];
        final innerHeight = window['innerHeight'];

        String result = '';
        if (innerWidth != null && innerHeight != null) {
          final w = (innerWidth as num).toDouble();
          final h = (innerHeight as num).toDouble();
          result = '${w.toInt()}×${h.toInt()} (inner)';
        }
        if (screen != null) {
          final width = screen['width'];
          final height = screen['height'];
          if (width != null && height != null) {
            final w = (width as num).toDouble();
            final h = (height as num).toDouble();
            if (result.isNotEmpty) {
              result += ' / ${w.toInt()}×${h.toInt()} (screen)';
            } else {
              result = '${w.toInt()}×${h.toInt()} (screen)';
            }
          }
        }
        return result.isNotEmpty ? result : 'unknown';
      }
    } catch (e) {
      return 'error: $e';
    }
    return 'unknown';
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NewPage extends StatefulWidget {
  final String title;

  const NewPage({super.key, required this.title});

  @override
  State<NewPage> createState() => _NewPageState();
}

class QAPair {
  final String question;
  String? response;
  bool isLoading;
  String? error;
  AnimationController? dotsController;

  QAPair({
    required this.question,
    this.response,
    this.isLoading = true,
    this.error,
    this.dotsController,
  });
}

class _NewPageState extends State<NewPage> with TickerProviderStateMixin {
  // List to store all Q&A pairs
  final List<QAPair> _qaPairs = [];
  final String _apiUrl = 'https://xp7k-production.up.railway.app';
  // API Key - read from window.APP_CONFIG.API_KEY at runtime
  String? _apiKey;
  final bool _isLoadingApiKey = false;
  late AnimationController _dotsController;

  /// Get top padding for TMA logo alignment using Telegram platform detection
  /// Uses Telegram Web App SDK to detect platform, then calculates appropriate padding
  /// Uses Telegram.WebApp.safeAreaInsets for accurate safe area values
  double _getTmaLogoTopPadding(BuildContext context) {
    // Get safe area from Telegram API (more reliable than MediaQuery in web)
    final telegramSafeArea = TelegramPlatform.getSafeAreaInsets();
    final safeAreaTop = telegramSafeArea['top'] ?? 0.0;

    final isIOS = TelegramPlatform.isIOS();
    final isAndroid = TelegramPlatform.isAndroid();

    if (isIOS) {
      // iOS: TMA elements respect safe area
      // For iPhone SE (no notch): safe area ~20px + 30px = 50px
      // For iPhone X-13 (notch): safe area ~44-47px + 40px = 84-87px
      // For iPhone 14+ (larger notch): safe area ~47-59px + 50px = 97-109px
      double offset;
      if (safeAreaTop < 30.0) {
        // iPhone SE or older (no notch) - use 30px offset
        offset = 30.0;
      } else if (safeAreaTop < 45.0) {
        // iPhone X - 13 (notch) - use 40px offset
        offset = 40.0;
      } else {
        // iPhone 14+ (larger notch/Dynamic Island, safe area >= 45px) - use 50px offset
        offset = 50.0;
      }
      return safeAreaTop + offset;
    } else if (isAndroid) {
      // Android: TMA header positioning can vary
      // On some devices, TMA header is at a fixed position from top
      // On others, it's status bar + header bar height
      // For OnePlus and similar: TMA header is typically around 48-56px from top
      if (safeAreaTop < 20.0) {
        // Very small status bar - TMA likely uses fixed ~48px positioning
        return 48.0;
      } else {
        // Normal status bar - TMA header is status bar + ~24px
        return safeAreaTop + 24.0;
      }
    } else {
      // Not in Telegram or platform unknown - use safe area + 30px as fallback
      return safeAreaTop + 30.0;
    }
  }

  // Input field controllers
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final GlobalKey _inputTextFieldKey = GlobalKey();
  bool _isInputFocused = false;

  // Scroll controller for auto-scrolling to new responses
  final ScrollController _scrollController = ScrollController();

  // Track if auto-scrolling is enabled (disabled when user manually scrolls)
  bool _autoScrollEnabled = true;

  // Scroll progress for custom scrollbar
  double _scrollProgress = 0.0;
  double _scrollIndicatorHeight = 1.0;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    // Listen to scroll changes to detect manual scrolling and update scrollbar
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        final maxScroll = position.maxScrollExtent;
        final currentScroll = position.pixels;
        final viewportHeight = position.viewportDimension;
        final totalHeight = viewportHeight + maxScroll;

        // Update scrollbar
        if (maxScroll > 0 && totalHeight > 0) {
          final indicatorHeight =
              (viewportHeight / totalHeight).clamp(0.0, 1.0);
          final scrollPosition = (currentScroll / maxScroll).clamp(0.0, 1.0);
          setState(() {
            _scrollIndicatorHeight = indicatorHeight;
            _scrollProgress = scrollPosition;
          });
        } else {
          setState(() {
            _scrollProgress = 0.0;
            _scrollIndicatorHeight = 1.0;
          });
        }

        // If user is near the bottom (within 50px), re-enable auto-scroll
        // Otherwise, disable auto-scroll if user scrolled up
        if (maxScroll > 0) {
          final distanceFromBottom = maxScroll - currentScroll;
          if (distanceFromBottom < 50) {
            // User is near bottom, enable auto-scroll
            // Also check if any response is still loading/streaming
            final hasLoadingContent = _qaPairs.any((pair) => pair.isLoading);
            if (!_autoScrollEnabled || hasLoadingContent) {
              setState(() {
                _autoScrollEnabled = true;
              });
              // If content is still streaming and user is at bottom, scroll immediately
              if (hasLoadingContent) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    final currentMaxScroll =
                        _scrollController.position.maxScrollExtent;
                    if (currentMaxScroll > 0) {
                      _scrollController.animateTo(
                        currentMaxScroll,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                });
              }
            }
          } else if (distanceFromBottom > 100) {
            // User scrolled up significantly, disable auto-scroll
            if (_autoScrollEnabled) {
              setState(() {
                _autoScrollEnabled = false;
              });
            }
          }
        }
      }
    });

    _inputController.addListener(() {
      // Check if text contains newline (Enter was pressed)
      if (_inputController.text.contains('\n')) {
        final textWithoutNewline = _inputController.text.replaceAll('\n', '');
        _inputController.value = TextEditingValue(
          text: textWithoutNewline,
          selection: TextSelection.collapsed(offset: textWithoutNewline.length),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _askNewQuestion();
        });
      }
      setState(() {});
    });
    // Add initial Q&A pair with the title
    setState(() {
      _qaPairs.add(QAPair(
        question: widget.title,
        isLoading: true,
        dotsController: _dotsController,
      ));
    });
    // Fetch response after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _qaPairs.isNotEmpty) {
        _fetchAIResponse(_qaPairs.last);
      }
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    // Dispose all animation controllers
    for (var pair in _qaPairs) {
      pair.dotsController?.dispose();
    }
    super.dispose();
  }

  void _askNewQuestion() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      // Clear input
      _inputController.clear();

      // Create new animation controller for this Q&A pair
      final newDotsController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat();

      // Add new Q&A pair at the end (bottom of the list)
      final newPair = QAPair(
        question: text,
        isLoading: true,
        dotsController: newDotsController,
      );
      setState(() {
        _qaPairs.add(newPair);
      });

      // Fetch AI response for the new question
      _fetchAIResponse(newPair);

      // Scroll to bottom after a short delay, only if auto-scroll is enabled
      if (_autoScrollEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            if (maxScroll > 0) {
              _scrollController.animateTo(
                maxScroll,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        });
      }
    }
  }

  Future<void> _fetchAIResponse(QAPair pair) async {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_apiUrl/api/chat'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'message': pair.question});

      final client = http.Client();
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        String accumulatedResponse = '';
        String? finalResponse;
        String buffer = ''; // Buffer for incomplete lines

        // Process the stream line by line as it arrives
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;
          final lines = buffer.split('\n');

          // Keep the last incomplete line in buffer
          if (lines.isNotEmpty) {
            buffer = lines.removeLast();
          } else {
            buffer = '';
          }

          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            try {
              final data = jsonDecode(line);

              // Check for final complete response
              if (data['response'] != null && data['done'] == true) {
                finalResponse = data['response'] as String;
                // Update with final complete response
                if (mounted) {
                  setState(() {
                    pair.response = finalResponse;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                }
              }
              // Process tokens as they arrive (for streaming effect)
              else if (data['token'] != null) {
                accumulatedResponse += data['token'] as String;
                // Update UI immediately with each token (streaming effect)
                if (mounted && finalResponse == null) {
                  setState(() {
                    pair.response = accumulatedResponse;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                  // Auto-scroll to bottom as response streams in, only if auto-scroll is enabled
                  if (_autoScrollEnabled) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        final maxScroll =
                            _scrollController.position.maxScrollExtent;
                        if (maxScroll > 0) {
                          _scrollController.animateTo(
                            maxScroll,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                    });
                  }
                }
              }
              // Check for errors
              else if (data['error'] != null) {
                if (mounted) {
                  setState(() {
                    pair.error = data['error'] as String;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                }
                client.close();
                return;
              }
            } catch (e) {
              // Skip invalid JSON lines (might be partial chunks)
              continue;
            }
          }
        }

        // Process any remaining buffer content
        if (buffer.trim().isNotEmpty) {
          try {
            final data = jsonDecode(buffer);
            if (data['response'] != null && data['done'] == true) {
              finalResponse = data['response'] as String;
            } else if (data['token'] != null) {
              accumulatedResponse += data['token'] as String;
            }
          } catch (e) {
            // Ignore parse errors for buffer
          }
        }

        // Use final response if available, otherwise use accumulated
        if (mounted && finalResponse != null) {
          setState(() {
            pair.response = finalResponse;
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
          // Scroll to bottom when response is complete, only if auto-scroll is enabled
          if (_autoScrollEnabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                if (maxScroll > 0) {
                  _scrollController.animateTo(
                    maxScroll,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          }
        } else if (mounted &&
            accumulatedResponse.isNotEmpty &&
            pair.response == null) {
          setState(() {
            pair.response = accumulatedResponse;
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
          // Scroll to bottom when response is complete, only if auto-scroll is enabled
          if (_autoScrollEnabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                if (maxScroll > 0) {
                  _scrollController.animateTo(
                    maxScroll,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          }
        }

        client.close();
      } else {
        if (mounted) {
          setState(() {
            pair.error = 'Error: ${streamedResponse.statusCode}';
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
        }
        client.close();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          pair.error = 'Failed to connect: $e';
          pair.isLoading = false;
          pair.dotsController?.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(0.0),
          thumbVisibility: WidgetStateProperty.all(false),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  //padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: _getTmaLogoTopPadding(context),
                            bottom: 30,
                            left: 30,
                            right: 30,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: SvgPicture.asset(
                            'assets/images/logo.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                reverse: false,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children:
                                        _qaPairs.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final pair = entry.value;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Question
                                          Text(
                                            pair.question,
                                            style: const TextStyle(
                                              fontFamily: 'Aeroport',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFFE4E4E4),
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          const SizedBox(height: 16),
                                          // Response (loading, error, or content)
                                          if (pair.isLoading &&
                                              pair.dotsController != null)
                                            AnimatedBuilder(
                                              animation: pair.dotsController!,
                                              builder: (context, child) {
                                                final progress =
                                                    pair.dotsController!.value;
                                                int dotCount = 1;
                                                if (progress < 0.33) {
                                                  dotCount = 1;
                                                } else if (progress < 0.66) {
                                                  dotCount = 2;
                                                } else {
                                                  dotCount = 3;
                                                }
                                                return Text(
                                                  '·' * dotCount,
                                                  style: const TextStyle(
                                                    fontFamily: 'Aeroport',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFE4E4E4),
                                                  ),
                                                  textAlign: TextAlign.left,
                                                );
                                              },
                                            )
                                          else if (pair.error != null)
                                            Text(
                                              pair.error!,
                                              style: const TextStyle(
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red,
                                              ),
                                              textAlign: TextAlign.left,
                                            )
                                          else if (pair.response != null)
                                            Text(
                                              pair.response!,
                                              style: const TextStyle(
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFE4E4E4),
                                              ),
                                              textAlign: TextAlign.left,
                                            )
                                          else
                                            const Text(
                                              'No response received',
                                              style: TextStyle(
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFE4E4E4),
                                              ),
                                            ),
                                          // Add spacing between Q&A pairs (except for the last one in reversed list)
                                          if (index < _qaPairs.length - 1)
                                            const SizedBox(height: 32),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            // Custom scrollbar - always visible on mobile
                            // Position it as a separate row item to ensure it's always in viewport
                            SizedBox(
                              width: 1.0,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Check for valid constraints and scroll controller
                                  if (!_scrollController.hasClients ||
                                      constraints.maxHeight ==
                                          double.infinity ||
                                      constraints.maxHeight <= 0) {
                                    return const SizedBox.shrink();
                                  }

                                  try {
                                    final maxScroll = _scrollController
                                        .position.maxScrollExtent;
                                    if (maxScroll <= 0) {
                                      return const SizedBox.shrink();
                                    }

                                    final containerHeight =
                                        constraints.maxHeight;
                                    final indicatorHeight = (containerHeight *
                                            _scrollIndicatorHeight)
                                        .clamp(0.0, containerHeight);
                                    final availableSpace =
                                        (containerHeight - indicatorHeight)
                                            .clamp(0.0, containerHeight);
                                    final topPosition =
                                        (_scrollProgress * availableSpace)
                                            .clamp(0.0, containerHeight);

                                    // Only show white thumb, no grey track background
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(top: topPosition),
                                        child: Container(
                                          width: 1.0,
                                          height: indicatorHeight.clamp(
                                              0.0, containerHeight),
                                          color: const Color(0xFFE4E4E4),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Return empty widget if any error occurs
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 30),
                                child: _inputController.text.isEmpty
                                    ? SizedBox(
                                        height: 30,
                                        child: TextField(
                                          key: _inputTextFieldKey,
                                          controller: _inputController,
                                          focusNode: _inputFocusNode,
                                          cursorColor: const Color(0xFFE4E4E4),
                                          cursorHeight: 15,
                                          maxLines: 11,
                                          minLines: 1,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          style: const TextStyle(
                                              fontFamily: 'Aeroport',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 2.0,
                                              color: Color(0xFFE4E4E4)),
                                          onSubmitted: (value) {
                                            _askNewQuestion();
                                          },
                                          decoration: InputDecoration(
                                            hintText: (_isInputFocused ||
                                                    _inputController
                                                        .text.isNotEmpty)
                                                ? null
                                                : 'Ask anything',
                                            hintStyle: const TextStyle(
                                                color: Color(0xFFE4E4E4),
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                height: 2.0),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            isDense: true,
                                            contentPadding: !_isInputFocused
                                                ? const EdgeInsets.only(
                                                    left: 0,
                                                    right: 0,
                                                    top: 5,
                                                    bottom: 5)
                                                : const EdgeInsets.only(
                                                    right: 0),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: TextField(
                                          key: _inputTextFieldKey,
                                          controller: _inputController,
                                          focusNode: _inputFocusNode,
                                          cursorColor: const Color(0xFFE4E4E4),
                                          cursorHeight: 15,
                                          maxLines: 11,
                                          minLines: 1,
                                          textAlignVertical: _inputController
                                                      .text
                                                      .split('\n')
                                                      .length ==
                                                  1
                                              ? TextAlignVertical.center
                                              : TextAlignVertical.bottom,
                                          style: const TextStyle(
                                              fontFamily: 'Aeroport',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 2,
                                              color: Color(0xFFE4E4E4)),
                                          onSubmitted: (value) {
                                            _askNewQuestion();
                                          },
                                          decoration: InputDecoration(
                                            hintText: (_isInputFocused ||
                                                    _inputController
                                                        .text.isNotEmpty)
                                                ? null
                                                : 'Ask anything',
                                            hintStyle: const TextStyle(
                                                color: Color(0xFFE4E4E4),
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                height: 2),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            isDense: true,
                                            contentPadding: _inputController
                                                        .text
                                                        .split('\n')
                                                        .length >
                                                    1
                                                ? const EdgeInsets.only(
                                                    left: 0, right: 0, top: 11)
                                                : const EdgeInsets.only(
                                                    right: 0),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                _askNewQuestion();
                              },
                              child: SvgPicture.asset(
                                'assets/icons/apply.svg',
                                width: 30,
                                height: 30,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFE4E4E4),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Debug panel overlay
            Positioned(
              top: 0,
              left: 0,
              child: _buildDebugPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Temporary debug panel to display safe area and platform info
  Widget _buildDebugPanel(BuildContext context) {
    // Get safe area from JavaScript (more reliable in web)
    final jsSafeArea = TelegramPlatform.getSafeAreaInsets();
    final safeAreaTop = jsSafeArea['top'] ?? 0.0;
    final safeAreaBottom = jsSafeArea['bottom'] ?? 0.0;
    final safeAreaLeft = jsSafeArea['left'] ?? 0.0;
    final safeAreaRight = jsSafeArea['right'] ?? 0.0;

    // Also get from MediaQuery for comparison
    final mediaQueryTop = MediaQuery.of(context).padding.top;
    final mediaQueryBottom = MediaQuery.of(context).padding.bottom;

    final platform = TelegramPlatform.getPlatform();
    final deviceModel = TelegramPlatform.getDeviceModel();
    final isIOS = TelegramPlatform.isIOS();
    final isAndroid = TelegramPlatform.isAndroid();
    final isInTelegram = TelegramPlatform.isInTelegram();
    final calculatedPadding = _getTmaLogoTopPadding(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.95), // Red background for visibility
        border: Border.all(color: Colors.yellow, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DEBUG PANEL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _buildDebugRow('Platform (TMA):', platform ?? 'null'),
          _buildDebugRow('Device Model:', deviceModel ?? 'unknown'),
          _buildDebugRow('Screen Size:', _getScreenSize()),
          _buildDebugRow('In Telegram:', isInTelegram.toString()),
          _buildDebugRow('Detected iOS:', isIOS.toString()),
          _buildDebugRow('Detected Android:', isAndroid.toString()),
          const Divider(color: Colors.white54, height: 16),
          const Text(
            'Telegram SafeAreaInset:',
            style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          _buildDebugRow('Top:', '${safeAreaTop.toStringAsFixed(1)}px'),
          _buildDebugRow('Bottom:', '${safeAreaBottom.toStringAsFixed(1)}px'),
          _buildDebugRow('Left:', '${safeAreaLeft.toStringAsFixed(1)}px'),
          _buildDebugRow('Right:', '${safeAreaRight.toStringAsFixed(1)}px'),
          const Divider(color: Colors.white54, height: 16),
          _buildDebugRow(
              'MediaQuery Top:', '${mediaQueryTop.toStringAsFixed(1)}px'),
          _buildDebugRow(
              'MediaQuery Bottom:', '${mediaQueryBottom.toStringAsFixed(1)}px'),
          const Divider(color: Colors.white54, height: 16),
          _buildDebugRow(
              'Logo Padding:', '${calculatedPadding.toStringAsFixed(1)}px'),
        ],
      ),
    );
  }

  String _getScreenSize() {
    try {
      final window = js.context['window'];
      if (window != null) {
        final screen = window['screen'];
        final innerWidth = window['innerWidth'];
        final innerHeight = window['innerHeight'];

        String result = '';
        if (innerWidth != null && innerHeight != null) {
          final w = (innerWidth as num).toDouble();
          final h = (innerHeight as num).toDouble();
          result = '${w.toInt()}×${h.toInt()} (inner)';
        }
        if (screen != null) {
          final width = screen['width'];
          final height = screen['height'];
          if (width != null && height != null) {
            final w = (width as num).toDouble();
            final h = (height as num).toDouble();
            if (result.isNotEmpty) {
              result += ' / ${w.toInt()}×${h.toInt()} (screen)';
            } else {
              result = '${w.toInt()}×${h.toInt()} (screen)';
            }
          }
        }
        return result.isNotEmpty ? result : 'unknown';
      }
    } catch (e) {
      return 'error: $e';
    }
    return 'unknown';
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
