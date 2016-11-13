#!/bin/bash

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

if [ "$(basename $0)" == 'momentum-beta' ]; then
  BETA_VERSION=true
else
  BETA_VERSION=
fi

while getopts ":vh-:" opt; do
  case "$opt" in
    -)
      case "${OPTARG}" in
        help|version)
          REDIRECT_STDERR=1
          EXPECT_OUTPUT=1
          ;;
      esac
      ;;
    h|v)
      REDIRECT_STDERR=1
      EXPECT_OUTPUT=1
      ;;
  esac
done

if [ $REDIRECT_STDERR ]; then
  exec 2> /dev/null
fi

if [ $EXPECT_OUTPUT ]; then
  export ELECTRON_ENABLE_LOGGING=1
fi

if [ $OS == 'Mac' ]; then
  if [ -n "$BETA_VERSION" ]; then
    MOMENTUM_APP_NAME="Momentum Beta.app"
    MOMENTUM_EXECUTABLE_NAME="Momentum Beta"
  else
    MOMENTUM_APP_NAME="Momentum.app"
    MOMENTUM_EXECUTABLE_NAME="Momentum"
  fi

  if [ -z "${MOMENTUM_PATH}" ]; then
    # If MOMENTUM_PATH isn't set, check /Applications then ~/Applications
    if [ -x "/Applications/$MOMENTUM_APP_NAME" ]; then
      MOMENTUM_PATH="/Applications"
    elif [ -x "$HOME/Applications/$MOMENTUM_APP_NAME" ]; then
      MOMENTUM_PATH="$HOME/Applications"
    else
      # We haven't found a Momentum.app, use spotlight to search for Momentum
      MOMENTUM_PATH="$(mdfind "kMDItemCFBundleIdentifier == 'io.getmomentum.core'" | grep -v ShipIt | head -1 | xargs -0 dirname)"

      # Exit if Momentum can't be found
      if [ ! -x "$MOMENTUM_PATH/$MOMENTUM_APP_NAME" ]; then
        echo "Cannot locate $MOMENTUM_APP_NAME, it is usually located in /Applications. Set the MOMENTUM_PATH environment variable to the directory containing $MOMENTUM_APP_NAME."
        exit 1
      fi
    fi
  fi

  if [ $EXPECT_OUTPUT ]; then
    "$MOMENTUM_PATH/$MOMENTUM_APP_NAME/Contents/MacOS/$MOMENTUM_EXECUTABLE_NAME" --executed-from="$(pwd)" --pid=$$ "$@"
    exit $?
  else
    open -a "$MOMENTUM_PATH/$MOMENTUM_APP_NAME" -n --args --executed-from="$(pwd)" --pid=$$ --path-environment="$PATH" "$@"
  fi
elif [ $OS == 'Linux' ]; then
  SCRIPT=$(readlink -f "$0")
  USR_DIRECTORY=$(readlink -f $(dirname $SCRIPT)/..)

  if [ -n "$BETA_VERSION" ]; then
    MOMENTUM_PATH="$USR_DIRECTORY/share/momentum-beta/momentum"
  else
    MOMENTUM_PATH="$USR_DIRECTORY/share/momentum/momentum"
  fi

  MOMENTUM_HOME="${MOMENTUM_HOME:-$HOME/.momentum}"
  mkdir -p "$MOMENTUM_HOME"

  : ${TMPDIR:=/tmp}

  [ -x "$MOMENTUM_PATH" ] || MOMENTUM_PATH="$TMPDIR/momentum-build/Momentum/momentum"

  if [ $EXPECT_OUTPUT ]; then
    "$MOMENTUM_PATH" --executed-from="$(pwd)" --pid=$$ "$@"
    exit $?
  else
    (
    nohup "$MOMENTUM_PATH" --executed-from="$(pwd)" --pid=$$ "$@" > "$MOMENTUM_HOME/nohup.out" 2>&1
    if [ $? -ne 0 ]; then
      cat "$MOMENTUM_HOME/nohup.out"
      exit $?
    fi
    ) &
  fi
fi
