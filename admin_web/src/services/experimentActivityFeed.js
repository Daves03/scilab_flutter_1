const DEFAULT_EXPERIMENT_TITLES = {
  ar1: 'Elephant Toothpaste',
  ar2: 'Silver Nitrate Precipitation Test',
  ar3: 'Limewater Test for Carbon Dioxide',
  ar4: 'Flame Test',
  ar5: 'Conductivity Test',
  ar6: 'Law of Conservation of Mass',
  ar7: 'pH Indicator Acid and Base',
  ar8: 'Interactive Periodic Table',
};

function canonicalExperimentId(id) {
  const value = String(id).trim().toLowerCase();
  return /^(?:ar)?\d+$/.test(value) ? `ar${value.replace(/^ar/, '')}` : value;
}

// Watch concrete user paths so the feed works with the existing Firestore
// rules for users/{uid}/experiment_activity/{experimentId}.
export function createExperimentActivityFeed({ watchUser, onChange, onError }) {
  let users = {};
  let experimentTitles = {};
  const records = new Map();
  const subscriptions = new Map();
  let disposed = false;

  function publish() {
    if (disposed) return;
    const logs = [];
    for (const [uid, experiments] of records) {
      const user = users[uid];
      if (!user) continue;
      for (const { id, data } of experiments) {
        for (const [field, action] of [['launchedAt', 'launch'], ['completedAt', 'complete']]) {
          const value = data[field];
          if (!value) continue;
          const timestamp = value.toDate ? value.toDate() : new Date(value);
          if (Number.isNaN(timestamp.getTime())) continue;
          logs.push({
            id: `${uid}/${id}-${action}`,
            uid,
            userName: user.name || user.displayName || user.email || 'Unknown User',
            userRole: user.role || 'student',
            type: `experiment_${action}`,
            title: experimentTitles[canonicalExperimentId(data.experimentId || id)]
              || data.experimentTitle
              || DEFAULT_EXPERIMENT_TITLES[canonicalExperimentId(data.experimentId || id)]
              || data.experimentId || id,
            timestamp,
          });
        }
      }
    }
    onChange(logs);
  }

  return {
    setExperiments(experiments) {
      if (disposed) return;
      experimentTitles = {};
      for (const { id, title } of experiments) {
        if (typeof title === 'string' && title.trim()) {
          experimentTitles[canonicalExperimentId(id)] = title.trim();
        }
      }
      publish();
    },
    setUsers(nextUsers) {
      if (disposed) return;
      users = nextUsers;
      for (const [uid, unsubscribe] of subscriptions) {
        if (Object.hasOwn(users, uid)) continue;
        unsubscribe();
        subscriptions.delete(uid);
        records.delete(uid);
      }
      for (const uid of Object.keys(users)) {
        if (subscriptions.has(uid)) continue;
        const unsubscribe = watchUser(uid, (experiments) => {
          if (!Object.hasOwn(users, uid) || disposed) return;
          records.set(uid, experiments);
          publish();
        }, (error) => {
          if (!disposed) onError(uid, error);
        });
        subscriptions.set(uid, unsubscribe);
      }
      publish();
    },
    dispose() {
      disposed = true;
      for (const unsubscribe of subscriptions.values()) unsubscribe();
      subscriptions.clear();
      records.clear();
    },
  };
}
