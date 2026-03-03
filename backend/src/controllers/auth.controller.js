const jwt = require('jsonwebtoken');
const User = require('../models/User');

const signToken = (id) =>
    jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '30d' });

/**
 * POST /api/auth/login
 * Called after Flutter OTP verification succeeds.
 * Body: none — Firebase token is in Authorization header.
 * Returns: { token, user }
 */
const login = async (req, res) => {
    const { uid, phone_number: phone } = req.firebaseUser;

    // Upsert user — create if first login, return existing if not
    let user = await User.findOne({ firebaseUid: uid });

    if (!user) {
        user = await User.create({ firebaseUid: uid, phone });
    }

    const token = signToken(user._id);

    res.json({
        token,
        user: {
            id: user._id,
            phone: user.phone,
            name: user.name,
            profilePicUrl: user.profilePicUrl,
            profileComplete: user.profileComplete,
        },
    });
};

/**
 * PUT /api/auth/profile
 * Update the logged-in user's name / profile pic.
 */
const updateProfile = async (req, res) => {
    const { name } = req.body;
    const update = { profileComplete: true };
    if (name) update.name = name;

    const user = await User.findByIdAndUpdate(req.user._id, update, { new: true });
    res.json({ user });
};

/**
 * GET /api/auth/me
 * Returns the current user profile.
 */
const getMe = async (req, res) => {
    res.json({ user: req.user });
};

module.exports = { login, updateProfile, getMe };
