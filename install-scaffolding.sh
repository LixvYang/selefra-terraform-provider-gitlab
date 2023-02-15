#!/bin/bash
set -e

RESET="\\033[0m"
RED="\\033[31;1m"
GREEN="\\033[32;1m"
YELLOW="\\033[33;1m"
BLUE="\\033[34;1m"
WHITE="\\033[37;1m"

say_green()
{
    [ -z "${SILENT}" ] && printf "%b%s%b\\n" "${GREEN}" "$1" "${RESET}"
    return 0
}

say_red()
{
    printf "%b%s%b\\n" "${RED}" "$1" "${RESET}"
}

say_yellow()
{
    [ -z "${SILENT}" ] && printf "%b%s%b\\n" "${YELLOW}" "$1" "${RESET}"
    return 0
}

say_blue()
{
    [ -z "${SILENT}" ] && printf "%b%s%b\\n" "${BLUE}" "$1" "${RESET}"
    return 0
}

say_white()
{
    [ -z "${SILENT}" ] && printf "%b%s%b\\n" "${WHITE}" "$1" "${RESET}"
    return 0
}

at_exit()
{
    if [ "$?" -ne 0 ]; then
        >&2 say_red
        >&2 say_red "We're sorry, but it looks like something might have gone wrong during installation."
        >&2 say_red "If you need help, please join us on https://www.selefra.io/community/join"
    fi
}

trap at_exit EXIT

print_unsupported_platform() {
    >&2 say_red "error: We're sorry, but it looks like Selefra is not supported on your platform"
    >&2 say_red "       We support 64-bit versions of Linux and macOS and are interested in supporting"
    >&2 say_red "       more platforms.  Please open an issue at https://github.com/selefra/selefra/issues"
    >&2 say_red "       and let us know what platform you're using!"
}

say_blue "begin download selefra-terraform-provider-scaffolding..."

# get os 
OS=""
case $(uname) in
    "Linux") OS="linux";;
    "Darwin") OS="darwin";;
    *)
        print_unsupported_platform
        exit 1
        ;;
esac

# get arch 
ARCH=""
case $(uname -m) in
    "x86_64") ARCH="amd64";;
    "arm64") ARCH="arm64";;
    "aarch64") ARCH="arm64";;
    *)
        print_unsupported_platform
        exit 1
        ;;
esac

# build download url
latest_response=`curl 'https://api.github.com/repos/selefra/selefra-terraform-provider-scaffolding/releases/latest'`
if [[ "$latest_response" == *"requests get a higher rate limit"* ]]; then
    >&2 say_red "We're sorry, But it seems the GitHub API request rate is maxed out, please try again later!"
    exit 1
fi
case $(uname) in
    "Linux")
      latest_version=`echo ${latest_response} | grep -oP '"tag_name": "v\d+.\d+.\d+"' | grep -oP 'v\d+.\d+.\d+' | head -n1`
      latest_version_num=`echo ${latest_response} | grep -oP '"tag_name": "v\d+.\d+.\d+"' | grep -oP '\d+.\d+.\d+' | head -n1`
      ;;
    "Darwin") OS="darwin"
        latest_version=`echo ${latest_response} | grep -oe '"tag_name":\s*"v\d.\d.\d\d"' | grep -oe 'v\d.\d.\d\d' | head -n1`
        latest_version_num=`echo ${latest_response} | grep -oe '"tag_name":\s*"v\d.\d.\d\d"' | grep -oe '\d.\d.\d\d' | head -n1`
        ;;
    *)
        print_unsupported_platform
        exit 1
        ;;
esac
if [ "$latest_version" = "" ]
then
        >&2 say_red "No available release found"
        exit 1
fi
download_url="https://github.com/selefra/selefra-terraform-provider-scaffolding/releases/download/$latest_version/selefra-terraform-provider-scaffolding_${latest_version_num}_${OS}_${ARCH}.tar.gz"
if [ ! -d "./bin" ]; then
  mkdir ./bin
fi
say_blue "begin download from $download_url"
wget $download_url -O ./bin/selefra-terraform-provider-scaffolding.tar.gz 
say_green "file download success!"

cd ./bin 
say_blue "begin unzip..."
tar zxvf ./selefra-terraform-provider-scaffolding.tar.gz
say_green "unzip success!"

say_green "selefra-terraform-provider-scaffolding download success!"
