# Packages **(PREMIUM)**

This document will guide you through adding another [package management system](../administration/packages/index.md) support to GitLab.

See already supported package types in [Packages documentation](../administration/packages/index.md)

Since GitLab packages' UI is pretty generic, it is possible to add basic new
package system support with solely backend changes. This guide is superficial and does
not cover the way the code should be written. However, you can find a good example
by looking at merge requests with Maven and NPM support:

- [NPM registry support](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/8673).
- [Conan repository](https://gitlab.com/gitlab-org/gitlab/issues/8248).
- [Maven repository](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/6607).
- [Instance level endpoint for Maven repository](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/8757)

## General information

The existing database model requires the following:

- Every package belongs to a project.
- Every package file belongs to a package.
- A package can have one or more package files.
- The package model is based on storing information about the package and its version.

### API endpoints

Package systems work with GitLab via API. For example `ee/lib/api/npm_packages.rb`
implements API endpoints to work with NPM clients. So, the first thing to do is to
add a new `ee/lib/api/your_name_packages.rb` file with API endpoints that are
necessary to make the package system client to work. Usually that means having
endpoints like:

- GET package information.
- GET package file content.
- PUT upload package.

Since the packages belong to a project, it's expected to have project-level endpoint (remote)
for uploading and downloading them. For example:

```plaintext
GET https://gitlab.com/api/v4/projects/<your_project_id>/packages/npm/
PUT https://gitlab.com/api/v4/projects/<your_project_id>/packages/npm/
```

Group-level and instance-level endpoints are good to have but are optional.

#### Remote hierarchy

Packages are scoped within various levels of access, which is generally configured by setting your remote. A
remote endpoint may be set at the project level, meaning when installing packages, only packages belonging to that
project will be visible. Alternatively, a group-level endpoint may be used to allow visibility to all packages
within a given group. Lastly, an instance-level endpoint can be used to allow visibility to all packages within an
entire GitLab instance.

Using group and project level endpoints will allow for more flexibility in package naming, however, more remotes
will have to be managed. Using instance level endpoints requires [stricter naming conventions](#naming-conventions).

The current state of existing package registries availability is:

| Repository Type | Project Level | Group Level | Instance Level |
|-----------------|---------------|-------------|----------------|
| Maven           | Yes           | Yes         | Yes            |
| Conan           | No - [open issue](https://gitlab.com/gitlab-org/gitlab/issues/11679) | No - [open issue](https://gitlab.com/gitlab-org/gitlab/issues/11679) | Yes |
| NPM             | No - [open issue](https://gitlab.com/gitlab-org/gitlab/issues/36853) | Yes | No - [open issue](https://gitlab.com/gitlab-org/gitlab/issues/36853) |

NOTE: **Note:** NPM is currently a hybrid of the instance level and group level.
It is using the top-level group or namespace as the defining portion of the name
(for example, `@my-group-name/my-package-name`).

### Naming conventions

To avoid name conflict for instance-level endpoints you will need to define a package naming convention
that gives a way to identify the project that the package belongs to. This generally involves using the project
id or full project path in the package name. See
[Conan's naming convention](../user/packages/conan_repository/index.md#package-recipe-naming-convention) as an example.

For group and project-level endpoints, naming can be less constrained, and it will be up to the group and project
members to be certain that there is no conflict between two package names, however the system should prevent
a user from reusing an existing name within a given scope.

Otherwise, naming should follow the package manager's naming conventions and include a validation in the `package.md`
model for that package type.

### Services and finders

Logic for performing tasks such as creating package or package file records or finding packages should not live
within the API file, but should live in services and finders. Existing services and finders should be used or
extended when possible to keep the common package logic grouped as much as possible.

### Configuration

GitLab has a `packages` section in its configuration file (`gitlab.rb`).
It applies to all package systems supported by GitLab. Usually you don't need
to add anything there.

Packages can be configured to use object storage, therefore your code must support it.

## MVC Approach

The way new package systems are integrated in GitLab is using an [MVC](https://about.gitlab.com/handbook/values/#minimum-viable-change-mvc). In this regard, the first iteration should support the bare minimal user actions:

- authentication
- uploading a package
- pulling a package
- required actions

Required actions are all the additional requests that GitLab will need to handle so the corresponding package manager CLI can work properly. Usually it can be a search feature or an endpoint providing meta information about a package. Here are some examples of such required actions:

- In NuGet, to support Visual Studio, the search request has been implemented during the first iteration of the MVC.
- In NPM, there is a metadata endpoint used by `npm` to get the tarball url.

For the first iteration of the MVC, it's recommended to stay at the project level of the [remote hierarchy](#remote-hierarchy). Other levels can be tackled with [future Merge Requests](#future-work)

There are basically 2 phases for the MVC:

- Analysis
- Implementation

### Keep iterations small

When implementing a new package manager, it is easy to end up creating one large merge request containing all of the
necessary endpoints and services necessary to support basic usage. If this is the case, consider putting the
API endpoints behind a [feature flag](feature_flags/development.md) and
submitting each endpoint or behavior (download, upload, etc) in different merge requests to shorten the review
process.

### Analysis

During this phase, the idea is to collect as much information about the API used by the package system as possible. Here some aspects that can be useful to include.

- *Authentication* What authentication mecanisms are available (OAuth, Basic Authorization, other). For this part, keep in mind that GitLab users will want to use their [Personal Access Tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html). Although not needed for the MVC first iteration, the [CI job tokens](https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html#job-token) have to be supported at some point in the future.
- *Requests* Which requests are needed to have a working MVC. Ideally, it's better to produce a list of all the requests needed for the MVC (including required actions). A further investigation could provide for each request an example with the request and the response bodies.
- *Upload* Carefully how the upload process works. This will probably be the most complex request to implement. A detailed analysis is desired here as uploads can be encoded in different ways (body or multipart) or can even be a totally different format (for example, it could be a JSON structure where the package file is a Base64 value of a particular field). These different encodings lead to slight different implementations on GitLab and GitLab Workhorse. For more detailed information, see [below](#file-uploads).
- *Endpoints* Suggest a list of endpoints urls that will be implemented on GitLab.
- *Split work* Suggest a list of changes to incrementally build the MVC. This will give a good idea of how much work there is to be done. Here is a general one that would need to be adapted on a case by case basis.
  1. Empty file structure (API file, base service for this package)
  1. Authentication system for 'logging in' to the package manager
  1. Identify metadata and create applicable tables
  1. Workhorse route for [object storage direct upload](uploads.md#direct-upload)
  1. Endpoints required for upload/publish
  1. Endpoints required for install/download
  1. Endpoints required for required actions

The analysis usually takes a full milestone to complete. Having said that, it's not impossible to start the implementation in the same milestone.

In particular, the upload request can have some requirements on the GitLab Workhorse project (see [below](#file-uploads)). This project having a different release cycle than the rails backend. It's **strongly** recommended to open an issue there as soon as the upload request analysis is done. The idea here is that when the upload request is implemented on the rails backend, GitLab Worhorse is already ready to handle such request.

### Implementation

The implementation of the different Merge Requests will vary from a package system integration to another. We will discuss some aspects of the implementation phase that contributors should take into account.

#### Authentication

The MVC must support [Personal Access Tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) right from the start. We currently support two ways for these tokens: OAuth and Basic Access.

For OAuth authentication, its support is already done for the APIs. You can see an example in the [npm API](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/api/npm_packages.rb#L14).

For [Basic Access autentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication), its support is done by override a specific function from the API helpers. You can see an example in the [Conan API](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/api/conan_packages.rb). For this authentication mechanism, keep in mind that some clients can send first an unauthenticated request, wait for the 401 Unauthorized response with the [`WWW-Authenticate`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate) field to then re execute the same request but in an authenticated way. This particular case is more involved as GitLab needs to handle the 401 Unauthorized response. the [Nuget API](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/api/nuget_packages.rb) supports this case.

#### Authorization

There are project and group level permissions for `read_package`, `create_package`, and `destroy_package`. Each
endpoint should
[authorize the requesting user](https://gitlab.com/gitlab-org/gitlab/blob/398fef1ca26ae2b2c3dc89750f6b20455a1e5507/ee/lib/api/conan_packages.rb)
against the project or group before continuing.

#### Database and handling metadata

The current database model allows you to store a name and a version for each package.
Every time you upload a new package, you can either create a new record of `Package`
or add files to existing record. `PackageFile` should be able to store all file-related
information like the file `name`, `side`, `sha1`, etc.

If there is specific data necessary to be stored for only one package system support,
consider creating a separate metadata model. See `packages_maven_metadata` table
and `Packages::MavenMetadatum` model as an example for package specific data, and `packages_conan_file_metadata` table
and `Packages::ConanFileMetadatum` model as an example for package file specific data.

If there is package specific behavior for a given package manager, add those methods to the metadata models and
delegate from the package model.

Note that the existing package UI only displays information within the `packages_packages` and `packages_package_files`
tables. If the data stored in the metadata tables need to be displayed, a ~frontend change will be required.

#### File uploads

File uploads should be handled by GitLab Workhorse using object accelerated uploads. What this means is that
the workhorse proxy that checks all incoming requests to GitLab will intercept the upload request,
upload the file, and forward a request to the main GitLab codebase only containing the metadata
and file location rather than the file itself. An overview of this process can be found in the
[development documentation](uploads.md#direct-upload).

In terms of code, this means a route will need to be added to the
[GitLab Workhorse project](https://gitlab.com/gitlab-org/gitlab-workhorse) for upload endpoint being added
(instance, group, project). [This merge request](https://gitlab.com/gitlab-org/gitlab-workhorse/-/merge_requests/412/diffs)
demonstrates adding an instance-level endpoint for Conan to workhorse. You can also see the Maven project level endpoint
implemented in the same file.

Once the route has been added, you will need to add an additional `/authorize` version of the upload endpoint to your API file.
[Here is an example](https://gitlab.com/gitlab-org/gitlab/blob/398fef1ca26ae2b2c3dc89750f6b20455a1e5507/ee/lib/api/maven_packages.rb#L164)
of the additional endpoint added for Maven. The `/authorize` endpoint verifies and authorizes the request from workhorse,
then the normal upload endpoint is implemented below, consuming the metadata that workhorse provides in order to
create the package record. Workhorse provides a variety of file metadata such as type, size, and different checksum formats.

For testing purposes, you may want to [enable object storage](https://gitlab.com/gitlab-org/gitlab-development-kit/blob/master/doc/howto/object_storage.md)
in your local development environment.

### Future Work

While working on the MVC, contributors will probably find features that are not mandatory for the MVC but can provide a better user experience. It's generally a good idea to keep an eye on those and open issues.

Here are some examples

1. Endpoints required for search
1. Front end updates to display additional package information and metadata
1. Limits on file sizes
1. Tracking for metrics
1. Read more metadata fields from the package to make it available to the front end. For example, it's usual to be able to tag a package. Those tags can be read and saved by backend and then displayed on the packages UI.
1. Endpoints for the upper levels of the [remote hierarchy](#remote-hierarchy). This step might need to create a [naming convention](#naming-conventions)

## Exceptions

This documentation is just guidelines on how to implement a package manager to match the existing structure and logic
already present within GitLab. While the structure is intended to be extendable and flexible enough to allow for
any given package manager, if there is good reason to stray due to the constraints or needs of a given package
manager, then it should be raised and discussed within the implementation issue or merge request to work towards
the most efficient outcome.
