# Front-end of CI Page diff

This React App creates the interface to display the changes of different version on the same website.
The app receives the data through the variable `window.DATA_CI`. It can be injected by replacing the string `"__INJECT__DATA__IMAGES__"` in `../dist/index.html` by a JSON dump following this format:

```
window.DATA_CI = {
  'deleted': {
    'product': 'examples/old.png',
  },
  'modified': {
    'services': [
      'examples/old.png',
      'examples/diff.png',
      'examples/new.png',
    ],
  },
  'created': { 'home': 'examples/new.png', }
}
```

Three keys: `deleted`, `modified` and `created` must be present. `deleted` and `created` both contains a map, where the key is the page name and the value is the image url of a screenshot the page. The key `modified` contains a map where the key is the page name and the content is a three entries array; containing the old screenshot url, the image url displaying the difference and the new screenshot url.

## Work on this project

```
$ npm install # install deps
$ npm start # run in dev mode, port 3000
$ npm run build # build the project for prod; output in dist folder
```

`src` contains the project source:

  - index.js bootstrap the project
  - app.js handles the "rooting", displaying either the list of pages or the selected page
  - ListPages displays the list of pages (first thing you see)
  - Page displays the page to be shown full screen
  - Slider is the comparator tool where you can slide to compare the two images
  - Thumbnail is used by ListPages, it's one clickable page, that redirects you to the Page component
