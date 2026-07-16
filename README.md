### Depends
- Audio_Modeling_SWAM_Bundle_2025.6.exe
- reaper777_x64-install.exe

### Build
```
docker build -t swam:1.0 .
```

### Alias
À améliorer notamment pour être lancé en mode non privilégié et non root
```
alias reaper="docker run --privileged --rm -it --ipc=host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e LIBGL_ALWAYS_SOFTWARE=1 --device /dev/bus/usb -v $XDG_RUNTIME_DIR/pulse:/tmp/runtime/pulse -e PULSE_SERVER=unix:/tmp/runtime/pulse/native -v $XDG_RUNTIME_DIR/pipewire-0:$XDG_RUNTIME_DIR/pipewire-0 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -e PIPEWIRE_REMOTE=pipewire-0 -v $HOME/Musique/reaper:/opt/wineprefix/drive_c/users/root/Documents/REAPER\ Media/ swam:1.0 reaper"
```
