const cloudinary = require('cloudinary').v2;
const multer = require('multer');

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Use memory storage — files are streamed directly to Cloudinary
const upload = multer({ storage: multer.memoryStorage() });

/**
 * Upload a file buffer to Cloudinary.
 * @param {Buffer} buffer  - File buffer from multer memoryStorage
 * @param {string} folder  - Cloudinary folder name
 * @param {string} resourceType - 'image' | 'raw' (for PDF)
 */
const uploadToCloudinary = (buffer, folder, resourceType = 'image') => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
            { folder: `evahan/${folder}`, resource_type: resourceType },
            (error, result) => {
                if (error) reject(error);
                else resolve(result);
            }
        );
        stream.end(buffer);
    });
};

module.exports = { cloudinary, upload, uploadToCloudinary };
