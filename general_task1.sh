#!/bin/bash
set -euo pipefail

green="\e[32m"
reset="\e[0m"

# Functions
installGo() {
    echo -e "${green}*************Installing Go*************${reset}"
    wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
    sudo rm -f go1.23.2.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    echo 'export GOPATH=$HOME/go' >> ~/.profile
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.profile
    source ~/.profile
    go version
}

installStory() {
    echo -e "${green}*************Installing Story*************${reset}"
    
    # Detect system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [[ "$ARCH" == "arm"* || "$ARCH" == "aarch64" ]]; then
        ARCH="arm64"
    else
        echo "Unsupported architecture: $ARCH"
        return 1
    fi
    
    # Fetch the latest release data
    RELEASE_DATA=$(curl -s https://api.github.com/repos/piplabs/story/releases/latest)
    
    # Extract the URL for the story binary based on architecture
    STORY_URL=$(echo "$RELEASE_DATA" | grep 'body' | grep -Eo "https?://[^ ]+story-linux-${ARCH}[^ ]+" | sed 's/......$//')
    
    if [ -z "$STORY_URL" ]; then
        echo "Failed to fetch Story URL. Exiting."
        return 1
    fi
    
    echo "Fetched Story URL: $STORY_URL"
    wget -qO story-linux-$ARCH.tar.gz "$STORY_URL"
    
    if [ ! -f story-linux-$ARCH.tar.gz ]; then
        echo "Failed to download Story. Exiting."
        return 1
    fi
    
    echo "Configuring Story..."
    
    # Check if the file is a tar.gz archive and extract it
    if file story-linux-$ARCH.tar.gz | grep -q 'gzip compressed data'; then
        tar -xzf story-linux-$ARCH.tar.gz
        rm story-linux-$ARCH.tar.gz
    else
        echo "Downloaded file is not a valid tar.gz archive. Exiting."
        return 1
    fi
    
    # Verify if the extracted folder exists
    EXTRACTED_FOLDER=$(ls -d story-linux-$ARCH-* 2>/dev/null || true)
    if [ -z "$EXTRACTED_FOLDER" ]; then
        echo "Extracted folder not found. Exiting."
        return 1
    fi
    
    [ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
    if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bash_profile
    fi
    
    # Move the contents of the extracted folder to $HOME/go/bin
    sudo rm -rf $HOME/go/bin/story
    sudo mv "$EXTRACTED_FOLDER"/* $HOME/go/bin/story
    rm -rf "$EXTRACTED_FOLDER"
    source $HOME/.bash_profile
    
    if ! $HOME/go/bin/story version; then
        echo "Failed to execute story. Please check permissions."
        return 1
    fi
    story version
}

installGeth() {
    echo -e "${green}*************Installing Geth*************${reset}"
    GETH_URL=$(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | grep 'browser_download_url' | grep 'geth-linux-amd64' | head -n 1 | cut -d '"' -f 4)
    
    if [ -z "$GETH_URL" ]; then
        echo "Failed to fetch Geth URL. Exiting."
        return 1
    fi
    
    echo "Fetched Geth URL: $GETH_URL"
    wget -qO geth-linux-amd64 "$GETH_URL"
    
    if [ ! -f geth-linux-amd64 ]; then
        echo "Failed to download Geth. Exiting."
        return 1
    fi
    
    echo "Configuring Story Geth..."
    
    chmod +x geth-linux-amd64
    
    [ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
    if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bash_profile
    fi
    
    rm -f $HOME/go/bin/story-geth
    mv geth-linux-amd64 $HOME/go/bin/story-geth
    chmod +x $HOME/go/bin/story-geth
    source $HOME/.bash_profile
    
    if ! $HOME/go/bin/story-geth version; then
        echo "Failed to execute story-geth. Please check permissions."
        return 1
    fi
}

installStoryConsensus() {
    echo -e "${green}*************Installing Story Consensus*************${reset}"
    
    # Detect system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [[ "$ARCH" == "arm"* || "$ARCH" == "aarch64" ]]; then
        ARCH="arm64"
    else
        echo "Unsupported architecture: $ARCH"
        return 1
    fi
    
    # Fetch the latest release data
    RELEASE_DATA=$(curl -s https://api.github.com/repos/piplabs/story/releases/latest)
    
    # Extract the URL for the story binary based on architecture
    STORY_URL=$(echo "$RELEASE_DATA" | grep 'body' | grep -Eo "https?://[^ ]+story-linux-${ARCH}[^ ]+" | sed 's/......$//')
    
    if [ -z "$STORY_URL" ]; then
        echo "Failed to fetch Story URL. Exiting."
        return 1
    fi
    
    echo "Fetched Story URL: $STORY_URL"
    wget -qO story-linux-$ARCH.tar.gz "$STORY_URL"
    
    if [ ! -f story-linux-$ARCH.tar.gz ]; then
        echo "Failed to download Story. Exiting."
        return 1
    fi
    
    echo "Configuring Story..."
    
    # Check if the file is a tar.gz archive and extract it
    if file story-linux-$ARCH.tar.gz | grep -q 'gzip compressed data'; then
        tar -xzf story-linux-$ARCH.tar.gz
        rm story-linux-$ARCH.tar.gz
    else
        echo "Downloaded file is not a valid tar.gz archive. Exiting."
        return 1
    fi
    
    # Verify if the extracted folder exists
    EXTRACTED_FOLDER=$(ls -d story-linux-$ARCH-* 2>/dev/null || true)
    if [ -z "$EXTRACTED_FOLDER" ]; then
        echo "Extracted folder not found. Exiting."
        return 1
    fi
    
    [ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
    if ! grep -q "$HOME/go/bin" $HOME/.bash_profile; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bash_profile
    fi
    
    # Move the contents of the extracted folder to $HOME/go/bin
    sudo rm -rf $HOME/go/bin/story
    sudo mv "$EXTRACTED_FOLDER"/* $HOME/go/bin/story
    rm -rf "$EXTRACTED_FOLDER"
    source $HOME/.bash_profile
    
    if ! $HOME/go/bin/story version; then
        echo "Failed to execute story. Please check permissions."
        return 1
    fi
    story version
}

autoUpdateStory() {
    echo -e "${green}*************Automatic Update Story*************${reset}"
    installGo
    cd $HOME && \
    rm -rf story && \
    git clone https://github.com/piplabs/story && \
    cd $HOME/story && \
    latest_branch=$(git branch -r | grep -o 'origin/[^ ]*' | grep -v 'HEAD' | tail -n 1 | cut -d '/' -f 2) && \
    git checkout $latest_branch && \
    go build -o story ./client && \
    old_bin_path=$(which story) && \
    home_path=$HOME && \
    rpc_port=$(grep -m 1 -oP '^laddr = "\K[^"]+' "$HOME/.story/story/config/config.toml" | cut -d ':' -f 3) && \
    [[ -z "$rpc_port" ]] && rpc_port=$(grep -oP 'node = "tcp://[^:]+:\K\d+' "$HOME/.story/story/config/client.toml") ; \
    tmux new -s story-upgrade "sudo bash -c 'curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/autoupgrade/upgrade.sh | bash -s -- -u \"1325860\" -b story -n \"$HOME/story/story\" -o \"$old_bin_path\" -h \"$home_path\" -p \"undefined\" -r \"$rpc_port\"'"
}

latestVersions() {
    echo -e "${green}*************Latest Versions*************${reset}"
    latestStoryVersion=$(curl -s https://api.github.com/repos/piplabs/story/releases/latest | grep tag_name | cut -d\" -f4)
    latestGethVersion=$(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | grep tag_name | cut -d\" -f4)
    echo "Latest Story version: $latestStoryVersion"
    echo "Latest Geth version: $latestGethVersion"
}

mainMenu() {
    echo -e "\033[36m""Main Menu""\e[0m"
    echo "1 Install Story"
    echo "2 Install Geth"
    echo "3 Install Story Consensus"
    echo "4 Automatic Update Story"
    echo "5 See Latest Story and Geth Version"
    echo "q Quit"
}

while true; do
    mainMenu
    read -ep "Enter the number of the option you want: " CHOICE
    case "$CHOICE" in
        "1") installStory ;;
        "2") installGeth ;;
        "3") installStoryConsensus ;;
        "4") autoUpdateStory ;;
        "5") latestVersions ;;
        "q") exit ;;
        *) echo "Invalid option $CHOICE" ;;
    esac
done