@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

/// Cache version - increment this to invalidate old caches
const String cacheVersion = 'v1';

/// Cache names
const String staticCacheName = 'tic-tac-toe-static-$cacheVersion';
const String dynamicCacheName = 'tic-tac-toe-dynamic-$cacheVersion';
const String syncQueueName = 'tic-tac-toe-sync-queue';

/// Base path for GitHub Pages deployment
const String basePath = '/tic_tac_toe';

/// Assets to precache during installation
const List<String> precacheAssets = [
  '$basePath/',
  '$basePath/index.html',
  '$basePath/offline.html',
  '$basePath/manifest.json',
  '$basePath/favicon.png',
  '$basePath/icons/Icon-192.png',
  '$basePath/icons/Icon-512.png',
  '$basePath/icons/Icon-maskable-192.png',
  '$basePath/icons/Icon-maskable-512.png',
  '$basePath/flutter_bootstrap.js',
  // Flutter generated assets
  '$basePath/main.dart.js',
  '$basePath/canvaskit/chromium/canvaskit.js',
  '$basePath/canvaskit/chromium/canvaskit.wasm',
  // Flutter asset manifests
  '$basePath/assets/AssetManifest.bin',
  '$basePath/assets/AssetManifest.bin.json',
  '$basePath/assets/FontManifest.json',
  // Material icons font
  '$basePath/assets/fonts/MaterialIcons-Regular.otf',
  // Drift database worker
  '$basePath/drift_worker.js',
  // sqlite3
  '$basePath/sqlite3.wasm',
];

/// File extensions that should use stale-while-revalidate
const List<String> staleWhileRevalidateExtensions = [
  '.js',
  '.css',
  '.wasm',
  '.html',
  '.json',
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.svg',
  '.ico',
  '.woff',
  '.woff2',
  '.ttf',
  '.otf',
];

/// Get the service worker global scope
@JS('self')
external ServiceWorkerGlobalScope get _self;

/// Main entry point for the service worker
void main() {
  // Install event - precache assets
  _self.addEventListener(
    'install',
    (ExtendableEvent event) {
      event.waitUntil(_onInstall().toJS);
    }.toJS,
  );

  // Activate event - clean old caches
  _self.addEventListener(
    'activate',
    (ExtendableEvent event) {
      event.waitUntil(_onActivate().toJS);
    }.toJS,
  );

  // Fetch event - handle requests with caching strategy
  _self.addEventListener(
    'fetch',
    (FetchEvent event) {
      event.respondWith(_onFetch(event).toJS);
    }.toJS,
  );

  // Sync event - background sync
  _self.addEventListener(
    'sync',
    (SyncEvent event) {
      if (event.tag == 'background-sync') {
        event.waitUntil(_onSync().toJS);
      }
    }.toJS,
  );

  // Message event - handle messages from main app
  _self.addEventListener(
    'message',
    (MessageEvent event) {
      _onMessage(event);
    }.toJS,
  );
}

/// Handle install event - precache critical assets
Future<void> _onInstall() async {
  final cache = await _self.caches.open(staticCacheName).toDart;

  // Precache all static assets
  for (final asset in precacheAssets) {
    try {
      final request = Request(asset.toJS);
      final response = await _self.fetch(request).toDart;
      if (response.ok) {
        await cache.put(request, response).toDart;
      }
    } catch (_) {
      // Continue with other assets if one fails
    }
  }

  // Skip waiting to activate immediately
  await _self.skipWaiting().toDart;
}

/// Handle activate event - cleanup old caches and claim clients
Future<void> _onActivate() async {
  // Get all cache names
  final cacheNames = await _self.caches.keys().toDart;
  final cacheList = cacheNames.toDart;

  // Delete old caches
  for (final cacheName in cacheList) {
    final name = cacheName.toDart;
    if (name != staticCacheName && name != dynamicCacheName) {
      await _self.caches.delete(name).toDart;
    }
  }

  // Claim all clients so the service worker takes control immediately
  await _self.clients.claim().toDart;
}

