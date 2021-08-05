class NumberTriviaEvent {}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;

  GetTriviaForConcreteNumber({required this.numberString});
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}