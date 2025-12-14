// Service Worker for UIDE-Link PWA
// Handles offline caching and background sync

const CACHE_VERSION = 'uide-link-v1';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const API_CACHE = `${CACHE_VERSION}-api`;
const IMAGE_CACHE = `${CACHE_VERSION}-images`;

// Assets to cache on install
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/student.html',
    '/driver.html',
    '/css/styles.css',
    '/js/app.js',
    '/js/db.js',
    '/js/sync.js',
    '/js/scanner.js',
    '/manifest.json',
    '/icons/icon-192.png',
    '/icons/icon-512.png'
];

// Install event: cache static assets
self.addEventListener('install', (event) => {
    console.log('[SW] Installing service worker...');

    event.waitUntil(
        caches.open(STATIC_CACHE)
            .then((cache) => {
                console.log('[SW] Caching static assets');
                return cache.addAll(STATIC_ASSETS);
            })
            .then(() => {
                console.log('[SW] Static assets cached');
                return self.skipWaiting(); // Activate immediately
            })
    );
});

// Activate event: cleanup old caches
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating service worker...');

    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames.map((cacheName) => {
                        if (cacheName.startsWith('uide-link-') && !cacheName.startsWith(CACHE_VERSION)) {
                            console.log('[SW] Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            })
            .then(() => {
                console.log('[SW] Service worker activated');
                return self.clients.claim(); // Take control immediately
            })
    );
});

// Fetch event: network strategies
self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);

    // API requests: Network-first, fallback to cache
    if (url.pathname.startsWith('/api/')) {
        event.respondWith(networkFirst(request, API_CACHE));
        return;
    }

    // Images: Cache-first
    if (request.destination === 'image') {
        event.respondWith(cacheFirst(request, IMAGE_CACHE));
        return;
    }

    // Static assets: Cache-first with network fallback
    event.respondWith(cacheFirst(request, STATIC_CACHE));
});

/**
 * Cache-first strategy
 * Use for: Static assets, images
 */
async function cacheFirst(request, cacheName) {
    const cache = await caches.open(cacheName);
    const cached = await cache.match(request);

    if (cached) {
        return cached;
    }

    try {
        const response = await fetch(request);
        if (response.ok) {
            cache.put(request, response.clone());
        }
        return response;
    } catch (error) {
        console.error('[SW] Fetch failed:', error);

        // Return offline page if available
        if (request.mode === 'navigate') {
            return caches.match('/offline.html') || new Response('Offline');
        }

        throw error;
    }
}

/**
 * Network-first strategy
 * Use for: API requests (with offline fallback)
 */
async function networkFirst(request, cacheName) {
    try {
        const response = await fetch(request);

        // Cache successful GET requests
        if (response.ok && request.method === 'GET') {
            const cache = await caches.open(cacheName);
            cache.put(request, response.clone());
        }

        return response;
    } catch (error) {
        console.log('[SW] Network failed, trying cache:', request.url);

        // Try cache for GET requests
        if (request.method === 'GET') {
            const cached = await caches.match(request);
            if (cached) {
                return cached;
            }
        }

        // For POST requests (scans), return success response
        // The client will queue in IndexedDB
        if (request.method === 'POST' && request.url.includes('/api/scans')) {
            return new Response(
                JSON.stringify({
                    offline: true,
                    message: 'Queued for sync when online'
                }),
                {
                    status: 202, // Accepted
                    headers: { 'Content-Type': 'application/json' }
                }
            );
        }

        throw error;
    }
}

// Background Sync: Sync queued scans when online
self.addEventListener('sync', (event) => {
    console.log('[SW] Background sync event:', event.tag);

    if (event.tag === 'sync-scans') {
        event.waitUntil(syncScans());
    }
});

/**
 * Sync queued scans to server
 */
async function syncScans() {
    console.log('[SW] Starting background scan sync...');

    try {
        // Open IndexedDB
        const db = await openDB();
        const tx = db.transaction(['scans'], 'readonly');
        const store = tx.objectStore('scans');
        const scans = await getAll(store);

        if (scans.length === 0) {
            console.log('[SW] No scans to sync');
            return;
        }

        console.log(`[SW] Syncing ${scans.length} scans...`);

        // Get auth token from IndexedDB
        const userDataTx = db.transaction(['userData'], 'readonly');
        const userDataStore = userDataTx.objectStore('userData');
        const userData = await get(userDataStore, 'currentUser');

        if (!userData || !userData.token) {
            console.error('[SW] No auth token found, cannot sync');
            return;
        }

        // Send to server
        const response = await fetch('/api/scans/bulk', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${userData.token}`
            },
            body: JSON.stringify({ scans })
        });

        if (response.ok) {
            const result = await response.json();
            console.log('[SW] Sync successful:', result);

            // Clear synced scans from IndexedDB
            const deleteTx = db.transaction(['scans'], 'readwrite');
            const deleteStore = deleteTx.objectStore('scans');
            await clearStore(deleteStore);

            // Notify clients
            const clients = await self.clients.matchAll();
            clients.forEach(client => {
                client.postMessage({
                    type: 'SYNC_COMPLETE',
                    data: result
                });
            });
        } else {
            console.error('[SW] Sync failed:', response.status);
        }

    } catch (error) {
        console.error('[SW] Background sync error:', error);
        throw error; // Retry sync
    }
}

// Helper: Open IndexedDB
function openDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open('UIDELinkDB', 1);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

// Helper: Get all records from object store
function getAll(store) {
    return new Promise((resolve, reject) => {
        const request = store.getAll();
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

// Helper: Get single record
function get(store, key) {
    return new Promise((resolve, reject) => {
        const request = store.get(key);
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
    });
}

// Helper: Clear object store
function clearStore(store) {
    return new Promise((resolve, reject) => {
        const request = store.clear();
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
    });
}

// Push notification (for future use)
self.addEventListener('push', (event) => {
    const data = event.data ? event.data.json() : {};

    const options = {
        body: data.message || 'Nueva notificación de UIDE-Link',
        icon: '/icons/icon-192.png',
        badge: '/icons/badge-72.png',
        vibrate: [200, 100, 200]
    };

    event.waitUntil(
        self.registration.showNotification(data.title || 'UIDE-Link', options)
    );
});
