import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class DistrictManagementScreen extends StatefulWidget {
  const DistrictManagementScreen({super.key});

  @override
  State<DistrictManagementScreen> createState() =>
      _DistrictManagementScreenState();
}

class _DistrictManagementScreenState extends State<DistrictManagementScreen> {
  List<String> allDistricts = []; // Tất cả quận từ Firebase
  List<String> selectedDistricts = []; // Quận được chọn hiển thị
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy danh sách quận từ Firebase
      await _loadDistrictsFromFirebase();

      // Lấy danh sách quận đã chọn từ local storage
      final savedDistricts = await StorageService.getDistricts();
      setState(() {
        selectedDistricts = savedDistricts.isNotEmpty
            ? savedDistricts
            : ['Quận 1', 'Quận 2'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  Future<void> _loadDistrictsFromFirebase() async {
    // Lấy danh sách quận từ Firebase
    final firebaseDistricts = await FirebaseService.getAllDistricts();
    setState(() {
      allDistricts = firebaseDistricts;
    });
  }

  Future<void> _saveSelectedDistricts() async {
    await StorageService.saveDistricts(selectedDistricts);
  }

  void _toggleDistrictSelection(String district) {
    setState(() {
      if (selectedDistricts.contains(district)) {
        selectedDistricts.remove(district);
      } else {
        selectedDistricts.add(district);
      }
    });
    _saveSelectedDistricts();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Quản lý Quận',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn quận hiển thị',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tích chọn quận để hiển thị trong app. Bỏ chọn để ẩn.',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đã chọn: ${selectedDistricts.length}/${allDistricts.length} quận',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Danh sách quận từ Firebase
                  const Text(
                    'Danh sách quận từ Firebase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: allDistricts.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có dữ liệu từ Firebase',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: allDistricts.length,
                            itemBuilder: (context, index) {
                              final district = allDistricts[index];
                              final isSelected = selectedDistricts.contains(
                                district,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.2)
                                      : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade700,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Colors.blue
                                        : Colors.grey.withOpacity(0.3),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check
                                          : Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    district,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    isSelected ? 'Đang hiển thị' : 'Đã ẩn',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue.shade300
                                          : Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: isSelected,
                                    onChanged: (_) =>
                                        _toggleDistrictSelection(district),
                                    activeColor: Colors.blue,
                                    inactiveThumbColor: Colors.grey,
                                  ),
                                  onTap: () =>
                                      _toggleDistrictSelection(district),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
