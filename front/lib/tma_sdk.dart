import 'dart:js' as js;

/// Wrapper for @tma.js/sdk
/// Provides access to the initialized TMA SDK instance
class TmaSdk {
  static js.JsObject? _sdk;

  /// Get the initialized SDK instance
  /// Returns null if SDK is not available
  static js.JsObject? get instance {
    if (_sdk != null) return _sdk;

    try {
      final tmaSdk = js.context['tmaSdk'];
      if (tmaSdk != null) {
        _sdk = tmaSdk as js.JsObject;
        return _sdk;
      }

      // Fallback: try old tmajs.sdk
      final tmajs = js.context['tmajs'];
      if (tmajs != null) {
        final tmajsObj = tmajs as js.JsObject;
        final sdk = tmajsObj['sdk'];
        if (sdk != null) {
          _sdk = sdk as js.JsObject;
          return _sdk;
        }
      }
    } catch (e) {
      print('Error getting TMA SDK instance: $e');
    }

    return null;
  }

  /// Check if SDK is available
  static bool get isAvailable => instance != null;

  /// Get the init function from @tma.js/sdk
  /// This is equivalent to: import { init } from '@tma.js/sdk'
  static js.JsFunction? get initFunction {
    try {
      final tmajs = js.context['tmajs'];
      if (tmajs != null) {
        final tmajsObj = tmajs as js.JsObject;
        final init = tmajsObj['init'];
        if (init != null && init is js.JsFunction) {
          return init;
        }
      }
    } catch (e) {
      print('Error getting init function: $e');
    }
    return null;
  }

  /// Initialize the SDK (if not already initialized)
  /// This is equivalent to: const sdk = init();
  static js.JsObject? initialize() {
    try {
      final initFn = initFunction;
      if (initFn != null) {
        final sdk = initFn.apply([]);
        if (sdk != null) {
          _sdk = sdk as js.JsObject;
          // Also expose globally
          js.context['tmaSdk'] = _sdk;
          return _sdk;
        }
      }
    } catch (e) {
      print('Error initializing TMA SDK: $e');
    }
    return null;
  }

  /// Get launch parameters
  /// Equivalent to: sdk.retrieveLaunchParams()
  static Map<String, dynamic>? getLaunchParams() {
    try {
      final sdk = instance;
      if (sdk != null) {
        final retrieveLaunchParams = sdk['retrieveLaunchParams'];
        if (retrieveLaunchParams != null) {
          final params = (retrieveLaunchParams as js.JsFunction).apply([]);
          if (params != null) {
            return _jsObjectToMap(params as js.JsObject);
          }
        }
      }
    } catch (e) {
      print('Error getting launch params: $e');
    }
    return null;
  }

  /// Get the viewport component from @tma.js/sdk
  /// Equivalent to: import { viewport } from '@tma.js/sdk'
  static js.JsObject? get viewport {
    try {
      final sdk = instance;
      if (sdk != null) {
        final viewportObj = sdk['viewport'];
        if (viewportObj != null) {
          return viewportObj as js.JsObject;
        }
      }
    } catch (e) {
      print('Error getting viewport: $e');
    }
    return null;
  }

