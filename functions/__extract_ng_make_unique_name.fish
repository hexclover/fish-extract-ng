function __extract_ng_make_unique_name
    set -l s $argv[1]
    set -l i 0
    while test -e $s
        set i (math $i + 1)
        set s "$argv[1]-$i"
    end
    echo $s
end
