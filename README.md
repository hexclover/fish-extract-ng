# fish-extract-ng

A plugin for the fish shell: extract various archives intelligently with a single command.

## Usage

This text can be outdated; see `x --help` or `extract -h` for the latest usage
information.

```plaintext
Usage: extract [OPTIONS] [FILE ...]
    Options:
    -d, --dry-run     don't actually unpack; just print the plan
    -h, --help        show this help and exit
    -i, --interactive be interactive, and also ask some commands I am going
                      to fire to do so
    -r, --remove      remove the archive after unpacking
    -s, --simple      even if the archive contains only one file, don't be
                      clever and move it up
```

## Options

Set before loading:

- `__extract_ng_suppress_alias`: When set to `1`, the script does not create
  the `x` alias.

## Acknowledgment & Inspiration

- <https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/extract/extract.plugin.zsh>
- <https://github.com/oh-my-fish/plugin-extract/blob/master/functions/extract.fish>
