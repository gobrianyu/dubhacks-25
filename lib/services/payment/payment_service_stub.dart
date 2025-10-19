import 'payment_service_base.dart';

class StubPaymentService implements PaymentService {
  @override
  Future<bool> pay({required int tokenCount}) async {
    throw UnimplementedError('Payment not supported on this platform');
  }
}

PaymentService createPlatformPaymentService() => StubPaymentService();
