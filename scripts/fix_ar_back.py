import os

filepath = 'lib/presentation/unity_ar_screen/unity_ar_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _closeUnityAndReturnToMenu
old_close_func = '''  void _closeUnityAndReturnToMenu() {
    sendToUnity('FlutterReceiver', 'LoadExperiment', '0');

    setState(() {
      _isExperimentActive = false;
      _isLoading = false;
      _activeExperimentId = null;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }'''

new_close_func = '''  void _closeUnityAndReturnToMenu() {
    sendToUnity('FlutterReceiver', 'LoadExperiment', '0');
    
    Future.delayed(const Duration(milliseconds: 150), () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }'''
content = content.replace(old_close_func, new_close_func)

# 2. Update PopScope canPop (should just be false, or handled differently)
# If _isExperimentActive doesn't matter anymore, we can just leave canPop: false and let the onPopInvokedWithResult call _closeUnityAndReturnToMenu which pops later.
old_pop = '''    return PopScope(
      canPop: !_isExperimentActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) { return; }
        _closeUnityAndReturnToMenu();
      },'''
new_pop = '''    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) { return; }
        _closeUnityAndReturnToMenu();
      },'''
content = content.replace(old_pop, new_pop)

# 3. Remove AppBar
old_appbar = "appBar: _isExperimentActive ? null : AppBar(title: const Text('Select an Experiment')),"
content = content.replace(old_appbar, "")

# 4. Remove the GRID SELECTION MENU from the stack
# Find the start of the grid selection menu
grid_start = content.find('// --- GRID SELECTION MENU (When experiment is inactive) ---')
if grid_start != -1:
    # Find the end of the Scaffold stack by looking for the end of the children array
    # We will replace from grid_start up to           ], with nothing.
    # Actually, we can just find class _ExperimentCard and remove the menu and the class.
    
    # Wait, it's easier to use a regex to wipe out the grid menu and the ExperimentCard class.
    pass

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Initial fixes applied')
