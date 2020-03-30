export const fakeIssues = [
  {
    id: 1,
    iid: 1,
    title: 'issue one',
    web_url: 'foo',
  },
  {
    id: 2,
    iid: 2,
    title: 'issue two',
    labels: [{ name: 'Accepting merge requests', color: '#69d100' }],
    milestone: {
      title: '12.10',
    },
    web_url: 'foo',
  },
  {
    id: 3,
    iid: 3,
    title: 'issue three',
    labels: [{ name: 'workflow::In dev', color: '#428bca' }],
    web_url: 'foo',
  },
  {
    id: 4,
    iid: 4,
    title: 'issue four',
    labels: [
      { name: 'Accepting merge requests', color: '#69d100' },
      { name: 'workflow::In dev', color: '#428bca' },
    ],
    web_url: 'foo',
  },
];

export const modifiedIssues = [
  {
    ...fakeIssues[0],
    isAcceptingContributions: null,
    workflow: null,
  },
  {
    ...fakeIssues[1],
    isAcceptingContributions: {
      name: 'Accepting merge requests',
      color: '#69d100',
    },
    workflow: null,
  },
  {
    ...fakeIssues[2],
    isAcceptingContributions: null,
    workflow: {
      name: 'workflow::In dev',
      color: '#428bca',
    },
  },
  {
    ...fakeIssues[3],
    isAcceptingContributions: {
      name: 'Accepting merge requests',
      color: '#69d100',
    },
    workflow: {
      name: 'workflow::In dev',
      color: '#428bca',
    },
  },
];
