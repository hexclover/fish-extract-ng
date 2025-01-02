function __extract_ng_traced
    if set -qg __extract_ng_flag_dry_run
        echo "<dry-run> $argv"
    else
        $argv
    end
end
