import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';
import 'notification_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  String? _connectedToken;
  String? activeChatId;

  final List<Function(dynamic)> _messageCallbacks = [];
  bool _globalListenerRegistered = false;

  void connect(String token) {
    // If already connected with the SAME token, do nothing.
    if (socket != null && socket!.connected && _connectedToken == token) return;

    // Disconnect previous socket (different user or stale connection).
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      _globalListenerRegistered = false;
    }

    _connectedToken = token;
    socket = IO.io(
      'https://evahan.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('⚡ Socket connected successfully');
      _setupMessageListener();
    });

    socket!.onDisconnect((_) {
      print('⚡ Socket disconnected');
      _globalListenerRegistered = false;
    });

    socket!.onConnectError((data) {
      print('⚡ Socket connection error: $data');
    });
  }

  void _setupMessageListener() {
    if (_globalListenerRegistered) return;
    if (socket != null) {
      socket!.on('new_message', (data) {
        // Trigger all registered callbacks (e.g. Chat window, Chat list update)
        final callbacks = List<Function(dynamic)>.from(_messageCallbacks);
        for (final cb in callbacks) {
          try {
            cb(data);
          } catch (e) {
            print('Error in message callback: $e');
          }
        }
        // Show push notification
        _showNotificationIfNeeded(data);
      });
      _globalListenerRegistered = true;
    }
  }

  Future<void> _showNotificationIfNeeded(dynamic data) async {
    try {
      final text = data['text'] ?? '';
      final sender = data['sender'];
      final senderId = (sender is Map) ? sender['_id'] : sender;
      final senderName = (sender is Map) ? (sender['name'] ?? 'Someone') : 'Someone';
      final chatId = data['chat'] ?? '';

      final myUserId = await ApiService.getMyUserId();

      // Don't notify if message is from ourselves
      if (senderId == myUserId) return;
      // Don't notify if user is actively in the chat window of this chatId
      if (activeChatId == chatId) return;

      // Trigger local notification
      await NotificationService().showNotification(
        id: chatId.hashCode,
        title: senderName,
        body: text,
      );
    } catch (e) {
      print('Error displaying message notification: $e');
    }
  }

  void joinChat(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_chat', chatId);
    }
  }

  void sendMessage(String chatId, String text) {
    if (socket != null && socket!.connected) {
      socket!.emit('send_message', {
        'chatId': chatId,
        'text': text,
      });
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (!_messageCallbacks.contains(callback)) {
      _messageCallbacks.add(callback);
    }
    // Set up the listener immediately if connected
    if (socket != null && socket!.connected) {
      _setupMessageListener();
    }
  }

  void offNewMessage(Function(dynamic) callback) {
    _messageCallbacks.remove(callback);
  }

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
    _connectedToken = null;
    _messageCallbacks.clear();
    _globalListenerRegistered = false;
    activeChatId = null;
  }
}
