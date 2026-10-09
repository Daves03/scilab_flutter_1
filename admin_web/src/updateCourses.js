import { initializeApp } from 'firebase/app';
import { getFirestore, collection, getDocs, updateDoc, doc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyDwtR0WcQFz6safW8xcgse2zEpqP96Z_Bk',
  authDomain: 'scilab-ar.firebaseapp.com',
  projectId: 'scilab-ar',
  storageBucket: 'scilab-ar.firebasestorage.app',
  messagingSenderId: '324252227250',
  appId: '1:324252227250:web:469938306e2ea2e2029bab',
  measurementId: 'G-KRX6Y31PD1'
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const chemistryIcons = [
  'science',
  'biotech',
  'sanitizer',
  'bubble_chart',
  'masks',
  'eco',
  'psychology',
  'wb_incandescent',
  'opacity',
  'whatshot',
  'blur_on',
  'water_drop',
  'grass',
  'coronavirus'
];

async function updateCourses() {
  const querySnapshot = await getDocs(collection(db, 'courses'));
  let count = 0;
  for (const document of querySnapshot.docs) {
    const data = document.data();
    if (data.iconName === 'science' || !data.iconName) {
      const randomIcon = chemistryIcons[Math.floor(Math.random() * chemistryIcons.length)];
      await updateDoc(doc(db, 'courses', document.id), {
        iconName: randomIcon
      });
      count++;
      console.log(`Updated course ${document.id} to ${randomIcon}`);
    }
  }
  console.log(`Finished updating ${count} courses.`);
  process.exit(0);
}

updateCourses().catch(err => {
    console.error(err);
    process.exit(1);
});
