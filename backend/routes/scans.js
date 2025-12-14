// Scan Events Routes (Core telemetry endpoints)
const express = require('express');
const router = express.Router();
const { query, transaction } = require('../db');
const { authenticateToken, requireStudent } = require('../middleware/auth');

/**
 * POST /api/scans/bulk
 * Bulk sync offline scans from client
 * Body: { scans: Array<ScanEvent> }
 * CRITICAL: This is the core offline sync endpoint
 */
router.post('/bulk', authenticateToken, async (req, res) => {
    try {
        const { scans } = req.body;

        if (!Array.isArray(scans) || scans.length === 0) {
            return res.status(400).json({
                error: 'Invalid input',
                message: 'Scans must be a non-empty array'
            });
        }

        // Limit bulk size to prevent abuse
        if (scans.length > 100) {
            return res.status(400).json({
                error: 'Too many scans',
                message: 'Maximum 100 scans per request'
            });
        }

        const results = {
            synced: [],
            conflicts: [],
            errors: []
        };

        // Process each scan in a transaction
        for (const scan of scans) {
            try {
                const {
                    clientId,
                    busId,
                    routeId,
                    eventType,
                    localTimestamp,
                    latitude,
                    longitude,
                    deviceInfo
                } = scan;

                // Validate required fields
                if (!clientId || !busId || !eventType || !localTimestamp) {
                    results.errors.push({
                        clientId,
                        error: 'Missing required fields'
                    });
                    continue;
                }

                // Check if already synced (idempotency via client_id)
                const existing = await query(
                    'SELECT id, sync_status FROM scan_events WHERE client_id = $1',
                    [clientId]
                );

                if (existing.rows.length > 0) {
                    // Already synced
                    results.synced.push({
                        clientId,
                        status: 'already_synced',
                        serverId: existing.rows[0].id
                    });
                    continue;
                }

                // Insert scan event
                const insertResult = await query(
                    `INSERT INTO scan_events (
            student_id, bus_id, route_id, event_type, 
            local_timestamp, sync_status, client_id,
            latitude, longitude, device_info
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          RETURNING id, sync_status`,
                    [
                        req.user.id, // From JWT token
                        busId,
                        routeId || null,
                        eventType,
                        localTimestamp,
                        'synced', // Will be changed to 'conflict' by trigger if duplicate
                        clientId,
                        latitude || null,
                        longitude || null,
                        deviceInfo ? JSON.stringify(deviceInfo) : null
                    ]
                );

                const inserted = insertResult.rows[0];

                // Check if conflict was detected by trigger
                if (inserted.sync_status === 'conflict') {
                    results.conflicts.push({
                        clientId,
                        serverId: inserted.id,
                        status: 'conflict_detected',
                        message: 'Duplicate scan detected'
                    });
                } else {
                    results.synced.push({
                        clientId,
                        serverId: inserted.id,
                        status: 'synced'
                    });
                }

            } catch (scanError) {
                console.error('Error processing scan:', scanError);
                results.errors.push({
                    clientId: scan.clientId,
                    error: scanError.message
                });
            }
        }

        res.json({
            success: true,
            summary: {
                total: scans.length,
                synced: results.synced.length,
                conflicts: results.conflicts.length,
                errors: results.errors.length
            },
            results: results
        });

    } catch (error) {
        console.error('Bulk sync error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to sync scans'
        });
    }
});

/**
 * GET /api/scans/student/:studentId
 * Get scan history for a student
 * Query params: ?days=7 (default), ?limit=50
 */
router.get('/student/:studentId', authenticateToken, async (req, res) => {
    try {
        const { studentId } = req.params;
        const days = parseInt(req.query.days) || 7;
        const limit = parseInt(req.query.limit) || 50;

        // Students can only view their own scans
        if (req.user.type === 'student' && req.user.id != studentId) {
            return res.status(403).json({
                error: 'Forbidden',
                message: 'You can only view your own scan history'
            });
        }

        const result = await query(
            `SELECT 
        se.id,
        se.event_type,
        se.local_timestamp,
        se.sync_status,
        se.latitude,
        se.longitude,
        b.bus_number,
        b.id as bus_id,
        r.name as route_name,
        r.id as route_id
      FROM scan_events se
      LEFT JOIN buses b ON se.bus_id = b.id
      LEFT JOIN routes r ON se.route_id = r.id
      WHERE se.student_id = $1
        AND se.local_timestamp > NOW() - ($2 || ' days')::INTERVAL
      ORDER BY se.local_timestamp DESC
      LIMIT $3`,
            [studentId, days, limit]
        );

        res.json({
            success: true,
            count: result.rows.length,
            scans: result.rows
        });

    } catch (error) {
        console.error('Get student scans error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve scan history'
        });
    }
});

/**
 * GET /api/scans/bus/:busId
 * Get scan history for a bus
 * Query params: ?date=YYYY-MM-DD (default: today)
 */
router.get('/bus/:busId', authenticateToken, async (req, res) => {
    try {
        const { busId } = req.params;
        const date = req.query.date || new Date().toISOString().split('T')[0];

        const result = await query(
            `SELECT 
        se.id,
        se.event_type,
        se.local_timestamp,
        se.sync_status,
        s.student_id,
        s.first_name,
        s.last_name
      FROM scan_events se
      JOIN students s ON se.student_id = s.id
      WHERE se.bus_id = $1
        AND DATE(se.local_timestamp) = $2
      ORDER BY se.local_timestamp DESC`,
            [busId, date]
        );

        // Calculate current occupancy
        const occupancyResult = await query(
            `SELECT COUNT(DISTINCT se.student_id) as count
      FROM scan_events se
      WHERE se.bus_id = $1
        AND se.event_type = 'ingress'
        AND se.local_timestamp > NOW() - INTERVAL '4 hours'
        AND NOT EXISTS (
          SELECT 1 FROM scan_events se2
          WHERE se2.student_id = se.student_id
            AND se2.bus_id = se.bus_id
            AND se2.event_type = 'egress'
            AND se2.local_timestamp > se.local_timestamp
        )`,
            [busId]
        );

        res.json({
            success: true,
            busId: busId,
            date: date,
            count: result.rows.length,
            currentOccupancy: occupancyResult.rows[0].count,
            scans: result.rows
        });

    } catch (error) {
        console.error('Get bus scans error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve bus scans'
        });
    }
});

/**
 * GET /api/scans/pending
 * Get count of pending/conflict scans (for debugging)
 */
router.get('/pending', authenticateToken, async (req, res) => {
    try {
        const pendingResult = await query(
            `SELECT COUNT(*) as count FROM scan_events WHERE sync_status = 'pending'`
        );

        const conflictResult = await query(
            `SELECT COUNT(*) as count FROM scan_events WHERE sync_status = 'conflict'`
        );

        res.json({
            success: true,
            pending: parseInt(pendingResult.rows[0].count),
            conflicts: parseInt(conflictResult.rows[0].count)
        });

    } catch (error) {
        console.error('Get pending scans error:', error);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

module.exports = router;
