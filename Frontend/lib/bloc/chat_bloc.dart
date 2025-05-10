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
}
