const router = require('express').Router();
const { login, updateProfile, getMe } = require('../controllers/auth.controller');
const { verifyFirebaseToken, protect } = require('../middleware/auth');
const { upload } = require('../config/cloudinary');

// Flutter sends Firebase ID token → we return our own JWT
router.post('/login', verifyFirebaseToken, login);

// Profile
router.get('/me', protect, getMe);
router.put('/profile', protect, upload.single('photo'), updateProfile);

module.exports = router;
