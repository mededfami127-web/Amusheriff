import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/repositories/inquiry_repository.dart';
import '../datasources/inquiries_remote_datasource.dart';

/// Maps raw `inquiries` rows to [Inquiry] and translates every failure into a
/// typed [AppFailure].
class InquiryRepositoryImpl implements InquiryRepository {
  InquiryRepositoryImpl(this._remote);

  final InquiriesRemoteDataSource _remote;

  @override
  Future<List<Inquiry>> fetchAll({int limit = 500}) => ErrorMapper.guard(
    () async {
      final List<Map<String, dynamic>> rows = await _remote.fetch(limit: limit);
      return rows.map(_decode).toList(growable: false);
    },
  );

  @override
  Stream<List<Inquiry>> watchAll() => _remote.watch().map(
    (List<Map<String, dynamic>> rows) => rows.map(_decode).toList(),
  );

  @override
  Future<void> remove(String id) => ErrorMapper.guard(() => _remote.remove(id));

  @override
  Future<void> log({
    String? productId,
    required String channel,
    String? deviceId,
  }) => _remote.logInquiry(
    productId: productId,
    channel: channel,
    deviceId: deviceId,
  );

  static Inquiry _decode(Map<String, dynamic> row) {
    final dynamic nested = row['products'];
    return Inquiry(
      id: row['id'] as String,
      channel: row['channel'] as String,
      productId: row['product_id'] as String?,
      deviceId: row['device_id'] as String?,
      productTitle: nested is Map<String, dynamic>
          ? nested['title'] as String?
          : null,
      createdAt: _parseTime(row['created_at']),
    );
  }

  static DateTime? _parseTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
