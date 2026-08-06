import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/auth_hero_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/register_form_widget.dart';

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

// TODO: Replace with [Riverpod/Bloc] for production auth state
class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isPendingApproval = false;
  late AnimationController _switchController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeOutCubic,
    );
    _switchController.forward();
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _switchController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _isPendingApproval = false;
      });
      _switchController.forward();
    });
  }

  void _onLoginSuccess(String role) {
    // TODO: Replace with [Riverpod/Bloc] for production auth routing
    if (role == 'teacher') {
      context.go(AppRoutes.teacherCoursesScreen);
    } else {
      context.go(AppRoutes.studentHomeScreen);
    }
  }

  void _onRegisterSuccess() {
    setState(() => _isPendingApproval = true);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Column(children: [const AuthHeroWidget(), _buildFormCard()]),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [const AuthHeroWidget(compact: true), _buildFormCard()],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1E35),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabToggle(),
            const SizedBox(height: 28),
            if (_isPendingApproval || context.watch<AuthService>().isPending)
              _buildPendingApprovalCard()
            else
              FadeTransition(
                opacity: _fadeAnimation,
                child: _isLogin
                    ? LoginFormWidget(onSuccess: _onLoginSuccess)
                    : RegisterFormWidget(onSuccess: _onRegisterSuccess),
              ),
            const SizedBox(height: 24),
            _buildToggleLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildToggleTab('Sign In', true),
          _buildToggleTab('Sign Up', false),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String label, bool isLoginTab) {
    final isSelected = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isLogin != isLoginTab) { _toggleMode(); }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00D4FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0A1628)
                    : const Color(0xFF8BA3C0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApprovalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2010),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB800).withAlpha(102),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'hourglass_top',
            color: const Color(0xFFFFB800),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Account Pending Approval',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your account has been submitted for review. An admin will approve your registration and assign your role shortly.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8BA3C0)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _isPendingApproval = false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFB800), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(
                  color: Color(0xFFFFB800),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account? " : 'Already have an account? ',
          style: const TextStyle(fontSize: 14, color: Color(0xFF8BA3C0)),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00D4FF),
            ),
          ),
        ),
      ],
    );
  }
}

