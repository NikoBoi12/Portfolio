import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { removeCard } from '../app/cardsSlice';

function CardList() {
  const hashTable = useSelector((state) => state.cards.hashTable);
  const dispatch = useDispatch();
  const allCards = Object.values(hashTable).flat();

  if (allCards.length === 0) {
    return <h2>You have no cards :(</h2>;
  }

  const handleRemoveCard = (card) => {
    dispatch(removeCard(card));
  };

  return (
    <div>
      <h2>Your Collection!!</h2>
      {allCards.map((card) => (
        <div key={card.hashTable+1}>
          <p>
            <strong>{card.name}</strong> - {card.series} ({card.rarity}) - Power Level: {card.powerLevel}
          </p>
          <button onClick={() => handleRemoveCard(card)}>Remove</button>
        </div>
      ))}
    </div>
  );
}

export default CardList;
