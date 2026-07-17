#!/bin/bash

mapfile -t instruments < <(
find "/opt/wineprefix/drive_c/Program Files/Common Files/VST3/SWAM/" \
-type f -name "*.vst3" -print0 |
grep -zv "Ambiente.vst3" |
while IFS= read -r -d '' i; do
    strings "$i" | awk '/\.zip/ {for(i=1;i<=7;i++){getline; if(length($0)==4){gsub(/\(8Cz/, "BBt3"); print; exit}}}'
done
)
for instrument in "${instruments[@]}"; do
  cp /tmp/default_datastore.xml /opt/wineprefix/drive_c/users/root/AppData/Roaming/Audio\ Modeling/UserData/${instrument}_datastore.xml
done
