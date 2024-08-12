import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_test/Model/Note.dart';
import 'package:sqlite_test/utils/SQLite_Interface.dart';
import 'dart:io' show Platform;

import 'newNotes.dart';

void main() {
  // this fix is needed for windows platform.
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const SQLiteNotes());
}

class SQLiteNotes extends StatelessWidget {
  const SQLiteNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Notes List'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SqliteNotes dbNote = SqliteNotes();
  List<Note> items = [];
  HashMap<int, bool> checked = HashMap();
  bool edit = false;

  Future<void> initDatabase() async {
    dbNote.init();
    // update list at init. this grant we have list of notes when lunch the application.
    updateList();
  }

  Future<void> updateList() async {
    // since setState() can not invoked as async, need to wait for response
    // here and pass notes list in items list.
    List<Note> notes = await dbNote.doRetrieveNotes();

    setState(() {
      items.clear();
      items = notes;
    });
  }

  String formatNumber(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  @override
  Widget build(BuildContext context) {
    initDatabase();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          TextButton(
            child: const Icon(Icons.edit),
            onPressed: () {
              edit = !edit;
              updateList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    trailing: edit ? Checkbox(
                      value: checked[items[index].id!] ?? false, onChanged: (bool? value) { setState(() {
                        checked[items[index].id!] = value!;
                      }); },
                    ) : null,
                    title: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: SizedBox(
                              height: 70,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(items[index].title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                      // sorry for this.
                                      Text(
                                          "${formatNumber(items[index].date!.hour)}:${formatNumber(items[index].date!.minute)} ${formatNumber(items[index].date!.day)}/${formatNumber(items[index].date!.month)}/${formatNumber(items[index].date!.year)}")
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(items[index].content,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SecondRoute(), settings: RouteSettings(arguments: items[index].id)
                                ),
                              )
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (edit) {
              // in edit mode, this button is used for remove selected notes.
              checked.removeWhere((key, value) => value = false );
              for (int id in checked.keys) {
                await dbNote.deleteNote(id);
              }
              updateList();
            } else {
              // use async method for reload list after exit in add notes page.
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecondRoute()),
              );
              // reload here the page with notes list.
              updateList();
            }
          },
          tooltip: edit ? 'Remove notes' : 'Add new notes',
          child: edit ? const Icon(Icons.delete_forever) : const Icon(Icons.add),
        ),
    );
  }
}
