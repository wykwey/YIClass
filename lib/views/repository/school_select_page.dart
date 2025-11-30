import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../services/repository/school_index_service.dart';
import '../../data/school_index.dart';
import '../../components/feedback/notifications.dart';
import '../../components/layout/appbar.dart';
import '../../components/inputs/components.dart';
import '../../components/feedback/dialogs.dart';
import '../../routes/route_utils.dart';

/// 学校选择页
class SchoolSelectPage extends StatefulWidget {
  const SchoolSelectPage({super.key});

  @override
  State<SchoolSelectPage> createState() => _SchoolSelectPageState();
}

class _SchoolSelectPageState extends State<SchoolSelectPage> {
  bool _isLoading = true;
  List<SchoolEntry> _allSchools = [];
  Map<String, List<SchoolEntry>> _groupedSchools = {};
  List<SchoolEntry> _filteredSchools = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);

    try {
      // 获取索引文件路径（从下载服务获取默认路径）
      final appDir = await _getAppDirectory();
      final indexPath = path.join(appDir.path, 'repository', 'index.isar');

      final opened = await SchoolIndexService.instance.openIndex(indexPath);
      if (!opened) {
        if (mounted) {
          _showLoadIndexDialog();
        }
        return;
      }

      // 加载学校数据
      _groupedSchools = await SchoolIndexService.instance.getSchoolsGroupedByLetter();
      _allSchools = await SchoolIndexService.instance.getAllSchools();
      _filteredSchools = _allSchools;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Notifications.sonner(context, message: '加载学校列表失败: $e');
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredSchools = _allSchools;
      });
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await SchoolIndexService.instance.searchSchools(query);
    setState(() {
      _filteredSchools = results;
    });
  }

  void _showLoadIndexDialog() {
    YicoreConfirm.show(
      context,
      title: '索引文件未找到',
      message: '请先在"教务导入配置"页面下载索引文件',
      confirmText: '前往配置',
      cancelText: '取消',
      onConfirm: () {
        RouteUtils.pushRepositoryConfig(context).then((_) {
          // 从配置页返回后，尝试重新加载学校列表
          _loadSchools();
        });
      },
    );
  }

  Future<Directory> _getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: YicoreAppBar(
        title: '选择学校',
        centerTitle: true,
        actions: [
          YicoreAppBarAction(
            icon: Icons.refresh,
            onPressed: _loadSchools,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 搜索框
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StatefulBuilder(
                    builder: (context, setStateLocal) {
                      return YicoreTextField(
                        controller: _searchController,
                        hintText: '搜索学校名称',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? YicoreIconButton(
                                icon: Icons.clear,
                                size: 36,
                                showBorder: false,
                                onPressed: () {
                                  _searchController.clear();
                                  setStateLocal(() {});
                                },
                              )
                            : null,
                        onChanged: (value) {
                          setStateLocal(() {});
                          // _onSearchChanged 已经通过监听器自动调用
                        },
                      );
                    },
                  ),
                ),
                // 学校列表
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults()
                      : _buildGroupedList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredSchools.isEmpty) {
      return const Center(
        child: Text('未找到匹配的学校'),
      );
    }

    return ListView.builder(
      itemCount: _filteredSchools.length,
      itemBuilder: (context, index) {
        final school = _filteredSchools[index];
        return _buildSchoolTile(school);
      },
    );
  }

  Widget _buildGroupedList() {
    if (_groupedSchools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无学校数据'),
            const SizedBox(height: 16),
            YicoreButton(
              text: '前往配置',
              isOutlined: true,
              onPressed: () {
                RouteUtils.pushRepositoryConfig(context).then((_) {
                  // 从配置页返回后，尝试重新加载学校列表
                  _loadSchools();
                });
              },
            ),
          ],
        ),
      );
    }

    // 构建字母索引侧边栏
    final letters = _groupedSchools.keys.toList();

    return Row(
      children: [
        // 主列表
        Expanded(
          child: ListView.builder(
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              final schools = _groupedSchools[letter]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 字母索引标题
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // 学校列表
                  ...schools.map((school) => _buildSchoolTile(school)),
                ],
              );
            },
          ),
        ),
        // 字母索引侧边栏
        _buildLetterIndex(letters),
      ],
    );
  }

  Widget _buildLetterIndex(List<String> letters) {
    return Container(
      width: 40,
      margin: const EdgeInsets.only(right: 8),
      child: ListView.builder(
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          return GestureDetector(
            onTap: () {
              // TODO: 滚动到对应位置
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchoolTile(SchoolEntry school) {
    return ListTile(
      title: Text(school.school),
      subtitle: Text('${school.scripts.length} 个脚本'),
      onTap: () {
        RouteUtils.pushScriptSelect(
          context,
          school: school,
        );
      },
    );
  }
}

