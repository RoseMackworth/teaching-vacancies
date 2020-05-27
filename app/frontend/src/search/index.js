/* global window */

import 'core-js/stable';
import 'regenerator-runtime/runtime';
import '../lib/classlist.polyfill';

import { connectSearchBox, connectAutocomplete, connectHits, connectSortBy, connectMenu } from 'instantsearch.js/es/connectors';
import { hits, pagination, configure } from 'instantsearch.js/es/widgets';

import { transform, templates, renderContent } from './hits';
import { searchClient } from './client';

import { renderSearchBox } from './ui/input';
import { renderAutocomplete } from './ui/autocomplete';
import { renderSortSelect } from './ui/sort';
import { renderRadiusSelect } from './ui/radius';
import { locations } from './data/locations';
import { updateUrlQueryParams, stringMatchesPostcode } from './utils';
import { getCoordinates } from './geoloc';
import { enableSubmitButton } from './ui/form';

if (document.querySelector('#vacancies-hits')) {
    const ALGOLIA_INDEX = 'Vacancy';
    const SEARCH_THRESHOLD = 3;

    const searchClientInstance = searchClient(ALGOLIA_INDEX);

    const searchBox = connectSearchBox(renderSearchBox);
    const autocomplete = connectAutocomplete(renderAutocomplete);
    const heading = connectHits(renderContent);
    const sortBy = connectSortBy(renderSortSelect);
    const locationRadius = connectMenu(renderRadiusSelect);

    const locationSearchBox = searchBox({
        container: document.querySelector('.filters-form'),
        inputElement: document.getElementById('location'),
        key: 'location',
        autofocus: true,
        queryHook(query, search) {
            query ? updateUrlQueryParams('location', document.querySelector('#location').value, window.location.href) : false;
            search(query);
        },
        onChange(query) {
            if (stringMatchesPostcode(query)) {
                getCoordinates(query).then(coords => {
                    document.querySelector('#location-radius-select').style.display = 'block';
                    document.querySelector('#location').dataset.coordinates = `${coords.lat}, ${coords.lng}`;
                    document.querySelector('#radius').dataset.radius = document.querySelector('#radius').value || 10;
                });
            } else {
                document.querySelector('#location-radius-select').style.display = 'none';
                delete document.querySelector('#location').dataset.coordinates;
                delete document.querySelector('#radius').dataset.radius;
            }
        },
    });

    searchClientInstance.addWidgets([
        configure({
            hitsPerPage: 10,
        }),
        autocomplete({
            container: document.querySelector('.app-site-search__wrapper'),
            input: document.querySelector('#location'),
            dataset: locations,
            threshold: SEARCH_THRESHOLD,
            onSelection: value => {
                updateUrlQueryParams('location', value, window.location.href);
            }
        }),
        locationSearchBox,
        searchBox({
            container: document.querySelector('.filters-form'),
            inputElement: document.getElementById('keyword'),
            key: 'keyword',
            autofocus: true,
            queryHook(query, search) {
                query ? updateUrlQueryParams('keyword', document.querySelector('#keyword').value, window.location.href) : false;
                search(query);
            },
        }),
        locationRadius({
            container: document.querySelector('#location-radius-select'),
            attribute: '_geoloc',
            inputElement: document.getElementById('radius'),
            onSelection: value => {
                updateUrlQueryParams('radius', value, window.location.href);
                document.querySelector('#radius').dataset.radius = `${value}`;
                enableSubmitButton(document.querySelector('.filters-form'));
                searchClientInstance.refresh();
            }
        }),
        sortBy({
            container: document.querySelector('#jobs_sort_form'),
            element: '#jobs_sort',
            items: [
                { label: 'Relevancy', value: 'Vacancy' },
                { label: 'Newest job listing', value: 'Vacancy_publish_on_desc' },
                { label: 'Oldest job listing', value: 'Vacancy_publish_on_asc' },
                { label: 'Newest closing date', value: 'Vacancy_expiry_time_desc' },
                { label: 'Oldest closing date', value: 'Vacancy_expiry_time_asc' },
            ],
        }),
        heading({
            container: document.querySelector('#job-count'),
            alert: document.querySelector('.vacancies-count'),
            threshold: SEARCH_THRESHOLD,
        }),
        hits({
            container: '#vacancies-hits',
            transformItems(items) {
                return transform(items);
            },
            templates,
            cssClasses: {
                list: ['vacancies'],
                item: 'vacancy'
            },
        }),
    ]);

    if (document.querySelector('#pagination-hits')) {
        searchClientInstance.addWidgets([
            pagination({
                container: '#pagination-hits',
                cssClasses: {
                    list: ['pagination'],
                    item: 'pagination__item'
                },
            }),
        ]);
    }

    searchClientInstance.start();
}
