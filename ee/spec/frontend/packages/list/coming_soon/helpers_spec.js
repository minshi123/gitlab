import * as comingSoon from 'ee/packages/list/coming_soon/helpers';
import Api from 'ee/api';
import { fakeIssues } from './mock_data';

jest.mock('ee/api.js');

describe('Coming Soon Helpers', () => {
  const gitlabAddress = 'gitlab.com';
  const localAddresss = '0.0.0.0';
  const gitlabProjectId = 278964;

  const setup = (url = gitlabAddress) => {
    window.gon = {
      gitlab_url: url,
    };
  };

  describe('isEnabled', () => {
    it('returns true for gitlab.com', () => {
      setup();
      expect(comingSoon.isEnabled()).toBe(true);
    });

    it('returns true for local', () => {
      setup(localAddresss);
      expect(comingSoon.isEnabled()).toBe(true);
    });

    it('returns false for anything else', () => {
      setup('foo');
      expect(comingSoon.isEnabled()).toBe(false);
    });
  });

  describe('fetchComingSoonIssues', () => {
    const params = {
      state: 'opened',
      labels: 'package::coming-soon',
      with_labels_details: 'true',
    };

    Api.projectIssues = jest.fn().mockResolvedValue(fakeIssues);

    beforeEach(() => {
      setup();
    });

    it('fetches and returns issues', () => {
      return comingSoon.fetchComingSoonIssues().then(result => {
        expect(Api.projectIssues).toHaveBeenCalledWith(gitlabProjectId, params);
        expect(result.length).toBe(fakeIssues.length);
      });
    });

    it('has two marked with isAcceptingContributions to true', () => {
      return comingSoon.fetchComingSoonIssues().then(result => {
        expect(Api.projectIssues).toHaveBeenCalledWith(gitlabProjectId, params);
        expect(result.filter(x => x.isAcceptingContributions).length).toBe(2);
      });
    });

    it('has two with a workflow', () => {
      return comingSoon.fetchComingSoonIssues().then(result => {
        expect(Api.projectIssues).toHaveBeenCalledWith(gitlabProjectId, params);
        expect(result.filter(x => x.workflow).length).toBe(2);
      });
    });
  });
});
