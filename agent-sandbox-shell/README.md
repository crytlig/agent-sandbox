# Setup commands for getting coding agents to work in sandboxes

## sbx commands

- Building and loading to sbx

```bash

# Build using regular docker builds
docker build -t <name>:<tag> -f <file> .

# Save to tar file
docker image save <name>:<tag> -o <file>.tar

# Sbx load
sbx template load <file>.tar

# Run (only works on creation)
sbx run --template <name>:<tag> shell

# Exec into an existing sandbox
# When inside the sandbox, the WORKDIR is set to /agent/workspace
# but the mounted DIR is probably something like /Users/name/repos/reo
sbx exec -it <name>:<tag> /bin/bash
```

## Setup Pi

### Openrouter

sbx supports setting secrets from the host instead of having them exposed
in clear text inside the sandbox.

To set it on the host level, there's an experimental command for `sbx secret`

```bash
 sbx secret set-custom -g --host openrouter.ai --env OPENROUTER_API_KEY --value <value>

 # When the secret is unnamed, the output might be something like:
 # sbx-cs-d2RLwcWbWTCrEPVb
 #
 # list secrets
 sbx secret list

 ## Remove custom secrets with:
sbx secret rm -g --host openrouter.ai --env OPENROUTER_API_KEY
```

Inside the sandbox, we need to reference the secret name:

```bash
export OPENROUTER_API_KEY=sbx-cs-d2RLwcWbWTCrEPVb
```

### GitHub Copilot

Copilot doesn't seem to be able to authenticate properly... So stop using copilot

## Specfiles

Look here:
[https://github.com/docker/sbx-kits-contrib/blob/main/pi/spec.yaml](https://github.com/docker/sbx-kits-contrib/blob/main/pi/spec.yaml)