/// Handle fetch event with stale-while-revalidate strategy
Future<Response> _onFetch(FetchEvent event) async {
  final request = event.request;
  final url = request.url;

  // Only handle GET requests
  if (request.method != 'GET') {
    return _self.fetch(request).toDart;
  }

  // Check if this is a navigation request
  if (request.mode == RequestMode.navigate) {
    return _handleNavigationRequest(request);
  }

  // Check if this URL should use stale-while-revalidate
  if (_shouldUseStaleWhileRevalidate(url)) {
    return _staleWhileRevalidate(request);
  }

  // Default: network first with cache fallback
  return _networkFirst(request);
}

/// Determine if URL should use stale-while-revalidate based on extension
bool _shouldUseStaleWhileRevalidate(String url) {
  final lowerUrl = url.toLowerCase();
  // Remove query string for extension matching
  final urlWithoutQuery = lowerUrl.split('?').first;
  for (final ext in staleWhileRevalidateExtensions) {
    if (urlWithoutQuery.endsWith(ext)) {
      return true;
    }
  }
  return false;
}

/// Stale-while-revalidate strategy
/// Returns cached response immediately while updating cache in background
Future<Response> _staleWhileRevalidate(Request request) async {
  final cache = await _self.caches.open(dynamicCacheName).toDart;

  // Try to get from cache first
  final cachedResponse = await cache.match(request).toDart;

  // If we have a cached response, return it immediately and update cache in background
  if (cachedResponse != null) {
    // Fire off the network request in background to update cache
    _updateCacheInBackground(cache, request);
    return cachedResponse;
  }

  // No cached response, must wait for network
  try {
    final response = await _self.fetch(request).toDart;
    if (response.ok) {
      await cache.put(request, response.clone()).toDart;
    }
    return response;
  } catch (_) {
    // Both cache and network failed, return offline page
    return _getOfflinePage();
  }
}

/// Update cache in background without blocking the response
void _updateCacheInBackground(Cache cache, Request request) {
  _self
      .fetch(request)
      .toDart
      .then((response) async {
        if (response.ok) {
          await cache.put(request, response.clone()).toDart;
        }
      })
      .catchError((_) {
        // Silently ignore network errors during background update
      });
}

/// Network-first strategy with cache fallback
Future<Response> _networkFirst(Request request) async {
  try {
    final response = await _self.fetch(request).toDart;

    // Cache successful responses
    if (response.ok) {
      final cache = await _self.caches.open(dynamicCacheName).toDart;
      await cache.put(request, response.clone()).toDart;
    }

    return response;
  } catch (_) {
    // Network failed, try cache
    final cache = await _self.caches.open(dynamicCacheName).toDart;
    final cachedResponse = await cache.match(request).toDart;

    if (cachedResponse != null) {
      return cachedResponse;
    }

    // Return offline page as last resort
    return _getOfflinePage();
  }
}

/// Handle navigation requests (page loads)
Future<Response> _handleNavigationRequest(Request request) async {
  try {
    // Try network first for navigation
    final response = await _self.fetch(request).toDart;

    // Cache the response
    if (response.ok) {
      final cache = await _self.caches.open(staticCacheName).toDart;
      await cache.put(request, response.clone()).toDart;
    }

    return response;
  } catch (_) {
    // Network failed, try cache
    final staticCache = await _self.caches.open(staticCacheName).toDart;

    // Try to return cached index.html for SPA routing
    final cachedIndex = await staticCache
        .match(Request('$basePath/index.html'.toJS))
        .toDart;
    if (cachedIndex != null) {
      return cachedIndex;
    }

    // Return offline page
    return _getOfflinePage();
  }
}

/// Get the offline fallback page
Future<Response> _getOfflinePage() async {
  final cache = await _self.caches.open(staticCacheName).toDart;
  final offlinePage = await cache.match(Request('$basePath/offline.html'.toJS)).toDart;

  if (offlinePage != null) {
    return offlinePage;
  }

  // Create a basic offline response if offline.html isn't cached
  return Response(
    '<html><body><h1>Offline</h1><p>Please check your connection.</p></body></html>'
        .toJS,
    ResponseInit(
      status: 503,
      statusText: 'Service Unavailable',
      headers: {'Content-Type': 'text/html'}.jsify() as HeadersInit,
    ),
  );
}

