
class Note {
  late int? id; // only on retrieve.
  String title;
  String content;
  late DateTime? date; // only on retrieve.

  Note(this.id, this.title, this.content, this.date);
}