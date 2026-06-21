import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/nav_helper.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'chat_window_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NavTab _currentTab = NavTab.chats;

  List<dynamic> _buyingChats = [];
  List<dynamic> _sellingChats = [];
  bool _isLoading = true;
  String? _error;

  Function(dynamic)? _socketCallback;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCachedChats();
    _fetchChats();
    _setupSocket();
  }

  Future<void> _setupSocket() async {
    final token = await ApiService.getToken();
    if (token != null) {
      final socketService = SocketService();
      socketService.connect(token);
      _socketCallback = (_) {
        if (mounted) {
          _fetchChats();
        }
      };
      socketService.onNewMessage(_socketCallback!);
    }
  }

  Future<void> _loadCachedChats() async {
    final cachedBuying = await ApiService.getCachedUserChats('buyer');
    final cachedSelling = await ApiService.getCachedUserChats('seller');
    if (mounted && _buyingChats.isEmpty && _sellingChats.isEmpty) {
      setState(() {
        _buyingChats = cachedBuying?['chats'] ?? [];
        _sellingChats = cachedSelling?['chats'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchChats() async {
    if (_buyingChats.isEmpty && _sellingChats.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final buyingRes = await ApiService.getUserChats('buyer');
      final sellingRes = await ApiService.getUserChats('seller');

      if (mounted) {
        setState(() {
          _buyingChats = buyingRes['chats'] ?? [];
          _sellingChats = sellingRes['chats'] ?? [];
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && _buyingChats.isEmpty && _sellingChats.isEmpty) {
        setState(() {
          _error = 'Could not load chats.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_socketCallback != null) {
      SocketService().offNewMessage(_socketCallback!);
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, color: AppColors.grey, size: 40),
                              const SizedBox(height: 12),
                              Text(_error!, style: GoogleFonts.poppins(color: AppColors.grey)),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _fetchChats,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.green,
                                  side: const BorderSide(color: AppColors.green),
                                ),
                                child: Text('Retry', style: GoogleFonts.poppins()),
                              )
                            ],
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildChatList(_buyingChats, isBuyerTab: true),
                            _buildChatList(_sellingChats, isBuyerTab: false),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: _currentTab,
        onTap: (tab) => handleNavTap(context, tab, _currentTab),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            'Chats',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final totalBuyingUnread = _buyingChats.fold<int>(0, (sum, chat) => sum + ((chat['unreadCount'] as num?)?.toInt() ?? 0));
    final totalSellingUnread = _sellingChats.fold<int>(0, (sum, chat) => sum + ((chat['unreadCount'] as num?)?.toInt() ?? 0));

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            bottom: BorderSide(color: AppColors.green, width: 2.5),
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelColor: AppColors.grey,
        tabs: [
          Tab(text: totalBuyingUnread > 0 ? 'Buying ($totalBuyingUnread)' : 'Buying'),
          Tab(text: totalSellingUnread > 0 ? 'Selling ($totalSellingUnread)' : 'Selling'),
        ],
      ),
    );
  }

  Widget _buildChatList(List<dynamic> chats, {required bool isBuyerTab}) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.grey, size: 48),
            const SizedBox(height: 12),
            Text(
              isBuyerTab
                  ? "You haven't messaged any sellers yet"
                  : "No buyers have messaged you yet",
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchChats,
      color: AppColors.green,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: chats.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.borderColor,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index] as Map<String, dynamic>;
          return _ChatTile(chat: chat, isBuyerTab: isBuyerTab);
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final bool isBuyerTab;

  const _ChatTile({
    required this.chat,
    required this.isBuyerTab,
  });

  String _formatLastTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'pm' : 'am';
        return '$hour:$minute $period';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = isBuyerTab
        ? chat['seller'] as Map<String, dynamic>?
        : chat['buyer'] as Map<String, dynamic>?;

    final otherUserName = otherUser?['name'] as String? ?? (isBuyerTab ? 'Seller' : 'Buyer');
    final otherUserPic = otherUser?['profilePicUrl'] as String? ?? '';

    final listing = chat['listing'] as Map<String, dynamic>?;
    final String vehicleName = (chat['listingTitle'] ?? listing?['adTitle'] ?? 'EV Car').toString();
    final vehiclePrice = '₹ ${chat['listingPrice'] ?? listing?['price'] ?? '--'}';
    final String vehicleImageUrl = (chat['listingThumbnail'] ??
        (listing?['photoUrls'] != null && (listing!['photoUrls'] as List).isNotEmpty
            ? listing['photoUrls'][0]
            : '')).toString();

    final lastMessage = chat['lastMessage'] as String? ?? 'No messages yet';
    final timeStr = _formatLastTime(chat['lastMessageTime'] as String?);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatWindowScreen(
              chatId: chat['_id'] as String,
              otherUserName: otherUserName,
              vehicleName: vehicleName,
              vehiclePrice: vehiclePrice,
              vehicleImageUrl: vehicleImageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // User/Listing Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (vehicleImageUrl.isNotEmpty || otherUserPic.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: vehicleImageUrl.isNotEmpty ? vehicleImageUrl : otherUserPic,
                      width: 58,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 58,
                        height: 52,
                        color: AppColors.cardBg,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 1.5),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 58,
                        height: 52,
                        color: AppColors.cardBg,
                        child: const Icon(Icons.directions_car, color: AppColors.grey),
                      ),
                    )
                  : Container(
                      width: 58,
                      height: 52,
                      color: AppColors.cardBg,
                      child: const Icon(Icons.directions_car, color: AppColors.grey),
                    ),
            ),

            const SizedBox(width: 12),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicleName,
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color: (chat['unreadCount'] ?? 0) > 0 ? AppColors.green : AppColors.grey,
                    fontSize: 11,
                    fontWeight: (chat['unreadCount'] ?? 0) > 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((chat['unreadCount'] ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '${chat['unreadCount']}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.more_vert, color: AppColors.grey, size: 18),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
