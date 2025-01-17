import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { addCard } from '../app/cardsSlice';

function CardForm() {
  const [form, setForm] = useState({
    name: '',
    series: '',
    rarity: '',
    powerLevel: '',
  });
  const dispatch = useDispatch();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleAddCard = () => {
    if (form.name && form.series && form.rarity && form.powerLevel) {
      dispatch(addCard(form));
      setForm({
        name: '',
        series: '',
        rarity: '',
        powerLevel: '',
      });
    }
  };

  return (
    <div>
      <h2>Add Card</h2>
      <input name="name" placeholder="Name" value={form.name} onChange={handleInputChange} />
      <input name="series" placeholder="Series" value={form.series} onChange={handleInputChange} />
      <input name="rarity" placeholder="Rarity" value={form.rarity} onChange={handleInputChange} />
      <input
        name="powerLevel"
        placeholder="Power Level"
        value={form.powerLevel}
        onChange={handleInputChange}
        type="number"
      />
      <button onClick={handleAddCard}>Add Card</button>
    </div>
  );
}

export default CardForm;
