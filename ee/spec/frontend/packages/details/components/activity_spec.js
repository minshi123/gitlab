import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlSkeletonLoader } from '@gitlab/ui';
import PackageActivity from 'ee/packages/details/components/activity.vue';
import {
  npmPackage,
  mavenPackage as packageWithoutBuildInfo,
  mockPipelineInfo,
} from '../../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('PackageActivity', () => {
  let wrapper;
  let store;

  function createComponent(
    packageEntity = packageWithoutBuildInfo,
    hasPipeline = false,
    isLoading = false,
    pipelineError = null,
  ) {
    store = new Vuex.Store({
      state: {
        isLoading,
        packageEntity,
        pipelineInfo: mockPipelineInfo,
        pipelineError,
      },
      getters: {
        packageHasPipeline: () => hasPipeline,
      },
    });

    wrapper = shallowMount(PackageActivity, {
      localVue,
      store,
    });
  }

  const commitInfo = () => wrapper.find({ ref: 'commit-info' });
  const pipelineInfo = () => wrapper.find({ ref: 'pipeline-info' });
  const pipelineLoadingSkeleton = () => wrapper.findAll(GlSkeletonLoader);
  const pipelineErrorMessage = () => wrapper.find({ ref: 'pipeline-error' });

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  describe('render', () => {
    it('to match the default snapshot when no pipeline', () => {
      createComponent();

      expect(wrapper.element).toMatchSnapshot();
    });

    it('to match the default snapshot when there is a pipeline', () => {
      createComponent(npmPackage, true, false, 'pipeline error');

      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('pipeline information', () => {
    it('does not display pipeline information when no build info is available', () => {
      createComponent();

      expect(pipelineInfo().exists()).toBe(false);
    });

    it('displays the loading skeleton when fetching information', () => {
      createComponent(npmPackage, true, true);

      expect(pipelineLoadingSkeleton()).toHaveLength(2);
    });

    it('displays that the pipeline error information fetching fails', () => {
      const pipelineError = 'an-error-message';
      createComponent(npmPackage, true, false, pipelineError);

      expect(commitInfo().exists()).toBe(true);
      expect(pipelineLoadingSkeleton().exists()).toBe(false);
      expect(pipelineErrorMessage().exists()).toBe(true);
      expect(pipelineErrorMessage().text()).toBe(pipelineError);
    });

    it('displays the pipeline information if found', () => {
      createComponent(npmPackage, true);

      expect(commitInfo().exists()).toBe(true);
      expect(pipelineInfo().exists()).toBe(true);
    });
  });
});
