const router = require('express').Router();
const { protect } = require('../middleware/auth');
const { upload } = require('../config/cloudinary');
const {
    createListing,
    getListings,
    getListing,
    getMyListings,
    updateListingStatus,
} = require('../controllers/listing.controller');

// Public
router.get('/', getListings);
router.get('/my', protect, getMyListings);
router.get('/:id', getListing);

// Protected — multipart: photos[] + cert (optional)
router.post(
    '/',
    protect,
    upload.fields([
        { name: 'photos', maxCount: 10 },
        { name: 'cert', maxCount: 1 },
    ]),
    createListing
);
router.patch('/:id/status', protect, updateListingStatus);

module.exports = router;
