import 'package:hive/hive.dart';

part 'testimonial_model.g.dart';

@HiveType(typeId: 2)
class TestimonialModel extends HiveObject {
  @HiveField(0)
  String type; // Kritik / Saran

  @HiveField(1)
  String content;

  @HiveField(2)
  String username; // Pemilik testimoni

  TestimonialModel({
    required this.type,
    required this.content,
    required this.username,
  });
}
