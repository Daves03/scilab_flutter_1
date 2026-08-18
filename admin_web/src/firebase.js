import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

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
export const auth = getAuth(app);
export const db = getFirestore(app);
