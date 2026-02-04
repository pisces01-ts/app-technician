import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idCardController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _expertiseController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idCardController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      fullname: _fullnameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      idCard: _idCardController.text.trim(),
      vehicleModel: _vehicleModelController.text.trim(),
      vehiclePlate: _vehiclePlateController.text.trim(),
      expertise: _expertiseController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลงทะเบียนสำเร็จ กรุณารอการอนุมัติจากผู้ดูแลระบบ'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครเป็นช่าง'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _register();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        child: _isLoading && _currentStep == 2
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_currentStep == 2 ? 'สมัครสมาชิก' : 'ถัดไป'),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('ย้อนกลับ'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('ข้อมูลส่วนตัว'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _fullnameController,
                      decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ-นามสกุล' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์', prefixIcon: Icon(Icons.phone_outlined)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
                        if (v.length < 9) return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idCardController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'เลขบัตรประชาชน', prefixIcon: Icon(Icons.credit_card_outlined)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'กรุณากรอกเลขบัตรประชาชน';
                        if (v.length != 13) return 'เลขบัตรประชาชนต้องมี 13 หลัก';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('ข้อมูลรถและความเชี่ยวชาญ'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _vehicleModelController,
                      decoration: const InputDecoration(labelText: 'ยี่ห้อ/รุ่นรถ', prefixIcon: Icon(Icons.directions_car_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vehiclePlateController,
                      decoration: const InputDecoration(labelText: 'ทะเบียนรถ', prefixIcon: Icon(Icons.confirmation_number_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _expertiseController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ความเชี่ยวชาญ',
                        hintText: 'เช่น ซ่อมเครื่องยนต์, เปลี่ยนยาง, ระบบไฟฟ้า',
                        prefixIcon: Icon(Icons.build_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('รหัสผ่าน'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                        if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
