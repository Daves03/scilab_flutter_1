# Teacher web portal Firestore requirement

The teacher web portal uses the same Firebase collections as the Flutter app.
Most existing rules already support it, but the `ar_experiments` rule must allow
approved teachers to update AR content.

The editor also saves per-experiment `ppeAssessment` and `assessmentQuestions`
fields on these documents. The same update permission covers PPE choices,
correct selections, and the 5–10-question end-of-experiment quiz. No additional
collection is used. The web editor validates settings before save, and Flutter
validates them when loading. Existing documents without these fields keep the
built-in assessments.

Replace the existing AR Experiments block with:

```firestore
// AR Experiments Collection
match /ar_experiments/{experimentId} {
  allow read: if request.auth != null;

  // Administrators retain full control. Approved teachers can edit existing
  // experiment content; the web UI limits them to their handled grade catalog.
  allow create, delete: if request.auth != null && isAdmin();
  allow update: if request.auth != null
    && (
      isAdmin()
      || (
        getUserRole() == 'teacher'
        && get(
          /databases/$(database)/documents/users/$(request.auth.uid)
        ).data.status == 'approved'
      )
    );
}
```

Do not keep a second recursive `match /ar_experiments/{document=**}` block,
because its admin-only write condition would make the intended permissions
unclear. Publish the updated rules in Firebase Console > Firestore Database >
Rules before testing teacher AR edits.

The portal itself filters the experiment IDs using the same mobile catalog:

- Grade 9: `ar3`, `ar2`, `ar5`
- Grade 10: `ar7`, `ar1`, `ar6`
- Enrichment for either handled grade: `ar4`, `ar8`
