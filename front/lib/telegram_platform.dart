import 'dart:js' as js;
import 'tma_sdk.dart';

/// Helper class to get platform information from Telegram Mini App SDK
/// Uses Telegram Web App API directly since there's no Flutter SDK yet
class TelegramPlatform {
  /// Get the platform from Telegram Web App SDK
  /// Returns: 'ios', 'android', 'macos', 'tdesktop', 'weba', 'web', 'webk', or null if not available
  static String? getPlatform() {
    try {
      final telegram = js.context['Telegram'];
      if (telegram != null) {
        final webApp = telegram['WebApp'];
        if (webApp != null) {
          final platform = webApp['platform'];
          if (platform != null) {
            return platform.toString();
          }
        }
      }

      // Also try TMA.js SDK as fallback
      final tmajs = js.context['tmajs'];
      if (tmajs != null) {
        final sdk = tmajs['sdk'];
        if (sdk != null) {
          final retrieveLaunchParams = sdk['retrieveLaunchParams'];
          if (retrieveLaunchParams != null) {
            final params = retrieveLaunchParams.apply([]);
            if (params != null) {
              final platform = params['platform'];
              if (platform != null) {
                return platform.toString();
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error getting Telegram platform: $e');
    }
    return null;
  }

  /// Check if running on iOS (via Telegram platform)
  static bool isIOS() {
    final platform = getPlatform();
    return platform == 'ios';
  }

  /// Check if running on Android (via Telegram platform)
  static bool isAndroid() {
    final platform = getPlatform();
    return platform == 'android';
  }

  /// Check if running in Telegram Mini App environment
  static bool isInTelegram() {
    final platform = getPlatform();
    return platform != null;
  }

  /// Get device model from screen dimensions and user agent
  /// Returns device model like "iPhone SE", "iPhone 14", etc.
  static String? getDeviceModel() {
    try {
      final window = js.context['window'];
      if (window == null) return null;

      double? w, h;

      // Try to get inner dimensions first (viewport - more accurate for web)
      try {
        final windowObj = window as js.JsObject;
        final innerWidth = windowObj['innerWidth'];
        final innerHeight = windowObj['innerHeight'];
        if (innerWidth != null && innerHeight != null) {
          w = (innerWidth as num).toDouble();
          h = (innerHeight as num).toDouble();
        }
      } catch (e) {
        // Fall through to try screen dimensions
      }

      // If inner dimensions failed, try screen dimensions
      if (w == null || h == null) {
        try {
          final screen = (window as js.JsObject)['screen'];
          if (screen != null) {
            final screenObj = screen as js.JsObject;
            final width = screenObj['width'];
            final height = screenObj['height'];
            if (width != null && height != null) {
              w = (width as num).toDouble();
              h = (height as num).toDouble();
            }
          }
        } catch (e) {
          // Screen access failed, continue with what we have
        }
      }

      if (w != null && h != null) {
        // Also get user agent for additional info
        String? userAgent;
        try {
          final navigator = js.context['navigator'];
          if (navigator != null) {
            userAgent = (navigator as js.JsObject)['userAgent'] as String?;
          }
        } catch (e) {
          // User agent access failed, continue without it
        }

        // Detect iPhone models based on screen dimensions
        // Use tolerance for dimension matching (in case of scaling)
        const tolerance = 5.0;

        if ((w - 375).abs() <= tolerance && (h - 667).abs() <= tolerance) {
          // iPhone SE (1st/2nd gen) or iPhone 8/7/6s
          return 'iPhone SE / 8';
        } else if ((w - 375).abs() <= tolerance &&
            (h - 812).abs() <= tolerance) {
          return 'iPhone X / 11 Pro / 12 mini / 13 mini';
        } else if ((w - 414).abs() <= tolerance &&
            (h - 896).abs() <= tolerance) {
          return 'iPhone 11 / XR';
        } else if ((w - 390).abs() <= tolerance &&
            (h - 844).abs() <= tolerance) {
          return 'iPhone 12 / 13 / 14';
        } else if ((w - 428).abs() <= tolerance &&
            (h - 926).abs() <= tolerance) {
          return 'iPhone 12/13/14 Pro Max';
        } else if ((w - 393).abs() <= tolerance &&
            (h - 852).abs() <= tolerance) {
          return 'iPhone 14 Pro / 15 Pro';
        } else if ((w - 430).abs() <= tolerance &&
            (h - 932).abs() <= tolerance) {
          return 'iPhone 15 Plus';
        }

        // For other sizes, return generic with dimensions
        if (userAgent != null) {
          final ua = userAgent.toLowerCase();
          if (ua.contains('iphone')) {
            return 'iPhone (${w.toInt()}×${h.toInt()})';
          } else if (ua.contains('ipad')) {
            return 'iPad (${w.toInt()}×${h.toInt()})';
          } else if (ua.contains('android')) {
            // Try to extract Android device model
            final match = RegExp(r'android.*?;\s*([^)]+)').firstMatch(ua);
            if (match != null) {
              return '${match.group(1)?.trim() ?? 'Android'} (${w.toInt()}×${h.toInt()})';
            }
            return 'Android (${w.toInt()}×${h.toInt()})';
          }
        }

        return 'Unknown (${w.toInt()}×${h.toInt()})';
      }

      // Fallback: try user agent only
      try {
        final navigator = js.context['navigator'];
        if (navigator != null) {
          final userAgent = (navigator as js.JsObject)['userAgent'] as String?;
          if (userAgent != null) {
            final ua = userAgent.toLowerCase();
            if (ua.contains('iphone')) {
              return 'iPhone';
            } else if (ua.contains('ipad')) {
              return 'iPad';
            } else if (ua.contains('android')) {
              return 'Android';
            }
          }
        }
      } catch (e) {
        // User agent fallback failed
      }
    } catch (e) {
      print('Error getting device model: $e');
    }
    return null;
  }

  /// Get safe area insets from Telegram Web App SDK
  /// Uses @tma.js/sdk viewport component first, then falls back to Telegram.WebApp.safeAreaInsets
  /// Returns a map with top, bottom, left, right safe area values in pixels
  static Map<String, double> getSafeAreaInsets() {
    try {
      // First try: Use @tma.js/sdk viewport component
      try {
        final insets = TmaSdk.getSafeAreaInsets();
        if (insets != null) {
          return insets;
        }
      } catch (e) {
        print('Error getting safe area from @tma.js/sdk viewport: $e');
        // Fall through to Telegram.WebApp
      }

      // Second try: Access Telegram.WebApp.safeAreaInsets
      final telegram = js.context['Telegram'];
      if (telegram != null) {
        final telegramObj = telegram as js.JsObject;
        final webApp = telegramObj['WebApp'];
        if (webApp != null) {
          final webAppObj = webApp as js.JsObject;
          final safeAreaInsets = webAppObj['safeAreaInsets'];
          if (safeAreaInsets != null) {
            final insetsObj = safeAreaInsets as js.JsObject;

            // Get top, bottom, left, right values
            final top = insetsObj['top'];
            final bottom = insetsObj['bottom'];
            final left = insetsObj['left'];
            final right = insetsObj['right'];

            return {
              'top': top != null ? (top as num).toDouble() : 0.0,
              'bottom': bottom != null ? (bottom as num).toDouble() : 0.0,
              'left': left != null ? (left as num).toDouble() : 0.0,
              'right': right != null ? (right as num).toDouble() : 0.0,
            };
          }
        }
      }
    } catch (e) {
      print('Error getting Telegram safe area insets: $e');
    }
    // Fallback to zero if Telegram API is not available
    return {'top': 0.0, 'bottom': 0.0, 'left': 0.0, 'right': 0.0};
  }
}
