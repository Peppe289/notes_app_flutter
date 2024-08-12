// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlite_test/Model/Note.dart';
import 'package:sqlite_test/utils/SQLite_Interface.dart';

class WriteNotes extends StatelessWidget {
  const WriteNotes({super.key});

  @override
  Widget build(BuildContext context) {
    /* controller for input filed. this needed for retrieve text */
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    int? id;

    /* on click call this async function. see save button. */
    Future<void> saveNote(Note note) async {
      SqliteNotes dbNote = SqliteNotes();
      // wait for initialize database in this instance.
      await dbNote.init();
      // retrieve result of saved in database action.
      if (id == null) {
        await dbNote.insert(note);
      } else {
        await dbNote.updateNote(note);
      }
    }

    // add the navigator pop here for wait in async function the result of insert.
    // In this way when we back to home, the home page can be reload all list without
    // delay and then fix issues witch don't show new notes.
    void saveAndGoBack(BuildContext context, Note note) async {
      await saveNote(note);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }

    // save into database new data.
    void saveData() {
      saveAndGoBack(context, Note(id, titleController.text, contentController.text, null));
    }

    /* check if id is passed in this page. if not, this can be get error. then catch the error end ignore. */
    try {
      id = ModalRoute.of(context)!.settings.arguments as int;
    // ignore: empty_catches
    } catch(ignore) {}

    Future<void> loadContent() async {
      if (id != null) {
        SqliteNotes sql = SqliteNotes();
        List<Note> notes = await sql.doRetrieveNotes();
        Iterable<Note> filter = notes.where((e) => e.id == id);
        titleController.text = filter.first.title;
        contentController.text = filter.first.content;
      }
    }

    loadContent();

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'New Notes' : 'Edit Notes'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => saveData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: id == null ? 'Title' : '',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: contentController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: id == null ? 'Write some stuff...' : '',
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                )
              ),
              Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Annulla'),
                        ),
                        ElevatedButton(
                          onPressed: () => saveData(),
                          child: const Text('Salva'),
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}