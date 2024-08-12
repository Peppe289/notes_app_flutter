import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_test/Model/Note.dart';
import 'package:sqlite_test/utils/SQLite_Inteface.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    /* controller for input filed. this needed for retrieve text */
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    /* on click call this async function. see save button. */
    Future<void> saveNote(Note note) async {
      SqliteNotes dbNote = SqliteNotes();
      // wait for initialize database in this instance.
      await dbNote.init();
      // retrieve result of saved in database action.
      int result = await dbNote.insert(note);
      if (kDebugMode) {
        print("Saved into database with result: $result");
      }
    }

    // add the navigator pop here for wait in async function the result of insert.
    // In this way when we back to home, the home page can be reload all list without
    // delay and then fix issues witch don't show new notes.
    void saveAndGoBack(BuildContext context, Note note) async {
      await saveNote(note);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: contentController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Write some stuff...',
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
                          onPressed: () {
                            // create note object with text label field text.
                            Note note = Note(null, titleController.text, contentController.text, null);
                            // see function docs.
                            saveAndGoBack(context, note);
                          },
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