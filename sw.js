const CACHE_NAME = 'gastosapp-v1';
const ASSETS_TO_CACHE = [
  '/GastosApp/',
  '/GastosApp/index.html',
  '/GastosApp/flutter_bootstrap.js',
  '/GastosApp/manifest.json',
  '/GastosApp/icons/Icon-192.png',
  '/GastosApp/icons/Icon-512.png',
  '/GastosApp/favicon.png'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', function(event) {
  if (event.request.method !== 'GET') return;
  
  event.respondWith(
    caches.match(event.request).then(function(response) {
      if (response) {
        return response;
      }
      
      return fetch(event.request).then(function(networkResponse) {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then(function(cache) {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      }).catch(function() {
        if (event.request.destination === 'document') {
          return caches.match('/GastosApp/index.html');
        }
      });
    })
  );
});
