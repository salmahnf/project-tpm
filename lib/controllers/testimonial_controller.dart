import 'package:hive/hive.dart';
import '../models/testimonial_model.dart';

class TestimonialController {
  final Box<TestimonialModel> _box = Hive.box<TestimonialModel>('testimonials');

  List<TestimonialModel> getByUser(String username) =>
      _box.values.where((t) => t.username == username).toList();

  List<TestimonialModel> getByType(String type, String username) =>
      _box.values.where((t) => t.type == type && t.username == username).toList();

  Future<void> add(TestimonialModel testimonial) async {
    await _box.add(testimonial);
  }

  Future<void> update(TestimonialModel testimonial, String newContent) async {
    testimonial.content = newContent;
    await testimonial.save();
  }

  Future<void> delete(TestimonialModel testimonial) async {
    await testimonial.delete();
  }
}
