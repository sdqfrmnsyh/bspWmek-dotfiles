if status is-interactive
    fastfetch
end

function fish_greeting
end

# pnpm
set -gx PNPM_HOME '/home/modz/.local/share/pnpm'
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# opencode
fish_add_path /home/modz/.opencode/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/modz/.local/bin" $PATH
