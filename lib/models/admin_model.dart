class Admin {
  Admin({required this.userId});

  final String userId;


  Admin.fromJson(Map<String, Object?> json)
  : this(
    userId: json['userId']! as String,
  );

  Map<String, Object?> toJson() => {
    'userId': userId,
    
  };
}