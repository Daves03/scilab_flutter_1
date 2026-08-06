import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/activity_service.dart';
import '../../models/experiment_step.dart';


class UnityArScreen extends StatefulWidget {
  final String? experimentId;
  const UnityArScreen({super.key, this.experimentId});

  @override
  State<UnityArScreen> createState() => _UnityArScreenState();
}

class _UnityArScreenState extends State<UnityArScreen> with TickerProviderStateMixin {
  bool _isExperimentActive = false;
  bool _isLoading = false;
  String? _activeExperimentId;
  final ActivityService _activityService = ActivityService();

  // --- NEW: Instructional Guide State ---
  bool _showGuide = false;
  int _guideStep = 0;
  late AnimationController _guideAnimationController;

  // --- NEW: Step tracking variables ---
  int _currentStepIndex = 0;

  // Define steps for each experiment ID (Add your 6 experiments here!)
  final Map<String, List<ExperimentStep>> _experimentStepsMap = {
    '1': [
      ExperimentStep(bottleTag: 'Surf', instructionTitle: 'Step 1: Add Soap', instructionDetail: 'Pour the dish soap into the beaker.'),
      ExperimentStep(bottleTag: 'Peroxide', instructionTitle: 'Step 2: Add Peroxide', instructionDetail: 'Add hydrogen peroxide to the mixture.'),
      ExperimentStep(bottleTag: 'Dye', instructionTitle: 'Step 3: Add Dye', instructionDetail: 'Add food coloring.'),
      ExperimentStep(bottleTag: 'Yeast', instructionTitle: 'Step 4: Add Yeast to Cylinder', instructionDetail: 'Pour the yeast into the cylinder with water'),
      ExperimentStep(bottleTag: 'Activator', instructionTitle: 'Step 5: Pour Yeast', instructionDetail: 'Pour the Cylinder with yeast last to start the reaction!')
    ],
    '2': [
      ExperimentStep(bottleTag: 'ChemicalA', instructionTitle: 'Step 1: Base Liquid', instructionDetail: 'Pour the base solution.'),
      ExperimentStep(bottleTag: 'ActivatorB', instructionTitle: 'Step 2: Catalyst', instructionDetail: 'Add the activator to complete.'),
    ],
    '3': [
      ExperimentStep(bottleTag: 'ElectrodeA', instructionTitle: 'Step 1: Setup', instructionDetail: 'Place the electrodes.'),
      ExperimentStep(bottleTag: 'Power', instructionTitle: 'Step 2: Power On', instructionDetail: 'Connect to battery.'),
    ],
    '4': [
      ExperimentStep(bottleTag: 'ReagentX', instructionTitle: 'Step 1: Reagent', instructionDetail: 'Add Reagent X.'),
    ],
    '5': [
      ExperimentStep(bottleTag: 'ElementA', instructionTitle: 'Step 1: Element', instructionDetail: 'Inspect Element A.'),
    ],
  };

  List<ExperimentStep> get _currentSteps => 
    _experimentStepsMap[_activeExperimentId] ?? [];

