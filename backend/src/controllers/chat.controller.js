const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Listing = require('../models/Listing');

/**
 * POST /api/chats
 * Start or get existing chat for a listing.
 * Body: { listingId }
 */
const getOrCreateChat = async (req, res) => {
    const { listingId } = req.body;
    const buyerId = req.user._id;

    const listing = await Listing.findById(listingId).populate('seller', '_id name');
    if (!listing) return res.status(404).json({ message: 'Listing not found' });

    if (listing.seller._id.toString() === buyerId.toString()) {
        return res.status(400).json({ message: 'You cannot chat about your own listing' });
    }

    // Upsert chat — one per (listing, buyer) pair
    let chat = await Chat.findOne({ listing: listingId, buyer: buyerId });
    if (!chat) {
        chat = await Chat.create({
            listing: listingId,
            buyer: buyerId,
            seller: listing.seller._id,
            listingTitle: listing.adTitle,
            listingPrice: listing.price,
            listingThumbnail: listing.photoUrls[0] || '',
        });
    }

    res.json({ chat });
};

/**
 * GET /api/chats
 * All chats for the current user — split by role.
 * ?role=buyer  → Buying tab
 * ?role=seller → Selling tab
 */
const getUserChats = async (req, res) => {
    const { role = 'buyer' } = req.query;
    const filter = role === 'seller' ? { seller: req.user._id } : { buyer: req.user._id };

    const chats = await Chat.find(filter)
        .sort({ lastMessageTime: -1 })
        .populate('buyer', 'name phone profilePicUrl')
        .populate('seller', 'name phone profilePicUrl')
        .populate('listing', 'adTitle price photoUrls');

    res.json({ chats });
};

/**
 * GET /api/chats/:chatId/messages
 * Fetch message history for a chat (paginated).
 */
const getMessages = async (req, res) => {
    const { page = 1, limit = 50 } = req.query;
    const messages = await Message.find({ chat: req.params.chatId })
        .sort({ createdAt: 1 })
        .skip((page - 1) * limit)
        .limit(Number(limit))
        .populate('sender', 'name profilePicUrl');

    // Mark as read
    await Message.updateMany(
        { chat: req.params.chatId, sender: { $ne: req.user._id }, isRead: false },
        { isRead: true }
    );

    res.json({ messages });
};

/**
 * POST /api/chats/:chatId/messages
 * Send a message (HTTP fallback — Socket.io is primary).
 */
const sendMessage = async (req, res) => {
    const { text } = req.body;
    if (!text?.trim()) return res.status(400).json({ message: 'Message text required' });

    const message = await Message.create({
        chat: req.params.chatId,
        sender: req.user._id,
        text: text.trim(),
    });

    // Update chat's last message snapshot
    await Chat.findByIdAndUpdate(req.params.chatId, {
        lastMessage: text.trim(),
        lastMessageTime: new Date(),
    });

    const populated = await message.populate('sender', 'name profilePicUrl');
    res.status(201).json({ message: populated });
};

module.exports = { getOrCreateChat, getUserChats, getMessages, sendMessage };
