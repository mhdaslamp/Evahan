require('dotenv').config();
require('express-async-errors');

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const connectDB = require('./src/config/db');
const initSocket = require('./src/socket');

const authRoutes = require('./src/routes/auth.routes');
const listingRoutes = require('./src/routes/listing.routes');
const chatRoutes = require('./src/routes/chat.routes');

const app = express();
const server = http.createServer(app);

// ── Socket.io ──────────────────────────────────
const io = new Server(server, {
    cors: { origin: '*' },
});
initSocket(io);

// ── Middleware ─────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Routes ─────────────────────────────────────
app.get('/health', (_req, res) => res.json({ status: 'ok', ts: new Date().toISOString() }));
app.use('/api/auth', authRoutes);
app.use('/api/listings', listingRoutes);
app.use('/api/chats', chatRoutes);

// ── Global error handler ───────────────────────
app.use((err, _req, res, _next) => {
    console.error(err);
    const status = err.status || 500;
    const message = err.message || 'Internal server error';
    res.status(status).json({ message });
});

// ── Start ──────────────────────────────────────
const PORT = process.env.PORT || 5000;

connectDB().then(() => {
    server.listen(PORT, () => {
        console.log(`🚀 E Vahan server running on port ${PORT}`);
    });
});
