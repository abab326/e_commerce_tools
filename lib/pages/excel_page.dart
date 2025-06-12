import 'package:flutter/material.dart';
import '../utils/ExcelParser.dart';

class ExcelPage extends StatefulWidget {
  const ExcelPage({Key? key}) : super(key: key);

  @override
  _ExcelPageState createState() => _ExcelPageState();
}

class _ExcelPageState extends State<ExcelPage> {
  Future<void> _pickExcelFile() async {
    ExcelParser.getKeywordsFromExcelFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickExcelFile,
          child: const Text('选择 Excel 文件'),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [DataColumn(label: Text('列1'))],
                rows: [],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
