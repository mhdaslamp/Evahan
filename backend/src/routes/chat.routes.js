const router = require('express').Router();
const { protect } = require('../middleware/auth');
const { getOrCreateChat, getUserChats, getMessages, sendMessage } = require('../controllers/chat.controller');

// All chat routes require auth
router.use(protect);

router.post('/', getOrCreateChat);                             // Start/get chat
router.get('/', getUserChats);                                 // ?role=buyer|seller
router.get('/:chatId/messages', getMessages);                  // Message history
router.post('/:chatId/messages', sendMessage);                 // HTTP fallback

module.exports = router;
