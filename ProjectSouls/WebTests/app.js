import './app.css';
import { Routes, Route } from 'react-router-dom';
import { Counter } from './features/counter/counter.js';

export function App() {
  return (
    <Routes>
      <Route path={'/*'} element={<Counter />} />
    </Routes>
  );
}
