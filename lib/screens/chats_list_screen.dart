import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/nav_helper.dart';
import 'chat_window_screen.dart';

final List<Map<String, String>> _dummyChats = List.generate(
  8,
  (_) => {
    'seller': 'Name of seller',
    'vehicle': 'EV Car Good Condition',
    'lastMessage': 'Hey, is that ok for you?',
    'time': '10:14 pm',
    'image': 'https://images.unsplash.com/photo-1552519507-da3b142148bb?w=200',
  },
);

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NavTab _currentTab = NavTab.chats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatList(), // Buying
                  _buildChatList(), // Selling
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.grey,
        tabs: const [
          Tab(text: 'Buying'),
          Tab(text: 'Selling'),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _dummyChats.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.borderColor,
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final chat = _dummyChats[index];
        return _ChatTile(chat: chat);
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, String> chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatWindowScreen(
            sellerName: chat['seller']!,
            vehicleName: chat['vehicle']!,
            vehiclePrice: '₹ 12,00,000',
            vehicleImageUrl: chat['image']!,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                chat['image']!,
                width: 58,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 58,
                  height: 52,
                  color: AppColors.cardBg,
                  child: const Icon(Icons.directions_car, color: AppColors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['seller']!,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat['vehicle']!,
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    chat['lastMessage']!,
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

            // Time + menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time']!,
                  style: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.more_vert, color: AppColors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
