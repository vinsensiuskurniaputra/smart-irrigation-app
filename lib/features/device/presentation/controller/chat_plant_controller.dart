
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_irrigation_app/service_locator.dart';
import 'package:smart_irrigation_app/features/device/data/services/chat_api_service.dart';

class ChatMessage {
	final String id;
	final String text;
	final bool fromUser;
	final DateTime time;

	ChatMessage({
		required this.id,
		required this.text,
		required this.fromUser,
		required this.time,
	});
}

class ChatPlantController extends GetxController {
	// Reactive list of messages
	final messages = <ChatMessage>[].obs;

	// Text controller for the input field
	final TextEditingController textController = TextEditingController();

	// Simple sending flag
	final isSending = false.obs;

	final ChatApiService _api = sl<ChatApiService>();

	// Send a text message only (no files). Ignores empty/whitespace messages.
	Future<void> sendText() async {
		final raw = textController.text;
		final text = raw.trim();
		if (text.isEmpty) return;

		isSending.value = true;

		final userMsg = ChatMessage(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			text: text,
			fromUser: true,
			time: DateTime.now(),
		);

		messages.add(userMsg);
		textController.clear();

		try {
			final resp = await _api.sendMessage(text);
			// Expecting response like: { "response": "..." }
			final data = resp.data;
			String botText = '';
			if (data is Map && data['response'] != null) {
				botText = data['response'].toString();
			} else if (data is String) {
				botText = data;
			}

			final botMsg = ChatMessage(
				id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
				text: botText,
				fromUser: false,
				time: DateTime.now(),
			);

			messages.add(botMsg);
		} catch (e) {
			final errorMsg = ChatMessage(
				id: DateTime.now().millisecondsSinceEpoch.toString() + '_err',
				text: 'Failed to send message. Please try again.',
				fromUser: false,
				time: DateTime.now(),
			);
			messages.add(errorMsg);
		} finally {
			isSending.value = false;
		}
	}

	@override
	void onClose() {
		textController.dispose();
		super.onClose();
	}
}
