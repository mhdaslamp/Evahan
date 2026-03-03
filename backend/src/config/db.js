const mongoose = require('mongoose');
const dns = require('dns');

// Use Google DNS — ISP DNS often blocks MongoDB SRV record lookups
dns.setDefaultResultOrder('ipv4first');
dns.setServers(['8.8.8.8', '8.8.4.4', '1.1.1.1']);

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI, {
            serverSelectionTimeoutMS: 10000,
        });
        console.log(`✅ MongoDB connected: ${conn.connection.host}`);
    } catch (err) {
        console.error('❌ MongoDB connection error:', err.message);
        process.exit(1);
    }
};

module.exports = connectDB;
