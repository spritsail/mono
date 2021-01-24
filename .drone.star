builds = [
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
  return [monobuild(**x) for x in builds]

def monobuild(desc, tags, pkgs=''):
  name = tags[0]
  return {
    "kind": "pipeline",
    "name": "build-%s" % name,
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
        "image": "${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}:${DRONE_STAGE_TOKEN}",
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
          "repo": "spritsail/mono",
          "tags": tags,
          "login": { "from_secret": "docker_login" },
        },
      },
    ],
  }

# vim: ft=python sw=2
