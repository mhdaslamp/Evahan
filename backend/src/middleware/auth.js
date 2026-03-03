const jwt = require('jsonwebtoken');
const admin = require('../config/firebase');
const User = require('../models/User');

/**
 * Middleware 1 — verifyFirebaseToken
 * Used only on POST /api/auth/login
 * Validates the Firebase ID token sent by the Flutter app after OTP
 * and exchanges it for our own JWT.
 */
const verifyFirebaseToken = async (req, res, next) => {
    const idToken = req.headers.authorization?.replace('Bearer ', '');
    if (!idToken) return res.status(401).json({ message: 'No Firebase token provided' });

    try {
        const decoded = await admin.auth().verifyIdToken(idToken);
        req.firebaseUser = decoded; // { uid, phone_number, ... }
        next();
    } catch (err) {
        console.error('Firebase token error:', err.message);
        return res.status(401).json({ message: 'Invalid or expired Firebase token' });
    }
};

/**
 * Middleware 2 — protect
 * Used on all other protected routes.
 * Validates our own JWT issued after login.
 */
const protect = async (req, res, next) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) return res.status(401).json({ message: 'Not authorised — no token' });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id).select('-__v');
        if (!user) return res.status(401).json({ message: 'User not found' });
        req.user = user;
        next();
    } catch (err) {
        return res.status(401).json({ message: 'Invalid or expired token' });
    }
};

module.exports = { verifyFirebaseToken, protect };
