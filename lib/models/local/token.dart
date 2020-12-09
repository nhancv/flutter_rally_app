class Token {
  Token({this.user});

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token(user: json['user'] as String);

  static const String localKey = 'token';

  final String user;

  Map<String, dynamic> toJson() => <String, dynamic>{'user': user};

  @override
  String toString() {
    return 'Token{user: $user}';
  }
}
