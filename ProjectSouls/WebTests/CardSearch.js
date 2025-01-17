import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { searchCard } from '../app/cardsSlice';

function CardSearch() {
  const [searchTerm, setSearchTerm] = useState('');
  const dispatch = useDispatch();
  const searchResults = useSelector((state) => state.cards.searchResults || []); // or

  const handleSearch = () => {
    dispatch(searchCard(searchTerm));
  };

  return (
    <div>
      <h2>Search for your Cards</h2>
      <input
        placeholder="Search by Name or Series"
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      <button onClick={handleSearch}>Search</button>
      <div>
        <h3>Results:</h3>
        {searchResults.length > 0 ? (
          searchResults.map((card) => (
            <p key={card.name}>
              {card.name} - {card.series} ({card.rarity}) - Power Level: {card.powerLevel}
            </p>
          ))
        ) : (
          <p>No cards found :(</p>
        )}
      </div>
    </div>
  );
}


export default CardSearch;
