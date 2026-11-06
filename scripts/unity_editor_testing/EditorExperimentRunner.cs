#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

// Automatically supplies Flutter's step-control role during Editor Play Mode.
// Uses the package's existing Editor message log; no plugin/player changes.
public sealed class EditorExperimentRunner : MonoBehaviour
{
    private const string Preference = "Scilab.EditorExperimentTesting";
    private const string Menu = "SciLab/Enable Editor Experiment Testing";
    private const string MessagePrefix = "SendToFlutter - ";
    private readonly Queue<string> messages = new Queue<string>();
    private EditorExperimentSteps steps;
    private bool initializeScene;
    private string warning;
    private string status;
    private bool collapsed;
    private Rect panel = new Rect(12, 12, 360, 310);

    [MenuItem(Menu)]
    private static void Toggle()
    {
        EditorPrefs.SetBool(Preference, !EditorPrefs.GetBool(Preference, true));
        Debug.Log("Editor experiment testing changed. Stop and restart Play Mode to apply.");
    }

    [MenuItem(Menu, true)]
    private static bool ValidateToggle()
    {
        UnityEditor.Menu.SetChecked(Menu, EditorPrefs.GetBool(Preference, true));
        return true;
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Bootstrap()
    {
        if (!EditorPrefs.GetBool(Preference, true)) return;
        if (FindFirstObjectByType<EditorExperimentRunner>() != null) return;
        GameObject host = new GameObject("Editor Experiment Testing");
        DontDestroyOnLoad(host);
        host.AddComponent<EditorExperimentRunner>();
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += SceneLoaded;
        Application.logMessageReceived += ReceiveLog;
        initializeScene = true;
    }

    private void OnDisable()
    {
        SceneManager.sceneLoaded -= SceneLoaded;
        Application.logMessageReceived -= ReceiveLog;
    }

    private void SceneLoaded(Scene scene, LoadSceneMode mode) { initializeScene = true; }

    private void ReceiveLog(string message, string stack, LogType type)
    {
        if (type == LogType.Log && message.StartsWith(MessagePrefix, System.StringComparison.Ordinal))
            messages.Enqueue(message.Substring(MessagePrefix.Length).Trim());
    }

    private FlutterBridge Bridge()
    {
        if (FlutterBridge.Instance != null) return FlutterBridge.Instance;
        FlutterBridge existing = FindFirstObjectByType<FlutterBridge>();
        if (existing != null) return existing;
        return new GameObject("FlutterReceiver").AddComponent<FlutterBridge>();
    }

    private void Update()
    {
        // First Update occurs after scene Start callbacks, which can hide guides.
        if (initializeScene)
        {
            initializeScene = false;
            messages.Clear();
            warning = null;
            TapSelector.IsModalOpen = false;
            string[] tags = EditorExperimentSteps.ForScene(SceneManager.GetActiveScene().name);
            steps = tags == null ? null : new EditorExperimentSteps(tags);
            if (steps != null)
            {
                status = "Perform the highlighted action; animations advance the guide automatically.";
                Bridge().SetActiveStep(steps.ActiveTag);
            }
        }
        while (messages.Count > 0)
        {
            string message = messages.Dequeue();
            if (steps == null) continue;
            if (message.StartsWith("STEP_COMPLETED:", System.StringComparison.Ordinal))
            {
                string item = message.Substring("STEP_COMPLETED:".Length).Trim();
                if (steps.Complete(item)) Bridge().SetActiveStep(steps.ActiveTag);
                status = "Animation completed: " + item;
            }
            else if (message.StartsWith("WARNING:", System.StringComparison.Ordinal))
            {
                warning = message.Substring("WARNING:".Length);
                TapSelector.IsModalOpen = true;
            }
            else if (message == "show_menu" || message == "EXPERIMENT_EXIT")
            {
                ReturnToExperimentList();
                break;
            }
            else if (message.StartsWith("EXPLANATION:", System.StringComparison.Ordinal))
            {
                status = message.Substring("EXPLANATION:".Length);
                if (SceneManager.GetActiveScene().name == "Exp7" && steps.Complete("Litmus"))
                    Bridge().SetActiveStep(steps.ActiveTag);
            }
        }
    }

    private void ReturnToExperimentList()
    {
        messages.Clear();
        warning = null;
        TapSelector.IsModalOpen = false;
        UnityEditor.SceneManagement.EditorSceneManager.LoadSceneInPlayMode(
            "Assets/Scenes/Landingpage.unity", new LoadSceneParameters(LoadSceneMode.Single));
    }

    private static string Instruction(string tag)
    {
        switch (tag)
        {
            case "LimeWater-Bottle": return "Pour limewater into the limewater beaker.";
            case "Acid-Bottle": return "Pour acid into the beaker containing sodium carbonate.";
            case "Delivery-Tube": return "Connect the delivery tube to the beaker opening.";
            case "Flask": return "Place the flask on the balance.";
            case "Vinegar-Bottle": return "Pour vinegar into the flask on the balance.";
            case "Baking-Soda": return "Pour baking soda inside the balloon.";
            case "Balloon": return "Fit the balloon over the flask and observe the reaction.";
            case "Rod1,Rod2": return "Place BOTH copper rods in the beaker.";
            case "Chemical-Bottle": return "Choose a flame solution below, then pour it into the dish.";
            case "Thread": return "Dip the nichrome wire into the dish.";
            case "Flame-Switch": return "Turn on the burner and move the coated wire into the flame.";
            case "Litmus": return "Mix a solution with water, then dip the litmus paper.";
            default: return "Move the green-arrow object to the red-arrow target.";
        }
    }

    private void OnGUI()
    {
        if (steps == null) return;
        panel.width = Mathf.Min(360, Screen.width - 24);
        panel.height = collapsed ? 58 : (warning != null ? 395 : 320);
        panel = GUI.Window(GetInstanceID(), panel, DrawPanel, "SciLab - Editor Testing");
    }

    private void DrawPanel(int id)
    {
        if (GUILayout.Button(collapsed ? "Show guide" : "Hide guide")) collapsed = !collapsed;
        if (collapsed) { GUI.DragWindow(new Rect(0, 0, panel.width, 20)); return; }
        GUILayout.Label(SceneManager.GetActiveScene().name + (steps.Finished ? " - Complete" :
            " - Step " + (steps.Index + 1) + "/" + steps.Tags.Length + ": " + steps.ActiveTag));
        GUILayout.Label(steps.Finished ? "Experiment complete. Restart for a fresh run." : Instruction(steps.ActiveTag), EditorStyles.wordWrappedLabel);
        GUILayout.Label(status, EditorStyles.wordWrappedLabel);
        if (SceneManager.GetActiveScene().name == "Exp4" && !steps.Finished && steps.ActiveTag == "Flame-Switch")
        {
            BunsenBurnerSwitch burner = FindFirstObjectByType<BunsenBurnerSwitch>();
            if (burner != null && GUILayout.Button(burner.IsBurning ? "Turn burner OFF" : "Turn burner ON"))
                Bridge().SetBurnerState(burner.IsBurning ? "off" : "on");
        }
        if (SceneManager.GetActiveScene().name == "Exp4" && !steps.Finished && steps.Index == 0)
        {
            string[] chemicals = { "Sodium", "Copper", "Potassium", "Strontium", "Barium", "Calcium" };
            GUILayout.BeginHorizontal();
            for (int i = 0; i < chemicals.Length; i++)
            {
                if (i == 3) { GUILayout.EndHorizontal(); GUILayout.BeginHorizontal(); }
                if (GUILayout.Button(chemicals[i])) Bridge().SelectFlameChemical(i.ToString());
            }
            GUILayout.EndHorizontal();
        }
        if (warning != null)
        {
            GUILayout.Label("Warning: " + warning + ". Finish the current guide step first.", EditorStyles.wordWrappedLabel);
            if (GUILayout.Button("Dismiss warning"))
            {
                warning = null;
                Bridge().OnWarningDismissed();
                Bridge().SetActiveStep(steps.ActiveTag);
            }
        }
        if (steps.Finished && GUILayout.Button("Finish experiment"))
            ReturnToExperimentList();
        if (GUILayout.Button("Restart experiment"))
        {
            TapSelector.IsModalOpen = false;
            UnityEditor.SceneManagement.EditorSceneManager.LoadSceneInPlayMode(
                SceneManager.GetActiveScene().path, new LoadSceneParameters(LoadSceneMode.Single));
        }
        GUILayout.Label("Editor only. Flutter controls steps in exported builds.", EditorStyles.wordWrappedLabel);
        GUI.DragWindow(new Rect(0, 0, panel.width, 20));
    }
}
#endif
