import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.find<LoginController>();
  bool _isManualMode = false;
  int _selectedProfileIndex = 1; // Default to Leonardo (Shift Sore)
  String _enteredPin = '';

  // Active cashier profiles mirroring the Figma design
  final List<Map<String, String>> _cashierProfiles = [
    {
      'name': 'Budi',
      'shift': '08:00 AM - 16:00 PM',
      'username': 'kasir',
      'desc': 'Shift Pagi',
    },
    {
      'name': 'Leonardo',
      'shift': '16:00 PM - 00:00 AM',
      'username': 'admin',
      'desc': 'Shift Sore (Admin)',
    },
    {
      'name': 'Alex',
      'shift': '00:00 AM - 08:00 AM',
      'username': 'kasir',
      'desc': 'Shift Malam',
    },
  ];

  @override
  void initState() {
    super.initState();
    _applyProfileSelection();
  }

  void _applyProfileSelection() {
    if (!_isManualMode) {
      final profile = _cashierProfiles[_selectedProfileIndex];
      controller.usernameController.text = profile['username'] ?? '';
      controller.passwordController.text = _enteredPin;
    }
  }

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'C') {
        _enteredPin = '';
      } else if (value == 'DEL') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        if (_enteredPin.length < 8) {
          _enteredPin += value;
        }
      }
      _applyProfileSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;
          if (isTablet) {
            return Row(
              children: [
                Expanded(flex: 4, child: _buildLeftBanner()),
                Expanded(flex: 5, child: _buildRightForm(true)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopBannerMobile(),
                  _buildRightForm(false),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.salmon, AppColors.salmonDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(40.r),
      child: Stack(
        children: [
          // Zen circular backgrounds
          Positioned(
            top: -100.h,
            left: -100.w,
            child: Container(
              width: 350.r,
              height: 350.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            right: -50.w,
            child: Container(
              width: 250.r,
              height: 250.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Core content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo stamp
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, py: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      '寿司',
                      style: TextStyle(
                        color: AppColors.salmonDark,
                        fontWeight: FontWeight.extrabold,
                        fontSize: 16.sp,
                        fontFamily: 'Serif',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'SUSHIMOO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.black,
                      fontSize: 18.sp,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),

              // Hero Text / Slogan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transform Your\nBusiness with\nSushimoo POS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.extrabold,
                      fontSize: 32.sp,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: 60.w,
                    height: 4.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Sistem Kasir Zen Precision dirancang khusus untuk kenyamanan operasional restoran modern yang serba cepat.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              // Sushi item motifs grid
              Opacity(
                opacity: 0.15,
                child: Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.white, size: 28.sp),
                    Icon(Icons.rice_bowl, color: Colors.white, size: 28.sp),
                    Icon(Icons.dinner_dining, color: Colors.white, size: 28.sp),
                    Icon(Icons.set_meal, color: Colors.white, size: 28.sp),
                    Icon(Icons.emoji_food_beverage, color: Colors.white, size: 28.sp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBannerMobile() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.salmon, AppColors.salmonDark],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        children: [
          Text(
            '寿司 SUSHIMOO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.extrabold,
              fontSize: 20.sp,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Zen Precision Restaurant POS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightForm(bool isTablet) {
    return SafeArea(
      left: !isTablet,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.r : 20.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 640.w : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header of login page
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cashier Login',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.extrabold,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Pilih akun kasir untuk memulai aktivitas shift Anda.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    // Toggle login mode
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isManualMode = !_isManualMode;
                          if (!_isManualMode) {
                            _enteredPin = '';
                            _applyProfileSelection();
                          } else {
                            controller.usernameController.clear();
                            controller.passwordController.clear();
                          }
                        });
                      },
                      icon: Icon(
                        _isManualMode ? Icons.pin : Icons.keyboard_alt_outlined,
                        size: 16.sp,
                        color: AppColors.salmonDark,
                      ),
                      label: Text(
                        _isManualMode ? 'Gunakan PIN' : 'Login Manual',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.salmonDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                if (_isManualMode)
                  _buildManualForm()
                else
                  _buildPinForm(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Username',
          hint: 'Masukkan username (admin / kasir)',
          controller: controller.usernameController,
        ),
        SizedBox(height: 16.h),
        AppTextField(
          label: 'Password',
          hint: 'Masukkan password Anda',
          controller: controller.passwordController,
          obscure: true,
        ),
        SizedBox(height: 28.h),
        Obx(() => AppButton(
              label: 'Masuk Ke Sistem',
              loading: controller.loading.value,
              onPressed: controller.submit,
            )),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            'Gunakan username "admin" password "password" untuk uji coba.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.inkMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinForm(bool isTablet) {
    final selectedProfile = _cashierProfiles[_selectedProfileIndex];

    return Column(
      children: [
        // Grid / Row layout for Cashier selection & PIN Pad
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Profile Cards List & Buka Shift Button
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PILIH KASIR AKTIF',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.extrabold,
                      letterSpacing: 1.2,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // List of cashier profile cards
                  ...List.generate(_cashierProfiles.length, (index) {
                    final profile = _cashierProfiles[index];
                    final isSelected = index == _selectedProfileIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProfileIndex = index;
                          _applyProfileSelection();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.salmonSoft : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected ? AppColors.salmon : AppColors.hairline,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundColor: isSelected ? AppColors.salmon : AppColors.surfaceAlt,
                              child: Icon(
                                profile['username'] == 'admin' ? Icons.admin_panel_settings : Icons.person_outline,
                                size: 16.sp,
                                color: isSelected ? Colors.white : AppColors.inkMuted,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['name']!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.salmonDark : AppColors.ink,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    profile['shift']!,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: isSelected ? AppColors.salmonDark.withOpacity(0.8) : AppColors.inkMuted,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.salmon,
                                size: 18.sp,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 16.h),

                  // Selected Cashier description banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Password/PIN default: "password" atau "123456"',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Big Action Button: Start Shift / Buka Shift
                  Obx(() => AppButton(
                        label: 'Buka Shift Kasir',
                        icon: Icons.vpn_key_outlined,
                        loading: controller.loading.value,
                        onPressed: () {
                          if (_enteredPin.isEmpty) {
                            Get.snackbar(
                              'PIN Dibutuhkan',
                              'Silakan masukkan PIN passcode Anda terlebih dahulu.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.dangerSoft,
                              colorText: AppColors.danger,
                            );
                            return;
                          }
                          controller.submit();
                        },
                      )),
                ],
              ),
            ),

            // Gap
            SizedBox(width: isTablet ? 32.w : 16.w),

            // Right Column: PIN Code Indicator & Tactical PIN Pad
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  // Passcode Dot Indicators
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      children: [
                        Text(
                          'MASUKKAN PASSCODE PIN',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.extrabold,
                            letterSpacing: 1.2,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isFilled = index < _enteredPin.length;
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              width: 14.r,
                              height: 14.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled ? AppColors.salmon : Colors.transparent,
                                border: Border.all(
                                  color: isFilled ? AppColors.salmon : AppColors.inkFaint,
                                  width: 1.5,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Passcode PIN Pad Grid
                  _buildKeyboardGrid(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardGrid() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', 'DEL'],
    ];

    return Table(
      children: keys.map((row) {
        return TableRow(
          children: row.map((key) {
            final isSpecial = key == 'C' || key == 'DEL';
            return Container(
              margin: EdgeInsets.all(4.r),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: InkWell(
                  onTap: () => _handleKeyPress(key),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSpecial ? Colors.slate.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSpecial ? Colors.slate.shade200 : AppColors.hairline,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isSpecial && key == 'DEL'
                        ? Icon(Icons.backspace_outlined, size: 18.sp, color: AppColors.ink)
                        : Text(
                            key,
                            style: TextStyle(
                              fontSize: isSpecial ? 14.sp : 18.sp,
                              fontWeight: FontWeight.bold,
                              color: key == 'C'
                                  ? AppColors.danger
                                  : (isSpecial ? AppColors.inkMuted : AppColors.ink),
                            ),
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

