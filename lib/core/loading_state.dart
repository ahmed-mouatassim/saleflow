/// Loading State Enum
/// Represents the different states of async operations
enum LoadingState { initial, loading, success, error }

/// Result wrapper for async operations
/// Provides a clean way to handle success and error states
class Result<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  const Result._({this.data, this.errorMessage, required this.isSuccess});

  /// Create a success result
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  /// Create an error result
  factory Result.error(String message) {
    return Result._(errorMessage: message, isSuccess: false);
  }

  /// Execute a callback based on result state
  void when({
    required void Function(T data) success,
    required void Function(String error) error,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else {
      error(errorMessage ?? 'Unknown error');
    }
  }
}

/// Base Provider State Mixin
/// Provides common state management functionality
/// The implementing class should override these getters
mixin BaseProviderState {
  LoadingState get loadingState;
  String? get errorMessage;

  bool get isLoading => loadingState == LoadingState.loading;
  bool get hasError => loadingState == LoadingState.error;
  bool get isSuccess => loadingState == LoadingState.success;
}
