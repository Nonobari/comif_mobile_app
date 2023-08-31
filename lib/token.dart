final home_token =
    'RaIxZ4fD5E1M2uWejLwQk8SCLgbeUOAFJTVPivBmbrQr4EWwJh8gf3KyaT3WO6Gs';

class Token {
  final int iat; // Issued At (timestamp)
  final int exp; // Expiration (timestamp)
  final String token; // Token string

  Token({
    required this.token,
    required this.iat,
    required this.exp,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      iat: json['iat'] as int? ?? 0,
      exp: json['exp'] as int? ?? 0,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iat': iat,
      'exp': exp,
      'token': token,
    };
  }
}
