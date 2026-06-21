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
    try {
        const { uid, phone_number, email, name, picture } = req.firebaseUser;

        // Google Sign-In users won't have phone_number — use a unique placeholder
        const phone = phone_number || `google_${uid}`;
        // Upsert user — create if first login, return existing if not
        let user = await User.findOne({ firebaseUid: uid });

        if (!user) {
            try {
                user = await User.create({
                    firebaseUid: uid,
                    phone,
                    email: email || '',
                    name: name || '',
                    profilePicUrl: picture || '',
                });
                console.log(`✅ New user created: ${email || phone} (uid: ${uid})`);
            } catch (err) {
                console.error('❌ User creation failed:', err.message);
                throw err;
            }
        } else {
            // Update name/email/photo from Google if they were empty before
            let updated = false;
            if (!user.name && name) { user.name = name; updated = true; }
            if (!user.email && email) { user.email = email; updated = true; }
            if (!user.profilePicUrl && picture) { user.profilePicUrl = picture; updated = true; }
            if (updated) await user.save();
            console.log(`👤 Existing user logged in: ${email || phone}`);
        }

        const token = signToken(user._id);

        res.json({
            token,
            user: {
                id: user._id,
                phone: user.phone,
                name: user.name,
                email: user.email,
                profilePicUrl: user.profilePicUrl,
                profileComplete: user.profileComplete,
            },
        });
    } catch (err) {
        console.error('❌ Login error:', err.message, err.code || '');
        // Duplicate key — user already exists with this phone/uid, try to fetch
        if (err.code === 11000) {
            const { uid } = req.firebaseUser;
            const user = await User.findOne({ firebaseUid: uid });
            if (user) {
                const token = signToken(user._id);
                return res.json({
                    token,
                    user: {
                        id: user._id,
                        phone: user.phone,
                        name: user.name,
                        email: user.email,
                        profilePicUrl: user.profilePicUrl,
                        profileComplete: user.profileComplete,
                    },
                });
            }
        }
        res.status(500).json({ message: err.message || 'Login failed' });
    }
};

const updateProfile = async (req, res) => {
    const { name, email, about } = req.body;
    const update = { profileComplete: true };
    if (name !== undefined) update.name = name;
    if (email !== undefined) update.email = email;
    if (about !== undefined) update.about = about;

    if (req.file) {
        try {
            const { uploadToCloudinary } = require('../config/cloudinary');
            const result = await uploadToCloudinary(req.file.buffer, 'profiles', 'image');
            update.profilePicUrl = result.secure_url;
            console.log(`✅ Profile pic uploaded: ${result.secure_url}`);
        } catch (err) {
            console.error('❌ Failed to upload profile pic:', err);
        }
    }

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
