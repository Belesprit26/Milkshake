import 'package:cloud_functions/cloud_functions.dart' hide Result;

import '../../../core/error/failure.dart';
import '../../../core/result/result.dart';
import '../../../domain/payments/repositories/payment_repository.dart';

class FirebasePaymentRepository implements PaymentRepository {
  FirebasePaymentRepository({required FirebaseFunctions functions}) : _functions = functions;

  final FirebaseFunctions _functions;

  @override
  Future<Result<String>> createCheckoutUrl({required String orderId}) async {
    try {
      final callable = _functions.httpsCallable('createCheckoutSession');
      final res = await callable.call(<String, dynamic>{'orderId': orderId});
      final data = res.data;
      final url = (data is Map ? data['checkoutUrl'] : null)?.toString();
      if (url == null || url.isEmpty) {
        return Err(const UnexpectedFailure('Missing checkoutUrl from function.'));
      }
      return Ok(url);
    } on FirebaseFunctionsException catch (e) {
      return Err(ValidationFailure(e.message ?? e.code));
    } catch (e) {
      return Err(UnexpectedFailure('Failed to start checkout: $e'));
    }
  }
}


