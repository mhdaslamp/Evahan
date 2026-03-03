const mongoose = require('mongoose');

const listingSchema = new mongoose.Schema(
    {
        seller: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
        category: { type: String, required: true, enum: ['Cars', 'Bikes', 'Scooters', 'Bicycles', 'Rickshaw'] },
        brand: { type: String, required: true },
        model: { type: String, required: true },
        year: { type: String, required: true },
        transmission: { type: String, enum: ['Automatic', 'Manual'], default: 'Automatic' },
        location: { type: String, default: '' },
        kmDriven: { type: Number, required: true },
        noOfOwners: { type: Number, default: 1 },
        adTitle: { type: String, required: true },
        price: { type: Number, required: true },
        photoUrls: [{ type: String }],          // Cloudinary image URLs
        batteryCertUrl: { type: String, default: '' }, // Cloudinary PDF/image URL
        status: { type: String, enum: ['active', 'sold', 'deleted'], default: 'active' },
    },
    { timestamps: true }
);

// Text index for search
listingSchema.index({ adTitle: 'text', brand: 'text', model: 'text', category: 'text', location: 'text' });

module.exports = mongoose.model('Listing', listingSchema);
