import 'payment/payment_service_base.dart';
import 'payment/payment_service_stub.dart'
    if (dart.library.io) 'payment/payment_service_mobile.dart'
    if (dart.library.html) 'payment/payment_service_web.dart';

// Expose a factory that returns the platform-specific implementation.
PaymentService createPaymentService() => createPlatformPaymentService();
