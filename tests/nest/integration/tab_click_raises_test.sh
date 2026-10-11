#!/usr/bin/env bash
# Clicking a tab of a window that is behind another app must focus and raise it.
# Titlebar and content already do; a lone tab (alwaysTabbar, or compact in the
# titlebar) hit TAB >= 0 and returned without a raise, so the window stayed
# behind. Same swallow in both layouts: the group-size > 1 path defers to
# release, and a window with one tab never takes it.
. "$(dirname "$0")/../../lib.sh"

SETTINGS="$NEST_SETTINGS"

click_tab_raises() { # MODE: always | compact
  local tabx taby
  nest_clean
  if [ "$1" = compact ]; then
    printf '%s\n' '{"options":{},"apps":{"foot":{"chrome":true,"alwaysTabbar":true,"compactTabs":true}}}' > "$SETTINGS"
  else
    printf '%s\n' '{"options":{},"apps":{"foot":{"chrome":true,"alwaysTabbar":true}}}' > "$SETTINGS"
  fi
  refresh_apps

  open_window foot
  open_window kitty
  place_frac foot 4 30 35 35
  place_frac kitty 58 30 35 35

  nest_ctl dispatch "hl.dsp.focus({ window = 'class:kitty' })" >/dev/null
  sleep 0.3
  assert_eq "$(topmost)" kitty "kitty is on top before the $1 tab click"

  if [ "$1" = compact ]; then
    read -r tabx taby <<<"$(compact_tab_point foot 0 1)"
  else
    read -r tabx taby <<<"$(tab_point foot 0 1)"
  fi
  pointer_click "$tabx" "$taby"
  sleep 0.3

  assert_eq "$(active_class)" foot "clicking the $1 tab focuses that window"
  assert_eq "$(topmost)" foot "clicking the $1 tab raises that window"
}

click_tab_raises always
click_tab_raises compact
