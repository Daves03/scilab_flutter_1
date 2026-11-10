import '../../models/experiment_assessment.dart';
import '../../services/experiment_step_progress.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/activity_service.dart';
import '../../models/experiment_step.dart';
import '../../models/ar_experiment_model.dart';
import '../../models/experiment_grade.dart';
import '../../models/ppe_selection.dart';
import '../../data/dummy_ar_experiments.dart';
import '../../data/ar_experiment_catalog.dart';
import '../../data/periodic_table_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/flame_solution_dialog.dart';
import 'widgets/collapsible_steps_panel.dart';
import 'widgets/ppe_selection_dialog.dart';
import 'widgets/experiment_result_rubric.dart';

class UnityArScreen extends StatefulWidget {
  final String? experimentId;
  const UnityArScreen({super.key, this.experimentId});

  @override
  State<UnityArScreen> createState() => _UnityArScreenState();
}

class _UnityArScreenState extends State<UnityArScreen>
    with TickerProviderStateMixin {
  bool _isExperimentActive = false;
  bool _isLoading = false;
  bool _isClosingAr = false;
  // Unity remains in memory when an AR route is closed. A later route must
  // reuse its readiness rather than wait for the bootstrap scene to load again.
  static bool _unityRuntimeReady = false;
  final Completer<void> _unityReady = Completer<void>();
  bool _sceneLoadRequested = false;
  Timer? _startupTimeout;
  Timer? _sceneReadyTimer;
  String? _arStartupError;
  String? _activeExperimentId;
  final ActivityService _activityService = ActivityService();
  ActivitySyncStatus? _completionSyncStatus;
  PpeSelectionResult? _ppeSelectionResult;
  ExperimentAssessment _assessment = ExperimentAssessment.fromExperiment(
    '1',
    const {},
  );
  ExperimentGrade? _experimentGrade;
  bool _showKnowledgeCheck = false;
  bool _isAwaitingKnowledgeCheck = false;
  List<int?> _knowledgeAnswers = const [];
  int _sequenceErrors = 0;
  int _equipmentErrors = 0;

  // --- NEW: Instructional Guide State ---
  bool _showGuide = false;
  int _guideStep = 0;
  late AnimationController _guideAnimationController;

  bool get _isPeriodicTable =>
      _activeExperimentId == '8' || _activeExperimentId == 'ar8';
  bool get _isFlameTest =>
      _activeExperimentId == '4' || _activeExperimentId == 'ar4';
  bool get _isPhExperiment =>
      _activeExperimentId == '7' || _activeExperimentId == 'ar7';
  bool get _isSilverNitrate =>
      _activeExperimentId == '2' || _activeExperimentId == 'ar2';

  // --- Flame Solution State ---
  int _selectedFlameChemicalIndex = -1;
  bool _showFlameSolutionPicker = false;
  bool _isBurnerOn = false;

  bool get _showBurnerToggle =>
      _isFlameTest &&
      !_hasCompleted &&
      !_showFlameSolutionPicker &&
      _currentSteps.isNotEmpty &&
      _currentStepIndex < _currentSteps.length &&
      _isTagMatching(
        _currentSteps[_currentStepIndex].bottleTag,
        'Flame-Switch',
      );

  void _toggleBurner() {
    if (!_showBurnerToggle || !_isExperimentActive || _isLoading) return;
    sendToUnity(
      'FlutterReceiver',
      'SetBurnerState',
      _isBurnerOn ? 'off' : 'on',
    );
  }

  void _openFlameSolutionPicker() {
    setState(() {
      _showFlameSolutionPicker = true;
    });
  }

  void _onFlameSolutionSelected(FlameChemical chem) {
    // A selection sent before scene_ready can reach the previous scene or be
    // hidden again by FlameTestController.Start when the new scene initializes.
    if (!mounted || !_isExperimentActive || _isLoading || !_isFlameTest) {
      return;
    }

    setState(() {
      _selectedFlameChemicalIndex = chem.index;
      _showFlameSolutionPicker = false;
    });

    // Send one canonical selection. Sending both the index and name to both
    // receivers made Unity hide/reset every bottle four times, which could
    // leave a model invisible while the embedded Unity view was resuming.
    debugPrint(
      'Flame selection: ${chem.elementName}, index=${chem.index}, '
      'receiver=FlutterReceiver.SelectFlameChemical',
    );
    sendToUnity(
      'FlutterReceiver',
      'SelectFlameChemical',
      chem.index.toString(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.whatshot_rounded, color: chem.flameColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${chem.fullName} (${chem.formula}) ready! Flame burns ${chem.flameColorName}.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0A1628),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: chem.flameColor, width: 1.5),
          ),
        ),
      );
    }
  }

  // --- NEW: Step tracking variables ---
  int _currentStepIndex = 0;
  List<ExperimentStep> _currentSteps = [];
  String? _activeExplanation;
  bool _hasCompleted = false;
  bool _showCompletionPopup = false;
  ExperimentStepProgress? _stepProgress;
  bool _isWarningDialogShowing = false;
  bool _isDropButtonCoolingDown = false;
  bool _isSilverNitrateDropReady = false;
  int _silverNitrateDropCount = 0;

  bool get _showSilverNitrateDropButton {
    if (!_isSilverNitrate ||
        !_isSilverNitrateDropReady ||
        _hasCompleted ||
        _showCompletionPopup) {
      return false;
    }
    if (_currentSteps.isEmpty || _currentStepIndex >= _currentSteps.length) {
      return false;
    }
    return _isTagMatching(
      _currentSteps[_currentStepIndex].bottleTag,
      'DropperDrop',
    );
  }

  Future<void> _dropSilverNitrate() async {
    if (_isDropButtonCoolingDown || !_showSilverNitrateDropButton) return;

    setState(() {
      _isDropButtonCoolingDown = true;
      if (_silverNitrateDropCount < 5) _silverNitrateDropCount++;
    });

    // The DropperButtonControl component is attached to this scene object.
    // Unity still owns the particles, VFX, cooldown, and completion event.
    sendToUnity('dropper', 'OnDropButtonClicked', '');

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted && !_hasCompleted) {
      setState(() => _isDropButtonCoolingDown = false);
    }
  }

  bool _isTagMatching(String tagA, String tagB) =>
      experimentTagsMatch(tagA, tagB);

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
    _isExperimentActive = false;
    _isWarningDialogShowing = false;
    _cancelUnityStartup();
    _guideAnimationController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _cancelUnityStartup() {
    _startupTimeout?.cancel();
    _sceneReadyTimer?.cancel();
    if (!_unityReady.isCompleted) _unityReady.complete();
  }

  void _failUnityStartup(String message) {
    if (!mounted || !_isExperimentActive || !_isLoading) return;
    _cancelUnityStartup();
    debugPrint('AR startup failed: $message');
    setState(() => _arStartupError = message);
  }

  Future<void> _loadUnityExperiment(String sceneId) async {
    // On a cold launch, FlutterReceiver does not exist until the bootstrap
    // scene reports scene_ready. Sending LoadExperiment earlier loses it.
    if (!_unityRuntimeReady) await _unityReady.future;
    if (!mounted || !_isExperimentActive || _arStartupError != null) return;

    // Let the native view attach/resume and drain bootstrap notifications
    // before accepting a readiness notification for the requested experiment.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_isExperimentActive || _arStartupError != null) return;

    _sceneLoadRequested = true;
    debugPrint('AR startup: loading Unity experiment $sceneId');
    sendToUnity('FlutterReceiver', 'LoadExperiment', sceneId);
  }

  Future<void> _launchExperiment(String experimentId) async {
    // Extract only digits: "Exp1" or "ar1" becomes "1"
    final normalizedId = experimentId.replaceAll(RegExp(r'[^0-9]'), '');

    final role = context.read<AuthService>().currentUser?.role;
    if (!canRoleAccessExperiment(role, experimentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This experiment is not available for your grade level.',
          ),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final fallbackExperiment = dummyArExperiments.firstWhere(
      (experiment) =>
          experiment.id.replaceAll(RegExp(r'[^0-9]'), '') == normalizedId,
      orElse: () => dummyArExperiments.first,
    );
    var launchExperiment = fallbackExperiment;
    var assessmentData = <String, dynamic>{};
    // Load PPE, questions and guide together. This snapshot stays fixed for
    // the run so teacher edits cannot change an answer key halfway through.
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ar_experiments')
          .doc(experimentId)
          .get()
          .timeout(const Duration(seconds: 10));
      if (snapshot.exists) {
        assessmentData = snapshot.data()!;
        launchExperiment = ArExperimentModel.fromMap(
          snapshot.id,
          assessmentData,
        );
      }
    } catch (error) {
      debugPrint('Using built-in experiment settings: $error');
    }
    if (!mounted) return;
    _assessment = ExperimentAssessment.fromExperiment(
      experimentId,
      assessmentData,
    );

    // PPE and the AR scene both use landscape. The PPE dialog uses a compact
    // two-column checklist so every choice remains visible at once.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;

    final requiredPpe = _assessment.requiredPpe;
    if (normalizedId != '8' && requiredPpe.isNotEmpty) {
      final ppeResult = await showDialog<PpeSelectionResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PpeSelectionDialog(
          experimentTitle: launchExperiment.title,
          requiredPpe: requiredPpe,
          options: _assessment.ppeChoices,
        ),
      );
      if (!mounted) return;
      if (ppeResult == null) {
        Navigator.of(context).pop();
        return;
      }
      _ppeSelectionResult = ppeResult;
    } else {
      _ppeSelectionResult = null;
    }

    final status = await Permission.camera.request();

    // --- ADD THIS LINE TO FIX THE ASYNC WARNING ---
    if (!mounted) {
      return;
    }

    if (status.isGranted) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (!mounted) return;

      setState(() {
        _isExperimentActive = true;
        _isLoading = true;
        _arStartupError = null;
        _sceneLoadRequested = false;
        _activeExperimentId = experimentId;
        _currentStepIndex = 0; // Reset steps on launch
        _hasCompleted = false;
        _completionSyncStatus = null;
        _experimentGrade = null;
        _showKnowledgeCheck = false;
        _isAwaitingKnowledgeCheck = false;
        _knowledgeAnswers = List<int?>.filled(
          _assessment.questions.length,
          null,
        );
        _sequenceErrors = 0;
        _equipmentErrors = 0;
        _showCompletionPopup = false;
        _silverNitrateDropCount = 0;
        _isDropButtonCoolingDown = false;
        _isSilverNitrateDropReady = false;
        _stepProgress = null;
        _selectedFlameChemicalIndex = -1;
        _isBurnerOn = false;
        _showFlameSolutionPicker =
            (experimentId == '4' || experimentId == 'ar4');
      });

      _startupTimeout = Timer(const Duration(seconds: 45), () {
        _failUnityStartup(
          'The AR scene could not start. Go back and open the experiment '
          'again. If this continues, close and reopen the app.',
        );
      });

      _currentSteps = launchExperiment.steps.isNotEmpty
          ? launchExperiment.steps
          : fallbackExperiment.steps;

      _stepProgress = ExperimentStepProgress(
        _currentSteps.map((step) => step.bottleTag),
      );

      await _loadUnityExperiment(normalizedId);

      if (!mounted || !_isExperimentActive || _arStartupError != null) return;
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null) {
        _activityService.logExperimentLaunch(uid, experimentId);
      }
    } else {
      if (!mounted) return;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera access is required to run AR experiments.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _closeUnityAndReturnToMenu() async {
    if (!mounted || _isClosingAr) return;

    setState(() {
      _isClosingAr = true;
      _isExperimentActive = false;
    });
    _cancelUnityStartup();
    if (_isWarningDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isWarningDialogShowing = false;
    }
    ScaffoldMessenger.of(context).clearSnackBars();

    // Give the platform view one frame to detach and pause Unity before the
    // route and its landscape surface are removed. This also prevents a fast
    // second back/exit event from popping the screen behind the AR route.
    await WidgetsBinding.instance.endOfFrame;
    await Future.wait<void>([
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    ]);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // --- Tell Unity which bottle ID is currently active ---
  void _notifyUnityActiveStep() {
    if (_currentSteps.isEmpty) {
      return;
    }
    sendToUnity(
      'FlutterReceiver',
      'SetStepPlan',
      jsonEncode({
        'tags': _currentSteps.map((step) => step.bottleTag).toList(),
      }),
    );
    final activeTag = _hasCompleted
        ? 'COMPLETED'
        : _stepProgress?.pendingTag(_currentStepIndex) ??
              _currentSteps[_currentStepIndex].bottleTag;

    // Send active step configuration to Unity's receiver
    sendToUnity('FlutterReceiver', 'SetActiveStep', activeTag);
  }

  // --- DYNAMIC REACTION EXPLANATIONS ---
  final Map<String, String> _reactionDatabase = {
    "bleach_lemon":
        "DANGER! Bleach (strong base) and Lemon (acid) react to create toxic Chlorine Gas! The pH remains highly alkaline (purple) because bleach dominates.",
    "bleach_soap":
        "DANGER! Bleach and ammonia-based soaps react to form toxic Chloramine Gas, which severely irritates eyes and lungs!",
    "bleach_blood":
        "Bleach is a powerful oxidizer. It destroys the hemoglobin in the blood, turning it dirty yellow. The pH is highly alkaline (purple).",
    "lemon_soap":
        "Acid-Base Neutralization! The acid in the lemon neutralizes the alkaline soap, creating a neutral (green) pH. The mixture turns cloudy as fatty acids separate.",
    "blood_lemon":
        "The acid from the lemon 'denatures' (cooks) the proteins in the blood, causing it to coagulate into a dark mass. The Litmus shows an acidic (orange) pH.",
    "blood_soap":
        "Hemolysis! The surfactants in the soap destroy the red blood cell membranes, making them burst into a clear red liquid. Litmus shows an alkaline (blue) pH.",
    "blood_water":
        "Water dilutes the blood, making it lighter in color. However, blood is buffered, so its pH remains safely around 7.4 (Teal).",
    "bleach":
        "Bleach is an extremely strong base. It overpowers the other substances, turning the Litmus paper purple (pH 13).",
    "lemon":
        "Lemon juice is a strong acid. It dominates the mixture, causing the Litmus paper to read highly acidic (orange).",
    "soap":
        "Soap is a moderate base. It dominates the mixture, turning the Litmus paper blue (pH 9).",
    "pure_blood":
        "Pure blood stains the paper red! You must dilute it with water first to read its true pH.",
    "pure_water":
        "You are testing pure water. The Litmus paper shows its natural pH level (Neutral/Green).",
    "pure_lemon":
        "You are testing pure lemon juice. The Litmus paper shows its natural pH level (Highly Acidic/Orange).",
    "pure_soap":
        "You are testing pure liquid soap. The Litmus paper shows its natural pH level (Basic/Blue).",
    "pure_bleach":
        "You are testing pure bleach. The Litmus paper shows its natural pH level (Highly Basic/Purple).",
    "complex_mix":
        "You've mixed a complex soup! Without strong acids or bases, it becomes a murky mix with a default pH.",
  };

  void _handleMessageFromUnity(String message) {
    final trimmedMessage = message.trim();
    debugPrint('Received from Unity: "$trimmedMessage"');

    if (trimmedMessage == 'show_menu' || trimmedMessage == 'EXPERIMENT_EXIT') {
      // A cold Unity launch can enter its menu before Flutter requests the
      // experiment. That bootstrap notification is not a user exit.
      if (mounted && _isExperimentActive && _sceneLoadRequested) {
        _closeUnityAndReturnToMenu();
      }
      return;
    }

    if (!mounted || !_isExperimentActive) return;

    if (trimmedMessage.startsWith('BURNER_STATE:')) {
      if (_isFlameTest) {
        setState(() => _isBurnerOn = trimmedMessage == 'BURNER_STATE:on');
      }
      return;
    }

    if (trimmedMessage == 'scene_ready') {
      _unityRuntimeReady = true;
      if (!_unityReady.isCompleted) _unityReady.complete();
      // Bootstrap readiness only unlocks LoadExperiment. It must not reveal
      // controls or the flame picker before the experiment itself has loaded.
      if (!_sceneLoadRequested || !_isLoading || _arStartupError != null) {
        return;
      }
      final readyExperimentId = _activeExperimentId;
      _sceneReadyTimer?.cancel();
      _sceneReadyTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted &&
            _isExperimentActive &&
            _arStartupError == null &&
            _activeExperimentId == readyExperimentId) {
          _startupTimeout?.cancel();
          setState(() {
            _isLoading = false;
            _showGuide =
                !_isFlameTest; // Don't block flame picker with interaction guide
            if (_isFlameTest && _selectedFlameChemicalIndex == -1) {
              _showFlameSolutionPicker = true;
            }
          });
          _notifyUnityActiveStep(); // Send first step as soon as scene is ready
        }
      });
      return;
    }

    if (trimmedMessage == 'DROP_BUTTON_READY:DropperDrop') {
      setState(() {
        _isSilverNitrateDropReady = true;
        _silverNitrateDropCount = 0;
        _isDropButtonCoolingDown = false;
      });
      return;
    }

    // --- CATCH EARLY ACTIVATOR WARNING ---
    if (trimmedMessage.startsWith("WARNING:")) {
      String ingredient = trimmedMessage.replaceFirst("WARNING:", "");

      // Safety check: If Flutter is already on this step, treat warning as false alarm and re-sync Unity
      if (_currentSteps.isNotEmpty &&
          _currentStepIndex < _currentSteps.length) {
        final currentTag = _currentSteps[_currentStepIndex].bottleTag;

        bool isCurrentTarget = _isTagMatching(ingredient, currentTag);

        if (isCurrentTarget) {
          debugPrint(
            "⚠️ Suppressing false warning for current active step: $ingredient. Re-syncing Unity.",
          );
          _notifyUnityActiveStep();
          return;
        }
      }

      _sequenceErrors++;
      _showEarlyActivatorWarning(ingredient);
      return;
    }

    // --- CATCH EXPLANATION FROM UNITY (Dynamic Lookup) ---
    if (trimmedMessage.startsWith("EXPLANATION:")) {
      // Unity sends: "EXPLANATION:bleach,lemon"
      String combinationKeys = trimmedMessage.replaceFirst("EXPLANATION:", "");

      // Look it up in our dynamic dictionary! If not found, show default.
      final knownExplanation = _reactionDatabase[combinationKeys];
      final explanation =
          knownExplanation ??
          (combinationKeys.contains(' ')
              ? combinationKeys
              : "You've mixed a complex soup! Without strong acids or bases, it becomes a murky mix with a default pH.");

      setState(() {
        _activeExplanation = explanation;
      });

      // pH is exploratory: any valid litmus result completes the activity,
      // regardless of how many optional solution steps the admin listed.
      if (_isPhExperiment) _handleExperimentComplete();
      return;
    }

    // --- CATCH ELEMENT CLICKED (Periodic Table AR) ---
    if (trimmedMessage.startsWith("ELEMENT_CLICKED:")) {
      String atomicNumberStr = trimmedMessage.replaceFirst(
        "ELEMENT_CLICKED:",
        "",
      );
      _showElementDetails(atomicNumberStr);
      return;
    }

    // --- CATCH STEP COMPLETION ---
    if (trimmedMessage.startsWith("STEP_COMPLETED")) {
      if (_hasCompleted) return;
      String completedItem = "";
      if (trimmedMessage.contains(":")) {
        completedItem = trimmedMessage
            .substring(trimmedMessage.indexOf(":") + 1)
            .trim();
      }

      if (_currentSteps.isEmpty) return;

      final progress = _stepProgress ??= ExperimentStepProgress(
        _currentSteps.map((step) => step.bottleTag),
      );
      final completion = progress.complete(completedItem);
      if (completion == StepCompletion.unknown) {
        _equipmentErrors++;
        debugPrint(
          'Ignoring completion for unconfigured model: $completedItem',
        );
        return;
      }
      if (completion == StepCompletion.duplicate) return;
      setState(() {
        _currentStepIndex = progress.nextIndex;
      });
      if (progress.finished) {
        _handleExperimentComplete();
      } else {
        _notifyUnityActiveStep();
      }
      return;
    }
  }

  void _handleExperimentComplete() {
    if (_isPeriodicTable) return;
    if (!mounted) return;
    if (_hasCompleted) return;
    setState(() {
      _hasCompleted = true;
      _knowledgeAnswers = List<int?>.filled(_assessment.questions.length, null);
      _isAwaitingKnowledgeCheck = true;
    });
    _notifyUnityActiveStep();
  }

  void _openKnowledgeCheck() {
    if (_isPeriodicTable) return;
    if (!mounted || !_isAwaitingKnowledgeCheck) return;
    setState(() {
      _isAwaitingKnowledgeCheck = false;
      _showKnowledgeCheck = true;
    });
  }

  Widget _buildObservationPrompt() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.fromLTRB(84, 12, 84, 18),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility_rounded, color: Color(0xFF00D4FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isPhExperiment
                      ? 'Observe the final litmus color and compare it with the pH color scale before continuing.'
                      : 'Observe the final reaction and result before continuing.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _openKnowledgeCheck,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: const Color(0xFF07111F),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitKnowledgeCheck() {
    if (_isPeriodicTable) return;
    final experimentId = _activeExperimentId;
    if (experimentId == null) return;
    final questions = _assessment.questions;
    if (_knowledgeAnswers
        .take(questions.length)
        .any((answer) => answer == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Answer all ${questions.length} questions to continue.',
          ),
        ),
      );
      return;
    }

    var correctAnswers = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_knowledgeAnswers[i] == questions[i].correctOption) {
        correctAnswers++;
      }
    }

    final grade = ExperimentGrade(
      ppeScore: _ppeSelectionResult?.score ?? 25,
      procedureSequenceEquipmentScore:
          (25 - (_sequenceErrors * 5) - (_equipmentErrors * 2)).clamp(0, 25),
      resultScore: 25,
      understandingScore: questions.isEmpty
          ? 0
          : ((correctAnswers / questions.length) * 25).round().clamp(0, 25),
      correctUnderstandingAnswers: correctAnswers,
      totalUnderstandingQuestions: questions.length,
      sequenceErrors: _sequenceErrors,
      equipmentErrors: _equipmentErrors,
    );

    setState(() {
      _experimentGrade = grade;
      _showKnowledgeCheck = false;
      _showCompletionPopup = true;
    });
    _saveExperimentGrade(grade);
  }

  void _saveExperimentGrade(ExperimentGrade grade) {
    if (_isPeriodicTable) return;
    try {
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid == null || _activeExperimentId == null) return;
      _activityService
          .markExperimentCompleted(
            uid,
            _activeExperimentId!,
            ppeScore: _ppeSelectionResult?.score,
            selectedPpe: _ppeSelectionResult?.selected.toList(),
            requiredPpe: _ppeSelectionResult?.required.toList(),
            rubricScores: grade.toMap(),
          )
          .then(
            (status) {
              if (mounted) setState(() => _completionSyncStatus = status);
            },
            onError: (Object error) {
              debugPrint('Failed to queue experiment grade: $error');
              if (mounted) {
                setState(
                  () => _completionSyncStatus = ActivitySyncStatus.pending,
                );
              }
            },
          );
    } catch (error) {
      debugPrint('Could not save experiment grade: $error');
    }
  }

  Widget _buildKnowledgeCheck() {
    final questions = _assessment.questions;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: Center(
          child: Container(
            width: 620,
            constraints: const BoxConstraints(maxHeight: 520),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz_rounded, color: Color(0xFF00D4FF)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Experiment Check',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '25 points • ${questions.length} questions',
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Answer using what you observed and learned in the experiment.',
                    style: TextStyle(color: Color(0xFF8BA3C0)),
                  ),
                ),
                const Divider(height: 22, color: Color(0x3300D4FF)),
                Expanded(
                  child: ListView.separated(
                    itemCount: questions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, questionIndex) {
                      final question = questions[questionIndex];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${questionIndex + 1}. ${question.prompt}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            RadioGroup<int>(
                              groupValue: _knowledgeAnswers[questionIndex],
                              onChanged: (value) {
                                setState(() {
                                  final answers = List<int?>.from(
                                    _knowledgeAnswers,
                                  );
                                  answers[questionIndex] = value;
                                  _knowledgeAnswers = answers;
                                });
                              },
                              child: Column(
                                children: List.generate(
                                  question.options.length,
                                  (optionIndex) {
                                    return RadioListTile<int>(
                                      value: optionIndex,
                                      title: Text(
                                        question.options[optionIndex],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      activeColor: const Color(0xFF00D4FF),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitKnowledgeCheck,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Submit and view grade'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPopup() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.sizeOf(context).height - 24,
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Experiment Complete!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Great job! You have successfully completed this chemistry experiment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8BA3C0),
                              fontSize: 16,
                            ),
                          ),
                          if (_experimentGrade != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              '${_experimentGrade!.totalScore}/100',
                              style: const TextStyle(
                                color: Color(0xFF00FF88),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              _experimentGrade!.performanceLevel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ExperimentResultRubric(
                                grade: _experimentGrade!,
                                ppeResult: _ppeSelectionResult,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            switch (_completionSyncStatus) {
                              ActivitySyncStatus.synced => 'Progress synced.',
                              ActivitySyncStatus.permissionDenied =>
                                'Progress saved on this device. Sync is waiting for account permission.',
                              ActivitySyncStatus.pending =>
                                'Progress saved on this device and will sync when you are online.',
                              null => 'Saving progress on this device…',
                            },
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _completionSyncStatus ==
                                      ActivitySyncStatus.synced
                                  ? const Color(0xFF00FF88)
                                  : const Color(0xFFFFC857),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 14, color: Color(0x3300D4FF)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      onPressed: _closeUnityAndReturnToMenu,
                      label: const Text(
                        'Finish',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEarlyActivatorWarning(String ingredient) {
    if (!mounted || !_isExperimentActive || _isWarningDialogShowing) return;

    _isWarningDialogShowing = true;

    String title = "Wait! Mix Ingredients First";
    String message =
        "Don't add the $ingredient yet. Mix all other preparatory ingredients first before using the activator.";
    Color accentColor = const Color(0xFFFFB800);
    IconData iconData = Icons.warning_amber_rounded;

    if (ingredient == "BeakerEmpty") {
      title = "Beaker Is Empty";
      message =
          "The beaker is still empty! Pour the solution into the beaker first.";
    } else if (ingredient == "EmptyDish") {
      title = "Dish Plate Is Empty";
      message =
          "There's no chemical solution on the dish plate yet! Pour a chemical solution first.";
    } else if (ingredient == "WireNotCoated") {
      title = "Coat the Wire First";
      message =
          "Dip the wire in the chemical solution before placing it in the flame.";
    } else if (ingredient == "PureBlood") {
      title = "Mix Blood with Water";
      message =
          "Mix the blood with water before testing. Undiluted blood is thick and will stain the litmus paper instead of showing a clear color change.";
    } else if (ingredient == "ToxicGas" || ingredient == "ChloramineGas") {
      title = "Critical Safety Violation";
      accentColor = const Color(0xFFFF4D4D);
      iconData = Icons.dangerous_rounded;
      if (ingredient == "ChloramineGas") {
        message =
            "CRITICAL SAFETY VIOLATION: Mixing Bleach and Detergent/Soap creates toxic Chloramine Gas! Resetting lab...";
      } else {
        message =
            "CRITICAL SAFETY VIOLATION: Mixing Bleach and Acid (Lemon) creates lethal Chlorine Gas! Resetting lab...";
      }

      // Automatically reset the experiment after 4 seconds because they failed the safety check!
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _isExperimentActive) {
          if (_isWarningDialogShowing) {
            Navigator.of(context, rootNavigator: true).pop();
            _isWarningDialogShowing = false;
          }
          _resetExperiment();
        }
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accentColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        title: Column(
          children: [
            Icon(iconData, color: accentColor, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8BA3C0),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _isWarningDialogShowing = false;
              // Reset any dragging / selection in Unity immediately so bottle never flies away
              sendToUnity('FlutterReceiver', 'OnWarningDismissed', '');
              sendToUnity('Flame', 'OnWarningDismissed', '');
              if (ingredient == "ToxicGas" || ingredient == "ChloramineGas") {
                _resetExperiment();
              }
            },
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isWarningDialogShowing = false;
      sendToUnity('FlutterReceiver', 'OnWarningDismissed', '');
      sendToUnity('Flame', 'OnWarningDismissed', '');
    });
  }

  void _resetExperiment() {
    // Tell Unity to reset the scene
    sendToUnity('FlutterReceiver', 'ResetExperiment', 'true');

    setState(() {
      _currentStepIndex = 0;
      _activeExplanation = null;
      _hasCompleted = false;
      _showCompletionPopup = false;
      _showKnowledgeCheck = false;
      _isAwaitingKnowledgeCheck = false;
      _experimentGrade = null;
      _knowledgeAnswers = List<int?>.filled(_assessment.questions.length, null);
      _sequenceErrors = 0;
      _equipmentErrors = 0;
      _selectedFlameChemicalIndex = -1;
      _isBurnerOn = false;
      _silverNitrateDropCount = 0;
      _isDropButtonCoolingDown = false;
      _isSilverNitrateDropReady = false;
      _stepProgress = ExperimentStepProgress(
        _currentSteps.map((step) => step.bottleTag),
      );
      if (_isFlameTest) {
        _showFlameSolutionPicker = true;
      }
    });
    _notifyUnityActiveStep();

    if (_isExperimentActive && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Experiment has been reset!'),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showElementDetails(String atomicNumberStr) {
    final data =
        getElementData(atomicNumberStr) ?? periodicTable[atomicNumberStr];
    if (data == null) {
      debugPrint("No element data found for: $atomicNumberStr");
      return;
    }
    final realWorldUse = realWorldUsesByAtomicNumber[data.atomicNumber];
    final detailsScrollController = ScrollController();

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
              width:
                  MediaQuery.of(context).size.width *
                  0.48, // Almost half the screen
              height: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF0A1628,
                ).withValues(alpha: 0.6), // <-- MADE IT MORE TRANSPARENT!
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  top: BorderSide(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  bottom: BorderSide(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(-10, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: detailsScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(10),
                      child: SingleChildScrollView(
                        controller: detailsScrollController,
                        padding: const EdgeInsets.only(right: 14),
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
                                    color: const Color(
                                      0xFF00D4FF,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF00D4FF),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.symbol,
                                      style: TextStyle(
                                        fontSize: data.symbol.length > 3
                                            ? 18
                                            : 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        data.category,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8BA3C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  data.atomicMass > 0
                                      ? "#${data.atomicNumber}"
                                      : data.symbol,
                                  style: TextStyle(
                                    fontSize: data.atomicMass > 0 ? 32 : 24,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF00D4FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (data.atomicMass > 0) ...[
                                  _buildElementStatBox(
                                    "Protons",
                                    data.atomicNumber.toString(),
                                  ),
                                  _buildElementStatBox(
                                    "Mass",
                                    data.atomicMass.toStringAsFixed(1),
                                  ),
                                  _buildElementStatBox(
                                    "Electrons",
                                    data.atomicNumber.toString(),
                                  ),
                                ] else ...[
                                  _buildElementStatBox("Elements", "15"),
                                  _buildElementStatBox("Range", data.symbol),
                                  _buildElementStatBox("Type", "Series"),
                                ],
                              ],
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              "FUN FACT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00D4FF),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data.funFact,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                            if (realWorldUse != null) ...[
                              const SizedBox(height: 28),
                              const Text(
                                "REAL-WORLD EXAMPLE — WHY?",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF00D4FF),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00D4FF,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00D4FF,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.public_rounded,
                                      color: Color(0xFF00D4FF),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        realWorldUse,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_up_rounded,
                          color: Color(0xFF00D4FF),
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Swipe up to see more",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
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
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    ).whenComplete(detailsScrollController.dispose);
  }

  Widget _buildElementStatBox(String label, String value) {
    return Container(
      width: 90, // Adjusted width slightly to fit nicely
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8BA3C0).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8BA3C0)),
          ),
        ],
      ),
    );
  }

  void _openInteractionGuide() {
    if (!mounted) return;
    setState(() {
      _guideStep = 0;
      _showGuide = true;
    });
  }

  void _nextGuideStep() {
    setState(() {
      if (_guideStep < 2) {
        _guideStep++;
      } else {
        _showGuide = false;
        if (_isFlameTest && _selectedFlameChemicalIndex == -1) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _openFlameSolutionPicker();
          });
        }
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
                    _guideStep < 2
                        ? "OBJECT INTERACTION GUIDE"
                        : "CAMERA ANGLE GUIDE",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF8BA3C0),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                      ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _guideStep == 2 ? "FINISH" : "NEXT",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
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
      case 0:
        return "Touch and drag the item to its target.";
      case 1:
        return "The item will move automatically after making contact.";
      case 2:
        return "BEST CAMERA ANGLE FOR DOING THE EXPERIMENT";
      default:
        return "";
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
      "DEBUG: Active=$_isExperimentActive, Loading=$_isLoading, StepsCount=${_currentSteps.length}, CurrentStepIndex=$_currentStepIndex",
    );

    return PopScope(
      canPop: _isClosingAr,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        unawaited(_closeUnityAndReturnToMenu());
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Offstage still creates its child. Mount Unity only after camera
            // permission and landscape setup have completed.
            if (_isExperimentActive)
              EmbedUnity(onMessageFromUnity: _handleMessageFromUnity),

            // --- UI OVERLAY FOR INSTRUCTIONS AND CONTROLS WHEN EXPERIMENT IS ACTIVE ---
            if (_isExperimentActive &&
                !_isLoading &&
                currentStepData != null) ...[
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
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                          ),
                        if (!_isPeriodicTable) const SizedBox(height: 12),
                        // REOPEN THE ORIGINAL INTERACTION GUIDE
                        if (!_isPeriodicTable)
                          FloatingActionButton(
                            heroTag: 'btn_guide',
                            mini: true,
                            backgroundColor: const Color(0xFF00D4FF),
                            tooltip: 'View operating guide',
                            onPressed: _openInteractionGuide,
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: Color(0xFF0A1628),
                            ),
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
                      child: CollapsibleStepsPanel(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0A1628,
                            ).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(
                                0xFF00D4FF,
                              ).withValues(alpha: 0.3),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _activeExplanation != null
                                        ? "SCIENTIFIC ANALYSIS"
                                        : "PROGRESS",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _activeExplanation != null
                                          ? const Color(0xFF00D4FF)
                                          : const Color(0xFF8BA3C0),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (_activeExplanation == null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00D4FF,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF00D4FF,
                                          ).withValues(alpha: 0.4),
                                        ),
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
                                _activeExplanation != null
                                    ? "Reaction Result"
                                    : currentStepData.instructionTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _activeExplanation ??
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
                ),

              // Silver nitrate uses Flutter UI while Unity runs the drop VFX.
              if (_showBurnerToggle && !_showGuide)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FilledButton.icon(
                        onPressed: _toggleBurner,
                        style: FilledButton.styleFrom(
                          backgroundColor: _isBurnerOn
                              ? Colors.deepOrange
                              : const Color(0xFF00D4FF),
                          foregroundColor: _isBurnerOn
                              ? Colors.white
                              : const Color(0xFF0A1628),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        icon: Icon(
                          _isBurnerOn
                              ? Icons.local_fire_department
                              : Icons.power_settings_new,
                        ),
                        label: Text(
                          _isBurnerOn ? 'TURN BURNER OFF' : 'TURN BURNER ON',
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showSilverNitrateDropButton && !_showGuide)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FilledButton.icon(
                        onPressed: _isDropButtonCoolingDown
                            ? null
                            : _dropSilverNitrate,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: const Color(0xFF0A1628),
                          disabledBackgroundColor: const Color(
                            0xFF00D4FF,
                          ).withValues(alpha: 0.45),
                          disabledForegroundColor: const Color(
                            0xFF0A1628,
                          ).withValues(alpha: 0.65),
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                        icon: _isDropButtonCoolingDown
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF0A1628),
                                ),
                              )
                            : const Icon(Icons.water_drop_rounded),
                        label: Text(
                          _silverNitrateDropCount == 0
                              ? 'ADD DROP'
                              : 'ADD DROP  $_silverNitrateDropCount/5',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],

            if (_isLoading)
              Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_arStartupError == null)
                        const CircularProgressIndicator()
                      else
                        const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _arStartupError ?? 'Preparing Chemistry Lab...',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _closeUnityAndReturnToMenu,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to experiments'),
                      ),
                    ],
                  ),
                ),
              ),

            if (_showGuide && !_isPeriodicTable) _buildGuideOverlay(theme),

            // FULL-SCREEN FLAME SOLUTION PICKER OVERLAY (REPLACES UNITY CANVAS)
            if (_isExperimentActive &&
                !_isLoading &&
                _isFlameTest &&
                _showFlameSolutionPicker)
              Positioned.fill(
                child: FlameSolutionPickerView(
                  selectedIndex: _selectedFlameChemicalIndex,
                  onSelectChemical: _onFlameSolutionSelected,
                  onBack: () {
                    if (_selectedFlameChemicalIndex == -1) {
                      _closeUnityAndReturnToMenu();
                    } else {
                      setState(() {
                        _showFlameSolutionPicker = false;
                      });
                    }
                  },
                ),
              ),

            if (_isAwaitingKnowledgeCheck) _buildObservationPrompt(),

            if (_showKnowledgeCheck) _buildKnowledgeCheck(),
            if (_showCompletionPopup) _buildCompletionPopup(),
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(phoneRect, const Radius.circular(3)),
      phonePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