/// Handle background sync
Future<void> _onSync() async {
  // Get queued requests from IndexedDB or cache
  // This is a placeholder - implement based on your sync needs
  final cache = await _self.caches.open(syncQueueName).toDart;
  final requests = await cache.keys().toDart;

  for (final request in requests.toDart) {
    try {
      final response = await _self.fetch(request).toDart;
      if (response.ok) {
        // Remove from queue on success
        await cache.delete(request).toDart;
      }
    } catch (_) {
      // Keep in queue for next sync attempt
    }
  }
}

/// Handle messages from the main app
void _onMessage(MessageEvent event) {
  final data = event.data;

  // Handle skip waiting message
  if (data != null && data.isA<JSObject>()) {
    final jsData = data as JSObject;
    if (jsData.has('type')) {
      final messageType = (jsData['type'] as JSString?)?.toDart;
      if (messageType == 'SKIP_WAITING') {
        _self.skipWaiting();
      }
    }
  }
}

/// Queue a failed request for background sync
Future<void> queueForSync(Request request) async {
  final cache = await _self.caches.open(syncQueueName).toDart;
  await cache.put(request, Response(''.toJS)).toDart;

  // Register for background sync if supported
  final registration = _self.registration;
  try {
    await registration.sync.register('background-sync').toDart;
  } catch (_) {
    // Background sync not supported
  }
}

/// Extension types for Web APIs not fully exposed in package:web

/// Extension for ServiceWorkerGlobalScope
extension type ServiceWorkerGlobalScope._(JSObject _) implements JSObject {
  external CacheStorage get caches;
  external Clients get clients;
  external ServiceWorkerRegistration get registration;
  external JSPromise<Response> fetch(Request request);
  external JSPromise<JSAny?> skipWaiting();
  external void addEventListener(String type, JSFunction callback);
}

/// Extension for CacheStorage
extension type CacheStorage._(JSObject _) implements JSObject {
  external JSPromise<Cache> open(String cacheName);
  external JSPromise<JSArray<JSString>> keys();
  external JSPromise<JSBoolean> delete(String cacheName);
}

/// Extension for Cache
extension type Cache._(JSObject _) implements JSObject {
  external JSPromise<Response?> match(Request request);
  external JSPromise<JSAny?> put(Request request, Response response);
  external JSPromise<JSBoolean> delete(Request request);
  external JSPromise<JSArray<Request>> keys();
}

/// Extension for Clients
extension type Clients._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> claim();
}

/// Extension for ExtendableEvent
extension type ExtendableEvent._(JSObject _) implements JSObject {
  external void waitUntil(JSPromise<JSAny?> promise);
}

/// Extension for FetchEvent
extension type FetchEvent._(JSObject _) implements ExtendableEvent {
  external Request get request;
  external void respondWith(JSPromise<Response> response);
}

/// Extension for SyncEvent
extension type SyncEvent._(JSObject _) implements ExtendableEvent {
  external String get tag;
}

/// Extension for SyncManager
extension type SyncManager._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> register(String tag);
}

/// Extension for ServiceWorkerRegistration with sync
extension ServiceWorkerRegistrationSync on ServiceWorkerRegistration {
  @JS('sync')
  external SyncManager get sync;
}

/// Extension for Request mode
extension RequestModeExtension on Request {
  String get mode {
    final jsObject = this as JSObject;
    if (jsObject.has('mode')) {
      final modeValue = jsObject['mode'] as JSString?;
      return modeValue?.toDart ?? '';
    }
    return '';
  }
}

/// Request mode constants
class RequestMode {
  static const String navigate = 'navigate';
  static const String sameOrigin = 'same-origin';
  static const String cors = 'cors';
  static const String noCors = 'no-cors';
}
