export const sourceContent = `
---
layout: handbook-page-toc
title: Handbook
twitter_image: '/images/tweets/handbook-gitlab.png'
---

## On this page
{:.no_toc .hidden-md .hidden-lg}

- TOC
{:toc .hidden-md .hidden-lg}
`;

export const sourceContentTitle = 'Handbook';

export const projectId = '123456';
export const sourcePath = 'foobar.md.html';

export const submitChangesResponse = {
  branch: {
    name: 'foobar',
    url: 'foobar/-/tree/foorbar',
  },
  commit: {
    shortId: 'c1461b08 ',
    url: 'foobar/-/c1461b08',
  },
  mergeRequest: {
    iid: '123',
    url: 'foobar/-/merge_requests/123',
  },
};

export const submitChangesError = 'Could not save changes';
