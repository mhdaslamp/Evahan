const Listing = require('../models/Listing');
const { uploadToCloudinary } = require('../config/cloudinary');

/**
 * POST /api/listings
 * Body: multipart/form-data
 * Fields: category, brand, model, year, transmission, location, kmDriven, noOfOwners, adTitle, price
 * Files:  photos (up to 10 images), cert (1 PDF or image)
 */
const createListing = async (req, res) => {
    const { category, brand, model, year, transmission, location, kmDriven, noOfOwners, adTitle, price } = req.body;

    const photoFiles = req.files?.photos || [];
    console.log(`📸 Photos received: ${photoFiles.length}`);

    const photoUrls = await Promise.all(
        photoFiles.map((f) => uploadToCloudinary(f.buffer, 'listings', 'image').then((r) => {
            console.log(`✅ Photo uploaded to Cloudinary: ${r.secure_url}`);
            return r.secure_url;
        }))
    );

    const certFile = req.files?.cert?.[0];
    let batteryCertUrl = '';
    if (certFile) {
        const resourceType = certFile.mimetype === 'application/pdf' ? 'raw' : 'image';
        const result = await uploadToCloudinary(certFile.buffer, 'certificates', resourceType);
        batteryCertUrl = result.secure_url;
    }

    const listing = await Listing.create({
        seller: req.user._id,
        category, brand, model, year, transmission, location,
        kmDriven: Number(kmDriven),
        noOfOwners: noOfOwners ? Number(noOfOwners) : 1,
        adTitle,
        price: Number(price),
        photoUrls,
        batteryCertUrl,
    });

    console.log(`✅ Listing saved | id: ${listing._id} | photos: ${photoUrls.length}`);
    res.status(201).json({ listing });
};

/**
 * GET /api/listings
 * Public feed. Supports ?category=Cars and ?search=tata
 */
const getListings = async (req, res) => {
    const { category, search, page = 1, limit = 20 } = req.query;
    const query = { status: 'active' };

    if (category) query.category = category;
    if (search) query.$text = { $search: search };

    const listings = await Listing.find(query)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(Number(limit))
        .populate('seller', 'name phone profilePicUrl');

    const total = await Listing.countDocuments(query);
    res.json({ listings, total, page: Number(page) });
};

/**
 * GET /api/listings/:id
 * Single listing detail.
 */
const getListing = async (req, res) => {
    const listing = await Listing.findById(req.params.id).populate('seller', 'name phone profilePicUrl');
    if (!listing || listing.status === 'deleted') return res.status(404).json({ message: 'Listing not found' });
    res.json({ listing });
};

/**
 * GET /api/listings/my
 * Current user's own listings (My Ads screen).
 */
const getMyListings = async (req, res) => {
    const listings = await Listing.find({ seller: req.user._id, status: { $ne: 'deleted' } }).sort({ createdAt: -1 });
    res.json({ listings });
};

/**
 * PATCH /api/listings/:id/status
 * Mark as sold or delete. Only the owner can do this.
 */
const updateListingStatus = async (req, res) => {
    const { status } = req.body; // 'sold' | 'deleted' | 'active'
    const listing = await Listing.findOne({ _id: req.params.id, seller: req.user._id });
    if (!listing) return res.status(404).json({ message: 'Listing not found or not yours' });
    listing.status = status;
    await listing.save();
    res.json({ listing });
};

module.exports = { createListing, getListings, getListing, getMyListings, updateListingStatus };
