# Pipelines for the GitLab project

Pipelines for <https://gitlab.com/gitlab-org/gitlab> and <https://gitlab.com/gitlab-org/gitlab-foss> (as well as the
`dev` instance's mirrors) are configured in the usual
[`.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/.gitlab-ci.yml)
which itself includes files under
[`.gitlab/ci/`](https://gitlab.com/gitlab-org/gitlab/tree/master/.gitlab/ci)
for easier maintenance.

We're striving to [dogfood](https://about.gitlab.com/handbook/engineering/#dogfooding)
GitLab [CI/CD features and best-practices](../ci/yaml/README.md)
as much as possible.

## Stages

The current stages are:

- `sync`: This stage is used to synchronize changes from <https://gitlab.com/gitlab-org/gitlab> to
  <https://gitlab.com/gitlab-org/gitlab-foss>.
- `prepare`: This stage includes jobs that prepare artifacts that are needed by
  jobs in subsequent stages.
- `test`: This stage includes most of the tests, DB/migration jobs, and static analysis jobs.
- `post-test`: This stage includes jobs that build reports or gather data from
  the `test` stage's jobs (e.g. coverage, Knapsack metadata etc.).
- `review-prepare`: This stage includes a job that build the CNG images that are
  later used by the (Helm) Review App deployment (see
  [Review Apps](testing_guide/review_apps.md) for details).
- `review`: This stage includes jobs that deploy the GitLab and Docs Review Apps.
- `qa`: This stage includes jobs that perform QA tasks against the Review App
  that is deployed in the previous stage.
- `post-qa`: This stage includes jobs that build reports or gather data from
  the `qa` stage's jobs (e.g. Review App performance report).
- `notification`: This stage includes jobs that sends notifications about pipeline status.
- `pages`: This stage includes a job that deploys the various reports as
  GitLab Pages (e.g. <https://gitlab-org.gitlab.io/gitlab/coverage-ruby/>,
  <https://gitlab-org.gitlab.io/gitlab/coverage-javascript/>,
  <https://gitlab-org.gitlab.io/gitlab/webpack-report/>).

## Default image

The default image is currently
`registry.gitlab.com/gitlab-org/gitlab-build-images:ruby-2.6.5-golang-1.12-git-2.24-lfs-2.9-chrome-73.0-node-12.x-yarn-1.21-postgresql-9.6-graphicsmagick-1.3.34`.

It includes Ruby 2.6.5, Go 1.12, Git 2.24, Git LFS 2.9, Chrome 73, Node 12, Yarn 1.21,
PostgreSQL 9.6, and Graphics Magick 1.3.33.

The images used in our pipelines are configured in the
[`gitlab-org/gitlab-build-images`](https://gitlab.com/gitlab-org/gitlab-build-images)
project, which is push-mirrored to <https://dev.gitlab.org/gitlab/gitlab-build-images>
for redundancy.

The current version of the build images can be found in the
["Used by GitLab section"](https://gitlab.com/gitlab-org/gitlab-build-images/blob/master/.gitlab-ci.yml).

## Default variables

In addition to the [predefined variables](../ci/variables/predefined_variables.md),
each pipeline includes default variables defined in
<https://gitlab.com/gitlab-org/gitlab/blob/master/.gitlab-ci.yml>.

## Common job definitions

Most of the jobs [extend from a few CI definitions](../ci/yaml/README.md#extends)
that are scoped to a single
[configuration parameter](../ci/yaml/README.md#configuration-parameters).

These common definitions are:

- `.default-tags`: Ensures a job has the `gitlab-org` tag to ensure it's using
  our dedicated runners.
- `.default-retry`: Allows a job to [retry](../ci/yaml/README.md#retry) upon `unknown_failure`, `api_failure`,
  `runner_system_failure`, `job_execution_timeout`, or `stuck_or_timeout_failure`.
- `.default-before_script`: Allows a job to use a default `before_script` definition
  suitable for Ruby/Rails tasks that may need a database running (e.g. tests).
- `.default-cache`: Allows a job to use a default `cache` definition suitable for
  Ruby/Rails and frontend tasks.
- `.use-pg9`: Allows a job to use the `postgres:9.6` and `redis:alpine` services.
- `.use-pg10`: Allows a job to use the `postgres:10.9` and `redis:alpine` services.
- `.use-pg9-ee`: Same as `.use-pg9` but also use the
  `docker.elastic.co/elasticsearch/elasticsearch:5.6.12` services.
- `.use-pg10-ee`: Same as `.use-pg10` but also use the
  `docker.elastic.co/elasticsearch/elasticsearch:5.6.12` services.
- `.as-if-foss`: Simulate the FOSS project by setting the `FOSS_ONLY='1'`
  environment variable.

## Changes detection

If a job extends from `.default-only` (and most of the jobs should), it can restrict
the cases where it should be created
[based on the changes](../ci/yaml/README.md#onlychangesexceptchanges)
from a commit or MR by extending from the following CI definitions:

- `.only:changes-code-backstage`: Allows a job to only be created upon code-related or backstage-related (e.g. Danger, RuboCop, specs) changes.
- `.only:changes-code-qa`: Allows a job to only be created upon code-related or QA-related changes.
- `.only:changes-code-backstage-qa`: Allows a job to only be created upon code-related, backstage-related (e.g. Danger, RuboCop, specs) or QA-related changes.

**See <https://gitlab.com/gitlab-org/gitlab/blob/master/.gitlab/ci/global.gitlab-ci.yml>
for the list of exact patterns.**

## Rules conditions and changes patterns

We're making use of the [`rules` keyword](https://docs.gitlab.com/ee/ci/yaml/#rules).

All `rules` conditions and patterns are declared in
<https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/ci/rules.gitlab-ci.yml>

### Conditions

#### Non-canonical namespace

The `if-not-canonical-namespace` condition matches if the project isn't in the
canonical (`gitlab-org/`) or security (`gitlab-org/security`) namespace.

Useful to:

- **not** create a job if the project is a fork (by using `when: never`)
- create a job for forks (by using `when: on_success|manual`).

#### Not EE

The `if-not-ee` condition matches if the project isn't EE (i.e. project name
isn't `gitlab` or `gitlab-ee`).

Useful to:

- **not** create a job if the project is EE (by using `when: never`)
- create a job only in the FOSS project (by using `when: on_success|manual`)

#### Not FOSS

The `if-not-foss` condition matches if the project isn't FOSS (i.e. project name
isn't `gitlab-foss`, `gitlab-ce`, or `gitlabhq`).

Useful to:

- **not** create a job if the project is FOSS (by using `when: never`)
- create a job only in the EE project (by using `when: on_success|manual`)

#### Default refs

The `if-default-refs` condition matches if the pipeline is for `master`,
`/^[\d-]+-stable(-ee)?$/` (stable branches), `/^\d+-\d+-auto-deploy-\d+$/`
(auto-deploy branches), `/^security\//` (security branches), merge requests, and
tags.

Note that jobs won't be created for branches with this default configuration.

#### `master` branch

The `if-master-refs` condition matches if the current branch is `master`.

#### `master` branch or tag

The `if-master-or-tag` condition matches if the pipeline is for the `master`
branch or for a tag.

#### merge request

The `if-merge-request` condition matches if the pipeline is for a merge request.

#### GitLab.com `gitlab-org` namespace scheduled pipelines

The `if-dot-com-gitlab-org-schedule` condition limits jobs creation to scheduled
pipelines for the `gitlab-org` group on GitLab.com.

#### GitLab.com `gitlab-org` namespace `master` branch

The `if-dot-com-gitlab-org-master` condition limits jobs creation to the
`master` branch for the `gitlab-org` group on GitLab.com.

#### GitLab.com `gitlab-org` namespace merge request

The `if-dot-com-gitlab-org-merge-request` condition limits jobs creation to
merge requests for the `gitlab-org` group on GitLab.com.

#### GitLab.com `gitlab-org`/`gitlab-org/security` namespace tag

The `if-canonical-dot-com-gitlab-org-and-security-tag` condition limits jobs
creation to tags for the `gitlab-org` and `gitlab-org/security` groups on GitLab.com.

#### GitLab.com `gitlab-org`/`gitlab-org/security` namespace merge request

The `if-canonical-dot-com-gitlab-org-and-security-merge-request` condition
limits jobs creation to merge requests for the `gitlab-org` and
`gitlab-org/security` groups on GitLab.com.

#### Scheduled pipelines with `$CI_REPO_CACHE_CREDENTIALS`

The `if-cache-credentials-schedule` condition limits jobs to scheduled pipelines
with the `$CI_REPO_CACHE_CREDENTIALS` variable set.

#### GitLab.com `gitlab-org/gitlab` project scheduled pipelines

The `if-canonical-dot-com-ee-schedule` condition limits jobs to scheduled pipelines
for the `gitlab-org/gitlab` project on GitLab.com.

### Change patterns

#### YAML

The `yaml-patterns` patterns allow a job to only be created upon YAML-related changes.

#### Docs

The `docs-patterns` patterns allow a job to only be created upon docs-related changes.

#### Backstage

The `backstage-patterns` patterns allow a job to only be created upon backstage-related changes.

#### Code

The `code-patterns` patterns allow a job to only be created upon code-related changes.

#### QA

The `qa-patterns` patterns allow a job to only be created upon QA-related changes.

#### Code + backstage

Combination of the `code-patterns`, and `backstage-patterns` patterns.

#### Code + QA

Combination of the `code-patterns`, and `qa-patterns` patterns.

#### Code + backstage + QA

Combination of the `code-patterns` `backstage-patterns`, and `qa-patterns` patterns.

## Directed acyclic graph

We're using the [`needs:`](../ci/yaml/README.md#needs) keyword to
execute jobs out of order for the following jobs:

```mermaid
graph RL;
  A[setup-test-env];
  B["gitlab:assets:compile pull-push-cache<br/>(canonical master only)"];
  C["gitlab:assets:compile pull-cache<br/>(canonical default refs only)"];
  D["cache gems<br/>(master and tags only)"];
  E[review-build-cng];
  F[build-qa-image];
  G[review-deploy];
  G2["schedule:review-deploy<br/>(master only)"];
  I["karma, jest, webpack-dev-server, static-analysis"];
  I2["karma-foss, jest-foss<br/>(EE default refs only)"];
  J["compile-assets pull-push-cache<br/>(master only)"];
  J2["compile-assets pull-push-cache foss<br/>(EE master only)"];
  K[compile-assets pull-cache];
  K2["compile-assets pull-cache foss<br/>(EE default refs only)"];
  M[coverage];
  N["pages (master only)"];
  Q[package-and-qa];
  S["RSpec<br/>(e.g. rspec unit pg9)"]
  T[retrieve-tests-metadata];

subgraph "`prepare` stage"
    A
    B
    C
    F
    K
    K2
    J
    J2
    T
    end

subgraph "`test` stage"
    D -.-> |needs| A;
    I -.-> |needs and depends on| A;
    I -.-> |needs and depends on| K;
    I2 -.-> |needs and depends on| A;
    I2 -.-> |needs and depends on| K;
    L -.-> |needs and depends on| A;
    S -.-> |needs and depends on| A;
    S -.-> |needs and depends on| K;
    S -.-> |needs and depends on| T;
    L["db:*, gitlab:setup, graphql-docs-verify, downtime_check"] -.-> |needs| A;
    end

subgraph "`post-test` stage"
    M --> |happens after| S
    end

subgraph "`review-prepare` stage"
    E -.-> |needs| C;
    E2["schedule:review-build-cng<br/>(master schedule only)"] -.-> |needs| C;
    end

subgraph "`review` stage"
    G --> |happens after| E
    G2 --> |happens after| E2
    end

subgraph "`qa` stage"
    Q -.-> |needs| C;
    Q -.-> |needs| F;
    QA1["review-qa-smoke, review-qa-all, review-performance, dast"] -.-> |needs and depends on| G;
    QA2["schedule:review-performance<br/>(master only)"] -.-> |needs and depends on| G2;
    end

subgraph "`post-qa` stage"
  PQA1["parallel-spec-reports"] -.-> |depends on `review-qa-all`| QA1;
  end

subgraph "`pages` stage"
    N -.-> |depends on| C;
    N -.-> |depends on karma| I;
    N -.-> |depends on| M;
    N --> |happens after| PQA1
    end
```

## Test jobs

Consult [GitLab tests in the Continuous Integration (CI) context](testing_guide/ci.md)
for more information.

## Review app jobs

Consult the [Review Apps](testing_guide/review_apps.md) dedicated page for more information.

---

[Return to Development documentation](README.md)
