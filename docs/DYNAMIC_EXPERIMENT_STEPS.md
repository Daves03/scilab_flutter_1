Admin step order and experiment guides
====================================

The Flutter app loads the saved `steps` array from `ar_experiments` when opening
an experiment. The order of that saved array determines the guide order.
Default steps apply when no saved guide is available. Flame Test and pH
use the same loading and progress rules as the other experiments.

Each admin `bottleTag` must match an existing Unity action identifier. Matching
ignores case, spaces, hyphens, and underscores. Commas group actions; all must
finish before that step completes. `RedWire`, `ElectrodeA`, and `Electrode` are
aliases for one action. Similar names such as `blackWire` and `2way-BlackWire`
remain separate. Completed members of a group lose their guide arrows while
the remaining members stay active.

| Scene | Existing action identifiers |
| --- | --- |
| Exp1 | Surf, Peroxide, Dye, Yeast, Activator |
| Exp2 | DropperFill, Beaker-Nitrate, DropperDrop |
| Exp3 | LimeWater-Bottle, Acid-Bottle, Delivery-Tube |
| Exp4 | Chemical-Bottle, Thread, Flame-Switch |
| Exp5 | Rod1, Rod2, 2way-BlackWire, RedWire / ElectrodeA, blackWire, Salt-Bottle |
| Exp6 | Flask, Vinegar-Bottle, Baking-Soda, Balloon |
| Exp7 | blood, lemon, water, soap, bleach, Litmus |

The active action enables its model's green arrow. Red arrows use the model's
configured `targetTag`, matching the actual receiving collider's Unity tag.
Exp3, Exp5, and Exp6 arrow controllers expose destination-tag fields in the
Inspector. Exp1 reads the colliders beneath each beaker's assigned red-arrow
parent; Exp2 uses the dropper's configured destination tags. The Flame Test
dish arrow follows the active bottle or wire destination. The wire's green
arrow also guides the burning action.

`Is Activator` continues to warn and block an action outside its active tag.
The Inspector's old `Is Last Step` and numeric step settings no longer finish
an admin-controlled experiment. Flutter completes the guide after every
configured action reports completion, except pH, where any valid litmus result
finishes the exploratory activity. Non-activator actions can still finish
out of order; the guide advances to the first unfinished action in admin order.

Physical prerequisites remain: a dropper needs liquid, a receiving beaker must
be filled where required, and the flame test needs a coated wire and a lit
burner. Reordering instructions does not supply missing materials or create
new model animations. Existing models mostly perform their action once per
run, so do not repeat the same action as separate steps.

pH bottles have an optional `Step Id` (defaults to `solutionName`). Their pours
now report completion separately, and litmus reports completion after the
configured color timing. The existing pH scene contains no arrow objects;
assign optional `Guide Arrow` fields and the litmus `Destination Arrow` when
adding arrows in Unity. Litmus accepts any filled dish, independently of the
active admin tag, so users can choose one solution or mix several before
testing. Blood samples require water first; an early attempt shows the
mix-with-water popup and leaves the paper available to try again. Empty dishes
and mixtures flagged by the existing lemon/bleach or
soap/bleach warnings cannot be tested. Completing the color change finishes
the pH activity without requiring all optional solution steps.

Standalone Unity Editor testing uses local defaults or the editable tag-order
field described in `scripts/unity_editor_testing/README.md`. It does not fetch
Firestore. Verify changed orders in Play Mode, then export the updated Unity
Android library and rebuild Flutter to include the runtime changes in the app.
