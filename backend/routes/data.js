// Routes and Data Routes
const express = require('express');
const router = express.Router();
const { query } = require('../db');

/**
 * GET /api/routes
 * Get all active routes
 */
router.get('/', async (req, res) => {
    try {
        const result = await query(
            `SELECT id, name, description 
       FROM routes 
       WHERE is_active = true 
       ORDER BY name`,
            []
        );

        res.json({
            success: true,
            count: result.rows.length,
            routes: result.rows
        });

    } catch (error) {
        console.error('Get routes error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve routes'
        });
    }
});

/**
 * GET /api/schedules
 * Get all operation schedules (arrivals and departures)
 */
router.get('/schedules', async (req, res) => {
    try {
        const result = await query(
            `SELECT id, schedule_type, time_slot 
       FROM schedules 
       WHERE is_active = true 
       ORDER BY schedule_type, time_slot`,
            []
        );

        // Group by type
        const arrivals = result.rows
            .filter(s => s.schedule_type === 'arrival')
            .map(s => s.time_slot);

        const departures = result.rows
            .filter(s => s.schedule_type === 'departure')
            .map(s => s.time_slot);

        res.json({
            success: true,
            schedules: {
                arrivals,
                departures
            }
        });

    } catch (error) {
        console.error('Get schedules error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve schedules'
        });
    }
});

/**
 * GET /api/buses
 * Get all active buses
 */
router.get('/buses', async (req, res) => {
    try {
        const result = await query(
            `SELECT 
        b.id, b.bus_number, b.license_plate, b.capacity,
        r.id as route_id, r.name as route_name
       FROM buses b
       LEFT JOIN routes r ON b.route_id = r.id
       WHERE b.is_active = true
       ORDER BY b.bus_number`,
            []
        );

        res.json({
            success: true,
            count: result.rows.length,
            buses: result.rows
        });

    } catch (error) {
        console.error('Get buses error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve buses'
        });
    }
});

/**
 * GET /api/qr/:busId
 * Get QR code data for a specific bus
 */
router.get('/qr/:busId', async (req, res) => {
    try {
        const { busId } = req.params;

        const result = await query(
            `SELECT id, bus_number, qr_code, route_id 
       FROM buses 
       WHERE id = $1 AND is_active = true`,
            [busId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'Not found',
                message: 'Bus not found'
            });
        }

        res.json({
            success: true,
            bus: result.rows[0]
        });

    } catch (error) {
        console.error('Get QR error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to retrieve QR code'
        });
    }
});

module.exports = router;
