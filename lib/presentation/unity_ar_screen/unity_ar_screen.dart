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
import 'widgets/flame_solution_dialog.dart';

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
  String? _activeExperimentId;
  final ActivityService _activityService = ActivityService();
  ActivitySyncStatus? _completionSyncStatus;

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

  void _openFlameSolutionPicker() {
    setState(() {
      _showFlameSolutionPicker = true;
    });
  }

  void _onFlameSolutionSelected(FlameChemical chem) {
    setState(() {
      _selectedFlameChemicalIndex = chem.index;
      _showFlameSolutionPicker = false;
    });

    // Send one canonical selection. Sending both the index and name to both
    // receivers made Unity hide/reset every bottle four times, which could
    // leave a model invisible while the embedded Unity view was resuming.
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
  final Set<int> _completedStepIndices = {};
  final Set<String> _completedSubTagsForCurrentStep = {};
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

  String _normalizeTag(String tag) {
    return tag.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
  }

  bool _isPureAlias(String tag) {
    final norm = _normalizeTag(tag);
    if (norm.contains('electrode') && norm.contains('redwire')) {
      return true;
    }
    return false;
  }

  bool _isTagMatching(String tagA, String tagB) {
    // 1. Check compound / comma-separated lists first (e.g. "Rod1,Rod2")
    if (tagB.contains(',')) {
      final list = tagB.split(',').map((t) => t.trim());
      for (final item in list) {
        if (_isTagMatching(tagA, item)) return true;
      }
      return false;
    }

    if (tagA.contains(',')) {
      final list = tagA.split(',').map((t) => t.trim());
      for (final item in list) {
        if (_isTagMatching(item, tagB)) return true;
      }
      return false;
    }

    final normA = _normalizeTag(tagA);
    final normB = _normalizeTag(tagB);
    if (normA.isEmpty || normB.isEmpty) return false;

    // Exact match
    if (normA == normB) return true;

    // Differentiate "2wayblackwire" from "blackwire"
    final aIs2Way = normA.contains('2way') || normA.contains('twoway');
    final bIs2Way = normB.contains('2way') || normB.contains('twoway');
    if (aIs2Way != bIs2Way &&
        (normA.contains('wire') || normB.contains('wire'))) {
      return false; // One is 2-way and the other is not, NEVER match!
    }

    // Differentiate "rod1" from "rod2"
    final aHasRod1 = normA.contains('rod1');
    final bHasRod1 = normB.contains('rod1');
    final aHasRod2 = normA.contains('rod2');
    final bHasRod2 = normB.contains('rod2');
    if ((aHasRod1 && bHasRod2) || (aHasRod2 && bHasRod1)) {
      return false; // Rod1 and Rod2 are distinct!
    }

    // Known Aliases:
    if ((normA.contains('electrode') || normA.contains('redwire')) &&
        (normB.contains('electrode') || normB.contains('redwire'))) {
      return true;
    }

    if (normA.contains(normB) || normB.contains(normA)) return true;

    return false;
  }

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
    if (!mounted) {
      return;
    }

    if (status.isGranted) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      setState(() {
        _isExperimentActive = true;
        _isLoading = true;
        _activeExperimentId = experimentId;
        _currentStepIndex = 0; // Reset steps on launch
        _hasCompleted = false;
        _completionSyncStatus = null;
        _showCompletionPopup = false;
        _silverNitrateDropCount = 0;
        _isDropButtonCoolingDown = false;
        _isSilverNitrateDropReady = false;
        _completedStepIndices.clear();
        _completedSubTagsForCurrentStep.clear();
        _selectedFlameChemicalIndex = -1;
        _showFlameSolutionPicker =
            (experimentId == '4' || experimentId == 'ar4');
      });

      // Fetch dynamic steps from Firestore
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('ar_experiments')
            .doc(experimentId)
            .get();
        if (docSnapshot.exists) {
          final experimentModel = ArExperimentModel.fromMap(
            docSnapshot.id,
            docSnapshot.data()!,
          );
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
        debugPrint('Error fetching experiment steps: $e');
      }

      // Ensure Flame Test always runs with the 3-step sequence
      if (_isFlameTest) {
        _currentSteps = [
          ExperimentStep(
            bottleTag: 'Chemical-Bottle',
            instructionTitle: 'STEP 1: SELECT & POUR SOLUTION',
            instructionDetail:
                'Choose a chemical solution from the Flame Solution menu, then pour a small amount onto the dish plate.',
          ),
          ExperimentStep(
            bottleTag: 'Thread',
            instructionTitle: 'STEP 2: COAT THE NICHROME WIRE',
            instructionDetail:
                'Pick up the nichrome wire and dip it into the solution on the dish plate to coat the wire with the metal ions.',
          ),
          ExperimentStep(
            bottleTag: 'Flame-Switch',
            instructionTitle: 'STEP 3: PERFORM THE FLAME TEST',
            instructionDetail:
                'Turn on the Bunsen burner flame, then place the coated nichrome wire over the burner to observe the flame color produced!',
          ),
        ];
      }

      // Tell Unity to load the experiment / scene
      sendToUnity('FlutterReceiver', 'LoadExperiment', normalizedId);

      if (!mounted) return;
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null) {
        _activityService.logExperimentLaunch(uid, experimentId);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera access is required to run AR experiments.'),
        ),
      );
    }
  }

  void _closeUnityAndReturnToMenu() {
    if (!mounted) return;
    _isExperimentActive = false;
    if (_isWarningDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isWarningDialogShowing = false;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // --- Tell Unity which bottle ID is currently active ---
  void _notifyUnityActiveStep() {
    if (_currentSteps.isEmpty) {
      return;
    }
    final activeTag = _currentSteps[_currentStepIndex].bottleTag;

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
      if (mounted) {
        _closeUnityAndReturnToMenu();
      }
      return;
    }

    if (!mounted || !_isExperimentActive) return;

    if (trimmedMessage == 'scene_ready') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
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

      _showEarlyActivatorWarning(ingredient);
      return;
    }

    // --- CATCH EXPLANATION FROM UNITY (Dynamic Lookup) ---
    if (trimmedMessage.startsWith("EXPLANATION:")) {
      // Unity sends: "EXPLANATION:bleach,lemon"
      String combinationKeys = trimmedMessage.replaceFirst("EXPLANATION:", "");

      // Look it up in our dynamic dictionary! If not found, show default.
      String explanation =
          _reactionDatabase[combinationKeys] ??
          "You've mixed a complex soup! Without strong acids or bases, it becomes a murky mix with a default pH.";

      setState(() {
        _activeExplanation = explanation;
      });
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
      String completedItem = "";
      if (trimmedMessage.contains(":")) {
        completedItem = trimmedMessage
            .substring(trimmedMessage.indexOf(":") + 1)
            .trim();
      }

      if (_currentSteps.isEmpty) return;

      // For pH indicator & Periodic table: keep strict sequential handling
      if (_isPhExperiment || _isPeriodicTable) {
        if (_currentStepIndex >= _currentSteps.length) return;
        final currentStep = _currentSteps[_currentStepIndex];
        final currentTag = currentStep.bottleTag;

        if (completedItem.isNotEmpty &&
            !_isTagMatching(completedItem, currentTag)) {
          debugPrint(
            "⚠️ Ignoring out-of-order STEP_COMPLETED for '$completedItem' (current step expects '$currentTag')",
          );
          return;
        }

        if (_currentStepIndex < _currentSteps.length - 1) {
          setState(() {
            _currentStepIndex++;
          });
          _notifyUnityActiveStep();
        } else {
          _handleExperimentComplete();
        }
        return;
      }

      // --- ALL OTHER EXPERIMENTS: Flexible mixing of ingredients before activator/last bottle ---
      final lastStepIndex = _currentSteps.length - 1;

      // 1. Find which step matches this completed item
      int matchedStepIndex = _currentSteps.indexWhere(
        (s) => _isTagMatching(completedItem, s.bottleTag),
      );

      if (matchedStepIndex == -1) {
        debugPrint(
          "⚠️ Received STEP_COMPLETED for unmapped item: '$completedItem'",
        );
        return;
      }

      final matchedStep = _currentSteps[matchedStepIndex];

      // 2. Handle multi-action step (e.g. "Rod1,Rod2")
      final subTags = matchedStep.bottleTag
          .split(',')
          .map((t) => t.trim())
          .toList();
      if (subTags.length > 1 && !_isPureAlias(matchedStep.bottleTag)) {
        final matchedSubTag = subTags.firstWhere(
          (t) => _isTagMatching(completedItem, t),
          orElse: () => completedItem,
        );
        _completedSubTagsForCurrentStep.add(_normalizeTag(matchedSubTag));

        bool allSubTagsDone = subTags.every(
          (t) => _completedSubTagsForCurrentStep.contains(_normalizeTag(t)),
        );

        if (!allSubTagsDone) {
          debugPrint(
            "⏳ Sub-step completed: $completedItem. Waiting for remaining items in step: ${matchedStep.bottleTag}",
          );
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _normalizeTag(matchedSubTag) == 'rod1'
                      ? "First copper rod placed! Now place the other copper rod into the beaker."
                      : "Copper rod placed! Now place the remaining copper rod into the beaker.",
                ),
                backgroundColor: const Color(0xFF00D4FF),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          return;
        }
      }

      // Step requirements satisfied -> mark step completed!
      _completedSubTagsForCurrentStep.clear();
      _completedStepIndices.add(matchedStepIndex);

      // Check if this was the last step / activator:
      if (matchedStepIndex == lastStepIndex) {
        // Verify all previous preparatory steps are completed!
        final allPrepDone = Iterable.generate(
          lastStepIndex,
          (i) => i,
        ).every((i) => _completedStepIndices.contains(i));

        if (allPrepDone) {
          debugPrint(
            "🎉 All ingredients were mixed and final activator finished! Completing experiment.",
          );
          _handleExperimentComplete();
        } else {
          debugPrint(
            "⚠️ Activator finished but some prep ingredients were not mixed yet!",
          );
          _showEarlyActivatorWarning(completedItem);
        }
        return;
      }

      // Preparatory ingredient completed!
      // Check if ALL preparatory steps are now completed:
      final allPrepDone = Iterable.generate(
        lastStepIndex,
        (i) => i,
      ).every((i) => _completedStepIndices.contains(i));

      if (allPrepDone) {
        // All prep ingredients mixed! Move directly to final activator!
        setState(() {
          _currentStepIndex = lastStepIndex;
        });
        _notifyUnityActiveStep();
      } else {
        // Move to the next uncompleted step:
        int nextUncompleted = 0;
        while (nextUncompleted < lastStepIndex &&
            _completedStepIndices.contains(nextUncompleted)) {
          nextUncompleted++;
        }
        setState(() {
          _currentStepIndex = nextUncompleted;
        });
        _notifyUnityActiveStep();
      }
      return;
    }
  }

  void _handleExperimentComplete() {
    if (!mounted) return;
    if (_hasCompleted) return;
    _hasCompleted = true;

    try {
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null && _activeExperimentId != null) {
        _activityService
            .markExperimentCompleted(uid, _activeExperimentId!)
            .then(
              (status) {
                if (mounted) setState(() => _completionSyncStatus = status);
              },
              onError: (Object error) {
                debugPrint('Failed to queue experiment completion: $error');
                if (mounted) {
                  setState(
                    () => _completionSyncStatus = ActivitySyncStatus.pending,
                  );
                }
              },
            );
      }
    } catch (e) {
      debugPrint("Auth error in _handleExperimentComplete: $e");
    }

    if (!mounted) return;

    // Keep the Unity platform view mounted and visible. A Navigator dialog
    // changes the Android platform-view visibility, which pauses/resumes Unity
    // and can replay the last active drag with stale coordinates.
    setState(() {
      _showCompletionPopup = true;
    });
  }

  Widget _buildCompletionPopup() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
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
                    style: TextStyle(color: Color(0xFF8BA3C0), fontSize: 16),
                  ),
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
                      color: _completionSyncStatus == ActivitySyncStatus.synced
                          ? const Color(0xFF00FF88)
                          : const Color(0xFFFFC857),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
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
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _showCompletionPopup = false;
                        });
                      }
                    },
                    child: const Text(
                      'Finish',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
    } else if (ingredient == "PureBlood") {
      title = "Stain Warning";
      message =
          "You dipped the litmus paper in pure blood! The red color is just a blood stain. Mix the blood with water first to read its true pH.";
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
      _selectedFlameChemicalIndex = -1;
      _silverNitrateDropCount = 0;
      _isDropButtonCoolingDown = false;
      _isSilverNitrateDropReady = false;
      _completedSubTagsForCurrentStep.clear();
      _completedStepIndices.clear();
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
          style: const TextStyle(
            color: Color(0xFF8BA3C0),
            height: 1.5,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Got it!",
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.5),
            width: 1.5,
          ),
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
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
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
                        // HINT BUTTON
                        if (!_isPeriodicTable)
                          FloatingActionButton(
                            heroTag: 'btn_hint',
                            mini: true,
                            backgroundColor: const Color(0xFF00D4FF),
                            onPressed: () => _showHint(currentStepData),
                            child: const Icon(
                              Icons.lightbulb_outline,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

              // Silver nitrate uses Flutter UI while Unity runs the drop VFX.
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

            // FULL-SCREEN FLAME SOLUTION PICKER OVERLAY (REPLACES UNITY CANVAS)
            if (_isFlameTest && _showFlameSolutionPicker)
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
