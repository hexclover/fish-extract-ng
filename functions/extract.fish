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
