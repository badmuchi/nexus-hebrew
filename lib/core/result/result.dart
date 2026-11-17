import 'package:equatable/equatable.dart';

import '../error/failures.dart';

sealed class Result<S, F extends Failure> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isError => this is Error<S, F>;

  S? getOrNull() => switch (this) {
        Success<S, F>(:final data) => data,
        Error<S, F>() => null,
      };

  F? failureOrNull() => switch (this) {
        Success<S, F>() => null,
        Error<S, F>(:final failure) => failure,
      };

  R fold<R>(R Function(F failure) onFailure, R Function(S data) onSuccess);

  Result<T, F> map<T>(T Function(S data) transform) => switch (this) {
        Success<S, F>(:final data) => Success<T, F>(transform(data)),
        Error<S, F>(:final failure) => Error<T, F>(failure),
      };

  Future<Result<T, F>> flatMapAsync<T>(
    Future<Result<T, F>> Function(S data) transform,
  ) async =>
      switch (this) {
        Success<S, F>(:final data) => await transform(data),
        Error<S, F>(:final failure) => Error<T, F>(failure),
      };
}

final class Success<S, F extends Failure> extends Result<S, F> {
  final S data;

  const Success(this.data);

  @override
  R fold<R>(R Function(F failure) onFailure, R Function(S data) onSuccess) {
    return onSuccess(data);
  }

  @override
  List<Object?> get props => [data];
}

final class Error<S, F extends Failure> extends Result<S, F> {
  final F failure;

  const Error(this.failure);

  @override
  R fold<R>(R Function(F failure) onFailure, R Function(S data) onSuccess) {
    return onFailure(failure);
  }

  @override
  List<Object?> get props => [failure];
}
