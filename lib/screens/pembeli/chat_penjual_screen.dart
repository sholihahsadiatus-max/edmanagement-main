import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPenjualScreen extends StatefulWidget {
  final String sellerId;
  final String namaPenjual;

  const ChatPenjualScreen({
    super.key,
    required this.sellerId,
    required this.namaPenjual,
  });

  @override
  State<ChatPenjualScreen> createState() => _ChatPenjualScreenState();
}

class _ChatPenjualScreenState extends State<ChatPenjualScreen> {
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();
  final Color primaryColor = const Color(0xFF006B42);

  String? chatId;
  String? errorMessage;
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      if (user.id == widget.sellerId) {
        throw Exception(
          'Penjual tidak dapat mengirim chat ke dirinya sendiri.',
        );
      }

      final existing = await supabase
          .from('chats')
          .select('id')
          .eq('buyer_id', user.id)
          .eq('seller_id', widget.sellerId)
          .maybeSingle();

      String id;

      if (existing != null) {
        id = existing['id'].toString();
      } else {
        final created = await supabase
            .from('chats')
            .insert({'buyer_id': user.id, 'seller_id': widget.sellerId})
            .select('id')
            .single();

        id = created['id'].toString();
      }

      if (!mounted) return;

      setState(() {
        chatId = id;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    final user = supabase.auth.currentUser;
    final id = chatId;

    if (text.isEmpty || user == null || id == null || sending) {
      return;
    }

    setState(() => sending = true);

    try {
      await supabase.from('messages').insert({
        'chat_id': id,
        'sender_id': user.id,
        'message': text,
      });

      controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pesan gagal dikirim: $e')));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(widget.namaPenjual),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Tidak dapat membuka chat.\n$errorMessage',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase
                        .from('messages')
                        .stream(primaryKey: ['id'])
                        .eq('chat_id', chatId!)
                        .order('created_at'),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Gagal memuat pesan: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data ?? [];
                      final currentUserId = supabase.auth.currentUser?.id;

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('Mulai percakapan dengan penjual.'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine = message['sender_id'] == currentUserId;

                          return Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMine ? primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                message['message']?.toString() ?? '',
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tulis pesan...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: sending ? null : _sendMessage,
                          icon: const Icon(Icons.send),
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
