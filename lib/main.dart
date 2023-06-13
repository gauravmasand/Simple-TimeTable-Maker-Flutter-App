import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TimetableScreenMainScreen(),
    );
  }
}

class TimetableScreenMainScreen extends StatefulWidget {
  @override
  _TimetableScreenMainScreenState createState() => _TimetableScreenMainScreenState();
}

class _TimetableScreenMainScreenState extends State<TimetableScreenMainScreen> {
  List<Professor> professors = [];

  void addProfessor(String name, String subject) {
    setState(() {
      professors.add(Professor(name, subject));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProfessorScreen(),
                  ),
                );
              },
              child: const Text("Add Professor"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetableScreen(),
                  ),
                );
              },
              child: const Text("Make Time Table"),
            ),
          ],
        ),
      ),
    );
  }
}

class Professor {
  String name;
  String subject;

  Professor(this.name, this.subject);
}

class Assets {
  static List<Professor> professors = [];
}

class AddProfessorScreen extends StatefulWidget {
  @override
  _AddProfessorScreenState createState() => _AddProfessorScreenState();
}

class _AddProfessorScreenState extends State<AddProfessorScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professor Details'),
      ),
      body: ListView.builder(
        itemCount: Assets.professors.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Assets.professors[index].name),
            subtitle: Text(Assets.professors[index].subject),
          );
        },
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () {
          _showAddProfessorDialog(context);
        },
        elevation: 2.0,
        fillColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              SizedBox(width: 5.0),
              Text(
                'Add professor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  void _showAddProfessorDialog(BuildContext context) {
    String name = '';
    String subject = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Professor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  subject = value;
                },
                decoration: InputDecoration(labelText: 'Subject'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  Assets.professors.add(Professor(name, subject));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Lecture {
  String day;
  int lectureNumber;
  String subject;

  Lecture(this.day, this.lectureNumber, this.subject);
}

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  List<int> lectureNumbers = List.generate(9, (index) => index + 1);

  List<List<Lecture>> timetable = List.generate(
    10,
        (index) =>
        List.generate(
          7,
              (index) => Lecture('', index + 1, ''),
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
        actions: [
          IconButton(onPressed: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TimetableScreen()));
          }, icon: Icon(Icons.clear),)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                border: TableBorder.all(),
                children: [
                  _buildTableHeaderRow(),
                  ..._buildTableRows(),
                ],
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: () {
              _exportToPdf();
            }, child: Text("Export")),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      children: [
        TableCell(
          child: SizedBox(),
        ),
        ...daysOfWeek.map((day) {
          return TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                day,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<TableRow> _buildTableRows() {
    return lectureNumbers.map((lectureNumber) {
      return TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '$lectureNumber',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...daysOfWeek.map((day) {
            final lecture = timetable[lectureNumber - 1][daysOfWeek.indexOf(
                day)];

            return TableCell(
              child: Padding(
                padding: EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () {
                    _showSubjectSelectionDialog(lecture);
                  },
                  child: Text(
                    lecture.subject,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      );
    }).toList();
  }

  void _showSubjectSelectionDialog(Lecture lecture) {
    List<String> subjects = Assets.professors.map((professor) =>
    professor.subject).toList();
    print("The subjects are " + subjects.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Subject'),
          content: SingleChildScrollView(
            child: ListBody(
              children: subjects.map((subject) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      lecture.subject = subject;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(subject),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    final tableHeaders = daysOfWeek.map((day) {
      return pw.Text(day, style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
    }).toList();

    final tableRows = lectureNumbers.map((lectureNumber) {
      final lecture = timetable[lectureNumber - 1];
      final rowCells = lecture.map((l) {
        return pw.Text(l.subject);
      }).toList();
      rowCells.insert(0, pw.Text('Lecture $lectureNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
      return pw.TableRow(children: rowCells);
    }).toList();

    final table = pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(children: tableHeaders),
        ...tableRows,
      ],
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(child: table),
      ),
    );

    if (await Permission.storage.request().isGranted) {
      final directory = await getApplicationSupportDirectory();
      final path = '${directory.path}/timetable.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PDF Exported'),
            content: Text('The timetable has been exported as a PDF.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Required'),
            content: Text('Storage permission is required to export the PDF.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}