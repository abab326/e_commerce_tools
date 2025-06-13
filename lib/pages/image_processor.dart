import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:intl/intl.dart';

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
  // 上传后图片地址
  String uploadedImageUrl = '';
  // 文件名前缀
  String fileNamePrefix = 'image';

  TextEditingController fileNamePrefixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final nowDate = DateFormat('yyyy/MM/dd').format(DateTime.now());
    uploadedImageUrl = 'https://s2.imgsha.com/' + nowDate + '/';
    // 初始化时加载文件名前缀
    fileNamePrefixController = TextEditingController(text: fileNamePrefix);
  }

  @override
  void dispose() {
    fileNamePrefixController.dispose();
    super.dispose();
  }

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
      final File item = mainImages.removeAt(oldIndex);
      mainImages.insert(newIndex, item);
    });
  }

  // 重新排序副图
  void reorderSecondaryImages(int oldIndex, int newIndex) {
    print('reorderSecondaryImage: $oldIndex, $newIndex ');
    setState(() {
      // 原逻辑可能不适用于将后面图片拖动到前面，移除索引调整
      final File item = secondaryImages.removeAt(oldIndex);
      secondaryImages.insert(newIndex, item);
    });
  }

  // 重置
  void reset() {
    setState(() {
      mainImages.clear(); // 清空主图列表
      secondaryImages.clear(); // 清空副图列表
      fileNamePrefix = 'image'; // 恢复默认文件名前缀
      fileNamePrefixController.text = fileNamePrefix; // 更新输入框内容
    });
  }

  // 保存图片
  void saveImages() async {
    if (mainImages.isEmpty && secondaryImages.isEmpty) {
      return; // 主图和副图都为空时不执行保存操作
    }

    List uploadImageUrls = [];
    var parentDirectoryPath = ''; // 父目录路径
    // 生成主图文件名
    for (int i = 0; i < mainImages.length; i++) {
      if (i == 0) {
        parentDirectoryPath = path.dirname(mainImages[i].path); // 获取父目录路径
      }
      String extension = path.extension(mainImages[i].path);
      if (extension.isEmpty) extension = '.jpg';
      String newName = '${fileNamePrefix}-main-${i + 1}$extension';
      uploadImageUrls.add(uploadedImageUrl + newName);
      await _saveImageWithNewName(mainImages[i], newName);
    }

    // 生成副图文件名
    for (int i = 0; i < secondaryImages.length; i++) {
      if (i == 0 && parentDirectoryPath.isEmpty) {
        parentDirectoryPath = path.dirname(secondaryImages[i].path); // 获取父目录路径
      }
      String extension = path.extension(secondaryImages[i].path);
      if (extension.isEmpty) extension = '.jpg';
      String newName = '${fileNamePrefix}-sub-${i + 1}$extension';
      uploadImageUrls.add(uploadedImageUrl + newName);
      await _saveImageWithNewName(secondaryImages[i], newName);
    }
    // 保存上传图片地址到文件
    final uploadDirectory = Directory(path.join(parentDirectoryPath, 'upload'));
    if (uploadDirectory.existsSync() == false) {
      uploadDirectory.createSync(); // 创建目录
    }
    final uploadFile = File(path.join(uploadDirectory.path, 'imageUrls.txt'));
    await uploadFile.writeAsString(uploadImageUrls.join('\n'));

    // 显示保存成功提示
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('图片保存成功')));
  }

  // 新增方法：以新名称保存图片
  Future<void> _saveImageWithNewName(File imageFile, String newName) async {
    final directory = imageFile.parent; // 使用导入的 path_provider 方法
    final uploadDirectory = Directory(path.join(directory.path, 'upload'));
    if (!uploadDirectory.existsSync()) {
      uploadDirectory.createSync(recursive: true); // 创建目录
    }
    final newFile = File(path.join(uploadDirectory.path, newName));

    // 读取原始图片数据
    final bytes = await imageFile.readAsBytes();
    // 保存图片到新路径
    await newFile.writeAsBytes(bytes);
  }

  Widget buildImageItem(File imageFile, int index, Function fun) {
    String imageName = path.basename(imageFile.path);
    return Tooltip(
      key: Key(imageFile.path + index.toString()),
      message: imageName,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                  imageFile,
                  width: 110,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 110,
                  color: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drag_handle, size: 14, color: Colors.grey),
                      SizedBox(width: 2),
                      Text(
                        '拖动',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
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
              onTap: () => fun(index),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: reset,
            tooltip: '重置',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                controller: fileNamePrefixController,
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
                    child: mainImages.isEmpty
                        ? Center(child: Text('暂无主图'))
                        : ReorderableGridView.builder(
                            shrinkWrap: true,
                            onReorder: reorderMainImages,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: mainImages.length,
                            itemBuilder: (context, index) => buildImageItem(
                              mainImages[index],
                              index,
                              removeMainImage,
                            ),
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
                    child: secondaryImages.isEmpty
                        ? Center(child: Text('暂无副图'))
                        : ReorderableGridView.builder(
                            shrinkWrap: true,
                            onReorder: reorderSecondaryImages,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: secondaryImages.length,
                            itemBuilder: (context, index) => buildImageItem(
                              secondaryImages[index],
                              index,
                              removeSecondaryImage,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
