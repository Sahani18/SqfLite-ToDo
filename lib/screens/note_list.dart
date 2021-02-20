import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../notes.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Notes> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Notes>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(' List Task'),
        backgroundColor: Color(0xff647dff),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      body: Container(
        child: getNoteListView(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/redraw.jpg'),
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff647dff),
        onPressed: () {
          navigateToDetails(Notes('', '', 2), 'Add note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, position) {
          return Card(
            color: Color(0xffa7c2ff),
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ListTile(
              onTap: () {
                detailNotes(this.noteList[position].title,
                    this.noteList[position].description);
              },
              onLongPress: () => menuOnTap(this.noteList[position]),
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/undraw.png"),
              ),
              title: Text(
                this.noteList[position].title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              subtitle: Text(
                this.noteList[position].date,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.open_in_new,
                  color: Colors.black54,
                ),
                onTap: () => menuOnTap(this.noteList[position]),
              ),
              //  print(${this.noteList[position].title});
            ),
          );
        });
  }

  void navigateToDetails(Notes notes, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(notes, title)));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Notes>> noteListFuture = databaseHelper.getNotesList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void detailNotes(String title, String desc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: GestureDetector(
              child: SingleChildScrollView(
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    children: <Widget>[
                      Text('$title',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Divider(),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      Expanded(
                        child: Text('$desc',
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: Navigator.of(context).pop,
            ),
          );
        });
  }

  void menuOnTap(Notes notes) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                      child: Text('Edit',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.black)),
                      onTap: () {
                        Navigator.of(context).pop();
                        navigateToDetails(notes, 'Edit list');
                      }),
                  Divider(),
                  GestureDetector(
                    child: Text('Delete',
                        style: TextStyle(fontSize: 15.0, color: Colors.black)),
                    onTap: () => delete(notes.id),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void delete(int id) async {
    updateListView();
    moveToLastScreen();

    if (id == null) {
      _showAlerDialog('Status', 'First Add a note');
      return;
    }
    int result = await databaseHelper.deleteNote(id);
    if (result != 0) {
      _showAlerDialog('Status', 'Deleted Successfully');
    } else {
      _showAlerDialog('Status', 'Error Occurred');
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlerDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
