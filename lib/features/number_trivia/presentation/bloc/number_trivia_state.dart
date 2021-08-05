import 'package:equatable/equatable.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaState extends Equatable {
  @override
  List<Object?> get props => [];
}

// class NumberTriviaInitial extends NumberTriviaState {}

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  Loaded({required this.trivia});
}

class Error extends NumberTriviaState {
  final String message;

  Error({required this.message});
}
