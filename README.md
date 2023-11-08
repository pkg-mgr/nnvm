# nnvm
## Version Manager for node

Inspired by pvm. An alternative to version managers like nvm or n.

Can currently install and switch between exact semantic versions, latest-of-major (ie: 18 -> 18.18.2) and lts code names (ie: lts/dubnium -> 10.24.1).

This is an early release and likely contains some bugs - please open an issue for any bugs you discover.

Feature request: open node docs from the command line with `nnvm docs` or `nnvm docs <version>`.
Example: https://nodejs.org/dist/latest-hydrogen/docs/api/

## Installation

First, remove any currently-installed node versions and node version managers (especially nvm or anything installed via brew). Remove any node or version manager logic from your profile (~/.zshrc or ~/.bashrc or ~/.profile or ~/.bash_profile). You can detect node versions with `which node` and then rm the file, continuing until the command is not found.

Next, install nnvm:
```sh
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/nnvm/main/setup.sh | bash
```

Alternately, to auto-remove any existing node installation before installing:
```sh
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/nnvm/main/setup.sh | NUKE_node=1 bash
```

## Uninstalling

```sh
rm -rf ~/.nnvm /usr/local/bin/node /usr/local/bin/nnvm
# or simply:
nnvm nuke
```

## Usage

Once nnvm is installed, you need to install at least one version of node (ex: `nnvm install 8.9.2`). You are now ready to use node. You can then install additional versions the same way and switch between them with `nnvm use <version>`.

You can also specify a default version (ex: `nnvm default 8.9.5`) for any new shell session where you have not run the `nnvm use <version>` command yet.

In addition, if you create a `.nnvmrc` file with a version in the same folder as a `package.json` file, any node command run in that folder will automatically use the specified version.

Example:
```sh
echo "8.9.2" > .nnvmrc
node --version
```
(The `.nnvmrc` must be in the same directory as your project's `package.json` file.)

## How It Works
* Individual command scripts are installed to `~/.nnvm/cmds` folder
* node binaries are installed to `~/.nnvm/version` folders (ex: `~/.nnvm/8.9.2`)
* The `run.sh` script is copied to `/usr/local/bin/node`. This allows us to intercept and run node commands with the correct version of node.
* The `cmd.sh` script is copied to `/usr/local/bin/nnvm` and `/usr/local/bin/nnvm`. This allows us to run the nnvm commands which collectively allow node version management.

## Commands
Note: after running setup, you can run `nnvm help` to see the list of available commands.
* `nnvm default` aka `~/.nnvm/cmds/default.sh` - lists the default version. (Initially set to the latest at time of original setup.)
* `nnvm default <version>` aka `~/.nnvm/cmds/default.sh` - sets the default node version
* `nnvm help` aka `~/.nnvm/cmds/help.sh` - lists all available commands
* `nnvm install` aka `~/.nnvm/cmds/install.sh` - installs the latest version of node
* `nnvm install <version>` aka `~/.nnvm/cmds/install.sh` - installs specified node version.
* `nnvm list` aka `~/.nnvm/cmds/list.sh` - lists all currently installed versions of node
* `nnvm list --remote` aka `~/.nnvm/cmds/list.sh` - lists all versions available to install
* `nnvm nuke` aka `~/.nnvm/cmds/nuke.sh` - removes nnvm and all node binaries completely
* `nnvm run` aka `~/.nnvm/cmds/run.sh` - runs a node command using automatic node version detection. (The node command will also do this directly.)
* `nnvm uninstall <version>` aka `~/.nnvm/cmds/uninstall.sh` - uninstalls specified node version
* `nnvm unuse` aka `~/.nnvm/cmds/unuse.sh` - un-sets the node version for the current terminal session
* `nnvm update` aka `~/.nnvm/cmds/` - updates all nnvm scripts
* `nnvm use` aka `~/.nnvm/cmds/use.sh` - sets the node version for the current terminal session

## Local Development Setup
### Local Dev Install:
* VS Code
* [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
* [shellcheck](https://github.com/koalaman/shellcheck) via the [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) for script linting
* [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format) for auto-formatting

### Local Testing
Make code changes, then run `./setup.sh` which will perform setup using your local code. You can now test your local changes with using the nnvm command.
Once you've tested the commands locally, raise a PR. The changes are live once they are merged to master.
