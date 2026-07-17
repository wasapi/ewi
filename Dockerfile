FROM ubuntu:26.04

ENV WINEPREFIX=/opt/wineprefix
ENV WINEARCH=win64
ENV WINEDEBUG=-all
ENV LANG=fr_FR.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg

# Installation du repo Wine
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.winehq.org/wine-builds/winehq.key \
      | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.gpg] https://dl.winehq.org/wine-builds/ubuntu resolute main" \
        > /etc/apt/sources.list.d/winehq.list

# Installation de Wine staging
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y winehq-staging winetricks xvfb language-pack-fr && \
    rm -rf /var/lib/apt/lists/*

# Copie l'installateur
#COPY Audio_Modeling_SWAM_Bundle_2025.6.exe /tmp/Audio_Modeling_SWAM_Bundle.exe
#COPY reaper777_x64-install.exe /tmp/reaper777_x64-install.exe

# Paramétrage de Wine 
RUN rm -rf /opt/wineprefix && wineboot --init && wineserver -w

# Installation de Swam
#RUN /usr/bin/xvfb-run -a wine /tmp/Audio_Modeling_SWAM_Bundle.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
#RUN --mount=type=secret,id=swam,target=/tmp/Audio_Modeling_SWAM_Bundle.exe \
#    /usr/bin/xvfb-run -a wine /tmp/Audio_Modeling_SWAM_Bundle.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
RUN --mount=type=bind,source=Audio_Modeling_SWAM_Bundle_2025.6.exe,target=/tmp/Audio_Modeling_SWAM_Bundle.exe,readonly \
    /usr/bin/xvfb-run -a wine /tmp/Audio_Modeling_SWAM_Bundle.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART

# Installation de Reaper
#RUN xvfb-run -a wine /tmp/reaper777_x64-install.exe /S || true
RUN --mount=type=bind,source=reaper777_x64-install.exe,target=/tmp/reaper777_x64-install.exe,readonly \
    xvfb-run -a wine /tmp/reaper777_x64-install.exe /S || true

# Installeur original pour Ewi USB
#COPY Akai_EWI_USB/ /tmp/Akai_EWI_USB/

# Paramétrage audio du système pour passer par jack
RUN apt update
RUN apt install -y git build-essential libjack-jackd2-dev wine-staging-dev
RUN echo "jackd2 jackd/tweak_rt_limits boolean true" | debconf-set-selections
RUN apt install -y pipewire-jack jackd2 jack-tools
RUN git clone https://github.com/wineasio/wineasio.git
RUN cd wineasio && make 64
RUN cp -f /wineasio/build64/wineasio64.dll /opt/wine-staging/lib/wine/x86_64-windows/wineasio.dll
RUN cp -f /wineasio/build64/wineasio64.dll.so /opt/wine-staging/lib/wine/x86_64-unix/wineasio.dll.so
RUN cp /wineasio/build64/wineasio64.dll /opt/wineprefix/drive_c/windows/system32/wineasio64.dll
RUN cp /wineasio/build64/wineasio64.dll /opt/wineprefix/drive_c/windows/system32/wineasio.dll

# Paramétrage audio/midi de Reaper
COPY REAPER.ini /opt/wineprefix/drive_c/users/root/AppData/Roaming/REAPER/REAPER.ini
COPY default_datastore.xml /tmp/default_datastore.xml
COPY set-default-datastore.sh /tmp/set-default-datastore.sh
RUN mkdir -p /opt/wineprefix/drive_c/users/root/AppData/Roaming/Audio\ Modeling/UserData && bash /tmp/set-default-datastore.sh

# Script pour démarrer reaper
RUN echo '#!/bin/bash\n\nwine regsvr32 /s wineasio64.dll\npw-jack wine "/opt/wineprefix/drive_c/Program Files/REAPER (x64)/reaper.exe" /nosplash\n' \
    > /usr/local/bin/reaper && chmod a+x /usr/local/bin/reaper
