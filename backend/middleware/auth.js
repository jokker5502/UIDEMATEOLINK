// JWT Authentication Middleware
const jwt = require('jsonwebtoken');

/**
 * Verify JWT token from Authorization header
 * Attaches decoded user data to req.user
 */
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({
            error: 'Authentication required',
            message: 'No token provided'
        });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            // Token expired or invalid
            return res.status(403).json({
                error: 'Invalid token',
                message: err.message,
                expired: err.name === 'TokenExpiredError'
            });
        }

        // Attach user data to request
        req.user = user;
        next();
    });
};

/**
 * Verify user is a student
 */
const requireStudent = (req, res, next) => {
    if (req.user.type !== 'student') {
        return res.status(403).json({
            error: 'Forbidden',
            message: 'Student access required'
        });
    }
    next();
};

/**
 * Verify user is a driver
 */
const requireDriver = (req, res, next) => {
    if (req.user.type !== 'driver') {
        return res.status(403).json({
            error: 'Forbidden',
            message: 'Driver access required'
        });
    }
    next();
};

/**
 * Verify user is an admin
 */
const requireAdmin = (req, res, next) => {
    if (req.user.type !== 'admin') {
        return res.status(403).json({
            error: 'Forbidden',
            message: 'Admin access required'
        });
    }
    next();
};

module.exports = {
    authenticateToken,
    requireStudent,
    requireDriver,
    requireAdmin,
};
