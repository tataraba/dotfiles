# Generally these items can be appended to an existing bashrc file.
# DO NOT REPLACE EXISTING bashrc file.

# Adds starship
eval "$(starship init bash)"
# Needed for uv
. "$HOME/.cargo/env"
# Direnv - This may need to be modifed with path to direnv
eval "$(direnv hook bash)"