import algoliasearch from 'algoliasearch';
import instantsearch from 'instantsearch.js';

import { getFilters, getQuery } from './query';
import { getKeyword } from './ui/input/keyword';
import { getCoords } from './ui/input/location';
import { getRadius } from './ui/input/radius';

export const clientElement = document.getElementsByClassName('filters-form')[0];

// This is the public API key which can be safely used in your frontend code.
// This key is usable for search queries and list the indices you've got access to.
export const search = algoliasearch(
  clientElement ? clientElement.getAttribute('data-app') : '',
  clientElement ? clientElement.getAttribute('data-api') : '',
);

export const searchClient = (indexName) => instantsearch({
  indexName,
  searchClient: search,
  searchFunction(helper) {
    onSearch(helper);
  },
});

export const getNewState = (state, add) => {
  const updatedState = { ...state, ...add };
  return updatedState;
};

export const onSearch = (helper) => {
  const page = helper.getPage(); // subsequent setQuery calls reset the page to 0

  if (getCoords()) {
    helper.setState(getNewState(helper.state, { aroundLatLng: getCoords() }));
  }

  if (getRadius()) {
    helper.setState(getNewState(helper.state, { aroundRadius: getRadius() }));
    helper.setQuery(getKeyword());
  } else {
    helper.setState(getNewState(helper.state, { aroundRadius: 'all' }));
    helper.setQuery(getQuery());
  }

  helper.setState(getNewState(helper.state, { filters: getFilters() }));

  helper.setPage(page);

  return helper.search();
};

export const index = (indexName) => search.initIndex(indexName);
