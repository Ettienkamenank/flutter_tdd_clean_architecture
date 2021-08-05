import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/usecases/usecase.dart';
import 'package:flutter_tdd/core/util/input_converter.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group(
    'GetTriviaForConcreteNumber',
    () {
      // The event takes in a String
      final tNumberString = '1';
      // This is the successful output of the InputConverter
      final tNumberParsed = int.parse(tNumberString);
      // NumberTrivia instance is needed too, of course
      final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

      void setUpMockInputConverterSuccess() =>
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Right(tNumberParsed));

      // blocTest<NumberTriviaBloc, NumberTriviaState>(
      //   'should call the InputConverter to validate and convert the string to an unsigned integer',
      //   build: () {
      //     setUpMockInputConverterSuccess();
      //     return bloc;
      //   },
      //   act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString)),
      //   expect: () => [
      //     verify(mockInputConverter.stringToUnsignedInteger(tNumberString)),
      //   ],
      // );
      // test(
      //   'should call the InputConverter to validate and convert the string to an unsigned integer',
      //       () async {
      //     // arrange
      //     setUpMockInputConverterSuccess();
      //     // act
      //     bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
      //     await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      //     // assert
      //     verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      //   },
      // );

      // test(
      //   'should emit [Error] when the input is invalid',
      //       () async {
      //     // arrange
      //     when(mockInputConverter.stringToUnsignedInteger(any))
      //         .thenReturn(Left(InvalidInputFailure()));
      //     // assert later
      //     final expected = [
      //       // The initial state is always emitted first
      //       Empty(),
      //       Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      //     ];
      //     await expectLater(bloc.stream.first, emitsInOrder(expected));
      //     // act
      //     bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
      //   },
      // );

      blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Error] when the input is invalid',
        build: () {
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Left(InvalidInputFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString)),
        expect: () => [
          // Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        ],
      );

      test(
        'should get data from the concrete use case',
            () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
          await untilCalled(mockGetConcreteNumberTrivia(any));
          // assert
          verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
            () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
          // assert later
          final expected = [
            // Empty(),
            Loading(),
            Loaded(trivia: tNumberTrivia),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
            () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          // assert later
          final expected = [
            // Empty(),
            Loading(),
            Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
            () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          // assert later
          final expected = [
            // Empty(),
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc.stream, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
        },
      );

    },
  );

  // group('GetTriviaForRandomNumber', () {
  //   final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
  //
  //   test(
  //     'should get data from the random use case',
  //         () async {
  //       // arrange
  //       when(mockGetRandomNumberTrivia(any))
  //           .thenAnswer((_) async => Right(tNumberTrivia));
  //       // act
  //       bloc.add(GetTriviaForRandomNumber());
  //       await untilCalled(mockGetRandomNumberTrivia(any));
  //       // assert
  //       verify(mockGetRandomNumberTrivia(NoParams()));
  //     },
  //   );
  //
  //   test(
  //     'should emit [Loading, Loaded] when data is gotten successfully',
  //         () async {
  //       // arrange
  //       when(mockGetRandomNumberTrivia(any))
  //           .thenAnswer((_) async => Right(tNumberTrivia));
  //       // assert later
  //       final expected = [
  //         Empty(),
  //         Loading(),
  //         Loaded(trivia: tNumberTrivia),
  //       ];
  //       expectLater(bloc, emitsInOrder(expected));
  //       // act
  //       bloc.add(GetTriviaForRandomNumber());
  //     },
  //   );
  //
  //   test(
  //     'should emit [Loading, Error] when getting data fails',
  //         () async {
  //       // arrange
  //       when(mockGetRandomNumberTrivia(any))
  //           .thenAnswer((_) async => Left(ServerFailure()));
  //       // assert later
  //       final expected = [
  //         Empty(),
  //         Loading(),
  //         Error(message: SERVER_FAILURE_MESSAGE),
  //       ];
  //       expectLater(bloc, emitsInOrder(expected));
  //       // act
  //       bloc.add(GetTriviaForRandomNumber());
  //     },
  //   );
  //
  //   test(
  //     'should emit [Loading, Error] with a proper message for the error when getting data fails',
  //         () async {
  //       // arrange
  //       when(mockGetRandomNumberTrivia(any))
  //           .thenAnswer((_) async => Left(CacheFailure()));
  //       // assert later
  //       final expected = [
  //         Empty(),
  //         Loading(),
  //         Error(message: CACHE_FAILURE_MESSAGE),
  //       ];
  //       expectLater(bloc, emitsInOrder(expected));
  //       // act
  //       bloc.add(GetTriviaForRandomNumber());
  //     },
  //   );
  // });

}
