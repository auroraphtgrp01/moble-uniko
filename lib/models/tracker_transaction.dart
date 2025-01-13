import 'package:uniko/models/expenditure_fund.dart';
import 'package:uniko/services/chat_service.dart';

class TrackerTransaction {
  final String id;
  final String trackerTypeId;
  final String reasonName;
  final String? description;
  final String participantId;
  final String fundId;
  final String transactionId;
  final Participant participant;
  final Transaction transaction;
  final Category trackerType;
  final DateTime time;
  final DateTime trackerTime;

  TrackerTransaction({
    required this.id,
    required this.trackerTypeId,
    required this.reasonName,
    this.description,
    required this.participantId,
    required this.fundId,
    required this.transactionId,
    required this.participant,
    required this.transaction,
    required this.trackerType,
    required this.time,
    required this.trackerTime,
  });

  factory TrackerTransaction.fromJson(Map<String, dynamic> json) {
    return TrackerTransaction(
      id: json['id'],
      trackerTypeId: json['trackerTypeId'],
      reasonName: json['reasonName'],
      description: json['description'],
      participantId: json['participantId'],
      fundId: json['fundId'],
      transactionId: json['transactionId'],
      participant: Participant.fromJson(json['participant']),
      transaction: Transaction.fromJson(json['Transaction']),
      trackerType: Category.fromJson(json['TrackerType']),
      time: DateTime.parse(json['time']),
      trackerTime: DateTime.parse(json['trackerTime']),
    );
  }
}

// Thêm các model class khác như Participant, Transaction, TrackerType tương ứng
