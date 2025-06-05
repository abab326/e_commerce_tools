import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ImageProcessor extends StatefulWidget {
  const ImageProcessor({Key? key}) : super(key: key);

  @override
  _ImageProcessorState createState() => _ImageProcessorState();
}

class _ImageProcessorState extends State<ImageProcessor> {
  // 主图列表
  List<File> mainImages = [];
  // 副图列表
  List<File> secondaryImages = [];
  // 文件名前缀
  String fileNamePrefix = 'product';

  // 添加主图
  Future<void> addMainImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              mainImages.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      print('选择图片出错: $e');
      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  // 添加副图
  Future<void> addSecondaryImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              secondaryImages.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      print('选择图片出错: $e');
      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  // 删除主图
  void removeMainImage(int index) {
    setState(() {
      mainImages.removeAt(index);
    });
  }

  // 删除副图
  void removeSecondaryImage(int index) {
    setState(() {
      secondaryImages.removeAt(index);
    });
  }

  // 重新排序主图
  void reorderMainImages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final File item = mainImages.removeAt(oldIndex);
      mainImages.insert(newIndex, item);
    });
  }

  // 重新排序副图
  void reorderSecondaryImages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final File item = secondaryImages.removeAt(oldIndex);
      secondaryImages.insert(newIndex, item);
    });
  }

  // 保存图片
  void saveImages() {
    // 实际应用中，这里应该处理图片保存逻辑
    List<String> mainImageNames = [];
    List<String> secondaryImageNames = [];

    // 生成主图文件名
    for (int i = 0; i < mainImages.length; i++) {
      String extension = path.extension(mainImages[i].path);
      if (extension.isEmpty) extension = '.jpg';
      mainImageNames.add('${fileNamePrefix}_main_${i + 1}$extension');
    }

    // 生成副图文件名
    for (int i = 0; i < secondaryImages.length; i++) {
      String extension = path.extension(secondaryImages[i].path);
      if (extension.isEmpty) extension = '.jpg';
      secondaryImageNames.add('${fileNamePrefix}_secondary_${i + 1}$extension');
    }

    // 显示保存成功对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('保存成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主图:'),
            ...mainImageNames.map((name) => Text('- $name')),
            SizedBox(height: 10),
            Text('副图:'),
            ...secondaryImageNames.map((name) => Text('- $name')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图片处理'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveImages,
            tooltip: '保存图片',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件名前缀输入
            TextField(
              decoration: InputDecoration(
                labelText: '文件名前缀',
                hintText: '请输入文件名前缀',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  fileNamePrefix = value;
                });
              },
              controller: TextEditingController(text: fileNamePrefix),
            ),
            SizedBox(height: 20),

            // 主图区域
            Text(
              '主图',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: addMainImages,
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('添加主图'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.drag_indicator, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '拖动可调整顺序',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  height: 120,
                  child: mainImages.isEmpty
                      ? Center(child: Text('暂无主图'))
                      : ReorderableListView(
                          scrollDirection: Axis.horizontal,
                          onReorder: reorderMainImages,
                          children: [
                            for (
                              int index = 0;
                              index < mainImages.length;
                              index++
                            )
                              Stack(
                                key: Key('main_$index'),
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.file(
                                          mainImages[index],
                                          width: 110,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          width: 110,
                                          color: Colors.grey.shade200,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.drag_handle,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '拖动',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () => removeMainImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // 副图区域
            Text(
              '副图',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: addSecondaryImages,
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('添加副图'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.drag_indicator, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '拖动可调整顺序',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  height: 120,
                  child: secondaryImages.isEmpty
                      ? Center(child: Text('暂无副图'))
                      : ReorderableListView(
                          scrollDirection: Axis.horizontal,
                          onReorder: reorderSecondaryImages,
                          children: [
                            for (
                              int index = 0;
                              index < secondaryImages.length;
                              index++
                            )
                              Stack(
                                key: Key('secondary_$index'),
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.file(
                                          secondaryImages[index],
                                          width: 110,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          width: 110,
                                          color: Colors.grey.shade200,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.drag_handle,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '拖动',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () => removeSecondaryImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
