# PlayMovie
息子をiPadであやす動画の表示用

## 動画作成方法
 + iPadの画面キャプチャで動画作成youtubeなど
 + Quick Timeで480xに変更後以下のコマンドを実施

    ffmpeg -i input.mov -r 20 output_fps20.mov
