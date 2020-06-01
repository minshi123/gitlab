const TEST_PROJECT_PATH = 'gitlab-test/test';

export const mockProject = {
  id: 50,
  description: '',
  name: 'Test Project',
  name_with_namespace: 'Administrator / Test Project',
  path: 'test',
  path_with_namespace: TEST_PROJECT_PATH,
  created_at: '2020-04-03T13:51:26.865Z',
  default_branch: 'master',
  tag_list: [],
  avatar_url: null,
  star_count: 0,
  forks_count: 0,
  last_activity_at: '2020-05-14T17:21:19.663Z',
  namespace: {
    id: 1,
    name: 'Administrator',
    path: 'root',
    kind: 'user',
    full_path: 'root',
    parent_id: null,
    avatar_url:
      'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
    web_url: '//root',
  },
  _links: {
    self: 'http://gitlab.local:3001/api/v4/projects/50',
    issues: 'http://gitlab.local:3001/api/v4/projects/50/issues',
    merge_requests: 'http://gitlab.local:3001/api/v4/projects/50/merge_requests',
    repo_branches: 'http://gitlab.local:3001/api/v4/projects/50/repository/branches',
    labels: 'http://gitlab.local:3001/api/v4/projects/50/labels',
    events: 'http://gitlab.local:3001/api/v4/projects/50/events',
    members: 'http://gitlab.local:3001/api/v4/projects/50/members',
  },
  empty_repo: false,
  archived: false,
  visibility: 'public',
  owner: {
    id: 1,
    name: 'Administrator',
    username: 'root',
    state: 'active',
    avatar_url:
      'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
    web_url: 'http://gitlab.local:3001/root',
  },
  merge_requests_enabled: true,
  jobs_enabled: true,
  can_create_merge_request_in: true,
  creator_id: 1,
  merge_method: 'merge',
  suggestion_commit_message: null,
  permissions: {
    project_access: { access_level: 40, notification_level: 3 },
    group_access: null,
  },
};

export const mockBranch = {
  name: 'master',
  commit: {
    id: 'e330608d6b9118a01d530d2c87fc77fe0703cb6f',
    short_id: 'e330608d',
    created_at: '2020-05-14T12:37:51.000-05:00',
    parent_ids: ['1bf356f4f2267466b615dcddbed32b7405753a97'],
    title: 'Update test',
    message: 'Update test\nDeleted test/123.txt',
    author_name: 'Administrator',
    author_email: 'admin@example.com',
    authored_date: '2020-05-14T12:37:51.000-05:00',
    committer_name: 'Administrator',
    committer_email: 'admin@example.com',
    committed_date: '2020-05-14T12:37:51.000-05:00',
    web_url:
      'http://gitlab.local:3001/root/empty-project-14/-/commit/e330608d6b9118a01d530d2c87fc77fe0703cb6f',
  },
  merged: false,
  protected: true,
  developers_can_push: false,
  developers_can_merge: false,
  can_push: true,
  default: true,
  web_url: 'http://gitlab.local:3001/root/empty-project-14/-/tree/master',
};

export const mockFiles = [
  '123.txt',
  'LICENSE',
  'NEW_FILE',
  'NEW_FILE2',
  'README.md',
  'config/temp.config.js',
  'config/test.config.js',
  'lorem/C.md',
  'src/test/ANOTHER_NEW_FILE',
  'test',
];
