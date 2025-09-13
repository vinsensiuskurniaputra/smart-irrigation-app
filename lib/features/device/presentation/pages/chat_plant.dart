import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_plant_controller.dart';

class ChatPlantPage extends StatefulWidget {
  final String? title;
  const ChatPlantPage({Key? key, this.title}) : super(key: key);

  @override
  State<ChatPlantPage> createState() => _ChatPlantPageState();
}

class _ChatPlantPageState extends State<ChatPlantPage> {
  late final ChatPlantController controller;
  final _hasText = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatPlantController());
    controller.textController.addListener(_onTextChanged);
    _onTextChanged();
  }

  void _onTextChanged() {
    _hasText.value = controller.textController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    controller.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final argTitle = Get.arguments is Map ? (Get.arguments['title'] as String?) : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(argTitle ?? widget.title ?? 'Chat Plant'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final msgs = controller.messages;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final message = msgs[msgs.length - 1 - index];
                    return _MessageBubble(message: message);
                  },
                );
              }),
            ),

            const Divider(height: 1),

            // Input area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onSubmitted: (_) => controller.sendText(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final canSend = _hasText.value && !controller.isSending.value;
                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: canSend ? Theme.of(context).primaryColor : Colors.grey.shade400,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: canSend ? controller.sendText : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser ? Theme.of(context).primaryColor : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: EdgeInsets.only(left: isUser ? 40 : 0, right: isUser ? 0 : 40),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: align,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.time),
                        style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
