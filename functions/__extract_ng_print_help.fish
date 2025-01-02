function __extract_ng_print_help
    echo "Usage: extract [OPTIONS] [FILE ...]\

    Options:
    -d, --dry-run     don't actually unpack; just print the plan
    -h, --help        show this help and exit
    -i, --interactive be interactive, and also ask some commands I am going
                      to fire to do so
    -r, --remove      remove the archive after unpacking
    -s, --simple      even if the archive contains only one file, don't be
                      clever and move it up"
end
