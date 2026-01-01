# Bash & ZSH
export PATH=/path/where/rakubrew/is:$PATH
export PATH=$(rakubrew home)/shims:$PATH

# Fish
fish_add_path -g /path/where/rakubrew/is
fish_add_path -g (rakubrew home)/shims
