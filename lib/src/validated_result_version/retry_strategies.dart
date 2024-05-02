sealed class RetryStrategy {
  final int nRetries;
  const RetryStrategy({this.nRetries = 3});
}

class LinearRetry extends RetryStrategy {
  final Duration delayDuration;
  const LinearRetry({super.nRetries, required this.delayDuration});
}

class IncrementalRetry extends LinearRetry {
  final Duration Function(Duration initialDelay, int nTry)? calcIncremental;
  const IncrementalRetry({
    super.nRetries,
    required super.delayDuration,
    this.calcIncremental
  });
}
