import 'dart:async';

/// SECURITY / HYGIENE FIX (audit finding #8):
///
/// Several controllers (`PosController.onSearchChanged`,
/// `CategoryController.onSearchChanged`, `ProductController
/// .onSearchChanged`, `IngredientController.setSearch`,
/// `StockController.setSearch`) previously fired a network request on
/// EVERY keystroke, with only a "staleness token" guard to discard
/// out-of-order responses — no throttling of the requests themselves.
/// This is an easy unintentional self-DoS vector: several POS terminals
/// typing search queries concurrently can multiply request volume
/// against the backend with no client-side backpressure, and there's no
/// evidence of server-side rate limiting to fall back on.
///
/// `Debouncer` delays invoking `action` until `delay` has passed without
/// a new call to `run()`, cancelling any pending invocation each time a
/// new one comes in. Callers should still keep their existing
/// "staleness token" pattern for out-of-order response safety — this
/// only reduces how many requests are fired in the first place.
///
/// Usage:
/// ```dart
/// final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
///
/// void onSearchChanged(String value) {
///   search.value = value;
///   _searchDebouncer.run(() => load());
/// }
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
