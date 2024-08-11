import 'package:flutter/material.dart';
import 'package:sqlite_test/Model/Note.dart';
import 'package:sqlite_test/utils/SQLite_Inteface.dart';

import 'newNotes.dart';

void main() {
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

  Future<void> initDatabase() async {
    dbNote.init();
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

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(items[index].title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                  // sorry for this.
                                  Text("${formatNumber(items[index].date!.hour)}:${formatNumber(items[index].date!.minute)} ${formatNumber(items[index].date!.day)}/${formatNumber(items[index].date!.month)}/${formatNumber(items[index].date!.year)}")
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
          // use async method for reload list after exit in add notes page.
          final value = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondRoute()),
          );
          // reload here the page with notes list.
          updateList();
        },
        tooltip: 'Add new notes',
        child: const Icon(Icons.add),
      ),
    ));
  }
}
