---
stage: Manage
group: Analytics
To determine the technical writer assigned to the Stage/Group associated with this page, see:
  https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Repository Analytics

Get high-level overview of the project's Git repository.

![Repository Analytics](img/repository_analytics.png)

## Availability

Repository Analytics is part of [GitLab Community Edition](https://gitlab.com/gitlab-org/gitlab-foss). It's available for anyone who has permission to clone the repository.

The feature requires the project's Git repository to be initialized and at least one commit in the default branch (`master` by default) should be present.

## Overview

Repository Analytics is located within the project's sidebar. To access the page, select the **Analytics > Repository** menu item.

NOTE: **Note:**
Without a Git commit in the default branch, the menu item won't be visible.

### Charts

The data in the charts are updated after each commit in the default branch with a slight delay.

Available charts:

* Programming languages used in the repository
* Commit statistics (last month)
* Commits per day of month
* Commits per weekday
* Commits per day hour (UTC)
