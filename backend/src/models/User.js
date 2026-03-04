const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
    {
        firebaseUid: { type: String, required: true, unique: true },
        phone: { type: String, required: true, unique: true },
        name: { type: String, default: '' },
        email: { type: String, default: '' },
        about: { type: String, default: '' },
        profilePicUrl: { type: String, default: '' },
        profileComplete: { type: Boolean, default: false },
    },
    { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
