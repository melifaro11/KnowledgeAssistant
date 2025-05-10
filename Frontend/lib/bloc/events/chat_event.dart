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

class DeleteMessage extends ChatEvent {
  final String collectionId;
  final String messageId;

  DeleteMessage({required this.collectionId, required this.messageId});
}

class DeleteHistory extends ChatEvent {
  final String collectionId;

  DeleteHistory(this.collectionId);
}

class EditMessage extends ChatEvent {
  final String collectionId;
  final String messageId;
  final String question;
  final String answer;

  EditMessage({
    required this.collectionId,
    required this.messageId,
    required this.question,
    required this.answer,
  });
}
