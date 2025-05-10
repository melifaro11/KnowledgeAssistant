import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/chat_event.dart';
import 'package:knowledge_assistant/bloc/states/chat_state.dart';

import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<DeleteHistory>(_onDeleteHistory);
    on<EditMessage>(_onEditMessage);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final history = await repository.getChatHistory(event.collectionId);
      emit(ChatLoaded(history));
    } catch (e) {
      emit(ChatError('History loading error: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final previousMessages =
        state is ChatLoaded ? (state as ChatLoaded).messages : [];
    emit(ChatLoading());

    try {
      final newMessage = await repository.askQuestion(
        collectionId: event.collectionId,
        question: event.question,
      );
      final updatedMessages = List<ChatMessage>.from(previousMessages)
        ..add(newMessage);
      emit(ChatLoaded(updatedMessages));
    } catch (e) {
      emit(ChatError('Error sending request: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = (state as ChatLoaded).messages;

    try {
      await repository.deleteMessage(
        collectionId: event.collectionId,
        messageId: event.messageId,
      );
      final updated = current.where((m) => m.id != event.messageId).toList();
      emit(ChatLoaded(updated));
    } catch (e) {
      emit(ChatError('Delete message error: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteHistory(
    DeleteHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await repository.deleteHistory(event.collectionId);
      emit(ChatLoaded([]));
    } catch (e) {
      emit(ChatError('Delete history error: ${e.toString()}'));
    }
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = (state as ChatLoaded).messages;

    try {
      final updatedMsg = await repository.updateMessage(
        collectionId: event.collectionId,
        messageId: event.messageId,
        question: event.question,
        answer: event.answer,
      );
      final updated =
          current.map((m) => m.id == updatedMsg.id ? updatedMsg : m).toList();
      emit(ChatLoaded(updated));
    } catch (e) {
      emit(ChatError('Update error: ${e.toString()}'));
    }
  }
}
