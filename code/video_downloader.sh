#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# File to store last used download directory
last_download_dir_file="last_download_dir.txt"

# Function to load last used download directory
load_last_download_dir() {
    if [ -f "$last_download_dir_file" ]; then
        cat "$last_download_dir_file"
    fi
}

# Function to save last used download directory
save_last_download_dir() {
    echo "$1" > "$last_download_dir_file"
}

# Function to download video using yt-dlp
download_video() {
    url="$1"
    output_dir="$2"
    
    echo "Downloading video from: $url"
    
    # Run yt-dlp with progress bar and json output for parsing
    yt-dlp --no-progress --newline --console-title --output "$output_dir/%(title)s.%(ext)s" -- "$url" \
    | while IFS= read -r line; do
        if [[ $line =~ "Downloading video" ]]; then
            echo -e "${GREEN}$line${RESET}"  # Colorize download message
        elif [[ $line =~ "\[download\] " ]]; then
            # Extract progress percentage, speed, ETA, and additional info
            progress=$(echo "$line" | grep -oP '\d+\.\d+%')
            speed=$(echo "$line" | grep -oP '\d+\.\d+\w+/s')
            eta=$(echo "$line" | grep -oP 'ETA \d+:\d+')
            additional_info=$(echo "$line" | grep -oP '\(.*\)')
            # Colorize progress, speed, ETA, and additional info
            colored_line=$(echo -e "$line" | sed -E "s/(\[download\] )(\d+\.\d+%)/\1${GREEN}\2${RESET}/" | sed -E "s/($speed)/${GREEN}\1${RESET}/" | sed -E "s/($eta)/${GREEN}\1${RESET}/" | sed -E "s/($additional_info)/${GREEN}\1${RESET}/")
            echo -e "$colored_line"
        else
            echo "$line"
        fi
    done
}

# Function to download videos from file
download_videos_from_file() {
    file_path="$1"
    output_dir="$2"
    
    echo "Downloading videos from file: $file_path"
    
    # Read each URL from file and download using download_video function
    while IFS= read -r url || [[ -n "$url" ]]; do
        download_video "$url" "$output_dir"
    done < "$file_path"
}

# Function to download all videos from a Pornhub author
download_pornhub_author_videos() {
    author="$1"
    output_dir="$2"
    
    search_url="https://www.pornhub.com/users/$author/videos"
    
    echo "Downloading all videos from Pornhub author: $author"
    
    # Run yt-dlp with progress bar and json output for parsing
    yt-dlp --no-progress --newline --console-title --output "$output_dir/%(title)s.%(ext)s" -- "$search_url" \
    | while IFS= read -r line; do
        if [[ $line =~ "Downloading video" ]]; then
            echo -e "${GREEN}$line${RESET}"  # Colorize download message
        elif [[ $line =~ "\[download\] " ]]; then
            # Extract progress percentage, speed, ETA, and additional info
            progress=$(echo "$line" | grep -oP '\d+\.\d+%')
            speed=$(echo "$line" | grep -oP '\d+\.\d+\w+/s')
            eta=$(echo "$line" | grep -oP 'ETA \d+:\d+')
            additional_info=$(echo "$line" | grep -oP '\(.*\)')
            # Colorize progress, speed, ETA, and additional info
            colored_line=$(echo -e "$line" | sed -E "s/(\[download\] )(\d+\.\d+%)/\1${GREEN}\2${RESET}/" | sed -E "s/($speed)/${GREEN}\1${RESET}/" | sed -E "s/($eta)/${GREEN}\1${RESET}/" | sed -E "s/($additional_info)/${GREEN}\1${RESET}/")
            echo -e "$colored_line"
        else
            echo "$line"
        fi
    done
}

# Main menu function
main_menu() {
    echo -e "${YELLOW}Welcome to Video Downloader (Shell Script)${RESET}"
    echo "1. Download a single video"
    echo "2. Download videos from a file"
    echo "3. Download all videos from a Pornhub author"
    echo "4. Change download directory"
    echo "5. Exit"
    read -p "Enter your choice (1/2/3/4/5): " choice
    
    case $choice in
        1)
            read -p "Enter the URL of the video: " url
            output_dir=$(load_last_download_dir)
            read -e -p "Enter the output directory (default: $output_dir): " new_output_dir
            output_dir=${new_output_dir:-$output_dir}
            mkdir -p "$output_dir"
            save_last_download_dir "$output_dir"
            download_video "$url" "$output_dir"
            ;;
        2)
            read -p "Enter the path to the file containing URLs: " file_path
            output_dir=$(load_last_download_dir)
            read -e -p "Enter the output directory (default: $output_dir): " new_output_dir
            output_dir=${new_output_dir:-$output_dir}
            mkdir -p "$output_dir"
            save_last_download_dir "$output_dir"
            download_videos_from_file "$file_path" "$output_dir"
            ;;
        3)
            read -p "Enter the Pornhub author username: " author
            output_dir=$(load_last_download_dir)
            read -e -p "Enter the output directory (default: $output_dir): " new_output_dir
            output_dir=${new_output_dir:-$output_dir}
            mkdir -p "$output_dir"
            save_last_download_dir "$output_dir"
            download_pornhub_author_videos "$author" "$output_dir"
            ;;
        4)
            read -p "Enter new download directory: " new_dir
            save_last_download_dir "$new_dir"
            echo -e "${YELLOW}Download directory changed to: $new_dir${RESET}"
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${RESET}"
            exit 1
            ;;
    esac
}

# Main execution starts here
while true; do
    main_menu
done
