abstract class Deserializable<T> {
  T fromJson(Map<String, dynamic> json);
}