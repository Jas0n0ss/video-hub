#!/bin/bash

# Default download path (change as needed)
default_download_path="/path/to/default/download"

# Function to install ffmpeg from source based on architecture
install_ffmpeg() {
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
}

# Function to download videos from a single URL
download_single_url() {
    echo "Enter the video URL:"
    read url

    # Prompt for download path
    read -p "Enter download path [$default_download_path]: " download_path
    download_path=${download_path:-$default_download_path}

    # Remember the last download path for next time
    echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

    # Download video using yt-dlp
    yt-dlp -o "$download_path/%(title)s.%(ext)s" $url
}

# Function to download videos from a YouTube playlist or Pornhub model
download_playlist_or_model() {
    echo "Choose an option:"
    echo "1. Download all videos from the list"
    echo "2. Download a specified number of videos"

    read option

    case $option in
        1)
            echo "Enter the playlist/model URL:"
            read playlist_url

            # Prompt for download path
            read -p "Enter download path [$default_download_path]: " download_path
            download_path=${download_path:-$default_download_path}

            # Remember the last download path for next time
            echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

            yt-dlp -o "$download_path/%(playlist_index)s - %(title)s.%(ext)s" --yes-playlist $playlist_url
            ;;
        2)
            echo "Enter the playlist/model URL:"
            read playlist_url
            echo "Enter the number of videos to download:"
            read count

            # Prompt for download path
            read -p "Enter download path [$default_download_path]: " download_path
            download_path=${download_path:-$default_download_path}

            # Remember the last download path for next time
            echo "export LAST_DOWNLOAD_PATH=\"$download_path\"" > ~/.video_downloader_config

            yt-dlp -o "$download_path/%(playlist_index)s - %(title)s.%(ext)s" --yes-playlist --playlist-end $count $playlist_url
            ;;
        *)
            echo "Invalid option. Please choose 1 or 2."
            ;;
    esac
}

# Function to download frontend
download_frontend() {
    echo "Downloading frontend..."

    # Add frontend download steps here (e.g., git clone, wget, etc.)
    # Example: git clone https://github.com/user/frontend.git

    echo "Frontend downloaded successfully."
}

# Function to download backend
download_backend() {
    echo "Downloading backend..."

    # Add backend download steps here (e.g., git clone, wget, etc.)
    # Example: git clone https://github.com/user/backend.git

    echo "Backend downloaded successfully."
}

# Submenu for downloading frontend or backend
download_types_submenu() {
    while true; do
        echo "Choose an option:"
        echo "1. Download frontend"
        echo "2. Download backend"
        echo "3. Back to main menu"

        read submenu_choice

        case $submenu_choice in
            1)
                download_frontend
                ;;
            2)
                download_backend
                ;;
            3)
                return
                ;;
            *)
                echo "Invalid option. Please choose 1, 2, or 3."
                ;;
        esac
    done
}

# Main menu
while true; do
    echo "Choose an option:"
    echo "1. Download from a single URL"
    echo "2. Download from a YouTube playlist or Pornhub model"
    echo "3. Install ffmpeg from source"
    echo "4. Download frontend or backend"
    echo "5. Exit"

    read choice

    case $choice in
        1)
            download_single_url
            ;;
        2)
            download_playlist_or_model
            ;;
        3)
            install_ffmpeg
            ;;
        4)
            download_types_submenu
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, 3, 4, or 5."
            ;;
    esac
done
