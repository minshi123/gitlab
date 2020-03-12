# Getting started with an air-gapped GitLab Installation

This is a step-by-step guide that helps you install, configure, and use a self-managed GitLab
instance entirely offline.

## Requirements

To load our software onto the isolated host, a method must be used for sideloading...

## Installation

**Note**: The below guide assumes the server to be Ubuntu 18.04, individual instructions may vary.
**Note**: The below guide assumes the server host resolves as `my-host` and should be substituted for your true server name.

https://about.gitlab.com/install/#ubuntu

```shell
$ sudo EXTERNAL_URL="http://my-host.internal" install gitlab-ee
```
## Enabling SSL

[Following the steps for Omnibus manual nginx SSL configuration](../../omnibus/settings/nginx.html#manually-configuring-https), let's enable SSL for our fresh instance.

Make the following changes to `/etc/gitlab/gitlab.rb`:

- Update `external_url` from "http" to "https"
- Replace `# letsencrypt['enable'] = nil` with `letsencrypt['enable'] = false`

Create the following directories with the appropriate permissions for generating self-signed certificates:

```shell
$ sudo mkdir -p /etc/gitlab/ssl
$ sudo chmod 755 /etc/gitlab/ssl
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/gitlab/ssl/my-host.internal.key -out /etc/gitlab/ssl/my-host.internal.crt
```

To apply the changes, now reconfigure your instance:

```shell
$ sudo gitlab-ctl reconfigure
```

## Enabling GitLab Container Registry

[Following the steps for configuring the container registry under an existing domain](../../ee/administration/packages/container_registry.html#configure-container-registry-under-an-existing-gitlab-domain), let's enable the registry.


Make the following changes to `/etc/gitlab/gitlab.rb`:

- Change `external_registry_url` to match `external_url`, but append the port `:4567`

To apply the changes, now reconfigure your instance:

```shell
$ sudo gitlab-ctl reconfigure
```

## Allow the docker daemon to trust the registry and gitlab runner

[Following the steps for using trusted certificates with our registry](../../ee/administration/packages/container_registry.html#using-self-signed-certificates-with-container-registry), we must provide our docker daemon with our certs.

```shell
$ sudo mkdir -p /etc/docker/certs.d/my-host.internal:5000

$ sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/docker/certs.d/my-host.internal:5000/ca.crt
```

[Following the steps for using trusted certificates with our runner](../../runner/install/docker.html#installing-trusted-ssl-server-certificates), we must provide our gitlab runner (to be installed next) with our certs.

- 

```shell
$ sudo mkdir -p /etc/gitlab-runner/certs

$ sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/gitlab-runner/certs/ca.crt
```

## Enabling GitLab Runner

[Following the steps for installing our GitLab Runner as a docker service](../../runner/install/docker.html#docker-image-installation), we must first register our runner.

```shell
$ sudo docker run --rm -it -v /etc/gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register
Updating CA certificates...
Runtime platform                                    arch=amd64 os=linux pid=7 revision=1b659122 version=12.8.0
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://my-host.internal
Please enter the gitlab-ci token for this runner:
XXXXXXXXXXX
Please enter the gitlab-ci description for this runner:
[eb18856e13c0]:
Please enter the gitlab-ci tags for this runner (comma separated):

Registering runner... succeeded                     runner=FSMwkvLZ
Please enter the executor: custom, docker, virtualbox, kubernetes, docker+machine, docker-ssh+machine, docker-ssh, parallels, shell, ssh:
docker
Please enter the default Docker image (e.g. ruby:2.6):
ruby:2.6
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

Now we must add some additional configuration to our runner:

Make the following changes to `/etc/gitlab-runner/config.toml`:

- Add docker socket to volumes `volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]`
- Add `pull_policy = "if-not-present"` to the executor configuration

Now we can start our runner:

```shell
sudo docker run -d --restart always --name gitlab-runner -v /etc/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
90646b6587127906a4ee3f2e51454c6e1f10f26fc7a0b03d9928d8d0d5897b64
```

### Authenticating the registry against the host OS

As noted in [Docker's registry authentication documentation](../../registry/insecure/#docker-still-complains-about-the-certificate-when-using-authentication), certain versions of docker require trusting the certificate chain at the OS level itself.

In the case of Ubuntu, this involves using `update-ca-certificates`:

```shell
$ sudo cp /etc/docker/certs.d/my-host.internal\:5000/ca.crt /usr/local/share/ca-certificates/my-host.internal.crt

$ sudo update-ca-certificates
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```
