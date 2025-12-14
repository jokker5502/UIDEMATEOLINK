// Sync Manager for UIDE-Link
// Handles automatic background sync of offline scans

class SyncManager {
    constructor() {
        this.syncing = false;
        this.lastSyncTime = null;
        this.syncInterval = null;
    }

    /**
     * Initialize sync manager
     */
    async init() {
        console.log('[Sync] Initializing sync manager...');

        // Listen for online/offline events
        window.addEventListener('online', () => {
            console.log('[Sync] Connection restored');
            this.updateConnectionStatus(true);
            this.syncNow();
        });

        window.addEventListener('offline', () => {
            console.log('[Sync] Connection lost');
            this.updateConnectionStatus(false);
        });

        // Listen for messages from Service Worker
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.addEventListener('message', (event) => {
                if (event.data.type === 'SYNC_COMPLETE') {
                    console.log('[Sync] Background sync completed:', event.data.data);
                    this.onSyncComplete(event.data.data);
                }
            });
        }

        // Start periodic sync (every minute when online)
        this.startPeriodicSync();

        // Set initial connection status
        this.updateConnectionStatus(navigator.onLine);

        // Sync immediately if online and has pending scans
        if (navigator.onLine) {
            const pendingCount = await window.DB.getPendingCount();
            if (pendingCount > 0) {
                console.log(`[Sync] Found ${pendingCount} pending scans, syncing...`);
                setTimeout(() => this.syncNow(), 1000);
            }
        }
    }

    /**
     * Start periodic sync check
     */
    startPeriodicSync() {
        // Clear existing interval
        if (this.syncInterval) {
            clearInterval(this.syncInterval);
        }

        // Sync every 60 seconds when online
        this.syncInterval = setInterval(() => {
            if (navigator.onLine && !this.syncing) {
                this.syncIfNeeded();
            }
        }, 60000);
    }

    /**
     * Sync if there are pending scans
     */
    async syncIfNeeded() {
        const pendingCount = await window.DB.getPendingCount();
        if (pendingCount > 0) {
            console.log(`[Sync] ${pendingCount} pending scans found`);
            this.syncNow();
        }
    }

    /**
     * Force sync now
     */
    async syncNow() {
        if (this.syncing) {
            console.log('[Sync] Already syncing, skipping');
            return;
        }

        if (!navigator.onLine) {
            console.log('[Sync] Offline, cannot sync');
            return;
        }

        this.syncing = true;
        this.updateSyncStatus('Sincronizando...');

        try {
            // Get pending scans
            const scans = await window.DB.getPendingScans();

            if (scans.length === 0) {
                console.log('[Sync] No scans to sync');
                this.syncing = false;
                this.updateSyncStatus('Sincronizado ✓');
                return;
            }

            console.log(`[Sync] Syncing ${scans.length} scans...`);

            // Get auth token
            const userData = await window.DB.getUserData();

            if (!userData || !userData.token) {
                console.error('[Sync] No auth token, cannot sync');
                this.syncing = false;
                this.updateSyncStatus('Error: No autenticado');
                return;
            }

            // Send to server
            const API_URL = window.CONFIG?.API_URL || 'http://localhost:3000';
            const response = await fetch(`${API_URL}/api/scans/bulk`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${userData.token}`
                },
                body: JSON.stringify({ scans })
            });

            if (!response.ok) {
                throw new Error(`Sync failed: ${response.status}`);
            }

            const result = await response.json();
            console.log('[Sync] Sync successful:', result);

            // Clear synced scans
            await window.DB.clearPendingScans();

            // Add to history
            for (const scan of scans) {
                await window.DB.addToHistory(scan);
            }

            this.lastSyncTime = new Date();
            this.updateSyncStatus(`Sincronizado ✓ (${scans.length})`);

            // Trigger sync complete event
            this.onSyncComplete(result);

        } catch (error) {
            console.error('[Sync] Sync error:', error);
            this.updateSyncStatus('Error de sincronización');

            // Register background sync for retry
            if ('serviceWorker' in navigator && 'sync' in ServiceWorkerRegistration.prototype) {
                const registration = await navigator.serviceWorker.ready;
                await registration.sync.register('sync-scans');
                console.log('[Sync] Background sync registered for retry');
            }

        } finally {
            this.syncing = false;
        }
    }

    /**
     * Update connection status UI
     * @param {boolean} online - Connection status
     */
    updateConnectionStatus(online) {
        const indicator = document.getElementById('connectionStatus');
        if (indicator) {
            if (online) {
                indicator.className = 'status-indicator online';
                indicator.innerHTML = '<span class="status-dot"></span> En línea';
            } else {
                indicator.className = 'status-indicator offline';
                indicator.innerHTML = '<span class="status-dot"></span> Sin conexión';
            }
        }
    }

    /**
     * Update sync status UI
     * @param {string} status - Status message
     */
    updateSyncStatus(status) {
        const statusEl = document.getElementById('syncStatus');
        if (statusEl) {
            statusEl.textContent = status;
        }
    }

    /**
     * Called when sync completes
     * @param {object} result - Sync result
     */
    async onSyncComplete(result) {
        console.log('[Sync] Sync complete callback:', result);

        // Update pending count display
        const pendingCount = await window.DB.getPendingCount();
        this.updatePendingCount(pendingCount);

        // Dispatch custom event for UI updates
        window.dispatchEvent(new CustomEvent('scansSynced', {
            detail: result
        }));
    }

    /**
     * Update pending scan count UI
     * @param {number} count - Pending count
     */
    updatePendingCount(count) {
        const countEl = document.getElementById('pendingCount');
        if (countEl) {
            if (count > 0) {
                countEl.textContent = `${count} escaneo${count > 1 ? 's' : ''} pendiente${count > 1 ? 's' : ''}`;
                countEl.classList.add('pending');
            } else {
                countEl.textContent = 'Todo sincronizado';
                countEl.classList.remove('pending');
            }
        }
    }

    /**
     * Manually trigger sync button
     */
    async manualSync() {
        const pendingCount = await window.DB.getPendingCount();

        if (pendingCount === 0) {
            console.log('[Sync] No pending scans');
            this.updateSyncStatus('No hay escaneos pendientes');
            return;
        }

        if (!navigator.onLine) {
            console.log('[Sync] Offline, cannot sync');
            this.updateSyncStatus('Sin conexión a internet');
            return;
        }

        await this.syncNow();
    }
}

// Create global instance
window.SyncManager = new SyncManager();
