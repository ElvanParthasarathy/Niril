import { initializeApp } from "firebase/app";
import { getDatabase } from "firebase/database";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyD_ch3dVGrIiJhmgqzGtXkjdJeK2EnYubQ",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "elvan-niril.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "elvan-niril",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "elvan-niril.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "609507731846",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:609507731846:web:9a8d2cbcd9f800e4696407",
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || "G-QCNJ8QPNVD",
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL || "https://elvan-niril-default-rtdb.asia-southeast1.firebasedatabase.app"
};

const app = initializeApp(firebaseConfig);
export const rtdb = getDatabase(app);
export const auth = getAuth(app);
