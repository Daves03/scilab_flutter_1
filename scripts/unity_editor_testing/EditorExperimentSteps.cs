#if UNITY_EDITOR
using System;
using System.Collections.Generic;

// Local equivalents of the Flutter guide tags. No player code is compiled.
public sealed class EditorExperimentSteps
{
    public readonly string[] Tags;
    private readonly HashSet<int> completed = new HashSet<int>();
    private readonly HashSet<string> rods = new HashSet<string>();
    public int Index { get; private set; }
    public bool Finished { get; private set; }
    public string ActiveTag { get { return Finished ? "COMPLETED" : Tags[Index]; } }

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

    private static string Normalize(string value)
    {
        return (value ?? "").Replace("-", "").Replace("_", "").Replace(" ", "").Trim().ToLowerInvariant();
    }

    public bool Complete(string item)
    {
        if (Finished || string.IsNullOrWhiteSpace(item)) return false;
        string normalized = Normalize(item);
        int found = -1;
        for (int i = 0; i < Tags.Length; i++)
            foreach (string alias in Tags[i].Split(','))
                if (Normalize(alias) == normalized) found = i;
        if (found < 0 || completed.Contains(found)) return false;
        // Rods are two separate actions; RedWire/ElectrodeA are aliases.
        if (Tags[found] == "Rod1,Rod2")
        {
            rods.Add(normalized);
            if (!rods.Contains("rod1") || !rods.Contains("rod2")) return false;
        }
        // The final activator must follow all preparatory actions.
        if (found == Tags.Length - 1 && completed.Count != Tags.Length - 1) return false;
        completed.Add(found);
        for (int i = 0; i < Tags.Length; i++)
            if (!completed.Contains(i)) { Index = i; return true; }
        Finished = true;
        return true;
    }
}
#endif