  @override
  void initState() {
    super.initState();
    _guideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.experimentId != null) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchExperiment(widget.experimentId!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No experiment selected.')),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _guideAnimationController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _launchExperiment(String experimentId) async {
    // Extract only digits: "Exp1" or "ar1" becomes "1"
    final normalizedId = experimentId.replaceAll(RegExp(r'[^0-9]'), '');

    final status = await Permission.camera.request();

    // --- ADD THIS LINE TO FIX THE ASYNC WARNING ---
    if (!mounted) { return; }

    if (status.isGranted) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      setState(() {
        _isExperimentActive = true;
        _isLoading = true;
        _activeExperimentId = normalizedId;
        _currentStepIndex = 0; // Reset steps on launch
      });

      // Tell Unity to load the experiment / scene
      sendToUnity('FlutterReceiver', 'LoadExperiment', normalizedId);

      // Now context is safe to use!
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null) {
        _activityService.logExperimentLaunch(uid, normalizedId);
      }
    } else {
      // We already checked !mounted above, so this context is safe too
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera access is required to run AR experiments.')),
      );
    }
  }
  void _closeUnityAndReturnToMenu() {
    sendToUnity('FlutterReceiver', 'LoadExperiment', '0');

    Future.delayed(const Duration(milliseconds: 150), () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  // --- Tell Unity which bottle ID is currently active ---
  void _notifyUnityActiveStep() {
    if (_currentSteps.isEmpty) { return; }
    final activeTag = _currentSteps[_currentStepIndex].bottleTag;
    
    // Send active step configuration to Unity's receiver
    sendToUnity('FlutterReceiver', 'SetActiveStep', activeTag);
  }

  void _handleMessageFromUnity(String message) {
    final trimmedMessage = message.trim();
    debugPrint('Received from Unity: "$trimmedMessage"');

    if (trimmedMessage == 'show_menu') {
      if (mounted) {
        _closeUnityAndReturnToMenu();
      }
    }

    if (trimmedMessage == 'scene_ready') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showGuide = true; // Show guide after loading
          });
          _notifyUnityActiveStep(); // Send first step as soon as scene is ready
        }
      });
    }

    // --- CATCH EARLY ACTIVATOR WARNING ---
    if (trimmedMessage.startsWith("WARNING:")) {
      String ingredient = trimmedMessage.replaceFirst("WARNING:", "");
      _showEarlyActivatorWarning(ingredient);
      return;
    }

    // --- CATCH STEP COMPLETION ---
    if (trimmedMessage.startsWith("STEP_COMPLETED:")) {
      if (_currentStepIndex < _currentSteps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
        _notifyUnityActiveStep();
      } else {
        // Last step finished -> Trigger completion workflow
        _handleExperimentComplete();
      }
    }
  }

  void _handleExperimentComplete() {
    final uid = context.read<AuthService>().currentUser?.id;
    if (uid != null && _activeExperimentId != null) {
      _activityService.markExperimentCompleted(uid, _activeExperimentId!);
    }
    // You can also pop up your completion dialog here!
  }

  void _showEarlyActivatorWarning(String ingredient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Wait! Don't add the $ingredient yet. Mix the other ingredients first.",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _nextGuideStep() {
    setState(() {
      if (_guideStep < 2) {
        _guideStep++;
      } else {
        _showGuide = false;
      }
    });
  }

  Widget _buildGuideOverlay(ThemeData theme) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 320),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _guideStep < 2 ? "OBJECT INTERACTION GUIDE" : "CAMERA ANGLE GUIDE",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF8BA3C0),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      "${_guideStep + 1}/3",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4FF),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0x2200D4FF)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: _buildAnimatedGuideContent()),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGuideText(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _nextGuideStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D4FF),
                                    foregroundColor: const Color(0xFF0A1628),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    _guideStep == 2 ? "FINISH" : "NEXT",
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGuideText() {
    switch (_guideStep) {
      case 0: return "Touch and drag the item to its target.";
      case 1: return "The item will move automatically after making contact.";
      case 2: return "BEST CAMERA ANGLE FOR DOING THE EXPERIMENT";
      default: return "";
    }
  }

  Widget _buildAnimatedGuideContent() {
    return AnimatedBuilder(
      animation: _guideAnimationController,
      builder: (context, child) {
        if (_guideStep == 0) {
          // Slide 1: Distance closing (Moving right)
          double progress = _guideAnimationController.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(progress * 100 - 50, 0),
                child: const Icon(Icons.science, size: 60, color: Colors.green),
              ),
              const SizedBox(width: 40),
              const Icon(Icons.biotech, size: 60, color: Color(0xFF00D4FF)),
            ],
          );
        } else if (_guideStep == 1) {
          // Slide 2: Pouring
          double rotation = _guideAnimationController.value * 0.8;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.rotate(
                angle: rotation,
                child: const Icon(Icons.science, size: 60, color: Colors.green),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Icon(Icons.biotech, size: 60, color: Color(0xFF00D4FF)),
              ),
            ],
          );
        } else {
          // Slide 3: Camera Angle
          return CustomPaint(
            size: const Size(120, 100),
            painter: _CameraAnglePainter(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSteps = _currentSteps.isNotEmpty;
    final currentStepData = hasSteps ? _currentSteps[_currentStepIndex] : null;

    debugPrint(
        "DEBUG: Active=$_isExperimentActive, Loading=$_isLoading, StepsCount=${_currentSteps
            .length}, CurrentStepIndex=$_currentStepIndex");


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) { return; }
        _closeUnityAndReturnToMenu();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Offstage(
              offstage: !_isExperimentActive,
              child: EmbedUnity(onMessageFromUnity: _handleMessageFromUnity),
            ),

            // --- UI OVERLAY FOR INSTRUCTIONS WHEN EXPERIMENT IS ACTIVE ---
            if (_isExperimentActive && !_isLoading && currentStepData != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "PROGRESS",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8BA3C0),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  "${_currentStepIndex + 1}/${_currentSteps.length}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00D4FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentStepData.instructionTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentStepData.instructionDetail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8BA3C0),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (_isLoading)
              Container(
                color: theme.colorScheme.surface,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      Text('Preparing Chemistry Lab...'),
                    ],
                  ),
                ),
              ),

            if (_showGuide) _buildGuideOverlay(theme),

          ],
        ),
      ),
    );
  }
}

class _CameraAnglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final markerLineStart = Offset(size.width * 0.1, size.height * 0.8);
    final markerLineEnd = Offset(size.width * 0.5, size.height * 0.8);
    
    // Draw Marker line
    canvas.drawLine(markerLineStart, markerLineEnd, paint);
    
    // Draw Angle line
    final angleEnd = Offset(size.width * 0.9, size.height * 0.2);
    canvas.drawLine(markerLineStart, angleEnd, paint);

    // Draw arc for angle
    canvas.drawArc(
      Rect.fromCircle(center: markerLineStart, radius: 30),
      -0.8,
      0.8,
      false,
      paint,
    );

    // Draw simplified Phone (Cyan)
    final phonePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final phoneRect = Rect.fromCenter(center: angleEnd, width: 20, height: 35);
    canvas.drawRRect(RRect.fromRectAndRadius(phoneRect, const Radius.circular(3)), phonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

