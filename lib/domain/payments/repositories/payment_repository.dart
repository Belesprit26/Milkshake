import '../../../core/result/result.dart';

abstract class PaymentRepository {
  Future<Result<String>> createCheckoutUrl({required String orderId});
}


