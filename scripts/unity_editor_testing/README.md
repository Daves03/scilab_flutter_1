# Testing experiments in Unity

The two C# files in this folder are installed in the Unity project's
`Assets/Script/Editor Testing/` folder. Keep these copies in sync when editing.
Both are wrapped in `UNITY_EDITOR` and compile to no code in exported players.

1. Open any experiment scene (`Exp1` through `Exp7`) in Unity.
2. Enter Play Mode. The **SciLab - Editor Testing** panel appears automatically.
3. Perform the action shown. The existing collision detection and animations run
   normally; their completion messages advance the guide to the next step.
4. Use **Dismiss warning** after an early action, or **Restart experiment** to
   reload the scene and reset animations, positions, and progress.
5. Click **Finish experiment** to return to the experiment list (`Landingpage`).
   The scene's completion-popup exit button returns there too.

The flame-test scene also has solution-selection buttons and a burner toggle in
the panel. The Unity burner button can be removed; keep the burner controller
and its flame VFX reference. Flutter supplies the burner toggle in exported apps.
The pH
scene completes on its existing litmus explanation message. Collapse the panel
with **Hide guide** or drag its title bar if it obscures an object.

**SciLab > Enable Editor Experiment Testing** toggles the runner for the next
Play session. It is enabled by default. No component assignment is required,
including when opening an experiment scene directly without the landing scene.

The runner supplies Flutter's step-control role through `FlutterBridge` and
listens to the integration package's existing `SendToFlutter - ` Editor log
messages. It does not force animation playback or bypass triggers. All existing
colliders, animation events, AR tracking, and model assignments still apply.
The test sequences use the repository's Flutter guide tags; if remote Firestore
guides change, update the Editor sequences to match.

Unity Play Mode checks are useful for scene interactions. Device AR tracking and
the Flutter interface still need a final exported-app check.
