import 'dart:io';
import 'dart:math';
import 'package:flutter_excel/excel.dart' as excel;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ExcelParser {
  // 获取多个 excel 文件的关键词列表
  static Future<List<Map<String, dynamic>>> getKeywordsFromExcelFiles() async {
    // Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'xlsm'],
    );
    if (result == null || result.files.isEmpty) {
      return [];
    }
    List<Map<String, dynamic>> keywords = [];
    for (var file in result.files) {
      // Get the file path
      PlatformFile platformFile = file;
      String? filePath = platformFile.path;
      // On web, we need to save to temporary directory first
      if (filePath != null) {
        // Read the Excel file
        var bytes = File(filePath).readAsBytesSync();
        var keyList = await readExcelByBytes(bytes);
        keywords.addAll(keyList);
      }
    }
    return [];
  }

  /// 读取关键词 excel 文件 并返回数据列表
  /// @returns {Promise<List<Map<String, dynamic>>>} 包含数据的列表
  static Future<List<Map<String, dynamic>>> readExcelByBytes(
    Uint8List bytes,
  ) async {
    // 1. 加载 Excel 文件
    var wokerExcel = excel.Excel.decodeBytes(bytes);
    if (wokerExcel.tables.isEmpty) {
      return [];
    }
    // 2. 获取工作表 Sheet  名称
    var sheetNames = wokerExcel.tables.keys.toList();
    var keywordSheetName = sheetNames.firstWhere(
      (element) => element.contains('-Keywords'),
      orElse: () => 'Sheet1', // 如果没有找到包含关键词的工作表，则使用默认的工作表名称
    );
    // 3. 获取第一个工作表
    var sheet = wokerExcel.tables[keywordSheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      return [];
    }
    // 4. 提取表头行
    List<String> headers = [];
    if (sheet.rows.isNotEmpty) {
      var headerRow = sheet.rows[1]; // 假设表头在第2行
      headers = headerRow.map((cell) => cell?.value.toString() ?? '').toList();
    }
    // 5. 找到所需列的索引
    int keywordIndex = headers.indexOf('关键词');
    int translationIndex = headers.indexOf('关键词翻译');
    int trafficShareIndex = headers.indexOf('流量占比');
    int exposureIndex = headers.indexOf('预估周曝光量');
    int keywordTypeIndex = headers.indexOf('关键词类型');
    int conversionIndex = headers.indexOf('转化效果');
    int trafficTypeIndex = headers.indexOf('流量词类型');

    final indexList = [
      keywordIndex,
      translationIndex,
      trafficShareIndex,
      exposureIndex,
      keywordTypeIndex,
      conversionIndex,
      trafficTypeIndex,
    ];
    // 计算 indexList 的最大值
    int maxIndex = indexList.reduce(max);
  
    // 6. 提取数据（从第3行开始，跳过表头）
    List<Map<String, dynamic>> data = [];
    for (int i = 3; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
   
      if (row.length > maxIndex) {
        data.add({
          '关键词': row[keywordIndex]?.value?.toString() ?? '',
          '关键词翻译': row[translationIndex]?.value?.toString() ?? '',
          '流量占比': row[trafficShareIndex]?.value?.toString() ?? '',
          '预估周曝光量': row[exposureIndex]?.value?.toString() ?? '',
          '关键词类型': row[keywordTypeIndex]?.value?.toString() ?? '',
          '转化效果': row[conversionIndex]?.value?.toString() ?? '',
          '流量词类型': row[trafficTypeIndex]?.value?.toString() ?? '',
        });
      }
    }
    return data;
  }
}
