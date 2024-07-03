### Setup ffmpeg and yt-dlp

This application depends on ffmpeg and yt-dlp , install them first:

- Ffmpeg :  https://johnvansickle.com/ffmpeg/
```
    cd /opt/src && wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
    tar -vfJ ffmpeg-release-amd64-static.tar.xz 
    # make sure "/usr/local/sbin" in your PATH
    ln -s /opt/src/ffmpeg-7.0.1-amd64-static/ffmpeg /usr/local/sbin/ffmpeg 
    ln -s /opt/src/ffmpeg-7.0.1-amd64-static/ffprobe /usr/local/sbin/ffprobe 
    which ffmpeg && ffmpeg -version
```

- yt-dlp: https://github.com/yt-dlp/yt-dlp
```
    wget -O /usr/local/sbin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
    yt-dlp --version
```
### Setup video-hub
