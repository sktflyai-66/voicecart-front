 
class MessageDTO {
  final String message;

  MessageDTO(this.message);

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}
