#!/usr/bin/env sh
# Usage: ./made.sh [applets_dir]
# Checks for <dir>/<dirname>/<filename>.ha for every coreutil

dir="${1:-src/applets}"
done_count=0
total=0

for name in "[" arch b2sum base32 base64 basename basenc cat chcon chgrp chmod \
chown chroot cksum comm coreutils cp csplit cut date dd df dir \
dircolors dirname du echo env expand expr factor false fmt fold \
groups head hostid id install join kill link ln logname ls md5sum \
mkdir mkfifo mknod mktemp mv nice nl nohup nproc numfmt od paste \
pathchk pinky pr printenv printf ptx pwd readlink realpath rm rmdir \
runcon seq sha1sum sha224sum sha256sum sha384sum sha512sum shred shuf \
sleep sort split stat stdbuf stty sum sync tac tail tee test \
timeout touch tr true truncate tsort tty uname unexpand uniq unlink \
uptime users vdir wc who whoami yes; do
total=$((total + 1))

dir_name="$name"
file_name="$name"
case "$name" in
"[") dir_name=bracket; file_name=bracket ;;
false) dir_name=untrue ;;
esac

if [ -f "$dir/$dir_name/$file_name.ha" ]; then
echo "\"$name\": made"
done_count=$((done_count + 1))
else
echo "\"$name\": not made"
fi
done

pct=$((done_count * 1000 / total))
echo
printf "%d/%d made (%d.%d%%)\n" "$done_count" "$total" $((pct / 10)) $((pct % 10))
