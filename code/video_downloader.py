#!/usr/bin/env python3
import yt_dlp as yt_dlp
import os
import json
from termcolor import colored
from colorama import init

# 初始化 colorama，使颜色输出在 Windows 中也能正常工作
init()

# 文件路径用于存储上次下载目录
last_download_dir_file = 'last_download_dir.json'

def load_last_download_dir():
    """加载上次使用的下载目录"""
    if os.path.exists(last_download_dir_file):
        with open(last_download_dir_file, 'r') as f:
            try:
                return json.load(f)['last_download_dir']
            except json.JSONDecodeError:
                return None
    else:
        return None

def save_last_download_dir(download_dir):
    """保存当前使用的下载目录"""
    with open(last_download_dir_file, 'w') as f:
        json.dump({'last_download_dir': download_dir}, f)

def download_video(url, output_dir):
    ydl_opts = {
        'format': 'best',
        'outtmpl': os.path.join(output_dir, '%(title)s.%(ext)s')
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            ydl.download([url])
            print(colored(f"Downloaded: {url}", "green"))
        except Exception as e:
            print(colored(f"Error downloading {url}: {str(e)}", "red"))

def download_videos_from_file(file_path, output_dir):
    with open(file_path, 'r') as file:
        urls = file.readlines()
    for url in urls:
        download_video(url.strip(), output_dir)

def download_pornhub_author_videos(author, output_dir):
    search_url = f"https://www.pornhub.com/users/{author}/videos"
    ydl_opts = {
        'format': 'best',
        'outtmpl': os.path.join(output_dir, '%(title)s.%(ext)s')
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            ydl.download([search_url])
            print(colored(f"Downloaded all videos from {author} on Pornhub", "green"))
        except Exception as e:
            print(colored(f"Error downloading Pornhub videos for {author}: {str(e)}", "red"))

def main():
    print(colored("Welcome to the Video Downloader", "cyan"))
    print("1. Download a single video")
    print("2. Download videos from a file")
    print("3. Download all videos from a Pornhub author")
    print("4. Change download directory")
    choice = input("Enter your choice (1/2/3/4): ")

    last_download_dir = load_last_download_dir()
    if last_download_dir:
        print(f"Last used download directory: {last_download_dir}")

    if choice == '4':
        new_dir = input("Enter new download directory: ")
        save_last_download_dir(new_dir)
        print(colored(f"Download directory changed to: {new_dir}", "yellow"))
        return

    output_dir = last_download_dir or input("Enter the output directory: ")
    os.makedirs(output_dir, exist_ok=True)

    if choice == '1':
        url = input("Enter the URL of the video: ")
        download_video(url, output_dir)
    elif choice == '2':
        file_path = input("Enter the path to the file containing URLs: ")
        download_videos_from_file(file_path, output_dir)
    elif choice == '3':
        author = input("Enter the Pornhub author username: ")
        download_pornhub_author_videos(author, output_dir)
    else:
        print(colored("Invalid choice. Exiting.", "red"))

if __name__ == '__main__':
    main()
