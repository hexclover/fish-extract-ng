complete -c extract -F
complete -c extract -f -s d -l "dry-run" -d "don't actually unpack; just print the plan"
complete -c extract -f -s h -l "help" -d "show this help and exit"
complete -c extract -f -s i -l "interactive" -d "be interactive, and also ask some commands I am going to fire to do so"
complete -c extract -f -s r -l "remove" -d "remove the archive after unpacking"
complete -c extract -f -s s -l "simple" -d "even if the archive contains only one file, don't be clever and move it up"
