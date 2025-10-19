abstract class PaymentService {
  /// Initiates a payment to buy [tokenCount] tokens.
  Future<void> pay({required int tokenCount});
}
