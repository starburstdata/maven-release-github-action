# Maven Release GitHub Action

## Assumptions (currently)

Your project uses the Maven Wrapper. The Maven Release GitHub Action runs in a docker container and we want to ensure that the Maven release is performed with the same version your project builds with. The Maven Wrapper is the easiest way to achieve this.

Your project use a GitHub service account user to perform the releases. You will be required to provde the username and and email of the service account user to that the docker container used to setup the release can make the release commits with the proper identity.

Your project doesn't require PGP signing of artifacts. Setting up a private key inside the docker image that performs the release has not yet been implemented. If you're deploying to your internal Maven repository this should not be an issue.

You either need to create a profile in your Maven `settings.xml` which sets the `gpg.skip` property to true, like so:

```
<settings>
  <profiles>
    <profile>
      <!-- This id is dependent on your configuration of the maven-release-plugin -->
      <id>oss-release</id>
      <properties>
        <gpg.skip>true</gpg.skip>
      </properties>
    </profile>
  </profiles>
</settings>
```

Or you need to configure the `maven-gpg-plugin` to skip execution, like so:

```
<project>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-gpg-plugin</artifactId>
        <configuration>
          <skip>true</skip>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

## Requirements

You need the following secrets defined in your organization:

- `MAVEN_RELEASE_SERVER_ID`: The id that is used in `distributionManagement/repository/id` in your `pom.xml`, which must match `server/id` of your release server in your Maven `settings.xml`. Might be something like `starburst.releases`.
- `MAVEN_RELEASE_SERVER_USERNAME`: The username for your release server.
- `MAVEN_RELEASE_SERVER_PASSWORD`: The password for your release server.

## GitHub Workflow Configuration

It is recommended to create a `.github/workflows/release.yml` workflow in your repository. A configuration for the Maven Release GitHub Action might look like the following:

```
on:
  workflow_dispatch:
    inputs:
      branch:
        description: "Release branch"
        default: "master"

env:
  # These envars are available to release post scripts
  dockerHubUsername: ${{ secrets.dockerHubUsername }}
  dockerHubPassword: ${{ secrets.dockerHubPassword }}
  dockerRegistry: ${{ secrets.dockerRegistry }}
  dockerRegistryUsername: ${{ secrets.dockerRegistryUsername }}
  dockerRegistryPassword: ${{ secrets.dockerRegistryPassword }}

jobs:
  release:
    runs-on: ubuntu-latest
    name: Maven Release
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Maven Release Step
        uses: starburstdata/mrel@1.0.0
        with:
          releaseBranchName: "${{ github.event.inputs.branch }}"

          gitUserName: "<your-automation-account-username>"
          gitUserEmail: "<your-automation-account-email>"

          mavenReleaseServerId: "${{secrets.MAVEN_RELEASE_SERVER_ID}}"
          mavenReleaseServerUsername: "${{secrets.MAVEN_RELEASE_SERVER_USERNAME}}"
          mavenReleaseServerPassword: "${{secrets.MAVEN_RELEASE_SERVER_PASSWORD}}"
          mavenReleaseArguments: "-Pdocker"
          mavenReleaseExecutePerform: "true"
          mavenReleasePushCommits: "true"
          mavenReleaseExecutePostScripts: "true"
```

The release is triggered using `workflow_dispatch` events. The easiest way to trigger the release is using the GitHub Actions UI:

![MREL GHA](/docs/images/mrelgha.png)

## Release post scripts

You may have scripts you would like to run after the Maven release process: there might not be a Maven plugin for what you need that you can integrate into the build process, or it may be just easier to write a shell script. This may be for copying files to S3, copying files to various Docker registries, or publishing documentation as part of a release.

By default the Maven Release GitHub Action will look in the `.mvn/release/post` directory for any scripts. If any scripts exist, and you have not disable the execution of release post scripts, they will be executed. When they are executed the version of the release is made available as the envar `${MAVEN_PROJECT_VERSION}`. The version of the release is also passed in as the first argument to the script.

So you can access the version of the release like this:

```
#!/usr/bin/env bash

echo "maven release version = ${MAVEN_PROJECT_VERSION}"
```

Or like this:

```
#!/usr/bin/env bash

version=${1}
echo "maven release version = ${version}"
```

Envars set in the `release.yml` worklfow are also available in any release post scripts. Usually your release post scripts should really only require the version of the release, but if you need custom parameters you can access them through envars.

If you need to get secrets into your release post scripts, it's easiest to configure envars that retrieve their values from GitHub's secrets manager. See the configuration above for an example.
