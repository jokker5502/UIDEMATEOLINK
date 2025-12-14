// UIDE-Link Backend Server
// Offline-First Bus Telemetry System

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Import database connection
const { pool } = require('./db');

// Import routes
const authRoutes = require('./routes/auth');
const scansRoutes = require('./routes/scans');
const dataRoutes = require('./routes/data');

// =====================================================
// MIDDLEWARE
// =====================================================

// Security headers
app.use(helmet());

// CORS configuration
const corsOptions = {
    origin: process.env.FRONTEND_URL || '*',
    credentials: true,
    optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Body parsing
app.use(express.json({ limit: '10mb' })); // Allow larger payloads for bulk sync
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 60000, // 1 minute
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    message: {
        error: 'Too many requests',
        message: 'Please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false,
});
app.use('/api/', limiter);

// Request logging (development)
if (process.env.NODE_ENV === 'development') {
    app.use((req, res, next) => {
        console.log(`${req.method} ${req.path}`);
        next();
    });
}

// =====================================================
// ROUTES
// =====================================================

// Health check
app.get('/health', async (req, res) => {
    try {
        // Check database connection
        await pool.query('SELECT 1');

        res.json({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            database: 'connected'
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            timestamp: new Date().toISOString(),
            database: 'disconnected',
            error: error.message
        });
    }
});

// API info
app.get('/api', (req, res) => {
    res.json({
        name: 'UIDE-Link API',
        version: '1.0.0',
        description: 'Offline-First Bus Telemetry System',
        endpoints: {
            auth: '/api/auth/*',
            scans: '/api/scans/*',
            routes: '/api/routes',
            schedules: '/api/schedules',
            buses: '/api/buses',
            qr: '/api/qr/:busId'
        }
    });
});

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/scans', scansRoutes);
app.use('/api', dataRoutes);

// =====================================================
// ERROR HANDLING
// =====================================================

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not found',
        message: `Route ${req.path} not found`
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);

    res.status(err.status || 500).json({
        error: err.message || 'Internal server error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
});

// =====================================================
// START SERVER
// =====================================================

app.listen(PORT, () => {
    console.log('');
    console.log('═══════════════════════════════════════════════');
    console.log('  🚌 UIDE-Link Backend Server');
    console.log('  Offline-First Bus Telemetry System');
    console.log('═══════════════════════════════════════════════');
    console.log(`  ✓ Server running on port ${PORT}`);
    console.log(`  ✓ Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`  ✓ API endpoint: http://localhost:${PORT}/api`);
    console.log('═══════════════════════════════════════════════');
    console.log('');
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM received, shutting down gracefully...');
    await pool.end();
    process.exit(0);
});

process.on('SIGINT', async () => {
    console.log('\nSIGINT received, shutting down gracefully...');
    await pool.end();
    process.exit(0);
});

module.exports = app;
