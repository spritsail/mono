repo = "spritsail/mono"
architectures = ["amd64", "arm64"]
publish_branches = ["master"]
matrix = [
  {
    "desc": "Mono runtime without any reference assemblies",
    "tags": ["runtime"],
  },
  {
    "desc": "Mono runtime, including the 2.0 and 3.5 reference assemblies",
    "pkgs": "mono-reference-assemblies-3.5",
    "tags": ["3.5"],
  },
  {
    "desc": "Mono runtime, including the default 4.5 reference assemblies",
    "pkgs": "mono-reference-assemblies",
    "tags": ["4.5", "latest"],
  },
  {
    "desc": "Mono runtime, including the 4.5 and 4.x reference assemblies",
    "pkgs": "mono-reference-assemblies-4.x",
    "tags": ["4.x"],
  },
]

def main(ctx):
  builds = []

  for bld in matrix:
    tag = bld["tags"][0]
    depends_on = []
    for arch in architectures:
      key = "build-%s-%s" % (tag, arch)
      builds.append(step(arch, key, **bld))
      depends_on.append(key)

    if ctx.build.branch in publish_branches:
      key = "publish-manifest-%s" % tag
      builds.append(publish(key, bld["tags"], depends_on))

  return builds

def step(arch, key, desc, tags, pkgs=""):
  return {
    "kind": "pipeline",
    "name": key,
    "platform": {
      "os": "linux",
      "arch": arch,
    },
    "environment": {
      "DOCKER_IMAGE_TOKEN": tags[0],
    },
    "steps": [
      {
        "name": "build",
        "image": "spritsail/docker-build",
        "pull": "always",
        "settings": {
          "build_args": [
            "MONO_PACKAGE=%s" % pkgs,
            "MONO_DESC=%s" % desc,
          ],
        },
      },
      {
        "name": "test",
        "image":"drone/${DRONE_REPO}/${DRONE_BUILD_NUMBER}/%s:${DRONE_STAGE_OS}-${DRONE_STAGE_ARCH}" % tags[0],
        "pull": "never",
        "commands": [
          "mono --version",
          "apk add ca-certificates-mono",
          "update-ca-certificates",
        ],
      },
      {
        "name": "publish",
        "image": "spritsail/docker-publish",
        "pull": "always",
        "settings": {
          "registry": {"from_secret": "registry_url"},
          "login": {"from_secret": "registry_login"},
        },
      },
    ],
  }

def publish(key, tags, depends_on):
  return {
    "kind": "pipeline",
    "name": key,
    "depends_on": depends_on,
    "platform": {
      "os": "linux",
    },
    "environment": {
      "DOCKER_IMAGE_TOKEN": tags[0],
    },
    "steps": [
      {
        "name": "publish",
        "image": "spritsail/docker-multiarch-publish",
        "pull": "always",
        "settings": {
          "tags": tags,
          "src_registry": {"from_secret": "registry_url"},
          "src_login": {"from_secret": "registry_login"},
          "dest_repo": repo,
          "dest_login": {"from_secret": "docker_login"},
        },
        "when": {
          "branch": publish_branches,
          "event": ["push"],
        },
      },
    ],
  }

# vim: ft=python sw=2
