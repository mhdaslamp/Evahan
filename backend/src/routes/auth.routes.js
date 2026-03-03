const router = require('express').Router();
const { login, updateProfile, getMe } = require('../controllers/auth.controller');
const { verifyFirebaseToken, protect } = require('../middleware/auth');

// Flutter sends Firebase ID token → we return our own JWT
router.post('/login', verifyFirebaseToken, login);

// Profile
router.get('/me', protect, getMe);
router.put('/profile', protect, updateProfile);

module.exports = router;
