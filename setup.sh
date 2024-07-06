#!/bin/bash

# ANSI color codes
YELLOW='\033[1;33m'  # Yellow
CYAN='\033[0;36m'    # Cyan for numbers
RESET='\033[0m'      # Reset color

# Default download path
default_download_path="/path/to/default/download"

# Function to check if ffmpeg is installed
check_ffmpeg_installed() {
    if command -v ffmpeg &>/dev/null; then
        echo "ffmpeg is already installed."
        return 0
    else
        echo "ffmpeg is not installed."
        return 1
    fi
}

# Function to install ffmpeg from source based on architecture
install_ffmpeg() {
    if ! check_ffmpeg_installed; then
        local architecture=$(uname -m)
        local system=$(uname -s)

        case $architecture in
            x86_64)
                echo "Detected architecture: x86_64"
                ;;
            arm*)
                echo "Detected architecture: ARM"
                ;;
            *)
                echo "Unsupported architecture: $architecture"
                exit 1
                ;;
        esac

        case $system in
            Linux)
                echo "Detected system: Linux"
                echo "Installing ffmpeg from source..."
                wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
                tar -xf ffmpeg-release-amd64-static.tar.xz
                cd ffmpeg-*-static
                sudo cp ffmpeg ffprobe /usr/local/bin/
                cd ..
                rm -rf ffmpeg-*-static
                rm ffmpeg-release-amd64-static.tar.xz
                echo "ffmpeg installed successfully."
                ;;
            Darwin)
                echo "Detected system: macOS"
                echo "Installing ffmpeg from source..."

                # Download and install ffmpeg on macOS
                if [ "$architecture" == "x86_64" ]; then
                    # For macOS on x86_64
                    wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
                    tar -xf ffmpeg-release-amd64-static.tar.xz
                    cd ffmpeg-*-static
                    sudo cp ffmpeg ffprobe /usr/local/bin/
                    cd ..
                    rm -rf ffmpeg-*-static
                    rm ffmpeg-release-amd64-static.tar.xz
                elif [ "${architecture:0:3}" == "arm" ]; then
                    # For macOS on arm64 (Apple Silicon)
                    wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz
                    tar -xf ffmpeg-release-arm64-static.tar.xz
                    cd ffmpeg-*-static
                    sudo cp ffmpeg ffprobe /usr/local/bin/
                    cd ..
                    rm -rf ffmpeg-*-static
                    rm ffmpeg-release-arm64-static.tar.xz
                else
                    echo "Unsupported architecture: $architecture"
                    exit 1
                fi

                echo "ffmpeg installed successfully."
                ;;
            *)
                echo "Unsupported system: $system"
                exit 1
                ;;
        esac
    fi
}

# Function to check if yt-dlp is installed
check_yt_dlp_installed() {
    if command -v yt-dlp &>/dev/null; then
        echo "yt-dlp is already installed."
        return 0
    else
        echo "yt-dlp is not installed."
        return 1
    fi
}

# Function to install yt-dlp from source
install_yt_dlp() {
    if ! check_yt_dlp_installed; then
        echo "Installing yt-dlp from source..."

        # Download and install yt-dlp
        sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
        sudo chmod a+rx /usr/local/bin/yt-dlp

        echo "yt-dlp installed successfully."
    fi
}

# Function to download videos from a single URL
download_single_url() {
    install_yt_dlp
    install_ffmpeg

    echo -e "${YELLOW}1. Download from a URL${RESET}"

    echo -e "${CYAN}Enter the video URL:${RESET}"
    read url

    # Prompt for download path
    echo -e "${CYAN}Enter download path [$default_download_path]:${RESET}"
    read download_path
    download_path=${download_path:-$default_download_path}

    # Remember the last download path for next time
    echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

    # Start backend download process with output to both terminal and log file
    echo -e "${YELLOW}Starting download from $url to $download_path...${RESET}"
    yt-dlp -o "$download_path/%(title)s.%(ext)s" --exec 'echo Download Progress: {}' "$url" | tee download.log

    echo -e "${YELLOW}Download complete!${RESET}"
}

# Function to download videos from a YouTube playlist or Pornhub model
download_playlist_or_model() {
    install_yt_dlp
    install_ffmpeg

    echo -e "${YELLOW}2. Download from a list or model${RESET}"

    echo -e "${CYAN}Choose an option:${RESET}"
    echo "1. Download all videos from the list"
    echo "2. Download a specified number of videos"

    read option

    case $option in
        1)
            echo -e "${CYAN}Enter the playlist/model URL:${RESET}"
            read playlist_url

            # Prompt for download path
            echo -e "${CYAN}Enter download path [$default_download_path]:${RESET}"
            read download_path
            download_path=${download_path:-$default_download_path}

            # Remember the last download path for next time
            echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

            # Start backend download process with output to both terminal and log file
            echo -e "${YELLOW}Starting download from $playlist_url to $download_path...${RESET}"
            yt-dlp -o "$download_path/%(title)s.%(ext)s" --exec 'echo Download Progress: {}' "$playlist_url" | tee download.log

            echo -e "${YELLOW}Download complete!${RESET}"
            ;;
        2)
            echo -e "${CYAN}Enter the playlist/model URL:${RESET}"
            read playlist_url
            echo -e "${CYAN}Enter the number of videos to download:${RESET}"
            read count

            # Prompt for download path
            echo -e "${CYAN}Enter download path [$default_download_path]:${RESET}"
            read download_path
            download_path=${download_path:-$default_download_path}

            # Remember the last download path for next time
            echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

            # Start backend download process with output to both terminal and log file
            echo -e "${YELLOW}Starting download $count videos from $playlist_url to $download_path...${RESET}"
            yt-dlp -o "$download_path/%(title)s.%(ext)s" --exec 'echo Download Progress: {}' --playlist-items $count "$playlist_url" | tee download.log

            echo -e "${YELLOW}Download complete!${RESET}"
            ;;
        *)
            echo -e "${CYAN}Invalid option. Please choose 1 or 2.${RESET}"
            ;;
    esac
}

# Main menu
while true; do
    echo -e "${YELLOW}Main Menu:${RESET}"
    echo -e "${CYAN}1. Download from a URL${RESET}"
    echo -e "${CYAN}2. Download from a list or model${RESET}"
    echo -e "${CYAN}3. Exit${RESET}"

    read choice

    case $choice in
        1)
            download_single_url
            ;;
        2)
            download_playlist_or_model
            ;;
        3)
            echo -e "${YELLOW}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${CYAN}Invalid option. Please choose 1, 2, or 3.${RESET}"
            ;;
    esac
done
