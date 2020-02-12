export default () => ({
  inputValue: '',
  isLoadingProjects: false,
  isAddingProjects: false,
  isRemovingProject: false,
  projectEndpoints: {
    list: null,
    add: null,
  },
  searchQuery: '',
  projects: [],
  projectSearchResults: [],
  selectedProjects: [],
  messages: {
    noResults: false,
    searchError: false,
    minimumQuery: false,
  },
  searchCount: 0,
  // @TODO - pagination data - maybe rename?
  pageInfo: {
    totalPages: 0,
    totalResults: 0,
    nextPage: 0,
    currentPage: 0,
  },
});
