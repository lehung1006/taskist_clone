import 'package:flutter/material.dart';
import 'header.dart';
import 'createlist.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:localstore/localstore.dart';
import 'tasks.dart';
import 'edit_task.dart';

class TaskList extends StatefulWidget {
  const TaskList({ Key? key }) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final _db = Localstore.instance;
  final _items = <String,Tasks>{};
  StreamSubscription<Map<String, dynamic>>? _subscription;

  int count = 0;

  @override
  void initState() {
    _subscription = _db.collection('TaskLists').stream.listen((event) {
      setState(() {
        final item = Tasks.fromMap(event);
        _items.putIfAbsent(item.name, () => item);
      });
    });
    if (kIsWeb) _db.collection('TaskLists').stream.asBroadcastStream();
    super.initState();
  }


  FutureOr onGoBack(dynamic value, Tasks item) {
    if(value) {
      setState(() {
        item.delete();
        _items.remove(item.name);
      });
    }
  }

  void navigateEditTask(item) {
    Route route = MaterialPageRoute(builder: (context) => EditTask(item: item));
    Navigator.push(context, route).then((value) => onGoBack(value, item));
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children:  <Widget> [
            const Header(title: 'List'),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 10),
              child: SizedBox(
                width: 55,
                height: 55,
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const CreateList();
                      })
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.black, size: 25)
                  ),
              ),
            ),
            const Text('Add List', style: TextStyle(color: Color(0xFF95a5a6))),
            Container(
              height: 320,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemCount: _items.keys.length,
                itemBuilder: (BuildContext context, index) {
                  final key = _items.keys.elementAt(index);
                  final item = _items[key]!;
                  // print(item.tasks[0].keys);
                  // print(item.tasks[0].values);
                  // Task item on Tasklist Screen
                  if(item.status == true) {
                    return Container();
                  }
                  return InkWell(
                    onTap: () {
                      navigateEditTask(item);
                    },
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color(0xFF6933FF),
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                            child: Text(item.name, style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ))
                          ),
                          const Divider(
                            indent: 50,
                            thickness: 3,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 180,
                            height: 200,
                            // margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                            child: Column(
                              children: item.tasks.map((item) {
                                return Row(
                                  children: <Widget> [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      shape: const CircleBorder(),
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      activeColor: const Color(0xFF6933FF),
                                      value: item.values.toList().first, 
                                      onChanged: (bool? value) {}
                                    ),
                                    Text(
                                      item.keys.toList().first,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: item.values.toList().first ? const Color(0xFFf7f1e3): Colors.white,
                                        decoration: item.values.toList().first ? TextDecoration.lineThrough : null
                                      )
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          )
                        ],
                      )
                    )
                  );
                },
              ),
            )
          ],
        )
      ),
    );
  }
}