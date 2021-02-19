#!/bin/bash
printlogo()
{
  echo ""
  echo "      ▟     ▟   ▟   ▟                     ▟▙  █  █ █  █ ▙    ▟"
  echo "    ▟ █     █   █   █   ▟                █▄▄█ █▄▄█ █  █ █▜▙▟▛█"
  echo "    ███▙   ▟█   █   █   █   ▟            █▔▔█ █▔▔█ █  █ █ ▜▛ █"
  echo "    ████   ██  ▟█  ▟█   █   █   ▌        █  █ █  █ ████ █    █"
  echo "   ▟█████████▙▟██▙███▙ ▟█▙ ▟█▙ ▟▙ ▟▙"
  echo "━━━██████████████████████████████████━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "   ▜█████████▛▜██▛███▛ ▜█▛ ▜█▛ ▜▛ ▜▛"
  echo "    ████   ██  ▜█  ▜█   █   █   ▌"
  echo "    ███▛   ▜█   █   █   █   ▜"
  echo "    ▜ █     █   █   █   ▜"
  echo "      ▜     ▜   ▜   ▜"
  echo ""
}
usage()
{
  printlogo
  echo "usage: workspace <command> [workspace]"
  echo ""
  echo "     -h, --help          Print this help."
  echo ""
  echo "Commands:"
  echo "     list      Lists all configured workspaces"
  echo "     start     Starts a workspace"
  echo "     stop      Stops a workspace"
}

list()
{
  printlogo
  echo "Available configs"
  cat .ahumconfig | while read line
  do
    if [[ "$line" == *"["* ]]; then
      echo "- "$line
    fi
  done
}
chrome_start()
{
  cmd="open -na 'Google Chrome' --args"
  if [[ "$line" == *";;"* ]]; then
    IFS=';'
    read -a urls <<< "$1"
    for u in "${urls[@]}"
    do
      if [[ ${#u} > 0 ]]; then
        cmd+=" --new-window '$u'"
      fi
    done
  else
    cmd+=" --new-window '$1'"
  fi
  eval "$cmd"
}
config()
{
  if [[ "$1" == "start" ]]; then
    launch="0"
    cat .ahumconfig | while read line
    do
      if [[ "$line" == *"["* ]]; then
        launch="0"
        if [[ "$line" == *"$2"* ]]; then
          launch="1"
        fi
      elif [[ "$launch" == "1" ]]; then
        IFS='='
        read -a command <<< "$line"
        case "${command[0]}" in
          .atom )
            eval "atom ${command[1]}"
            ;;
          .chrome )
            chrome_start "${command[1]}"
            ;;
          .vagrant )
            eval "vagrant up ${command[1]}"
            ;;
          * )
            echo "Unsupported app: ${command[0]}"
            ;;
        esac
      fi
    done
  elif [[ "$1" == "stop" ]]; then
    kill="0"
    cat .ahumconfig | while read line
    do
      if [[ "$line" == *"["* ]]; then
        kill="0"
        if [[ "$line" == *"$2"* ]]; then
          kill="1"
        fi
      elif [[ "$kill" == "1" ]]; then
        IFS='='
        read -a command <<< "$line"
        case "${command[0]}" in
          .atom )
            osascript -e 'quit app "Atom"'
            ;;
          .chrome )
            osascript -e 'quit app "Chrome"'
            ;;
          .vagrant )
            eval "vagrant halt ${command[1]}"
            ;;
          * )
            echo "Unsupported app: ${command[0]}"
            ;;
        esac
      fi
    done
  fi
}
if [ "$1" != "" ]; then
  while [ "$1" != "" ]; do
    case $1 in
      # HELP
      -h | --help | help ) 
        usage
        exit
        ;;
      # LIST
      -l | --list | list )
        list
        exit
        ;;
      * )
        config "$1" "$2"
        exit
        ;;
    esac
    shift
  done
else
  usage
fi
