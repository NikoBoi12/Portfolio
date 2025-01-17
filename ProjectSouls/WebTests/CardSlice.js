import { createSlice } from '@reduxjs/toolkit';

const calculateHash = (name) => {
  let hash = 0;
  const hashNum = 5;
  for (let i = 0; i < name.length; i++) {
    hash = (hash << hashNum) - hash + name.charCodeAt(i);
    hash |= 0;
  }
  return hash;
};

const cardsSlice = createSlice({
  name: 'cards',
  initialState: {
    hashTable: {},
    hashTableRarity: {},
    searchResults: [],
  },
  reducers: {
    addCard: (state, action) => {
      const { name, series } = action.payload;
      const hashName = calculateHash(name.toLowerCase());
      const hashRarity = calculateHash(series.toLowerCase());

      if (!state.hashTable[hashName]) {
        state.hashTable[hashName] = [];
      }
      state.hashTable[hashName].push(action.payload);

      if (!state.hashTableRarity[hashRarity]) {
        state.hashTableRarity[hashRarity] = [];
      }
      state.hashTableRarity[hashRarity].push(action.payload);
    },

    removeCard: (state, action) => {
      const { name, series } = action.payload;
      const hashName = calculateHash(name.toLowerCase());
      const hashRarity = calculateHash(series.toLowerCase());

      if (state.hashTable[hashName]) {
        state.hashTable[hashName] = state.hashTable[hashName].filter(
          (card) => card.name !== name
        );
        if (state.hashTable[hashName].length === 0) {
          delete state.hashTable[hashName];
        }
      }

      if (state.hashTableRarity[hashRarity]) {
        state.hashTableRarity[hashRarity] = state.hashTableRarity[hashRarity].filter(
          (card) => card.series !== series
        );
        if (state.hashTableRarity[hashRarity].length === 0) {
          delete state.hashTableRarity[hashRarity];
        }
      }
    },

    searchCard: (state, action) => {
      const searchTerm = action.payload.toLowerCase();
      const searchHash = calculateHash(searchTerm);

      const result = state.hashTable[searchHash] || state.hashTableRarity[searchHash] || [];

      state.searchResults = result;
    },
  },
});

export const { addCard, removeCard, searchCard } = cardsSlice.actions;
export default cardsSlice.reducer;
