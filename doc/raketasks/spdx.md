# SPDX license list import **(PREMIUM ONLY)**

GitLab provides a Rake task for uploading a fresh copy of the [SPDX license list](https://spdx.org/licenses/)
to GitLab instance.
This list is needed for matching [License Compliance policies](../user/compliance/license_compliance/index.md) names.

To import a fresh copy of the PDX license list, run:

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:spdx:import

# source installations
bundle exec rake gitlab:spdx:import RAILS_ENV=production
```

To perform this task in the [offline environment](../user/application_security/offline_deployments/#defining-offline-environments),
ounbound connection to https://spdx.org/licenses/licenses.json should be allowed.
