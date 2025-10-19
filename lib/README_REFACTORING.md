# Code Refactoring

## Cấu trúc mới

```
lib/
├── models/           # Data models
├── services/         # Business logic
├── screens/          # UI screens
├── widgets/          # Reusable components
└── main.dart         # App entry point
```

## Luồng điều hướng Screen

### 1. **SplashScreen** (Màn hình khởi động)
- **Chức năng**: Kiểm tra trạng thái đăng nhập
- **Logic**: 
  - Nếu đã đăng nhập → `SensorMonitoringPage`
  - Nếu chưa đăng nhập → `LoginScreen`
- **Thời gian**: Hiển thị 1 giây

### 2. **LoginScreen** (Đăng nhập)
- **Chức năng**: Xác thực tài khoản
- **Navigation**:
  - Đăng nhập thành công → `SensorStationScreen`
  - "Quên mật khẩu" → `ForgotPasswordScreen`
  - "Đăng ký" → `RegisterScreen`
- **Validation**: Kiểm tra username/password từ StorageService

### 3. **SensorStationScreen** (Chọn khu vực)
- **Chức năng**: Hiển thị danh sách quận để giám sát
- **Navigation**:
  - Chọn quận → `SensorMonitoringPage` (với areaId)
  - Settings icon → `DistrictManagementScreen`
- **Data**: Load districts từ StorageService

### 4. **SensorMonitoringPage** (Giám sát cảm biến)
- **Chức năng**: Hiển thị dữ liệu real-time từ Firebase
- **Navigation**:
  - Drawer "Trang chủ" → `SensorStationScreen`
  - Settings icon → `SettingsScreen`
  - Logout → `LoginScreen`
- **Features**: 
  - Real-time data từ Firebase
  - Biểu đồ sensor history
  - Điều khiển switch
  - Chuyển đổi giữa các quận

### 5. **DistrictManagementScreen** (Quản lý quận)
- **Chức năng**: Thêm/xóa quận hiển thị
- **Navigation**: Back → `SensorStationScreen`
- **Data**: 
  - Load districts từ Firebase
  - Save selection vào StorageService

### 6. **SettingsScreen** (Cài đặt)
- **Chức năng**: Cấu hình ngưỡng cảm biến
- **Navigation**: Back → `SensorMonitoringPage`
- **Features**: Slider cho temp, humidity, wind, rain thresholds

### 7. **RegisterScreen** & **ForgotPasswordScreen**
- **Chức năng**: Đăng ký tài khoản mới / Khôi phục mật khẩu
- **Navigation**: Back → `LoginScreen`
- **Data**: Lưu vào StorageService

## Luồng dữ liệu

```
Firebase ←→ FirebaseService ←→ SensorMonitoringPage
    ↓
StorageService ←→ Tất cả screens (login status, districts, settings)
```