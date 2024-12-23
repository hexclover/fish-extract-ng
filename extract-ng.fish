function __extract_ng_basename
    echo (command basename $argv[1])
end

function __extract_ng_traced
    if set -qg __extract_ng_flag_dry_run
        echo "<dry-run> $argv"
    else
        $argv
    end
end

function __extract_ng_make_unique_name
    set -l s $argv[1]
    set -l i 0
    while test -e $s
        set i (math $i + 1)
        set s "$argv[1]-$i"
    end
    echo $s
end

function __extract_ng_handle_file
    set -l file $argv[1]
    if not set -l realpath (realpath $file)
        return $status
    end
    set -l basename (__extract_ng_basename $argv[1])
    set -l toks (string split . $basename)
    set -l suffix

    if test (count $toks) -le 1
        or test -z $toks[-2]
        # Basename is XXX
        set suffix ''
    else if test (count $toks) -gt 2
        and test $toks[-2] = tar
        and test -n $toks[-3]
        and contains $toks[-1] gz bz2 zstd
        # Basename is XXX.tar.YYY
        set suffix (string join . $toks[-2..-1])
    else
        set suffix $toks[-1]
    end

    set -l extract_dir (__extract_ng_make_unique_name "./extract-$basename")
    set -l err 0

    echo "Will extract to $extract_dir."

    while true
        if not __extract_ng_traced mkdir $extract_dir
            break
        end

        __extract_ng_traced pushd $extract_dir

        switch $suffix
            case 7z
                __extract_ng_traced 7z x $realpath
                set err $status
            case tar
                __extract_ng_traced tar xvf $realpath
                set err $status
            case tbz2 tar.bz2
                __extract_ng_traced tar jxvf $realpath
                set err $status
            case tgz tar.gz
                __extract_ng_traced tar zxvf $realpath
                set err $status
            case txz tar.xz
                __extract_ng_traced tar Jxvf $realpath
                set err $status
            case tar.zstd
                __extract_ng_traced tar xvf --zstd $file
                set err $status
            case zip
                __extract_ng_traced unzip $file
                set err $status
            case '*'
                echo "$file: Unrecognized suffix: `$suffix'" > /dev/stderr
                set err 1
        end

        __extract_ng_traced popd

        if test $err -ne 0
            __extract_ng_traced rm -rf $extract_dir
        end

        break
    end

    if test $err -ne 0
        return $err
    end

    # At this stage, the archive has been successfully unpacked.
    set -l final_xdir $extract_dir

    # Smart unpacking -- move the sole file/directory out of $extract_dir
    if not set -qg __extract_ng_flag_simple
        while true
            if set -qg __extract_ng_flag_dry_run
                echo "WARNING: --dry-run cannot simulate smart unpacking behavior"
                break
            end

            set -l contents $extract_dir/* $extract_dir/.*
            if test (count $contents) -ne 1
                break
            end

            set -l contents_dest ./(__extract_ng_basename $contents)
            if test -e $contents_dest
                echo "$contents_dest already exists, not moving." \
                    > /dev/stderr
                break
            end

            # Swap using a temporary name for the sole file
            set -l tmp_for_contents ./(__extract_ng_make_unique_name \
                (__extract_ng_basename $contents-tmp))
            # Move the file out
            if not __extract_ng_traced mv $contents $tmp_for_contents
                set err $status
                break
            end
            # Remove $extract_dir which should be empty now
            if not __extract_ng_traced rm -r $extract_dir
                set err $status
                break
            end
            # Rename the temporary file to its original name
            if not __extract_ng_traced mv $tmp_for_contents $contents_dest
                set err $status
                break
            end

            set final_xdir $contents_dest
        end
    end

    if set -qg __extract_ng_flag_dry_run
        echo "Doing a dry run, nothing written."
    else
        echo "Archive $file extracted to $final_xdir."
    end

    if set -qg __extract_ng_flag_remove
        echo "Removing $file after extraction."
        __extract_ng_traced rm $__extract_ng_rm_flags $realpath
    end

    return $err
end

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

function extract --description "Extract archive files"
    if not argparse d/dry-run h/help i/interactive r/remove s/simple -- $argv
        __extract_ng_print_help > /dev/stderr
        return 1
    end

    # Export flags globally for use in helper functions
    for f in dry_run interactive remove simple
        if set -ql _flag_$f
            set -g __extract_ng_flag_$f $_flag_$f
        else
            set -ge __extract_ng_flag_$f
        end
    end

    if set -ql _flag_help
        __extract_ng_print_help
        return 0
    end

    if test (count $argv) -eq 0
        __extract_ng_print_help > /dev/stderr
        return 1
    end

    if set -ql _flag_interactive
        set -g __extract_ng_rm_flags "--interactive"
        set -g __extract_ng_mv_flags "--interactive"
    end

    set -l err 0
    for file in $argv
        if not __extract_ng_handle_file "$file"
            set err 1
        end
    end

    return $err
end

if test "$__extract_ng_suppress_alias" != 1
    alias x=extract
end
