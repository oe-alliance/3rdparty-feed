#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin
pkg_dir=$1
if [[ -z $pkg_dir || ! -d $pkg_dir ]] ; then
    echo "Usage: recreate_feed <package_directory>"
    exit 1
fi

find $pkg_dir -maxdepth 1 -type f -name '*.ipk' | sort | while read pkg ; do
    filename=${pkg##*/}
    pkgname=${filename%%_*}
    echo "Generating index for package $pkgname" >&2
    oldflag=
    for other in $pkg_dir/${pkgname}_*; do
        if [[ $pkg != $other && $other -nt $pkg ]] ; then
            oldflag=y
            echo >&2 "Skipped old file: $pkg ($other is newer)"
            [[ ! -d $pkg_dir/old ]] && mkdir $pkg_dir/old
            mv $pkg $pkg_dir/old/.
            break
        fi
    done
    [[ -n $oldflag ]] && continue

    file_size=$(stat -c %s $pkg)
    md5sum=$(md5sum $pkg | cut -d' ' -f1)
    file -b $pkg | grep gzip >/dev/null
    if [ $? -eq 0 ]; then
        tar -xzf $pkg ./control.tar.gz 
    else
        ar x $pkg control.tar.gz
    fi
    tar -zxOf control.tar.gz ./control >/dev/null
    if [ $? -eq 0 ]; then
       tar -zxOf control.tar.gz ./control | egrep -iv "^Filename:|^MD5SUm:|^Size:|^$" | sed -e "/^Depends:/s/(>\([^>=]\)/(>=\1/g" -e "/^Depends:/s/(<\([^<=]\)/(<=\1/g"
    else
       tar -zxOf control.tar.gz control | egrep -iv "^Filename:|^MD5SUm:|^Size:|^$" | sed -e "/^Depends:/s/(>\([^>=]\)/(>=\1/g" -e "/^Depends:/s/(<\([^<=]\)/(<=\1/g"
    fi
    echo "Filename: $filename"
    echo "Size: $file_size"
    echo "MD5Sum: $md5sum"
    echo ""
    rm control.tar.gz
done >> $pkg_dir/Packages

rm -f $pkg_dir/Packages.gz
gzip $pkg_dir/Packages
touch $pkg_dir/Packages.gz
