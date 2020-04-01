import { sourceContent, sourceContentTitle } from '../mock_data';
import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';

import loadSourceContent from '~/static_site_editor/services/load_source_content';

describe('loadSourceContent', () => {
  let mock;
  const projectId = '123456';
  const sourcePath = 'foobar.md.html';

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('requesting source content succeeds', () => {
    beforeEach(() => {
      const encodedFilePath = encodeURIComponent(sourcePath);

      mock
        .onGet(`/api/v4/projects/${projectId}/repository/files/${encodedFilePath}/raw?ref=master`)
        .reply(200, sourceContent);
    });

    it('extracts page title from source content', () => {
      return loadSourceContent({ projectId, sourcePath }).then(data => {
        expect(data.title).toBe(sourceContentTitle);
      });
    });

    it('returns raw content', () => {
      return loadSourceContent({ projectId, sourcePath }).then(data => {
        expect(data.content).toBe(sourceContent);
      });
    });
  });
});
