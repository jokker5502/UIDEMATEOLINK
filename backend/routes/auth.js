// Authentication Routes
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { query } = require('../db');

/**
 * Generate JWT token
 * @param {object} user - User data
 * @param {string} type - User type (student, driver, admin)
 * @returns {string} JWT token
 */
const generateToken = (user, type) => {
    const payload = {
        id: user.id,
        email: user.email,
        type: type,
        // For students, include student_id for offline validation
        ...(type === 'student' && { student_id: user.student_id }),
        ...(type === 'driver' && { driver_id: user.driver_id }),
    };

    return jwt.sign(payload, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRATION || '24h',
    });
};

/**
 * POST /api/auth/login
 * Login for students, drivers, and admins
 * Body: { email, password, userType: 'student' | 'driver' | 'admin' }
 */
router.post('/login', async (req, res) => {
    try {
        const { email, password, userType } = req.body;

        if (!email || !password || !userType) {
            return res.status(400).json({
                error: 'Missing fields',
                message: 'Email, password, and userType are required'
            });
        }

        let user;
        let tableName;

        // Query appropriate table based on user type
        switch (userType) {
            case 'student':
                tableName = 'students';
                break;
            case 'driver':
                tableName = 'drivers';
                break;
            case 'admin':
                tableName = 'admins';
                break;
            default:
                return res.status(400).json({
                    error: 'Invalid user type',
                    message: 'userType must be student, driver, or admin'
                });
        }

        const result = await query(
            `SELECT * FROM ${tableName} WHERE email = $1 AND is_active = true`,
            [email]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({
                error: 'Invalid credentials',
                message: 'Email or password incorrect'
            });
        }

        user = result.rows[0];

        // Verify password
        const validPassword = await bcrypt.compare(password, user.password_hash);

        if (!validPassword) {
            return res.status(401).json({
                error: 'Invalid credentials',
                message: 'Email or password incorrect'
            });
        }

        // Update last_login timestamp
        await query(
            `UPDATE ${tableName} SET last_login = CURRENT_TIMESTAMP WHERE id = $1`,
            [user.id]
        );

        // Generate token
        const token = generateToken(user, userType);

        // Return user data (without password hash)
        delete user.password_hash;

        res.json({
            success: true,
            token: token,
            user: user,
            userType: userType,
            expiresIn: '24h'
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'An error occurred during login'
        });
    }
});

/**
 * POST /api/auth/refresh
 * Refresh token (can be called before expiration to extend session)
 */
router.post('/refresh', async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({
                error: 'No token provided'
            });
        }

        // Verify token (allow expired tokens for refresh)
        const decoded = jwt.verify(token, process.env.JWT_SECRET, {
            ignoreExpiration: true
        });

        // Check if token is actually expired
        const now = Math.floor(Date.now() / 1000);
        const gracePeriod = 7 * 24 * 60 * 60; // 7 days

        if (decoded.exp && (now - decoded.exp) > gracePeriod) {
            return res.status(403).json({
                error: 'Token expired beyond refresh period',
                message: 'Please login again'
            });
        }

        // Get fresh user data
        let tableName;
        switch (decoded.type) {
            case 'student': tableName = 'students'; break;
            case 'driver': tableName = 'drivers'; break;
            case 'admin': tableName = 'admins'; break;
            default:
                return res.status(400).json({ error: 'Invalid token type' });
        }

        const result = await query(
            `SELECT * FROM ${tableName} WHERE id = $1 AND is_active = true`,
            [decoded.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'User not found or inactive'
            });
        }

        const user = result.rows[0];
        delete user.password_hash;

        // Generate new token
        const newToken = generateToken(user, decoded.type);

        res.json({
            success: true,
            token: newToken,
            user: user,
            userType: decoded.type,
            expiresIn: '24h'
        });

    } catch (error) {
        console.error('Token refresh error:', error);
        res.status(500).json({
            error: 'Server error',
            message: 'Failed to refresh token'
        });
    }
});

module.exports = router;
