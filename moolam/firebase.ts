import { initializeApp } from "firebase/app";
import { getDatabase } from "firebase/database";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyD_ch3dVGrIiJhmgqzGtXkjdJeK2EnYubQ",
  authDomain: "elvan-niril.firebaseapp.com",
  projectId: "elvan-niril",
  storageBucket: "elvan-niril.firebasestorage.app",
  messagingSenderId: "609507731846",
  appId: "1:609507731846:web:9a8d2cbcd9f800e4696407",
  measurementId: "G-QCNJ8QPNVD",
  // Providing standard realtime database URL since it wasn't in config
  databaseURL: "https://elvan-niril-default-rtdb.asia-southeast1.firebasedatabase.app"
};

const app = initializeApp(firebaseConfig);
export const rtdb = getDatabase(app);
export const auth = getAuth(app);
