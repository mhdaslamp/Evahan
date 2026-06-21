const Message = require('../models/Message');
const Chat = require('../models/Chat');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Authenticate socket connections using our JWT.
 */
const authenticateSocket = async (socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('Authentication error'));

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id).select('_id name');
        if (!user) return next(new Error('User not found'));
        socket.user = user;
        next();
    } catch {
        next(new Error('Invalid token'));
    }
};

const initSocket = (io) => {
    io.use(authenticateSocket);

    io.on('connection', (socket) => {
        console.log(`🔌 Socket connected: ${socket.user._id}`);

        // Client joins a chat room
        socket.on('join_chat', (chatId) => {
            socket.join(chatId);
        });

        // Client sends a message
        socket.on('send_message', async ({ chatId, text }) => {
            if (!text?.trim()) return;

            try {
                // Check if both users are actively in the chat room
                const room = io.sockets.adapter.rooms.get(chatId);
                const isRead = room && room.size > 1;

                const message = await Message.create({
                    chat: chatId,
                    sender: socket.user._id,
                    text: text.trim(),
                    isRead: isRead ? true : false,
                });

                await Chat.findByIdAndUpdate(chatId, {
                    lastMessage: text.trim(),
                    lastMessageTime: new Date(),
                });

                const populated = await message.populate('sender', 'name profilePicUrl');

                // Broadcast to everyone in the chat room (including sender)
                io.to(chatId).emit('new_message', populated);
            } catch (err) {
                socket.emit('error', { message: 'Failed to send message' });
            }
        });

        socket.on('disconnect', () => {
            console.log(`🔌 Socket disconnected: ${socket.user._id}`);
        });
    });
};

module.exports = initSocket;
