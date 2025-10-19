abstract class PaymentService {
  /// Initiates a payment to buy [tokenCount] tokens. Returns true if successful.
  Future<bool> pay({required int tokenCount});
}
