# GitLab NuGet Repository **(PREMIUM)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/issues/20050) in [GitLab Premium](https://about.gitlab.com/pricing/) 12.8.

With the GitLab NuGet Repository, every project can have its own space to store NuGet packages.

The GitLab NuGet Repository works with either [nuget CLI](https://www.nuget.org/) or [Visual Studio](https://visualstudio.microsoft.com/vs/).

## Setting up your development environment

You will need [nuget CLI](https://www.nuget.org/) 5.2 or above. Previous versions have not been tested against the GitLab NuGet Repository and might not work. You can install it by visiting the [downloads page](https://www.nuget.org/downloads).

If you have [Visual Studio](https://visualstudio.microsoft.com/vs/), [nuget CLI](https://www.nuget.org/) is probably already installed.

Alternatively, you may use the [.NET SDK](https://dotnet.microsoft.com/) 3.0 or above which installs [nuget CLI](https://www.nuget.org/).

You can confirm that [nuget CLI](https://www.nuget.org/) is properly installed with:

```shell
nuget help
```

You should see something similar to:

```
NuGet Version: 5.2.0.6090
usage: NuGet <command> [args] [options]
Type 'NuGet help <command>' for help on a specific command.

Available commands:

[output truncated]
```

## Enabling the NuGet Repository

NOTE: **Note:**
This option is available only if your GitLab administrator has
[enabled support for the NuGet Repository](../../../administration/packages/index.md).**(PREMIUM ONLY)**

After the NuGet Repository is enabled, it will be available for all new projects
by default. To enable it for existing projects, or if you want to disable it:

1. Navigate to your project's **Settings > General > Permissions**.
1. Find the Packages feature and enable or disable it.
1. Click on **Save changes** for the changes to take effect.

You should then be able to see the **Packages** section on the left sidebar.

## Adding the GitLab NuGet Repository as a source to nuget

You will need the following:

- Your GitLab username.
- A personal access token. You can generate a [personal access token](../../../user/profile/personal_access_tokens.md) with the scope set to `api` for repository authentication.
- A suitable name for your source.
- Your project ID which can be found on the home page of your project.

You can now add a new source to nuget either using [nuget CLI](https://www.nuget.org/) or [Visual Studio](https://visualstudio.microsoft.com/vs/).

### Using nuget CLI

To add the GitLab NuGet Repository as a source with `nuget`:

```shell
nuget source Add -Name <source_name> -Source "https://example.gitlab.com/api/v4/projects/<your_project_id>/packages/nuget/index.json" -UserName <gitlab_username> -Password <gitlab_token>
```

Replace:

- `<source_name>` with your desired source name.
- `<your_project_id>` with your project ID.
- `<gitlab-username>` with your GitLab username.
- `<gitlab-token>` with your personal access token.
- `example.gitlab.com` with the URL of the GitLab instance you're using.

For example:

```shell
nuget source Add -Name "GitLab" -Source "https//gitlab.example/api/v4/projects/10/packages/nuget/index.json" -UserName carol -Password 12345678asdf
```

### Using Visual Studio

1. Open [Visual Studio](https://visualstudio.microsoft.com/vs/).
1. Open the **FILE > OPTIONS** (Windows) or **Visual Studio > Preferences** (Mac OS).
1. In the **NuGet** section, open **Sources**. You will see a list of all your NuGet sources.
1. Click **Add**.
1. Fill the fields with:
   - **Name**: Desired name for the source
   - **Location**: `https://gitlab.com/api/v4/projects/<your_project_id>/packages/nuget/index.json`
     - Replace `<your_project_id>` with your project ID.
     - If you have a self-hosted GitLab installation, replace `gitlab.com` with your domain name.
   - **Username**: Your GitLab username
   - **Password**: Your personal access token

   ![Visual Studio Adding a NuGet source](img/visual_studio_adding_nuget_source.png)

1. Click **Save**.

   ![Visual Studio NuGet source added](img/visual_studio_nuget_source_added.png)

In case of any warning, please make sure that the **Location**, **Username** and **Password** are correct.

### Using dotnet CLI

To add the GitLab NuGet Repository as a source for `dotnet`, create a file named `nuget.config` at the root of your project with the following content:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <clear />
        <add key="gitlab" value="https://example.gitlab.com/api/v4/projects/<your_project_id>/packages/nuget" />
    </packageSources>
    <packageSourceCredentials>
        <gitlab>
            <add key="Username" value="<gitlab-username>" />
            <add key="ClearTextPassword" value="<gitlab-token>" />
        </gitlab>
    </packageSourceCredentials>
</configuration>
```

Replace:

- `<your_project_id>` with your project ID.
- `<gitlab-username>` with your GitLab username.
- `<gitlab-token>` with your personal access token.
- `example.gitlab.com` with the URL of the GitLab instance you're using.

For example:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <clear />
        <add key="gitlab" value="https//gitlab.example/api/v4/projects/10/packages/nuget/index.json" />
    </packageSources>
    <packageSourceCredentials>
        <gitlab>
            <add key="Username" value="carol" />
            <add key="ClearTextPassword" value="12345678asdf" />
        </gitlab>
    </packageSourceCredentials>
</configuration>
```

## Uploading packages

CAUTION: **Caveats:**
- When uploading a package, the maximum allowed size is 50 Megabytes.
- If you upload several times the same package with the same version, each consecutive upload is saved as a separated file. When installing a package, the most recent file is served by GitLab.

NOTE: **Note:**
When uploading packages to GitLab, those are not available right away as they are processed. Once their handling is done, they are displayed in the packages part of your project.

### Using nuget CLI

This documentation that your project has been properly built and a nuget package has been created. For more information, please see https://docs.microsoft.com/en-us/nuget/create-packages/creating-a-package.

You will need the following:
- Your package file ending in `.nupkg`
- The source name used during the [setup](#adding-the-gitlab-nuget-repository-as-a-source-to-nuget)

You can now upload your package using the following command:

```shell
nuget push <package_file> -Source <source_name>
```

Replace:

- `<package_file>` with your package filename.
- `<source_name>` with your source name.

For example:

```shell
nuget push MyPackage.1.0.0.nupkg -Source gitlab
```

### Using dotnet CLI

This documentation that your project has been properly built and a nuget package has been created. For more information, please see https://docs.microsoft.com/en-us/nuget/create-packages/creating-a-package-dotnet-cli.

You will need the following:
- Your package file ending in `.nupkg`
- The source name used during the [setup](#adding-the-gitlab-nuget-repository-as-a-source-to-nuget)

You can now upload your package using the following command:

```shell
dotnet nuget push <package_file> --source <source_name>
```

Replace:

- `<package_file>` with your package filename.
- `<source_name>` with your source name.

For example:

```shell
dotnet nuget push MyPackage.1.0.0.nupkg --source gitlab
```

## Installing a package

### Using nuget CLI

CAUTION: **Warning:**
When installing a package, the official source `nuget.org` is checked first by `nuget`. If you happen to have on GitLab a package with a name that already exists on `nuget.org`, you will be installing the wrong package. Please specify the source using the `-Source` parameter.

You will need the following:
- The package id.
- The output directoy where to download the package.
- (optionnal) The package version.
- (optionnal) The source name.

You can now install the latest version of a package using the following command:

```shell
nuget install <package_id> -OutputDirectory <output_directory>
```

You can specify a version using the `-Version` parameter:

```shell
nuget install <package_id> -Version <package_version> -OutputDirectory <output_directory>
```

You can specify a source to be used with the `-Source` parameter:

```shell
nuget install <package_id> -Source <source_name> -OutputDirectory <output_directory>
```

Replace:

- `<package_id>` with your package id.
- `<package_version>` with your package version.
- `<output_directory>` with your output directory.
- `<source_name>` with your source name.

Examples:
```shell
nuget install MyPackage -OutputDirectory packages
```

```shell
nuget install MyPackage -Version 2.0.5 -OutputDirectory packages
```

```shell
nuget install MyPackage -Version 2.0.5 -Source gitlab -OutputDirectory packages
```

### Using dotnet CLI

CAUTION: **Warning:**
When installing a package, the order which `dotnet` will check to sources is defined by the `nuget.config` file.

You will need the following:
- The package id.
- The package version.

You can now install the latest version of a package using the following command:

```shell
dotnet add package <package_id>
```

You can specify a version using the `-v` parameter:
```shell
dotnet add package <package_id> -v <package_version>
```

Replace:

- `<package_id>` with your package id.
- `<package_version>` with your package version.

Examples:
```shell
dotnet add package MyPackage
```

```shell
dotnet add package MyPackage -v 2.0.5
```
