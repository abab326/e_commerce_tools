import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/ExcelParser.dart';

class KeywordProcessor extends StatefulWidget {
  const KeywordProcessor({Key? key}) : super(key: key);

  @override
  _KeywordProcessorState createState() => _KeywordProcessorState();
}

class _KeywordProcessorState extends State<KeywordProcessor> {
  List<File> selectedFiles = [];
  List<Map<String, dynamic>> mergedData = [];

  Future<void> selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
      await parseFiles();
    }
  }

  Future<void> parseFiles() async {
    mergedData = [];
    for (var file in selectedFiles) {
      var bytes = await file.readAsBytes();
      var data = await ExcelParser.readExcelByBytes(bytes);
      mergedData.addAll(data);
    }
    setState(() {});
  }

  Future<void> exportToExcel() async {
    // 这里需要实现导出 Excel 的逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关键词处理')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: selectFiles,
            child: const Text('选择 Excel 文件'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(selectedFiles[index].path.split('/').last),
                );
              },
            ),
          ),
          if (mergedData.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                    columnSpacing: 4,
                    horizontalMargin: 16,
                    columns: mergedData[0].keys
                        .map(
                          (key) => DataColumn(
                            label: Text(key),
                            columnWidth: FlexColumnWidth(),
                            numeric: false,
                            onSort: (int columnIndex, bool ascending) {
                              // 这里可以添加排序逻辑
                            },
                          ),
                        )
                        .toList(),
                    rows: mergedData
                        .map(
                          (data) => DataRow(
                            cells: data.values
                                .map(
                                  (value) => DataCell(Text(value.toString())),
                                )
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
              ),
            )
          else
            Expanded(child: Center(child: Text('暂无合并数据'))),
          ElevatedButton(
            onPressed: exportToExcel,
            child: const Text('导出为 Excel'),
          ),
        ],
      ),
    );
  }
}
