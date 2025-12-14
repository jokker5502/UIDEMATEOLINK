// IndexedDB Wrapper for Offline Storage
// Manages local scan queue and cached data

const DB_NAME = 'UIDELinkDB';
const DB_VERSION = 1;

class UIDEDatabase {
    constructor() {
        this.db = null;
    }

    /**
     * Initialize database connection
     */
    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(DB_NAME, DB_VERSION);

            request.onerror = () => {
                console.error('IndexedDB error:', request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                this.db = request.result;
                console.log('✓ IndexedDB initialized');
                resolve(this.db);
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                console.log('Creating IndexedDB schema...');

                // Scans object store (offline queue)
                if (!db.objectStoreNames.contains('scans')) {
                    const scanStore = db.createObjectStore('scans', {
                        keyPath: 'clientId'
                    });
                    scanStore.createIndex('timestamp', 'localTimestamp', { unique: false });
                    scanStore.createIndex('syncStatus', 'syncStatus', { unique: false });
                }

                // Routes cache
                if (!db.objectStoreNames.contains('routes')) {
                    db.createObjectStore('routes', { keyPath: 'id' });
                }

                // QR codes cache
                if (!db.objectStoreNames.contains('qrCodes')) {
                    db.createObjectStore('qrCodes', { keyPath: 'busId' });
                }

                // User data cache (token, profile)
                if (!db.objectStoreNames.contains('userData')) {
                    db.createObjectStore('userData', { keyPath: 'key' });
                }

                // Scan history (successful syncs)
                if (!db.objectStoreNames.contains('scanHistory')) {
                    const historyStore = db.createObjectStore('scanHistory', {
                        keyPath: 'id',
                        autoIncrement: true
                    });
                    historyStore.createIndex('timestamp', 'localTimestamp', { unique: false });
                }

                console.log('✓ IndexedDB schema created');
            };
        });
    }

    /**
     * Add scan to offline queue
     * @param {object} scanData - Scan event data
     * @returns {Promise<string>} Client ID
     */
    async addScan(scanData) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scans'], 'readwrite');
            const store = tx.objectStore('scans');

            // Generate client ID if not provided
            if (!scanData.clientId) {
                scanData.clientId = this.generateUUID();
            }

            scanData.syncStatus = 'pending';
            scanData.queuedAt = new Date().toISOString();

            const request = store.add(scanData);

            request.onsuccess = () => {
                console.log('✓ Scan queued:', scanData.clientId);
                resolve(scanData.clientId);
            };

            request.onerror = () => {
                console.error('Failed to queue scan:', request.error);
                reject(request.error);
            };
        });
    }

    /**
     * Get all pending scans
     * @returns {Promise<array>} Pending scans
     */
    async getPendingScans() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scans'], 'readonly');
            const store = tx.objectStore('scans');
            const index = store.index('syncStatus');
            const request = index.getAll('pending');

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Mark scan as synced and remove from queue
     * @param {string} clientId - Client ID of scan
     */
    async markSynced(clientId) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scans'], 'readwrite');
            const store = tx.objectStore('scans');
            const request = store.delete(clientId);

            request.onsuccess = () => {
                console.log('✓ Scan marked as synced:', clientId);
                resolve();
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Clear all pending scans (after successful bulk sync)
     */
    async clearPendingScans() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scans'], 'readwrite');
            const store = tx.objectStore('scans');
            const request = store.clear();

            request.onsuccess = () => {
                console.log('✓ Pending scans cleared');
                resolve();
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Cache routes data
     * @param {array} routes - Routes array
     */
    async cacheRoutes(routes) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['routes'], 'readwrite');
            const store = tx.objectStore('routes');

            // Clear existing routes
            store.clear();

            // Add new routes
            routes.forEach(route => {
                store.put(route);
            });

            tx.oncomplete = () => {
                console.log('✓ Routes cached:', routes.length);
                resolve();
            };

            tx.onerror = () => {
                reject(tx.error);
            };
        });
    }

    /**
     * Get cached routes
     * @returns {Promise<array>} Routes
     */
    async getRoutes() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['routes'], 'readonly');
            const store = tx.objectStore('routes');
            const request = store.getAll();

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Store user data (token, profile)
     * @param {object} userData - User data
     */
    async setUserData(userData) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['userData'], 'readwrite');
            const store = tx.objectStore('userData');

            const data = {
                key: 'currentUser',
                ...userData,
                cachedAt: new Date().toISOString()
            };

            const request = store.put(data);

            request.onsuccess = () => {
                console.log('✓ User data cached');
                resolve();
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Get user data
     * @returns {Promise<object>} User data
     */
    async getUserData() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['userData'], 'readonly');
            const store = tx.objectStore('userData');
            const request = store.get('currentUser');

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Clear user data (logout)
     */
    async clearUserData() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['userData'], 'readwrite');
            const store = tx.objectStore('userData');
            const request = store.delete('currentUser');

            request.onsuccess = () => {
                console.log('✓ User data cleared');
                resolve();
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Add to scan history
     * @param {object} scan - Scan event
     */
    async addToHistory(scan) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scanHistory'], 'readwrite');
            const store = tx.objectStore('scanHistory');
            const request = store.add(scan);

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Get scan history (recent)
     * @param {number} limit - Number of records
     * @returns {Promise<array>} Scan history
     */
    async getHistory(limit = 20) {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scanHistory'], 'readonly');
            const store = tx.objectStore('scanHistory');
            const index = store.index('timestamp');
            const request = index.openCursor(null, 'prev');

            const results = [];
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && results.length < limit) {
                    results.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(results);
                }
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }

    /**
     * Generate UUID v4
     * @returns {string} UUID
     */
    generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    /**
     * Get pending scan count
     * @returns {Promise<number>} Count
     */
    async getPendingCount() {
        if (!this.db) await this.init();

        return new Promise((resolve, reject) => {
            const tx = this.db.transaction(['scans'], 'readonly');
            const store = tx.objectStore('scans');
            const request = store.count();

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    }
}

// Export singleton instance
const DB = new UIDEDatabase();
window.DB = DB;
