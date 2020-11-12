const algoliaClient = algoliasearch('1EO21A8JUS', 'd9dbd088080405972f4961d28c73f89b')

const searchClient = {
  search(requests) {
    if (requests.every(({ params }) => !params.query || params.query.length < 3)) {
      return Promise.resolve({
        results: requests.map(() => ({
          hits: [],
          nbHits: 0,
          nbPages: 0,
        })),
      })
    }

    return algoliaClient.search(requests)
  },
}

const search = instantsearch({
  indexName: 'icons',
  searchClient,
})

const packRefinementListWithPanel = instantsearch.widgets.panel({
  templates: { header: 'pack' },
  hidden: (options) => options.results.nbHits === 0
})(instantsearch.widgets.refinementList)

const tagsRefinementListWithPanel = instantsearch.widgets.panel({
  templates: { header: 'tags' },
  hidden: (options) => options.results.nbHits === 0
})(instantsearch.widgets.refinementList)

const formatsRefinementListWithPanel = instantsearch.widgets.panel({
  templates: { header: 'formats' },
  hidden: (options) => options.results.nbHits === 0
})(instantsearch.widgets.refinementList)

search.addWidgets([
  instantsearch.widgets.configure({
    hitsPerPage: 1000
  }),

  instantsearch.widgets.searchBox({
    container: '#searchbox',
  }),

  packRefinementListWithPanel({
    container: '#refinement-list-pack',
    attribute: 'pack.name',
    limit: 20,
    sortBy: ['name:asc']
  }),

  tagsRefinementListWithPanel({
    container: '#refinement-list-tag',
    attribute: 'tags',
    limit: 20,
    sortBy: ['isRefined', 'count:desc', 'name:asc']
  }),

  formatsRefinementListWithPanel({
    container: '#refinement-list-format',
    attribute: 'pack.formats',
    limit: 20,
    sortBy: ['name:asc']
  }),

  // instantsearch.widgets.hits({
  //   container: '#hits',
  //   templates: {
  //     empty: 'No results for <q>{{ query }}</q>',
  //     item: `
  //       {{name}}
  //     `,
  //   },
  // })

  // we're using a custom `hits` widget since the build-in one can't config the complex UI
  {
    render(options) {
      function renderIcon(hit) {
        svg_url = `https://rawcdn.githack.com/${hit.pack.repo}/${hit.pack.ver_tag}/${hit.svg_path}`

        return `
          <li class="col mb-4" data-tags="picture photo">
            <a class="d-block text-dark text-decoration-none">
              <div class="p-3 py-4 mb-2 bg-light text-center rounded">
                <img
                  src="${svg_url}" class="img-fluid" alt="${hit.name}"
                  height="24px" width="24px" />
              </div>
              <div class="name text-muted text-decoration-none text-center pt-1">${hit.name}</div>
            </a>
          </li>
        `
      }

      function renderPack(icons) {
        const pack = icons[0].pack
        const packUrl = `https://github.com/${pack.repo}`

        let header = `
          <div class="row">
            <h5 class="col">
              <a href="${packUrl}" target="_blank">
                <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-box" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                  <path fill-rule="evenodd" d="M8.186 1.113a.5.5 0 0 0-.372 0L1.846 3.5 8 5.961 14.154 3.5 8.186 1.113zM15 4.239l-6.5 2.6v7.922l6.5-2.6V4.24zM7.5 14.762V6.838L1 4.239v7.923l6.5 2.6zM7.443.184a1.5 1.5 0 0 1 1.114 0l7.129 2.852A.5.5 0 0 1 16 3.5v8.662a1 1 0 0 1-.629.928l-7.185 2.874a.5.5 0 0 1-.372 0L.63 13.09a1 1 0 0 1-.63-.928V3.5a.5.5 0 0 1 .314-.464L7.443.184z"/>
                </svg>
                ${pack.name}
              </a>
            </h5>
          </div>
        `

        let iconsList = `
          <ul class="row row-cols-3 row-cols-sm-4 row-cols-lg-6 row-cols-xl-8 list-unstyled list mt-4 mb-5">
            ${icons.map(icon => `
              ${renderIcon(icon)}
            `).join('')}
          </ul>
        `

        return header + iconsList
      }

      const groups = _.groupBy(options.results.hits, (hit) => hit.pack.name)

      document.querySelector('#hits').innerHTML = Object.values(groups)
        .map((icons) => renderPack(icons))
        .join('')

      // TODO improve performance, via lit-html or such
    },
  }
])

search.start()