  /// Get safe area insets from viewport component
  /// Equivalent to: viewport.safeAreaInsets()
  /// Returns a map with top, bottom, left, right safe area values in pixels
  static Map<String, double>? getSafeAreaInsets() {
    try {
      final vp = viewport;
      if (vp != null) {
        // Check if viewport is mounted
        final isMounted = vp['isMounted'];
        bool mounted = false;
        if (isMounted != null) {
          if (isMounted is js.JsFunction) {
            mounted = (isMounted as js.JsFunction).apply([]) as bool? ?? false;
          } else {
            mounted = isMounted as bool? ?? false;
          }
        }

        // If not mounted, try to mount it
        if (!mounted) {
          final mountFn = vp['mount'];
          if (mountFn != null && mountFn is js.JsFunction) {
            try {
              (mountFn as js.JsFunction).apply([]);
              // Wait a bit for mounting (it's async, but we'll try to get the value anyway)
            } catch (e) {
              print('Error mounting viewport: $e');
            }
          }
        }

        // Get safe area insets
        final safeAreaInsetsFn = vp['safeAreaInsets'];
        if (safeAreaInsetsFn != null) {
          if (safeAreaInsetsFn is js.JsFunction) {
            final insets = (safeAreaInsetsFn as js.JsFunction).apply([]);
            if (insets != null && insets is js.JsObject) {
              final insetsObj = insets as js.JsObject;
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
          } else if (safeAreaInsetsFn is js.JsObject) {
            // If it's already an object (signal value)
            final insetsObj = safeAreaInsetsFn as js.JsObject;
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

        // Fallback: try individual getters
        final topFn = vp['safeAreaInsetTop'];
        final bottomFn = vp['safeAreaInsetBottom'];
        final leftFn = vp['safeAreaInsetLeft'];
        final rightFn = vp['safeAreaInsetRight'];

        if (topFn != null || bottomFn != null || leftFn != null || rightFn != null) {
          double top = 0.0;
          double bottom = 0.0;
          double left = 0.0;
          double right = 0.0;

          if (topFn != null && topFn is js.JsFunction) {
            top = ((topFn as js.JsFunction).apply([]) as num?)?.toDouble() ?? 0.0;
          }
          if (bottomFn != null && bottomFn is js.JsFunction) {
            bottom = ((bottomFn as js.JsFunction).apply([]) as num?)?.toDouble() ?? 0.0;
          }
          if (leftFn != null && leftFn is js.JsFunction) {
            left = ((leftFn as js.JsFunction).apply([]) as num?)?.toDouble() ?? 0.0;
          }
          if (rightFn != null && rightFn is js.JsFunction) {
            right = ((rightFn as js.JsFunction).apply([]) as num?)?.toDouble() ?? 0.0;
          }

          return {'top': top, 'bottom': bottom, 'left': left, 'right': right};
        }
      }
    } catch (e) {
      print('Error getting safe area insets from viewport: $e');
    }
    return null;
  }

  /// Post an event to Telegram
  /// Equivalent to: sdk.postEvent(event, data)
  static void postEvent(String event, [Map<String, dynamic>? data]) {
    try {
      final sdk = instance;
      if (sdk != null) {
        final postEventFn = sdk['postEvent'];
        if (postEventFn != null) {
          if (data != null) {
            (postEventFn as js.JsFunction).apply([event, _mapToJsObject(data)]);
          } else {
            (postEventFn as js.JsFunction).apply([event]);
          }
        }
      }
    } catch (e) {
      print('Error posting event: $e');
    }
  }

  /// Get the init function reference
  /// This allows you to call init() directly if needed
  static js.JsFunction? get init {
    return initFunction;
  }

  /// Helper to convert JS object to Dart Map
  static Map<String, dynamic> _jsObjectToMap(js.JsObject obj) {
    final map = <String, dynamic>{};
    try {
      final keys = js.context['Object'].callMethod('keys', [obj]);
      if (keys != null) {
        final keysList = keys as js.JsArray;
        for (var i = 0; i < keysList.length; i++) {
          final key = keysList[i].toString();
          final value = obj[key];
          if (value is js.JsObject) {
            map[key] = _jsObjectToMap(value);
          } else if (value is js.JsArray) {
            map[key] = _jsArrayToList(value);
          } else {
            map[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error converting JS object to map: $e');
    }
    return map;
  }

  /// Helper to convert JS array to Dart List
  static List<dynamic> _jsArrayToList(js.JsArray arr) {
    final list = <dynamic>[];
    try {
      for (var i = 0; i < arr.length; i++) {
        final value = arr[i];
        if (value is js.JsObject) {
          list.add(_jsObjectToMap(value));
        } else if (value is js.JsArray) {
          list.add(_jsArrayToList(value));
        } else {
          list.add(value);
        }
      }
    } catch (e) {
      print('Error converting JS array to list: $e');
    }
    return list;
  }

  /// Helper to convert Dart Map to JS object
  static js.JsObject _mapToJsObject(Map<String, dynamic> map) {
    final obj = js.JsObject.jsify(map);
    return obj;
  }
}

