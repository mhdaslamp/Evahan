import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isSent;
  final String time;
  bool isRead;

  ChatMessage({
    required this.text,
    required this.isSent,
    required this.time,
    this.isRead = true,
  });
}

class ChatWindowScreen extends StatefulWidget {
  final String sellerName;
  final String vehicleName;
  final String vehiclePrice;
  final String vehicleImageUrl;

  const ChatWindowScreen({
    super.key,
    required this.sellerName,
    required this.vehicleName,
    required this.vehiclePrice,
    required this.vehicleImageUrl,
  });

  @override
  State<ChatWindowScreen> createState() => _ChatWindowScreenState();
}

class _ChatWindowScreenState extends State<ChatWindowScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  final List<ChatMessage> _messages = [
    ChatMessage(text: 'available ?', isSent: true, time: '1:59 pm'),
    ChatMessage(text: 'available ?', isSent: true, time: '1:59 pm'),
    ChatMessage(text: 'available ?', isSent: true, time: '1:59 pm'),
    ChatMessage(text: 'available ?', isSent: true, time: '1:59 pm'),
    ChatMessage(text: 'available ?', isSent: true, time: '1:59 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
    ChatMessage(text: 'available ?', isSent: false, time: '1:58 pm'),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'am' : 'pm';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _messages.add(ChatMessage(text: text, isSent: true, time: timeStr));
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildVehicleSubheader(),
            Expanded(child: _buildMessageList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),

          // Seller avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.vehicleImageUrl,
              width: 42,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 42,
                height: 38,
                color: AppColors.cardBg,
                child: const Icon(Icons.person, color: AppColors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Seller name
          Expanded(
            child: Text(
              widget.sellerName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Phone
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.phone, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // More
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSubheader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.vehicleName,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            widget.vehiclePrice,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _messages.length + 1, // +1 for date header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Today',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }
        final message = _messages[index - 1];
        return _MessageBubble(message: message);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Attachment
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.attach_file_rounded, color: Colors.black54, size: 24),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),

          // Send or Mic
          GestureDetector(
            onTap: _hasText ? _sendMessage : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? Container(
                      key: const ValueKey('send'),
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                    )
                  : const Icon(
                      key: ValueKey('mic'),
                      Icons.mic_none_rounded,
                      color: Colors.black54,
                      size: 26,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFFDCF8C6) : const Color(0xFFBBDEFF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isSent ? 14 : 4),
            bottomRight: Radius.circular(isSent ? 4 : 14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontSize: 10,
                  ),
                ),
                if (isSent) ...[
                  const SizedBox(width: 3),
                  Icon(
                    Icons.done_all,
                    size: 13,
                    color: message.isRead ? Colors.blue : Colors.black45,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
