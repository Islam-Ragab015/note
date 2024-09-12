import 'package:flutter_day4/util/constants.dart';

class Note {
  int? id;
  String text = '';
  String date = '';
  int color = 0; // New field for the color

  Note({
    this.id,
    required this.text,
    required this.date,
    this.color = 0,
  });

  Map<String, dynamic> toMap() {
    return {colId: id, colText: text, colDate: date, colColor: color};
  }

  Note.fromNote(Map<String, dynamic> map) {
    id = map[colId];
    text = map[colText];
    date = map[colDate];
    color = map[colColor] ?? 0; // Default color is 0 if not provided
  }
}
