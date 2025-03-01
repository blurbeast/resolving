#!/bin/bash
set -e
echo -e "installing the resolver cli via curl"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
WHITE="\033[0m"

# getting the operating system of the machine
OS=$(uname -s)
echo -e "${RED} RED first ,${GREEN} Green next, ${YELLOW} Yellow after"

check_for_pkg_config_openssl() {
    echo -e "checking if openssl and pkg_config are available"
    if ! pkg-config --exists openssl; then 
        echo -e "could not find openssl and pkg_config"     
        #check for the os 
        echo -e "checking the machine OS and the installing the packages"
        if [ "$OS" = "Darwin" ]; then
            if ! command -v brew >/dev/null ; then
                echo -e "homebrew is not installed, installing homebrew"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            echo -e "installing openssl and pkg_config"
            brew install openssl
            brew install pkg-config

        elif [ "$OS" = "Linux" ]; then
            echo -e "updating linux packages"
            sudo apt-get update -y || true
            echo -e "installing openssl and pkg-config"
            sudo apt-get install -y libssl-dev pkg-config
        
        else 
            echo -e "Unsupported OS: ${OS} detected"
            exit 1
        fi
    else
        echo -e "${GREEN} openssl and pkg-config are already installed"
    fi
}

echo -e "checking if curl already exists"
if ! command -v curl >/dev/null; then
    echo -e "${RED} curl is missing"
    exit 1
fi

check_for_pkg_config_openssl

echo -e "checking if rust is installed "
if ! (command -v rustc >/dev/null && cargo >/dev/null); then
    #install rust here if not installed
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo -e "${GREEN} rust is already installed with ${YELLOW}$(rustc --version), ${YELLOW}$(cargo --version)"
fi


if ! command -v resolver-cli >/dev/null; then 
    # install resolver here 
    cargo install resolver-cli
    echo -e "${GREEN}resolver-cli has been installed successfully"
else
    echo -e "${WHITE} resolver version ${YELLOW}$(resolver-cli --version) is already installed"
fi