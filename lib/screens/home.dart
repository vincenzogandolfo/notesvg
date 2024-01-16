import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesvg/constants/colors.dart';
import 'package:notesvg/models/note.dart';
import 'package:notesvg/screens/edit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    filteredNotes = sampleNotes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchText(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.title.toLowerCase().contains(searchText.toLowerCase()) ||
              note.content.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const Edit(),
      ),
    );
    if (result != null) {
      setState(() {
        sampleNotes.add(
          Note(
            id: sampleNotes.length,
            title: result[0],
            content: result[1],
            modifiedTime: DateTime.now(),
          ),
        );
        filteredNotes = sampleNotes;
      });
    }
  }

  void onDeleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      filteredNotes = List.from(sampleNotes); // Update filteredNotes
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes VG',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  GestureDetector(
                    onTap: addNote,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 2),
                          Text('Aggiungi', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: onSearchText,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Cerca nota..",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: Colors.grey.shade800,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
              if (filteredNotes.isNotEmpty)
                Container(
                  height: 2,
                  width: double.infinity,
                  margin: const EdgeInsets.all(25),
                  color: Colors.grey.shade800,
                ),
              Expanded(
                child: filteredNotes.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Edit(
                                    note: filteredNotes[index],
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  int originalIndex = sampleNotes.indexOf(filteredNotes[index]);

                                  sampleNotes[originalIndex] = Note(
                                    id: sampleNotes[originalIndex].id,
                                    title: result[0],
                                    content: result[1],
                                    modifiedTime: DateTime.now(),
                                  );

                                  filteredNotes[index] = Note(
                                    id: filteredNotes[index].id,
                                    title: result[0],
                                    content: result[1],
                                    modifiedTime: DateTime.now(),
                                  );
                                });
                              }
                            },
                            child: Card(
                              color: getRandomColor(),
                              margin: const EdgeInsets.only(bottom: 15),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredNotes[index].title,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            filteredNotes[index].content,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Creazione: ${DateFormat('dd/MM/yyyy - HH:mm').format(filteredNotes[index].modifiedTime)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.black,
                                        onPressed: () async {
                                          final result =
                                              await confirmDialog(context);
                                          if (result != null && result) {
                                            onDeleteNote(index);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.note_add),
                            iconSize: 50,
                            color: Colors.white,
                            onPressed: addNote,
                          ),
                          const SizedBox(height: 15),
                          const Text('Elenco vuoto',
                              style: TextStyle(color: Colors.white, fontSize: 20)),
                          const SizedBox(height: 10),
                          const Text('(Aggiungi una nota)',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          icon: Icon(
            Icons.info,
            color: Colors.grey.shade400,
          ),
          title: const Text(
            "Vuoi eliminare la nota?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  elevation: 10,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                child: const Text(
                  "Annulla",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 10,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                child: const Text(
                  "Elimina",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
