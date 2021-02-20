import 'dart:ui';

import 'package:flutter/material.dart';
import '../notes.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final Notes notes;
  final String appBarTitle;

  NoteDetail(this.notes, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.notes, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Notes notes;

  NoteDetailState(this.notes, this.appBarTitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(notes!=null){
      titleController.text=notes.title;
      descriptionController.text=notes.description;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: Color(0xff647dff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: moveToLastScreen,
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: height,
              width: width,
              margin: EdgeInsets.only(top: 160),
              child: Center(
                child: Image.asset("assets/undraw.png"),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                color: Colors.white.withOpacity(0),
                height: 340,
                width: 400,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                      //dropdown menu
                      child: new ListTile(
                        leading: const Icon(Icons.low_priority),
                        title: DropdownButton(
                            items: _priorities.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              );
                            }).toList(),
                            value: getPrioritiesAsString(notes.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                    ),
                    // Second Element
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, bottom: 15.0, left: 15.0),
                      child: TextField(
                        controller: titleController,
                        style: textStyle,
                        onChanged: (value) {
                          updateTitle();
                        },
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          icon: Icon(Icons.title),
                        ),
                      ),
                    ),

                    // Third Element
                    Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value) {
                          updateDescription();
                        },
                        decoration: InputDecoration(
                          labelText: 'Details',
                          icon: Icon(Icons.details),
                        ),
                      ),
                    ),

                    // Fourth Element
                    Padding(
                      padding: EdgeInsets.only(top: 15, left: 8, right: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              textColor: Colors.white,
                              color: Colors.green,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Save',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                debugPrint("Save button clicked");
                                _save();
                              },
                            ),
                          ),
                          Container(
                            width: 5.0,
                          ),
                          Expanded(
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              textColor: Colors.white,
                              color: Colors.red,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Cancel',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                moveToLastScreen();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void updateTitle() {
    notes.title = titleController.text;
  }

  void updateDescription() {
    notes.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    notes.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (notes.id != null) {
      result = await helper.updatetNote(notes);
    } else {
      result = await helper.insertNote(notes);
    }
    if (result != 0) {
      _showAlerDialog('Status', 'Note Saved Sucessfully');
    } else {
      _showAlerDialog('Status', 'Error Occured');
    }
  }

  //convert to int to save into database

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        notes.priority = 1;
        break;
      case 'Low':
        notes.priority = 2;
        break;
    }
  }

  //convert to int to String to show user

  String getPrioritiesAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
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
