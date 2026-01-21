import '../../../core/result/result.dart';
import '../entities/order_draft.dart';
import '../entities/order_list_item.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<Result<OrderDraft>> createDraft(OrderDraft draft);
  Future<Result<OrderDraft>> updateDraft(OrderDraft draft);

  Future<Result<List<OrderListItem>>> listForUser(String uid);

  Future<Result<OrderDraft>> getById(String orderId);
  Future<Result<void>> setStatus({required String orderId, required OrderStatus status});
}


