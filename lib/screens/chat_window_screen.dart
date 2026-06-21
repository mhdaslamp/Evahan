import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatWindowScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String vehicleName;
  final String vehiclePrice;
  final String vehicleImageUrl;

  const ChatWindowScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
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

  List<dynamic> _messages = [];
  bool _isLoading = true;
  String? _myUserId;
  Function(dynamic)? _socketCallback;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    // 1. Get current logged-in user ID FIRST so alignment is correct on first render
    _myUserId = await ApiService.getMyUserId();

    // 2. Fetch past message history
    try {
      final res = await ApiService.getMessages(widget.chatId);
      if (mounted) {
        setState(() {
          _messages = res['messages'] ?? [];
          _isLoading = false;
        });
        // Jump instantly to bottom on load (no animation lag)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // 3. Connect to Socket and Join the Chat Room
    final token = await ApiService.getToken();
    if (token != null) {
      final socketService = SocketService();
      socketService.connect(token);
      socketService.joinChat(widget.chatId);
      socketService.activeChatId = widget.chatId;
      _socketCallback = (data) {
        if (mounted) {
          setState(() {
            final msgId = data['_id'];
            final text = data['text'] ?? '';
            final sender = data['sender'];
            final senderId = (sender is Map) ? sender['_id'] : sender;
            final isMe = senderId == _myUserId;

            if (isMe) {
              // Try to find the matching optimistic message to replace it
              final index = _messages.indexWhere((m) =>
                  m['isOptimistic'] == true && m['text'] == text);
              if (index != -1) {
                _messages[index] = data;
              } else {
                // Check duplicate by ID and append
                if (!_messages.any((m) => m['_id'] == msgId)) {
                  _messages.add(data);
                }
              }
            } else {
              // Check duplicate by ID and append
              if (!_messages.any((m) => m['_id'] == msgId)) {
                _messages.add(data);
              }
            }
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      };
      socketService.onNewMessage(_socketCallback!);
    }

    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Create optimistic message to show instantly in UI
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}';
    final tempMsg = {
      '_id': tempId,
      'sender': {'_id': _myUserId},
      'text': text,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'isRead': false,
      'isOptimistic': true,
    };

    setState(() {
      _messages.add(tempMsg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    SocketService().sendMessage(widget.chatId, text);
    _controller.clear();
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'pm' : 'am';
      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    if (_socketCallback != null) {
      SocketService().offNewMessage(_socketCallback!);
    }
    if (SocketService().activeChatId == widget.chatId) {
      SocketService().activeChatId = null;
    }
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                  : _buildMessageList(),
            ),
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
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),

          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.vehicleImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.vehicleImageUrl,
                    width: 42,
                    height: 38,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 42,
                      height: 38,
                      color: AppColors.cardBg,
                      child: const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 1.5),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 42,
                      height: 38,
                      color: AppColors.cardBg,
                      child: const Icon(Icons.person, color: AppColors.grey, size: 20),
                    ),
                  )
                : Container(
                    width: 42,
                    height: 38,
                    color: AppColors.cardBg,
                    child: const Icon(Icons.person, color: AppColors.grey, size: 20),
                  ),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Text(
              widget.otherUserName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Actions
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.phone, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
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
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Say hello to start the conversation!',
          style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index] as Map<String, dynamic>;
        final sender = message['sender'];
        final senderId = (sender is Map) ? sender['_id'] : sender;
        final isMe = senderId == _myUserId;
        final text = message['text'] ?? '';
        final timeStr = _formatTime(message['createdAt'] as String?);
        final isRead = message['isRead'] as bool? ?? false;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFDCF8C6) : const Color(0xFFBBDEFF),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        color: Colors.black45,
                        fontSize: 9,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message['isOptimistic'] == true
                            ? Icons.done
                            : Icons.done_all,
                        size: 13,
                        color: isRead ? Colors.blue : Colors.black45,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.attach_file_rounded, color: Colors.black54, size: 24),
          ),
          const SizedBox(width: 10),

          // Input field
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
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

          // Send button
          GestureDetector(
            onTap: _hasText ? _sendMessage : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _hasText
                  ? Container(
                      key: const ValueKey('send'),
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
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
