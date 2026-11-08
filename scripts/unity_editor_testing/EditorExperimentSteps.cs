#if UNITY_EDITOR
using System;
using System.Collections.Generic;

// Local equivalents of the Flutter guide tags. No player code is compiled.
public sealed class EditorExperimentSteps
{
    public readonly string[] Tags;
    private readonly HashSet<int> completed = new HashSet<int>();
    private readonly Dictionary<int, HashSet<string>> actions = new Dictionary<int, HashSet<string>>();
    public int Index { get; private set; }
    public bool Finished { get; private set; }
    public string ActiveTag
    {
        get
        {
            if (Finished) return "COMPLETED";
            if (!actions.TryGetValue(Index, out HashSet<string> done)) return Tags[Index];
            var pending = new List<string>();
            foreach (string action in Tags[Index].Split(','))
                if (!done.Contains(DynamicExperimentGuide.Canonical(action))) pending.Add(action);
            return string.Join(",", pending);
        }
    }

    public EditorExperimentSteps(string[] tags) { Tags = tags; }

    public static string[] ForScene(string scene)
    {
        switch (scene)
        {
            case "Exp1": return new[] { "Surf", "Peroxide", "Dye", "Yeast", "Activator" };
            case "Exp2": return new[] { "DropperFill", "Beaker-Nitrate", "DropperDrop" };
            case "Exp3": return new[] { "LimeWater-Bottle", "Acid-Bottle", "Delivery-Tube" };
            case "Exp4": return new[] { "Chemical-Bottle", "Thread", "Flame-Switch" };
            case "Exp5": return new[] { "Rod1,Rod2", "2way-BlackWire", "RedWire,ElectrodeA", "blackWire", "Salt-Bottle" };
            case "Exp6": return new[] { "Flask", "Vinegar-Bottle", "Baking-Soda", "Balloon" };
            case "Exp7": return new[] { "Litmus" };
            default: return null;
        }
    }

    public void Finish() { Finished = true; }

    public bool Complete(string item)
    {
        if (Finished || string.IsNullOrWhiteSpace(item)) return false;
        for (int offset = 0; offset < Tags.Length; offset++)
        {
            int found = (Index + offset) % Tags.Length;
            if (completed.Contains(found) || !DynamicExperimentGuide.Matches(Tags[found], item)) continue;
            if (!actions.TryGetValue(found, out HashSet<string> done))
            {
                done = new HashSet<string>();
                actions[found] = done;
            }
            foreach (string action in Tags[found].Split(','))
                if (DynamicExperimentGuide.Matches(action, item)) done.Add(DynamicExperimentGuide.Canonical(action));
            bool allDone = true;
            foreach (string action in Tags[found].Split(','))
                if (!done.Contains(DynamicExperimentGuide.Canonical(action))) allDone = false;
            if (!allDone) return false;
            completed.Add(found);
            for (int i = 0; i < Tags.Length; i++)
                if (!completed.Contains(i)) { Index = i; return true; }
            Finished = true;
            return true;
        }
        return false;
    }
}
#endif
