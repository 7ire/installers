# !/bin/bash
#
# Utility functions
print_debug() { echo -e "\e[${1}m${2}\e[0m"; }
print_success() { print_debug "32" "$1"; }
print_info() { print_debug "36" "$1"; }



# ------------------------------------------------------------------------------
#                         GNOME Keybinds - support vars
# ------------------------------------------------------------------------------
KEYS_GNOME_WM=/org/gnome/desktop/wm/keybindings                                      # GNOME window manager keybindings
KEYS_GNOME_SHELL=/org/gnome/shell/keybindings                                        # GNOME shell keybindings
KEYS_MUTTER=/org/gnome/mutter/keybindings                                            # GNOME mutter keybindings
KEYS_MEDIA=/org/gnome/settings-daemon/plugins/media-keys                             # GNOME media keybindings
KEYS_MUTTER_WAYLAND_RESTORE=/org/gnome/mutter/wayland/keybindings/restore-shortcuts  # GNOME mutter wayland restore keybindings



# ------------------------------------------------------------------------------
#                                 GNOME Keybinds
# ------------------------------------------------------------------------------
# Reset conflict shortcut
for i in {1..9}; do
    dconf write "${KEYS_GNOME_SHELL}/switch-to-application-${i}" "@as []" &> /dev/null
done

dconf write ${KEYS_GNOME_WM}/close "['<Super>q', '<Alt>F4']"  # Close Window
dconf write ${KEYS_MEDIA}/screensaver "['<Super>Escape']"     # Lock screen
# Application
dconf write ${KEYS_MEDIA}/terminal "['<Super>t']"  # Launch terminal
dconf write ${KEYS_MEDIA}/www "['<Super>f']"       # Launch web browser
dconf write ${KEYS_MEDIA}/email "['<Super>m']"     # Launch email client
dconf write ${KEYS_MEDIA}/home "['<Super>e']"      # Home folder
# Workspaces - move to N workspace
for i in {1..9}; do
    dconf write "${KEYS_GNOME_WM}/switch-to-workspace-${i}" "['<Super>${i}']" &> /dev/null
done
# Workspaces - move current application to N workspace
for i in {1..9}; do
    dconf write "${KEYS_GNOME_WM}/move-to-workspace-${i}" "['<Shift><Super>${i}']" &> /dev/null
done


# Workspaces - move to N workspace
    for i in {1..9}; do
        dconf write "${KEYS_GNOME_WM}/switch-to-workspace-${i}" "['<Super>${i}']" &> /dev/null
    done
    # Workspaces - move current application to N workspace
    for i in {1..9}; do
        dconf write "${KEYS_GNOME_WM}/move-to-workspace-${i}" "['<Shift><Super>${i}']" &> /dev/null
    done
    # Workspace - motion
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-right "['<Alt><Super>Right']" &> /dev/null  # Move right
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-left "['<Alt><Super>Left']" &> /dev/null    # Move left
    dconf write ${KEYS_GNOME_WM}/switch-to-workspace-last "['<Super>0']" &> /dev/null            # Move last