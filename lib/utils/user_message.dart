// lib/utils/user_message.dart (or similar location)
enum MessageType { success, error, warning, info }
enum StatusType { success, error, warning, info }

class UserMessage {
  final String text;
  final MessageType type;

  UserMessage(this.text, {this.type = MessageType.info});
}