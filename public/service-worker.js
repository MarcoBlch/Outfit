// Service Worker for Outfit PWA
const CACHE_VERSION = 'outfit-v1';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const DYNAMIC_CACHE = `${CACHE_VERSION}-dynamic`;
const IMAGE_CACHE = `${CACHE_VERSION}-images`;

// Assets to cache on install
const STATIC_ASSETS = [
  '/',
  '/offline.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing...');

  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => {
        console.log('[Service Worker] Caching static assets');
        return cache.addAll(STATIC_ASSETS.filter(url => url !== '/icon-192.png' && url !== '/icon-512.png'));
      })
      .then(() => self.skipWaiting())
      .catch((error) => {
        console.error('[Service Worker] Failed to cache static assets:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating...');

  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((name) => name.startsWith('outfit-') && name !== STATIC_CACHE && name !== DYNAMIC_CACHE && name !== IMAGE_CACHE)
            .map((name) => {
              console.log('[Service Worker] Deleting old cache:', name);
              return caches.delete(name);
            })
        );
      })
      .then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache when possible
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Skip chrome-extension and other non-http(s) requests
  if (!url.protocol.startsWith('http')) {
    return;
  }

  // Handle image requests with cache-first strategy
  if (request.destination === 'image' || url.pathname.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i)) {
    event.respondWith(
      caches.open(IMAGE_CACHE)
        .then((cache) => {
          return cache.match(request)
            .then((cachedResponse) => {
              if (cachedResponse) {
                return cachedResponse;
              }

              return fetch(request)
                .then((networkResponse) => {
                  // Only cache successful responses
                  if (networkResponse && networkResponse.status === 200) {
                    cache.put(request, networkResponse.clone());
                  }
                  return networkResponse;
                })
                .catch(() => {
                  // Return a placeholder image if offline
                  return new Response(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect fill="#9333ea" width="200" height="200"/><text x="50%" y="50%" text-anchor="middle" dy=".3em" fill="white" font-size="14">Offline</text></svg>',
                    { headers: { 'Content-Type': 'image/svg+xml' } }
                  );
                });
            });
        })
    );
    return;
  }

  // Handle navigation requests with network-first strategy
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache the page for offline use
          return caches.open(DYNAMIC_CACHE)
            .then((cache) => {
              cache.put(request, response.clone());
              return response;
            });
        })
        .catch(() => {
          // If offline, try to serve from cache
          return caches.match(request)
            .then((cachedResponse) => {
              if (cachedResponse) {
                return cachedResponse;
              }
              // If not in cache, show offline page
              return caches.match('/offline.html');
            });
        })
    );
    return;
  }

  // For all other requests, try network first, then cache
  event.respondWith(
    fetch(request)
      .then((response) => {
        // Clone the response before caching
        const responseToCache = response.clone();

        caches.open(DYNAMIC_CACHE)
          .then((cache) => {
            cache.put(request, responseToCache);
          });

        return response;
      })
      .catch(() => {
        // If network fails, try to serve from cache
        return caches.match(request);
      })
  );
});

// Background sync for offline uploads (future enhancement)
self.addEventListener('sync', (event) => {
  console.log('[Service Worker] Background sync:', event.tag);

  if (event.tag === 'sync-wardrobe-uploads') {
    event.waitUntil(
      // Future: sync pending uploads
      Promise.resolve()
    );
  }
});

// Push notification handler (future enhancement)
self.addEventListener('push', (event) => {
  console.log('[Service Worker] Push notification received');

  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Outfit';
  const options = {
    body: data.body || 'You have a new notification',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    data: data.url || '/',
    ...data.options
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
  console.log('[Service Worker] Notification clicked');

  event.notification.close();

  event.waitUntil(
    clients.openWindow(event.notification.data || '/')
  );
});
