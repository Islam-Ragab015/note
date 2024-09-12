import 'package:flutter/material.dart';
import 'package:flutter_day4/db/CURD.dart';
import 'package:flutter_day4/model/Note.dart';
import 'package:flutter_day4/util/DateTimeManager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  List<Note> _notes = [];

  // List of available colors
  final List<Color> _colors = [
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
  ];

  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    viewNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _key,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _controller,
                  validator: (value) =>
                      value!.isEmpty ? 'This field is required' : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = _colors[index];
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _colors[index],
                          border: Border.all(
                            color: _selectedColor == _colors[index]
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    Note note = Note(
                      text: _controller.value.text,
                      date: DateTimeManager.currentDateTime(),
                      color: _selectedColor.value,
                    );
                    saveNote(note);
                  }
                },
                child: const Text('Add Note'),
              ),
              const SizedBox(height: 8),
              // Add space between notes
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final Note note = _notes[index];
                  return ListTile(
                    tileColor: Color(note.color),
                    leading: const Icon(Icons.note, color: Colors.white),
                    title: Text(
                      note.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      note.date,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              deleteNote(note.id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              updateNotes(note);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveNote(Note note) {
    CURD.curd.insertNote(note).then((row) {
      // Show success message
      showMessage(context, 'Note is inserted Successfully');
      // Refresh
      setState(() {
        _notes.add(note);
      });
      // Clear fields
      clearFields();
    });
  }

  void clearFields() {
    _controller.text = '';
    // Reset the color to default after adding a new note
    setState(() {
      _selectedColor = Colors.white;
    });
  }

  void viewNotes() {
    CURD.curd.selectNotes().then((listOfNote) {
      setState(() {
        _notes = listOfNote;
      });
    });
  }

  void deleteNote(int? id) {
    CURD.curd.deleteNote(id).then((row) {
      setState(() {
        int index = _notes.indexWhere((element) => element.id == id);
        _notes.removeAt(index);
      });
      showMessage(context, 'Note is deleted successfully');
    });
  }

  void updateNotes(Note note) {
    TextEditingController editController =
        TextEditingController(text: note.text);
    GlobalKey<FormState> editKey = GlobalKey();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Note'),
        content: Wrap(children: [
          Form(
            key: editKey,
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: editController,
              validator: (value) =>
                  value!.isEmpty ? 'This field is required' : null,
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              if (editKey.currentState!.validate()) {
                note.text = editController.value.text;
                note.date = DateTimeManager
                    .currentDateTime(); // Update the date and time
                updateNoteInDatabase(note);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void updateNoteInDatabase(Note note) {
    CURD.curd.updateNote(note).then((value) {
      showMessage(context, 'Note is updated successfully');
      setState(() {
        // Refresh the notes list after updating the note in the database
        viewNotes();
      });
    });
  }

  // Helper function to show a SnackBar
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
