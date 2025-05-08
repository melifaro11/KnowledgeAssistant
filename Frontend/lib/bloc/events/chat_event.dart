abstract class ChatEvent {
  const ChatEvent();
}

class SendMessage extends ChatEvent {
  final String collectionId;
  final String question;

  const SendMessage({required this.collectionId, required this.question});
}

class LoadChatHistory extends ChatEvent {
  final String collectionId;

  const LoadChatHistory(this.collectionId);
}
