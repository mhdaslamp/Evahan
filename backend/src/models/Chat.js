const mongoose = require('mongoose');

// A chat thread between a buyer and a seller about a specific listing
const chatSchema = new mongoose.Schema(
    {
        listing: { type: mongoose.Schema.Types.ObjectId, ref: 'Listing', required: true },
        buyer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
        seller: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
        lastMessage: { type: String, default: '' },
        lastMessageTime: { type: Date, default: Date.now },
        // Denormalised snapshot so chat list doesn't need extra joins
        listingTitle: { type: String, default: '' },
        listingPrice: { type: Number, default: 0 },
        listingThumbnail: { type: String, default: '' },
    },
    { timestamps: true }
);

// Ensure one chat per (listing, buyer) pair
chatSchema.index({ listing: 1, buyer: 1 }, { unique: true });

module.exports = mongoose.model('Chat', chatSchema);
