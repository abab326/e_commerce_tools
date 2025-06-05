import 'package:flutter/material.dart';
import 'image_processor.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const Center(child: Text('首页')),
    const Center(child: Text('商品管理')),
    const Center(child: Text('订单管理')),
    const Center(child: Text('客户管理')),
    const Center(child: Text('统计分析')),
    const Center(child: Text('系统设置')),
    const ImageProcessor(),
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
                  leading: Icon(Icons.home),
                  title: Text('首页'),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.inventory),
                  title: Text('商品管理'),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('订单管理'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('客户管理'),
                  selected: _selectedIndex == 3,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('统计分析'),
                  selected: _selectedIndex == 4,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('系统设置'),
                  selected: _selectedIndex == 5,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('图片处理'),
                  selected: _selectedIndex == 6,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 6;
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
