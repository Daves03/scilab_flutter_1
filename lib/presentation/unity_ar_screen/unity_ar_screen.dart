import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/activity_service.dart';
import '../../models/experiment_step.dart';
import '../../models/ar_experiment_model.dart';
import '../../data/dummy_ar_experiments.dart';
import '../../data/periodic_table_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  bool get _isPeriodicTable => _activeExperimentId == '8' || _activeExperimentId == 'ar8';

  // --- NEW: Step tracking variables ---
  int _currentStepIndex = 0;
  List<ExperimentStep> _currentSteps = [];
  String? _activeExplanation;

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
        _activeExperimentId = experimentId;
        _currentStepIndex = 0; // Reset steps on launch
      });

      // Fetch dynamic steps from Firestore
      try {
        final docSnapshot = await FirebaseFirestore.instance.collection('ar_experiments').doc(experimentId).get();
        if (docSnapshot.exists) {
          final experimentModel = ArExperimentModel.fromMap(docSnapshot.id, docSnapshot.data()!);
          if (mounted) {
            setState(() {
              _currentSteps = experimentModel.steps;
            });
          }
        } else {
          final dummyExp = dummyArExperiments.firstWhere(
            (e) => e.id == experimentId,
            orElse: () => dummyArExperiments.first,
          );
          if (mounted) {
            setState(() {
              _currentSteps = dummyExp.steps;
            });
          }
        }
      } catch (e) {
        print('Error fetching experiment steps: $e');
      }

      // Tell Unity to load the experiment / scene
      sendToUnity('FlutterReceiver', 'LoadExperiment', normalizedId);

      // Now context is safe to use!
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null) {
        _activityService.logExperimentLaunch(uid, experimentId);
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

  // --- DYNAMIC REACTION EXPLANATIONS ---
  final Map<String, String> _reactionDatabase = {
    "bleach_lemon": "DANGER! Bleach (strong base) and Lemon (acid) react to create toxic Chlorine Gas! The pH remains highly alkaline (purple) because bleach dominates.",
    "bleach_blood": "Bleach is a powerful oxidizer. It destroys the hemoglobin in the blood, turning it dirty yellow. The pH is highly alkaline (purple).",
    "lemon_soap": "Acid-Base Neutralization! The acid in the lemon neutralizes the alkaline soap, creating a neutral (green) pH. The mixture turns cloudy as fatty acids separate.",
    "blood_lemon": "The acid from the lemon 'denatures' (cooks) the proteins in the blood, causing it to coagulate into a dark mass. The Litmus shows an acidic (orange) pH.",
    "blood_soap": "Hemolysis! The surfactants in the soap destroy the red blood cell membranes, making them burst into a clear red liquid. Litmus shows an alkaline (blue) pH.",
    "blood_water": "Water dilutes the blood, making it lighter in color. However, blood is buffered, so its pH remains safely around 7.4 (Teal).",
    "bleach": "Bleach is an extremely strong base. It overpowers the other substances, turning the Litmus paper purple (pH 13).",
    "lemon": "Lemon juice is a strong acid. It dominates the mixture, causing the Litmus paper to read highly acidic (orange).",
    "soap": "Soap is a moderate base. It dominates the mixture, turning the Litmus paper blue (pH 9).",
    "pure_blood": "Pure blood stains the paper red! You must dilute it with water first to read its true pH.",
    "pure_water": "You are testing pure water. The Litmus paper shows its natural pH level (Neutral/Green).",
    "pure_lemon": "You are testing pure lemon juice. The Litmus paper shows its natural pH level (Highly Acidic/Orange).",
    "pure_soap": "You are testing pure liquid soap. The Litmus paper shows its natural pH level (Basic/Blue).",
    "pure_bleach": "You are testing pure bleach. The Litmus paper shows its natural pH level (Highly Basic/Purple).",
    "complex_mix": "You've mixed a complex soup! Without strong acids or bases, it becomes a murky mix with a default pH."
  };

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

    // --- CATCH EXPLANATION FROM UNITY (Dynamic Lookup) ---
    if (trimmedMessage.startsWith("EXPLANATION:")) {
      // Unity sends: "EXPLANATION:bleach,lemon"
      String combinationKeys = trimmedMessage.replaceFirst("EXPLANATION:", "");
      
      // Look it up in our dynamic dictionary! If not found, show default.
      String explanation = _reactionDatabase[combinationKeys] ?? 
                           "You've mixed a complex soup! Without strong acids or bases, it becomes a murky mix with a default pH.";
      
      setState(() {
        _activeExplanation = explanation;
      });
      return;
    }

    // --- CATCH ELEMENT CLICKED (Periodic Table AR) ---
    if (trimmedMessage.startsWith("ELEMENT_CLICKED:")) {
      String atomicNumberStr = trimmedMessage.replaceFirst("ELEMENT_CLICKED:", "");
      _showElementDetails(atomicNumberStr);
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
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 50),
            SizedBox(height: 10),
            Text("Experiment Complete!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Great job! You have successfully completed this chemistry experiment.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF8BA3C0), fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF00D4FF).withValues(alpha: 0.5), width: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _closeUnityAndReturnToMenu(); // Return to main menu
            },
            child: const Text("Finish & Exit", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEarlyActivatorWarning(String ingredient) {
    String message = "Wait! Don't add the $ingredient yet. Mix the other ingredients first.";
    
    if (ingredient == "BeakerEmpty") {
      message = "The beaker is still empty! Pour the bottle first.";
    } else if (ingredient == "EmptyDish") {
      message = "There's no liquid solution on the dish plate yet!";
    } else if (ingredient == "PureBlood") {
      message = "You dipped the litmus paper in pure blood! The red color is just a blood stain. Mix the blood with water first to read its true pH.";
    } else if (ingredient == "ToxicGas") {
      message = "CRITICAL SAFETY VIOLATION: Mixing Bleach and Acid creates lethal Chlorine Gas! Resetting lab...";
      
      // Automatically reset the experiment after 4 seconds because they failed the safety check!
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _resetExperiment();
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
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

  void _resetExperiment() {
    // Tell Unity to reset the scene
    sendToUnity('FlutterReceiver', 'ResetExperiment', 'true');
    
    setState(() {
      _currentStepIndex = 0;
      _activeExplanation = null;
    });
    _notifyUnityActiveStep();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Experiment has been reset!'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showElementDetails(String atomicNumberStr) {
    final data = periodicTable[atomicNumberStr];
    if (data == null) {
      debugPrint("No element data found for Atomic Number: $atomicNumberStr");
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.transparent, // <-- REMOVES THE DARK OVERLAY!
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.48, // Almost half the screen
              height: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628).withValues(alpha: 0.6), // <-- MADE IT MORE TRANSPARENT!
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                border: Border(
                  left: BorderSide(color: const Color(0xFF00D4FF).withValues(alpha: 0.3), width: 1.5),
                  top: BorderSide(color: const Color(0xFF00D4FF).withValues(alpha: 0.3), width: 1.5),
                  bottom: BorderSide(color: const Color(0xFF00D4FF).withValues(alpha: 0.3), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(-10, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00D4FF)),
                          ),
                          child: Center(
                            child: Text(
                              data.symbol,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                data.category,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF8BA3C0)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "#${data.atomicNumber}",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF00D4FF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildElementStatBox("Protons", data.atomicNumber.toString()),
                        _buildElementStatBox("Mass", data.atomicMass.toStringAsFixed(1)),
                        _buildElementStatBox("Electrons", data.atomicNumber.toString()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text("FUN FACT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00D4FF), letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Text(
                      data.funFact,
                      style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildElementStatBox(String label, String value) {
    return Container(
      width: 90, // Adjusted width slightly to fit nicely
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8BA3C0).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8BA3C0))),
        ],
      ),
    );
  }

  void _showHint(ExperimentStep? currentStep) {
    if (currentStep == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Color(0xFF00D4FF)),
            SizedBox(width: 10),
            Text("Need a Hint?", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          currentStep.instructionDetail,
          style: const TextStyle(color: Color(0xFF8BA3C0), height: 1.5, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Got it!", style: TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF00D4FF).withValues(alpha: 0.5), width: 1.5),
        ),
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

            // --- UI OVERLAY FOR INSTRUCTIONS AND CONTROLS WHEN EXPERIMENT IS ACTIVE ---
            if (_isExperimentActive && !_isLoading && currentStepData != null) ...[
              
              // 1. ACTION BUTTONS (TOP LEFT)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EXIT BUTTON
                        FloatingActionButton(
                          heroTag: 'btn_exit',
                          mini: true,
                          backgroundColor: Colors.red[800],
                          onPressed: _closeUnityAndReturnToMenu,
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                        if (!_isPeriodicTable) const SizedBox(height: 12),
                        // RESET BUTTON
                        if (!_isPeriodicTable)
                          FloatingActionButton(
                            heroTag: 'btn_reset',
                            mini: true,
                            backgroundColor: Colors.orange[800],
                            onPressed: _resetExperiment,
                            child: const Icon(Icons.refresh, color: Colors.white),
                          ),
                        if (!_isPeriodicTable) const SizedBox(height: 12),
                        // HINT BUTTON
                        if (!_isPeriodicTable)
                          FloatingActionButton(
                            heroTag: 'btn_hint',
                            mini: true,
                            backgroundColor: const Color(0xFF00D4FF),
                            onPressed: () => _showHint(currentStepData),
                            child: const Icon(Icons.lightbulb_outline, color: Color(0xFF0A1628)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. PROGRESS & INSTRUCTION BOX (TOP RIGHT)
              if (!_isPeriodicTable)
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
                                Text(
                                  _activeExplanation != null ? "SCIENTIFIC ANALYSIS" : "PROGRESS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _activeExplanation != null ? const Color(0xFF00D4FF) : const Color(0xFF8BA3C0),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (_activeExplanation == null)
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
                              _activeExplanation != null ? "Reaction Result" : currentStepData.instructionTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _activeExplanation ?? currentStepData.instructionDetail,
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
            ],

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

            if (_showGuide && !_isPeriodicTable) _buildGuideOverlay(theme),

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

