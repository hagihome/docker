# Vivadoをdockerで動かす
## 参考
- [Ubuntuにdockerをインストールする](https://qiita.com/tkyonezu/items/0f6da57eb2d823d2611d)
- [Dockerを一般ユーザで実行する](https://qiita.com/naomichi-y/items/93819573a5a51ae8cc07)
- [Xilinxの開発ツールをDockerコンテナに閉じ込める](https://blog.myon.info/entry/2018/09/15/install-xilinx-tools-into-docker-container/)
- [BBN-Q/vivado-docker](https://github.com/BBN-Q/vivado-docker)

## dockerのインストール
前提ソフトウェアのインストール
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```
GPG公開鍵とかのインストール
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
APTリポジトリの設定
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
dockerのインストール
```
sudo apt update
sudo apt install -y docker-ce
```
一般ユーザで実行できるようにする
再起動したほうが、めんどくさくないのでrestartさせている。
```
sudo usermod -g docker $USER
sudo restart
```
再起動後、実行できるか確認。
```
docker info
```

## Vivadoインストールの準備（CUIインストール用設定ファイルの生成）
XilinxからVivadoをダウンロード。Full版でダウンロードしておく。19GBくらいある。
取得したバージョンは、2018.3_1207_2324。
```
tar xf Xilinx_Vivado_SDK_2018.3_1207_2324.tar.gz
docker container run --rm -it -v $HOME/Downloads/Xilinx_Vivado_SDK_2018.3_1207_2324:/vivado -w /vivado ubuntu:xenial /bin/bash
```
dockerのコンソールに入るので、セットアップを実行。CUIインストールするために、xsetupのオプションに-b ConfigGenを使う。
```
./xsetup -b ConfigGen
cp /root/.Xilinx/install_config.txt .
```

## ファイル受け渡し用WEBサーバを用意
pythonで簡易サーバを立ち上げてたいおうするため、python3を入れておく。
```
sudo apt install python3
```

## Dockerイメージの生成
XORGの環境を作ってから、別途Vivadoのインストールをする。
XORG環境はほかでも使えるね。
Dockerfileはこんな感じ。
```{txt}
FROM ubuntu:xenial
ENV DEBIAN_FRONTEND noninteractive
RUN \
  sed -i -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list && \
  apt update && \
  apt upgrade -y && \
  apt -y --no-install-recommends install \
  ca-certificates curl sudo xorg dbus dbus-x11 ubuntu-gnome-default-settings gtk2-engines \
  ttf-ubuntu-font-family fonts-ubuntu-font-family-console fonts-droid-fallback lxappearance && \
  apt autoclean && \
  apt autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ARG gosu_version=1.10
RUN \
  curl -SL "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-$(dpkg --print-architecture)" \
  -o /usr/local/bin/gosu && \
  curl -SL "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-$(dpkg --print-architecture).asc" \
  -o /usr/local/bin/gosu.asc && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
  gpg --verify /usr/local/bin/gosu.asc && \
  rm -rf /usr/local/bin/gosu.asc /root/.gnupg && \
  chmod +x /usr/local/bin/gosu
```
実行
```
docker image build --rm --no-cache --pull -t ubuntu-xorg .
```
Vivadoインストール用Dockerfileは次の感じ。
```
FROM ubuntu-xorg

RUN \
  dpkg --add-architecture i386 && \
  apt update && \
  apt -y --no-install-recommends install \
    build-essential git gcc-multilib libc6-dev:i386 ocl-icd-opencl-dev libjpeg62-dev && \
  apt-get autoclean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/*

COPY install_config.txt /vivado-installer/

ARG VIVADO_TAR_HOST
ARG VIVADO_TAR_FILE
RUN \
  wget http://${VIVADO_TAR_HOST}/${VIVADO_TAR_FILE} | tar zx --strip-components=1 -C /vivado-installer && \
  /vivado-installer/xsetup \
    --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA \
    --batch Install \
    --config /vivado-installer/install_config.txt && \
  rm -rf /vivado-installer

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash", "-l"]
```

ENTORYPOINTのシェル
```
#!/bin/bash

UART_GROUP_ID=${UART_GROUP_ID:-20}
if ! grep -q "x:${UART_GROUP_ID}:" /etc/group; then
  groupadd -g "$UART_GROUP_ID" uart
fi
UART_GROUP=$(grep -Po "^\\w+(?=:x:${UART_GROUP_ID}:)" /etc/group)

if [[ -n "$USER_ID" ]]; then
  useradd -s /bin/bash -u "$USER_ID" -o -d "$PWD" user
  usermod -aG sudo user
  usermod -aG "$UART_GROUP" user
  chown user $(tty)
  exec /usr/local/bin/gosu user "$@"
else
  exec "$@"
fi
```

wget用のサーバを別端末で立ち上げておく。
```
cd $HOME/Downloads
python -m http.server
```

```
docker build -f Dockerfile.vivado --build-arg VIVADO_TAR_HOST=IP_ADDRESS:8000 --build-arg VIVADO_TAR_FILE=Xilinx_Vivado_SDK_2018.3_1207_2324.tar.gz -t ubuntu-vivado .
```

## Vivadoを起動する
dockerイメージの実行
```
mkdir ~/work/localhost/vivado
xhost +si:localuser:$(whoami)
docker container run -it --rm -e USER_ID=$UID -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro -v ~/work/localhost/vivado:/work -w /work ubuntu-vivado
```
ログイン後、こんな感じ。
```
source /tools/Xilinx/Vivado/2018.3/settings64.sh
vivado or vivado_hls
```
XSDKは
```
source /tools/Xilinx/SDK/2018.3/settings64.sh
xsdk
```

## driver for zybo
login on vivado container and copy driver rule file.
```
cp /tools/Xilinx/Vivado/2018.3/data/xicom/cable_drivers/lin64/install_script/install_drivers/52-xilinx-digilent-usb.rules .
```
copy the file to /etc/udev/rules.d and reboot machine.

when you run the vivado container, you set the device driver using --devie option.
for exmple,
```text
--device $(lsusb -d 0403:6010 | perl -pe 's!Bus\s(\d{3])\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!')
```
If you disconnect the zybo board, you must rerun the vivado-container.
In the vivado container, I cannot install cu using apt.
I connect the serial port in the host machine.
```text
chmod 666 /dev/ttyUSB1
cu -s 115200 -l /dev/ttyUSB1
```
If you want to disconnect the serial port, you put "~." to the terminal.

