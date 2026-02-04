class JobModel {
  final int requestId;
  final int customerId;
  final int? technicianId;
  final String problemType;
  final String problemDetails;
  final String? problemImage;
  final double locationLat;
  final double locationLng;
  final String status;
  final double price;
  final String? requestTime;
  final String? completedTime;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  JobModel({
    required this.requestId,
    required this.customerId,
    this.technicianId,
    required this.problemType,
    this.problemDetails = '',
    this.problemImage,
    required this.locationLat,
    required this.locationLng,
    required this.status,
    this.price = 0,
    this.requestTime,
    this.completedTime,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      requestId: _parseInt(json['request_id']),
      customerId: _parseInt(json['customer_id']),
      technicianId: json['technician_id'] != null ? _parseInt(json['technician_id']) : null,
      problemType: json['problem_type'] ?? '',
      problemDetails: json['problem_details'] ?? '',
      problemImage: json['problem_image'],
      locationLat: _parseDouble(json['location_lat']),
      locationLng: _parseDouble(json['location_lng']),
      status: json['status'] ?? 'pending',
      price: _parseDouble(json['price']),
      requestTime: json['request_time'],
      completedTime: json['completed_time'],
      customerName: json['customer_name'] ?? json['fullname'],
      customerPhone: json['customer_phone'] ?? json['phone'],
      customerAddress: json['customer_address'] ?? json['address'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isTraveling => status == 'traveling';
  bool get isWorking => status == 'working';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => ['accepted', 'traveling', 'working'].contains(status);
  bool get canAccept => status == 'pending' && (technicianId == null || technicianId == 0);
}
