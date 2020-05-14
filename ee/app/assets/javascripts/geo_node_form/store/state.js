const createState = () => ({
  isLoading: false,
  synchronizationNamespaces: [],
  formErrors: {
    name: '',
    url: '',
    reposMaxCapacity: '',
    filesMaxCapacity: '',
    containerRepositoriesMaxCapacity: '',
    verificationMaxCapacity: '',
    minimumReverificationInterval: '',
  },
});
export default createState;
