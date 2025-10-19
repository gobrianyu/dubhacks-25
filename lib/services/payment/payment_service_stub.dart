import 'payment_service_base.dart';

class StubPaymentService implements PaymentService {
  @override
  Future<void> pay({required int tokenCount}) async {
    throw UnimplementedError('Payment not supported on this platform');
  }
}

PaymentService createPlatformPaymentService() => StubPaymentService();
