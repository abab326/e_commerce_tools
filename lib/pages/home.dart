import 'package:flutter/material.dart';
import 'image_processor.dart';
import 'excel_page.dart';
import 'keyword_processor.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ImageProcessor(),
    const ExcelPage(),
    const KeywordProcessor(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧菜单栏
          Container(
            width: 260,
            color: Colors.grey[200],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Text(
                      '电商工具箱',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
          
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('图片处理'),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Excel 处理'),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.keyboard),
                  title: Text('关键词处理'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
          // 右侧内容区域
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
