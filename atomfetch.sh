#!/usr/bin/env bash

version=7.1.0

bash_version=${BASH_VERSINFO[0]:-5}
shopt -s eval_unsafe_arith &>/dev/null

sys_locale=${LANG:-C}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
PATH=$PATH:/usr/xpg4/bin:/usr/sbin:/sbin:/usr/etc:/usr/libexec
reset='\e[0m'
shopt -s nocasematch

LC_ALL=C
LANG=C

export GIO_EXTRA_MODULES=/usr/lib/x86_64-linux-gnu/gio/modules/

read -rd '' config <<'EOF'

print_info() {
    info title
    info underline

    info "OS" distro
    info "Host" model
    
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
   
    info "Terminal" term
   
    info "CPU" cpu
    
    info "Memory" memory
   
    
    info "Disk" disk
    info "Battery" battery
  
    info "Local IP" local_ip
    info "Public IP" public_ip
    info "ROS Master URI" users
    info "CPU Temperature" users1
    info "CPU Voltage" users2

    info cols
}

# Title
title_fqdn="off"
# Kernel
kernel_shorthand="on"


# Distro

distro_shorthand="off"


os_arch="on"

uptime_shorthand="on"



memory_percent="off"



memory_unit="mib"



package_managers="on"



shell_path="off"

shell_version="on"


# CPU


speed_type="bios_limit"


speed_shorthand="off"


cpu_brand="on"


cpu_speed="on"


cpu_cores="logical"


cpu_temp="off"

public_ip_host="http://ident.me"


public_ip_timeout=2


local_ip_interface=('auto')






disk_show=('/')

disk_subtitle="mount"

disk_percent="on"



colors=(distro)



bold="on"


underline_enabled="on"


underline_char="-"



separator=":"



block_range=(0 15)


color_blocks="on"


block_width=3

block_height=1


col_offset="auto"


bar_char_elapsed="-"
bar_char_total="="


bar_border="on"


bar_length=15


bar_color_elapsed="distro"
bar_color_total="distro"



memory_display="off"
battery_display="off"
disk_display="off"



image_backend="ascii"


image_source="auto"



ascii_distro="auto"


ascii_colors=(distro)


ascii_bold="on"


image_loop="off"


thumbnail_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/thumbnails/neofetch"


crop_mode="normal"


crop_offset="center"


image_size="auto"


catimg_size="2"


gap=3


yoffset=0
xoffset=0


background_color=

stdout="off"
EOF

# DETECT INFORMATION

get_os() {
    # $kernel_name is set in a function called cache_uname and is
    # just the output of "uname -s".
    case $kernel_name in
        Darwin)   os=$darwin_name ;;
        SunOS)    os=Solaris ;;
        Haiku)    os=Haiku ;;
        MINIX)    os=MINIX ;;
        AIX)      os=AIX ;;
        IRIX*)    os=IRIX ;;
        FreeMiNT) os=FreeMiNT ;;

        Linux|GNU*)
            os=Linux
        ;;

        *BSD|DragonFly|Bitrig)
            os=BSD
        ;;

        CYGWIN*|MSYS*|MINGW*)
            os=Windows
        ;;

        *)
            printf '%s\n' "Unknown OS detected: '$kernel_name', aborting..." >&2
            printf '%s\n' "Open an issue on GitHub to add support for your OS." >&2
            exit 1
        ;;
    esac
}

get_distro() {
    [[ $distro ]] && return

    case $os in
        Linux|BSD|MINIX)
            if [[ -f /bedrock/etc/bedrock-release && -z $BEDROCK_RESTRICT ]]; then
                case $distro_shorthand in
                    on|tiny) distro="Bedrock Linux" ;;
                    *) distro=$(< /bedrock/etc/bedrock-release)
                esac

            elif [[ -f /etc/redstar-release ]]; then
                case $distro_shorthand in
                    on|tiny) distro="Red Star OS" ;;
                    *) distro="Red Star OS $(awk -F'[^0-9*]' '$0=$2' /etc/redstar-release)"
                esac

            elif [[ -f /etc/armbian-release ]]; then
                . /etc/armbian-release
                distro="Armbian $DISTRIBUTION_CODENAME (${VERSION:-})"

            elif [[ -f /etc/siduction-version ]]; then
                case $distro_shorthand in
                    on|tiny) distro=Siduction ;;
                    *) distro="Siduction ($(lsb_release -sic))"
                esac

            elif [[ -f /etc/mcst_version ]]; then
                case $distro_shorthand in
                    on|tiny) distro="OS Elbrus" ;;
                    *) distro="OS Elbrus $(< /etc/mcst_version)"
                esac

            elif type -p pveversion >/dev/null; then
                case $distro_shorthand in
                    on|tiny) distro="Proxmox VE" ;;
                    *)
                        distro=$(pveversion)
                        distro=${distro#pve-manager/}
                        distro="Proxmox VE ${distro%/*}"
                esac

            elif type -p lsb_release >/dev/null; then
                case $distro_shorthand in
                    on)   lsb_flags=-si ;;
                    tiny) lsb_flags=-si ;;
                    *)    lsb_flags=-sd ;;
                esac
                distro=$(lsb_release "$lsb_flags")

            elif [[ -f /etc/os-release || \
                    -f /usr/lib/os-release || \
                    -f /etc/openwrt_release || \
                    -f /etc/lsb-release ]]; then

                # Source the os-release file
                for file in /etc/lsb-release /usr/lib/os-release \
                            /etc/os-release  /etc/openwrt_release; do
                    source "$file" && break
                done

                # Format the distro name.
                case $distro_shorthand in
                    on)   distro="${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}" ;;
                    tiny) distro="${NAME:-${DISTRIB_ID:-${TAILS_PRODUCT_NAME}}}" ;;
                    off)  distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}" ;;
                esac

            elif [[ -f /etc/GoboLinuxVersion ]]; then
                case $distro_shorthand in
                    on|tiny) distro=GoboLinux ;;
                    *) distro="GoboLinux $(< /etc/GoboLinuxVersion)"
                esac

            elif [[ -f /etc/SDE-VERSION ]]; then
                distro="$(< /etc/SDE-VERSION)"
                case $distro_shorthand in
                    on|tiny) distro="${distro% *}" ;;
                esac

            elif type -p crux >/dev/null; then
                distro=$(crux)
                case $distro_shorthand in
                    on)   distro=${distro//version} ;;
                    tiny) distro=${distro//version*}
                esac

            elif type -p tazpkg >/dev/null; then
                distro="SliTaz $(< /etc/slitaz-release)"

            elif type -p kpt >/dev/null && \
                 type -p kpm >/dev/null; then
                distro=KSLinux

            elif [[ -d /system/app/ && -d /system/priv-app ]]; then
                distro="Android $(getprop ro.build.version.release)"

            # Chrome OS doesn't conform to the /etc/*-release standard.
            # While the file is a series of variables they can't be sourced
            # by the shell since the values aren't quoted.
            elif [[ -f /etc/lsb-release && $(< /etc/lsb-release) == *CHROMEOS* ]]; then
                distro='Chrome OS'

            elif type -p guix >/dev/null; then
                case $distro_shorthand in
                    on|tiny) distro="Guix System" ;;
                    *) distro="Guix System $(guix -V | awk 'NR==1{printf $4}')"
                esac

            # Display whether using '-current' or '-release' on OpenBSD.
            elif [[ $kernel_name = OpenBSD ]] ; then
                read -ra kernel_info <<< "$(sysctl -n kern.version)"
                distro=${kernel_info[*]:0:2}

            else
                for release_file in /etc/*-release; do
                    distro+=$(< "$release_file")
                done

                if [[ -z $distro ]]; then
                    case $distro_shorthand in
                        on|tiny) distro=$kernel_name ;;
                        *) distro="$kernel_name $kernel_version" ;;
                    esac

                    distro=${distro/DragonFly/DragonFlyBSD}

                    # Workarounds for some BSD based distros.
                    [[ -f /etc/pcbsd-lang ]]       && distro=PCBSD
                    [[ -f /etc/trueos-lang ]]      && distro=TrueOS
                    [[ -f /etc/pacbsd-release ]]   && distro=PacBSD
                    [[ -f /etc/hbsd-update.conf ]] && distro=HardenedBSD
                fi
            fi

            if [[ $(< /proc/version) == *Microsoft* || $kernel_version == *Microsoft* ]]; then
                windows_version=$(wmic.exe os get Version)
                windows_version=$(trim "${windows_version/Version}")

                case $distro_shorthand in
                    on)   distro+=" [Windows $windows_version]" ;;
                    tiny) distro="Windows ${windows_version::2}" ;;
                    *)    distro+=" on Windows $windows_version" ;;
                esac

            elif [[ $(< /proc/version) == *chrome-bot* || -f /dev/cros_ec ]]; then
                [[ $distro != *Chrome* ]] &&
                    case $distro_shorthand in
                        on)   distro+=" [Chrome OS]" ;;
                        tiny) distro="Chrome OS" ;;
                        *)    distro+=" on Chrome OS" ;;
                    esac
                    distro=${distro## on }
            fi

            distro=$(trim_quotes "$distro")
            distro=${distro/NAME=}

            # Get Ubuntu flavor.
            if [[ $distro == "Ubuntu"* ]]; then
                case $XDG_CONFIG_DIRS in
                    *"studio"*)   distro=${distro/Ubuntu/Ubuntu Studio} ;;
                    *"plasma"*)   distro=${distro/Ubuntu/Kubuntu} ;;
                    *"mate"*)     distro=${distro/Ubuntu/Ubuntu MATE} ;;
                    *"xubuntu"*)  distro=${distro/Ubuntu/Xubuntu} ;;
                    *"Lubuntu"*)  distro=${distro/Ubuntu/Lubuntu} ;;
                    *"budgie"*)   distro=${distro/Ubuntu/Ubuntu Budgie} ;;
                    *"cinnamon"*) distro=${distro/Ubuntu/Ubuntu Cinnamon} ;;
                esac
            fi
        ;;

        "Mac OS X"|"macOS")
            case $osx_version in
                10.4*)  codename="Mac OS X Tiger" ;;
                10.5*)  codename="Mac OS X Leopard" ;;
                10.6*)  codename="Mac OS X Snow Leopard" ;;
                10.7*)  codename="Mac OS X Lion" ;;
                10.8*)  codename="OS X Mountain Lion" ;;
                10.9*)  codename="OS X Mavericks" ;;
                10.10*) codename="OS X Yosemite" ;;
                10.11*) codename="OS X El Capitan" ;;
                10.12*) codename="macOS Sierra" ;;
                10.13*) codename="macOS High Sierra" ;;
                10.14*) codename="macOS Mojave" ;;
                10.15*) codename="macOS Catalina" ;;
                10.16*) codename="macOS Big Sur" ;;
                11.*)  codename="macOS Big Sur" ;;
                12.*)  codename="macOS Monterey" ;;
                *)      codename=macOS ;;
            esac

            distro="$codename $osx_version $osx_build"

            case $distro_shorthand in
                on) distro=${distro/ ${osx_build}} ;;

                tiny)
                    case $osx_version in
                        10.[4-7]*)            distro=${distro/${codename}/Mac OS X} ;;
                        10.[8-9]*|10.1[0-1]*) distro=${distro/${codename}/OS X} ;;
                        10.1[2-6]*|11.0*)     distro=${distro/${codename}/macOS} ;;
                    esac
                    distro=${distro/ ${osx_build}}
                ;;
            esac
        ;;

        "iPhone OS")
            distro="iOS $osx_version"

            # "uname -m" doesn't print architecture on iOS.
            os_arch=off
        ;;

        Windows)
            distro=$(wmic os get Caption)
            distro=${distro/Caption}
            distro=${distro/Microsoft }
        ;;

        Solaris)
            case $distro_shorthand in
                on|tiny) distro=$(awk 'NR==1 {print $1,$3}' /etc/release) ;;
                *)       distro=$(awk 'NR==1 {print $1,$2,$3}' /etc/release) ;;
            esac
            distro=${distro/\(*}
        ;;

        Haiku)
            distro=Haiku
        ;;

        AIX)
            distro="AIX $(oslevel)"
        ;;

        IRIX)
            distro="IRIX ${kernel_version}"
        ;;

        FreeMiNT)
            distro=FreeMiNT
        ;;
    esac

    distro=${distro//Enterprise Server}

    [[ $distro ]] || distro="$os (Unknown)"

    # Get OS architecture.
    case $os in
        Solaris|AIX|Haiku|IRIX|FreeMiNT)
            machine_arch=$(uname -p)
        ;;

        *)  machine_arch=$kernel_machine ;;
    esac

    [[ $os_arch == on ]] && \
        distro+=" $machine_arch"

    [[ ${ascii_distro:-auto} == auto ]] && \
        ascii_distro=$(trim "$distro")
}



get_title() {
    user=${USER:-$(id -un || printf %s "${HOME/*\/}")}

    case $title_fqdn in
        on) hostname=$(hostname -f) ;;
        *)  hostname=${HOSTNAME:-$(hostname)} ;;
    esac

    title=${title_color}${bold}${user}${at_color}@${title_color}${bold}${hostname}
    length=$((${#user} + ${#hostname} + 1))
}

get_kernel() {
    # Since these OS are integrated systems, it's better to skip this function altogether
    [[ $os =~ (AIX|IRIX) ]] && return
    case $kernel_shorthand in
        on)  kernel=$kernel_version ;;
        off) kernel="$kernel_name $kernel_version" ;;
    esac
}

get_uptime() {
    # Get uptime in seconds.
    case $os in
        Linux|Windows|MINIX)
            if [[ -r /proc/uptime ]]; then
                s=$(< /proc/uptime)
                s=${s/.*}
            else
                boot=$(date -d"$(uptime -s)" +%s)
                now=$(date +%s)
                s=$((now - boot))
            fi
        ;;

        "Mac OS X"|"macOS"|"iPhone OS"|BSD|FreeMiNT)
            boot=$(sysctl -n kern.boottime)
            boot=${boot/\{ sec = }
            boot=${boot/,*}

            # Get current date in seconds.
            now=$(date +%s)
            s=$((now - boot))
        ;;

        Solaris)
            s=$(kstat -p unix:0:system_misc:snaptime | awk '{print $2}')
            s=${s/.*}
        ;;

        AIX|IRIX)
            t=$(LC_ALL=POSIX ps -o etime= -p 1)

            [[ $t == *-*   ]] && { d=${t%%-*}; t=${t#*-}; }
            [[ $t == *:*:* ]] && { h=${t%%:*}; t=${t#*:}; }

            h=${h#0}
            t=${t#0}

            s=$((${d:-0}*86400 + ${h:-0}*3600 + ${t%%:*}*60 + ${t#*:}))
        ;;

        Haiku)
            s=$(($(system_time) / 1000000))
        ;;
    esac

    d="$((s / 60 / 60 / 24)) days"
    h="$((s / 60 / 60 % 24)) hours"
    m="$((s / 60 % 60)) minutes"

    # Remove plural if < 2.
    ((${d/ *} == 1)) && d=${d/s}
    ((${h/ *} == 1)) && h=${h/s}
    ((${m/ *} == 1)) && m=${m/s}

    # Hide empty fields.
    ((${d/ *} == 0)) && unset d
    ((${h/ *} == 0)) && unset h
    ((${m/ *} == 0)) && unset m

    uptime=${d:+$d, }${h:+$h, }$m
    uptime=${uptime%', '}
    uptime=${uptime:-$s seconds}

    # Make the output of uptime smaller.
    case $uptime_shorthand in
        on)
            uptime=${uptime/ minutes/ mins}
            uptime=${uptime/ minute/ min}
            uptime=${uptime/ seconds/ secs}
        ;;

        tiny)
            uptime=${uptime/ days/d}
            uptime=${uptime/ day/d}
            uptime=${uptime/ hours/h}
            uptime=${uptime/ hour/h}
            uptime=${uptime/ minutes/m}
            uptime=${uptime/ minute/m}
            uptime=${uptime/ seconds/s}
            uptime=${uptime//,}
        ;;
    esac
}

get_packages() {
    # to adjust the number of pkgs per pkg manager
    pkgs_h=0

    # has: Check if package manager installed.
    # dir: Count files or dirs in a glob.
    # pac: If packages > 0, log package manager name.
    # tot: Count lines in command output.
    has() { type -p "$1" >/dev/null && manager=$1; }
    # globbing is intentional here
    # shellcheck disable=SC2206
    dir() { pkgs=($@); ((packages+=${#pkgs[@]})); pac "$((${#pkgs[@]}-pkgs_h))"; }
    pac() { (($1 > 0)) && { managers+=("$1 (${manager})"); manager_string+="${manager}, "; }; }
    tot() {
        IFS=$'\n' read -d "" -ra pkgs <<< "$("$@")";
        ((packages+=${#pkgs[@]}));
        pac "$((${#pkgs[@]}-pkgs_h))";
    }

    # Redefine tot() and dir() for Bedrock Linux.
    [[ -f /bedrock/etc/bedrock-release && $PATH == */bedrock/cross/* ]] && {
        br_strata=$(brl list)
        tot() {
            IFS=$'\n' read -d "" -ra pkgs <<< "$(for s in ${br_strata}; do strat -r "$s" "$@"; done)"
            ((packages+="${#pkgs[@]}"))
            pac "$((${#pkgs[@]}-pkgs_h))";
        }
        dir() {
            local pkgs=()
            # globbing is intentional here
            # shellcheck disable=SC2206
            for s in ${br_strata}; do pkgs+=(/bedrock/strata/$s/$@); done
            ((packages+=${#pkgs[@]}))
            pac "$((${#pkgs[@]}-pkgs_h))"
        }
    }

    case $os in
        Linux|BSD|"iPhone OS"|Solaris)
            # Package Manager Programs.
            has kiss       && tot kiss l
            has cpt-list   && tot cpt-list
            has pacman-key && tot pacman -Qq --color never
            has dpkg       && tot dpkg-query -f '.\n' -W
            has xbps-query && tot xbps-query -l
            has apk        && tot apk info
            has opkg       && tot opkg list-installed
            has pacman-g2  && tot pacman-g2 -Q
            has lvu        && tot lvu installed
            has tce-status && tot tce-status -i
            has pkg_info   && tot pkg_info
            has pkgin      && tot pkgin list
            has tazpkg     && pkgs_h=6 tot tazpkg list && ((packages-=6))
            has sorcery    && tot gaze installed
            has alps       && tot alps showinstalled
            has butch      && tot butch list
            has swupd      && tot swupd bundle-list --quiet
            has pisi       && tot pisi li
            has pacstall   && tot pacstall -L

            # Using the dnf package cache is much faster than rpm.
            if has dnf && type -p sqlite3 >/dev/null && [[ -f /var/cache/dnf/packages.db ]]; then
                pac "$(sqlite3 /var/cache/dnf/packages.db "SELECT count(pkg) FROM installed")"
            else
                has rpm && tot rpm -qa
            fi

            # 'mine' conflicts with minesweeper games.
            [[ -f /etc/SDE-VERSION ]] &&
                has mine && tot mine -q

            # Counting files/dirs.
            # Variables need to be unquoted here. Only Bedrock Linux is affected.
            # $br_prefix is fixed and won't change based on user input so this is safe either way.
            # shellcheck disable=SC2086
            {
            shopt -s nullglob
            has brew    && dir "$(brew --cellar)/* $(brew --caskroom)/*"
            has emerge  && dir "/var/db/pkg/*/*"
            has Compile && dir "/Programs/*/"
            has eopkg   && dir "/var/lib/eopkg/package/*"
            has crew    && dir "${CREW_PREFIX:-/usr/local}/etc/crew/meta/*.filelist"
            has pkgtool && dir "/var/log/packages/*"
            has scratch && dir "/var/lib/scratchpkg/index/*/.pkginfo"
            has kagami  && dir "/var/lib/kagami/pkgs/*"
            has cave    && dir "/var/db/paludis/repositories/cross-installed/*/data/*/ \
                               /var/db/paludis/repositories/installed/data/*/"
            shopt -u nullglob
            }

            # Other (Needs complex command)
            has kpm-pkg && ((packages+=$(kpm  --get-selections | grep -cv deinstall$)))

            has guix && {
                manager=guix-system && tot guix package -p "/run/current-system/profile" -I
                manager=guix-user   && tot guix package -I
            }

            has nix-store && {
                nix-user-pkgs() {
                    nix-store -qR ~/.nix-profile
                    nix-store -qR /etc/profiles/per-user/"$USER"
                }
                manager=nix-system  && tot nix-store -qR /run/current-system/sw
                manager=nix-user    && tot nix-user-pkgs
                manager=nix-default && tot nix-store -qR /nix/var/nix/profiles/default
            }

            # pkginfo is also the name of a python package manager which is painfully slow.
            # TODO: Fix this somehow.
            has pkginfo && tot pkginfo -i

            case $os-$kernel_name in
                BSD-FreeBSD|BSD-DragonFly)
                    has pkg && tot pkg info
                ;;

                BSD-*)
                    has pkg && dir /var/db/pkg/*

                    ((packages == 0)) &&
                        has pkg && tot pkg list
                ;;
            esac

            # List these last as they accompany regular package managers.
            has flatpak && tot flatpak list
            has spm     && tot spm list -i
            has puyo    && dir ~/.puyo/installed

            # Snap hangs if the command is run without the daemon running.
            # Only run snap if the daemon is also running.
            has snap && ps -e | grep -qFm 1 snapd >/dev/null && \
            pkgs_h=1 tot snap list && ((packages-=1))

            # This is the only standard location for appimages.
            # See: https://github.com/AppImage/AppImageKit/wiki
            manager=appimage && has appimaged && dir ~/.local/bin/*.appimage
        ;;

        "Mac OS X"|"macOS"|MINIX)
            has port  && pkgs_h=1 tot port installed && ((packages-=1))
            has brew  && dir "$(brew --cellar)/* $(brew --caskroom)/*"
            has pkgin && tot pkgin list
            has dpkg  && tot dpkg-query -f '.\n' -W

            has nix-store && {
                nix-user-pkgs() {
                    nix-store -qR ~/.nix-profile
                    nix-store -qR /etc/profiles/per-user/"$USER"
                }
                manager=nix-system && tot nix-store -qR /run/current-system/sw
                manager=nix-user   && tot nix-user-pkgs
            }
        ;;

        AIX|FreeMiNT)
            has lslpp && ((packages+=$(lslpp -J -l -q | grep -cv '^#')))
            has rpm   && tot rpm -qa
        ;;

        Windows)
            case $kernel_name in
                CYGWIN*) has cygcheck && tot cygcheck -cd ;;
                MSYS*)   has pacman   && tot pacman -Qq --color never ;;
            esac

            # Scoop environment throws errors if `tot scoop list` is used
            has scoop && pkgs_h=1 dir ~/scoop/apps/* && ((packages-=1))

            # Count chocolatey packages.
            [[ -d /cygdrive/c/ProgramData/chocolatey/lib ]] && \
                dir /cygdrive/c/ProgramData/chocolatey/lib/*
        ;;

        Haiku)
            has pkgman && dir /boot/system/package-links/*
            packages=${packages/pkgman/depot}
        ;;

        IRIX)
            manager=swpkg
            pkgs_h=3 tot versions -b && ((packages-=3))
        ;;
    esac

    if ((packages == 0)); then
        unset packages

    elif [[ $package_managers == on ]]; then
        printf -v packages '%s, ' "${managers[@]}"
        packages=${packages%,*}

    elif [[ $package_managers == tiny ]]; then
        packages+=" (${manager_string%,*})"
    fi

    packages=${packages/pacman-key/pacman}
}

get_shell() {
    case $shell_path in
        on)  shell="$SHELL " ;;
        off) shell="${SHELL##*/} " ;;
    esac

    [[ $shell_version != on ]] && return

    case ${shell_name:=${SHELL##*/}} in
        bash)
            [[ $BASH_VERSION ]] ||
                BASH_VERSION=$("$SHELL" -c "printf %s \"\$BASH_VERSION\"")

            shell+=${BASH_VERSION/-*}
        ;;

        sh|ash|dash|es) ;;

        *ksh)
            shell+=$("$SHELL" -c "printf %s \"\$KSH_VERSION\"")
            shell=${shell/ * KSH}
            shell=${shell/version}
        ;;

        osh)
            if [[ $OIL_VERSION ]]; then
                shell+=$OIL_VERSION
            else
                shell+=$("$SHELL" -c "printf %s \"\$OIL_VERSION\"")
            fi
        ;;

        tcsh)
            shell+=$("$SHELL" -c "printf %s \$tcsh")
        ;;

        yash)
            shell+=$("$SHELL" --version 2>&1)
            shell=${shell/ $shell_name}
            shell=${shell/ Yet another shell}
            shell=${shell/Copyright*}
        ;;

        nu)
            shell+=$("$SHELL" -c "version | get version")
            shell=${shell/ $shell_name}
        ;;


        *)
            shell+=$("$SHELL" --version 2>&1)
            shell=${shell/ $shell_name}
        ;;
    esac

    # Remove unwanted info.
    shell=${shell/, version}
    shell=${shell/xonsh\//xonsh }
    shell=${shell/options*}
    shell=${shell/\(*\)}
}

get_cpu() {
    case $os in
        "Linux" | "MINIX" | "Windows")
            # Get CPU name.
            cpu_file="/proc/cpuinfo"

            case $kernel_machine in
                "frv" | "hppa" | "m68k" | "openrisc" | "or"* | "powerpc" | "ppc"* | "sparc"*)
                    cpu="$(awk -F':' '/^cpu\t|^CPU/ {printf $2; exit}' "$cpu_file")"
                ;;

                "s390"*)
                    cpu="$(awk -F'=' '/machine/ {print $4; exit}' "$cpu_file")"
                ;;

                "ia64" | "m32r")
                    cpu="$(awk -F':' '/model/ {print $2; exit}' "$cpu_file")"
                    [[ -z "$cpu" ]] && cpu="$(awk -F':' '/family/ {printf $2; exit}' "$cpu_file")"
                ;;

                *)
                    cpu="$(awk -F '\\s*: | @' \
                            '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ {
                            cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' "$cpu_file")"
                ;;
            esac

            speed_dir="/sys/devices/system/cpu/cpu0/cpufreq"

            # Select the right temperature file.
            for temp_dir in /sys/class/hwmon/*; do
                [[ "$(< "${temp_dir}/name")" =~ (cpu_thermal|coretemp|fam15h_power|k10temp) ]] && {
                    temp_dirs=("$temp_dir"/temp*_input)
                    temp_dir=${temp_dirs[0]}
                    break
                }
            done

            # Get CPU speed.
            if [[ -d "$speed_dir" ]]; then
                # Fallback to bios_limit if $speed_type fails.
                speed="$(< "${speed_dir}/${speed_type}")" ||\
                speed="$(< "${speed_dir}/bios_limit")" ||\
                speed="$(< "${speed_dir}/scaling_max_freq")" ||\
                speed="$(< "${speed_dir}/cpuinfo_max_freq")"
                speed="$((speed / 1000))"

            else
                case $kernel_machine in
                    "sparc"*)
                        # SPARC systems use a different file to expose clock speed information.
                        speed_file="/sys/devices/system/cpu/cpu0/clock_tick"
                        speed="$(($(< "$speed_file") / 1000000))"
                    ;;

                    *)
                        speed="$(awk -F ': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' "$cpu_file")"
                        speed="${speed/MHz}"
                    ;;
                esac
            fi

            # Get CPU temp.
            [[ -f "$temp_dir" ]] && deg="$(($(< "$temp_dir") * 100 / 10000))"

            # Get CPU cores.
            case $kernel_machine in
                "sparc"*)
                    case $cpu_cores in
                        # SPARC systems doesn't expose detailed topology information in
                        # /proc/cpuinfo so I have to use lscpu here.
                        "logical" | "on")
                            cores="$(lscpu | awk -F ': *' '/^CPU\(s\)/ {print $2}')"
                        ;;
                        "physical")
                            cores="$(lscpu | awk -F ': *' '/^Core\(s\) per socket/ {print $2}')"
                            sockets="$(lscpu | awk -F ': *' '/^Socket\(s\)/ {print $2}')"
                            cores="$((sockets * cores))"
                        ;;
                    esac
                ;;

                *)
                    case $cpu_cores in
                        "logical" | "on")
                            cores="$(grep -c "^processor" "$cpu_file")"
                        ;;
                        "physical")
                            cores="$(awk '/^core id/&&!a[$0]++{++i} END {print i}' "$cpu_file")"
                        ;;
                    esac
                ;;
            esac
        ;;

        "Mac OS X"|"macOS")
            cpu="$(sysctl -n machdep.cpu.brand_string)"

            # Get CPU cores.
            case $cpu_cores in
                "logical" | "on") cores="$(sysctl -n hw.logicalcpu_max)" ;;
                "physical")       cores="$(sysctl -n hw.physicalcpu_max)" ;;
            esac
        ;;

        "iPhone OS")
            case $kernel_machine in
                "iPhone1,"[1-2] | "iPod1,1"): "Samsung S5L8900 (1) @ 412MHz" ;;
                "iPhone2,1"):                 "Samsung S5PC100 (1) @ 600MHz" ;;
                "iPhone3,"[1-3] | "iPod4,1"): "Apple A4 (1) @ 800MHz" ;;
                "iPhone4,1" | "iPod5,1"):     "Apple A5 (2) @ 800MHz" ;;
                "iPhone5,"[1-4]): "Apple A6 (2) @ 1.3GHz" ;;
                "iPhone6,"[1-2]): "Apple A7 (2) @ 1.3GHz" ;;
                "iPhone7,"[1-2]): "Apple A8 (2) @ 1.4GHz" ;;
                "iPhone8,"[1-4] | "iPad6,1"[12]): "Apple A9 (2) @ 1.85GHz" ;;
                "iPhone9,"[1-4] | "iPad7,"[5-6] | "iPad7,1"[1-2]):
                    "Apple A10 Fusion (4) @ 2.34GHz"
                ;;
                "iPhone10,"[1-6]): "Apple A11 Bionic (6) @ 2.39GHz" ;;
                "iPhone11,"[2468] | "iPad11,"[1-4] | "iPad11,"[6-7]): "Apple A12 Bionic (6) @ 2.49GHz" ;;
                "iPhone12,"[1358]): "Apple A13 Bionic (6) @ 2.65GHz" ;;
                "iPhone13,"[1-4] | "iPad13,"[1-2]): "Apple A14 Bionic (6) @ 3.00Ghz" ;;

                "iPod2,1"): "Samsung S5L8720 (1) @ 533MHz" ;;
                "iPod3,1"): "Samsung S5L8922 (1) @ 600MHz" ;;
                "iPod7,1"): "Apple A8 (2) @ 1.1GHz" ;;
                "iPad1,1"): "Apple A4 (1) @ 1GHz" ;;
                "iPad2,"[1-7]): "Apple A5 (2) @ 1GHz" ;;
                "iPad3,"[1-3]): "Apple A5X (2) @ 1GHz" ;;
                "iPad3,"[4-6]): "Apple A6X (2) @ 1.4GHz" ;;
                "iPad4,"[1-3]): "Apple A7 (2) @ 1.4GHz" ;;
                "iPad4,"[4-9]): "Apple A7 (2) @ 1.4GHz" ;;
                "iPad5,"[1-2]): "Apple A8 (2) @ 1.5GHz" ;;
                "iPad5,"[3-4]): "Apple A8X (3) @ 1.5GHz" ;;
                "iPad6,"[3-4]): "Apple A9X (2) @ 2.16GHz" ;;
                "iPad6,"[7-8]): "Apple A9X (2) @ 2.26GHz" ;;
                "iPad7,"[1-4]): "Apple A10X Fusion (6) @ 2.39GHz" ;;
                "iPad8,"[1-8]): "Apple A12X Bionic (8) @ 2.49GHz" ;;
                "iPad8,9" | "iPad8,1"[0-2]): "Apple A12Z Bionic (8) @ 2.49GHz" ;;
            esac
            cpu="$_"
        ;;

        "BSD")
            # Get CPU name.
            cpu="$(sysctl -n hw.model)"
            cpu="${cpu/[0-9]\.*}"
            cpu="${cpu/ @*}"

            # Get CPU speed.
            speed="$(sysctl -n hw.cpuspeed)"
            [[ -z "$speed" ]] && speed="$(sysctl -n  hw.clockrate)"

            # Get CPU cores.
            case $kernel_name in
                "OpenBSD"*)
                    [[ "$(sysctl -n hw.smt)" == "1" ]] && smt="on" || smt="off"
                    ncpufound="$(sysctl -n hw.ncpufound)"
                    ncpuonline="$(sysctl -n hw.ncpuonline)"
                    cores="${ncpuonline}/${ncpufound},\\xc2\\xa0SMT\\xc2\\xa0${smt}"
                ;;
                *)
                    cores="$(sysctl -n hw.ncpu)"
                ;;
            esac

            # Get CPU temp.
            case $kernel_name in
                "FreeBSD"* | "DragonFly"* | "NetBSD"*)
                    deg="$(sysctl -n dev.cpu.0.temperature)"
                    deg="${deg/C}"
                ;;
                "OpenBSD"* | "Bitrig"*)
                    deg="$(sysctl hw.sensors | \
                        awk -F'=|degC' '/(ksmn|adt|lm|cpu)0.temp0/ {printf("%2.1f", $2); exit}')"
                ;;
            esac
        ;;

        "Solaris")
            # Get CPU name.
            cpu="$(psrinfo -pv)"
            cpu="${cpu//*$'\n'}"
            cpu="${cpu/[0-9]\.*}"
            cpu="${cpu/ @*}"
            cpu="${cpu/\(portid*}"

            # Get CPU speed.
            speed="$(psrinfo -v | awk '/operates at/ {print $6; exit}')"

            # Get CPU cores.
            case $cpu_cores in
                "logical" | "on") cores="$(kstat -m cpu_info | grep -c -F "chip_id")" ;;
                "physical") cores="$(psrinfo -p)" ;;
            esac
        ;;

        "Haiku")
            # Get CPU name.
            cpu="$(sysinfo -cpu | awk -F '\\"' '/CPU #0/ {print $2}')"
            cpu="${cpu/@*}"

            # Get CPU speed.
            speed="$(sysinfo -cpu | awk '/running at/ {print $NF; exit}')"
            speed="${speed/MHz}"

            # Get CPU cores.
            cores="$(sysinfo -cpu | grep -c -F 'CPU #')"
        ;;

        "AIX")
            # Get CPU name.
            cpu="$(lsattr -El proc0 -a type | awk '{printf $2}')"

            # Get CPU speed.
            speed="$(prtconf -s | awk -F':' '{printf $2}')"
            speed="${speed/MHz}"

            # Get CPU cores.
            case $cpu_cores in
                "logical" | "on")
                    cores="$(lparstat -i | awk -F':' '/Online Virtual CPUs/ {printf $2}')"
                ;;

                "physical")
                    cores="$(lparstat -i | awk -F':' '/Active Physical CPUs/ {printf $2}')"
                ;;
            esac
        ;;

        "IRIX")
            # Get CPU name.
            cpu="$(hinv -c processor | awk -F':' '/CPU:/ {printf $2}')"

            # Get CPU speed.
            speed="$(hinv -c processor | awk '/MHZ/ {printf $2}')"

            # Get CPU cores.
            cores="$(sysconf NPROC_ONLN)"
        ;;

        "FreeMiNT")
            cpu="$(awk -F':' '/CPU:/ {printf $2}' /kern/cpuinfo)"
            speed="$(awk -F '[:.M]' '/Clocking:/ {printf $2}' /kern/cpuinfo)"
        ;;
    esac

    # Remove un-needed patterns from cpu output.
    cpu="${cpu//(TM)}"
    cpu="${cpu//(tm)}"
    cpu="${cpu//(R)}"
    cpu="${cpu//(r)}"
    cpu="${cpu//CPU}"
    cpu="${cpu//Processor}"
    cpu="${cpu//Dual-Core}"
    cpu="${cpu//Quad-Core}"
    cpu="${cpu//Six-Core}"
    cpu="${cpu//Eight-Core}"
    cpu="${cpu//[1-9][0-9]-Core}"
    cpu="${cpu//[0-9]-Core}"
    cpu="${cpu//, * Compute Cores}"
    cpu="${cpu//Core / }"
    cpu="${cpu//(\"AuthenticAMD\"*)}"
    cpu="${cpu//with Radeon * Graphics}"
    cpu="${cpu//, altivec supported}"
    cpu="${cpu//FPU*}"
    cpu="${cpu//Chip Revision*}"
    cpu="${cpu//Technologies, Inc}"
    cpu="${cpu//Core2/Core 2}"

    # Trim spaces from core and speed output
    cores="${cores//[[:space:]]}"
    speed="${speed//[[:space:]]}"

    # Remove CPU brand from the output.
    if [[ "$cpu_brand" == "off" ]]; then
        cpu="${cpu/AMD }"
        cpu="${cpu/Intel }"
        cpu="${cpu/Core? Duo }"
        cpu="${cpu/Qualcomm }"
    fi

    # Add CPU cores to the output.
    [[ "$cpu_cores" != "off" && "$cores" ]] && \
        case $os in
            "Mac OS X"|"macOS") cpu="${cpu/@/(${cores}) @}" ;;
            *)                  cpu="$cpu ($cores)" ;;
        esac

    # Add CPU speed to the output.
    if [[ "$cpu_speed" != "off" && "$speed" ]]; then
        if (( speed < 1000 )); then
            cpu="$cpu @ ${speed}MHz"
        else
            [[ "$speed_shorthand" == "on" ]] && speed="$((speed / 100))"
            speed="${speed:0:1}.${speed:1}"
            cpu="$cpu @ ${speed}GHz"
        fi
    fi

    # Add CPU temp to the output.
    if [[ "$cpu_temp" != "off" && "$deg" ]]; then
        deg="${deg//.}"

        # Convert to Fahrenheit if enabled
        [[ "$cpu_temp" == "F" ]] && deg="$((deg * 90 / 50 + 320))"

        # Format the output
        deg="[${deg/${deg: -1}}.${deg: -1}°${cpu_temp:-C}]"
        cpu="$cpu $deg"
    fi
}

get_gpu() {
    case $os in
        "Linux")
            # Read GPUs into array.
            gpu_cmd="$(lspci -mm |
                       awk -F '\"|\" \"|\\(' \
                              '/"Display|"3D|"VGA/ {
                                  a[$0] = $1 " " $3 " " ($(NF-1) ~ /^$|^Device [[:xdigit:]]+$/ ? $4 : $(NF-1))
                              }
                              END { for (i in a) {
                                  if (!seen[a[i]]++) {
                                      sub("^[^ ]+ ", "", a[i]);
                                      print a[i]
                                  }
                              }}')"
            IFS=$'\n' read -d "" -ra gpus <<< "$gpu_cmd"

            # Remove duplicate Intel Graphics outputs.
            # This fixes cases where the outputs are both
            # Intel but not entirely identical.
            #
            # Checking the first two array elements should
            # be safe since there won't be 2 intel outputs if
            # there's a dedicated GPU in play.
            [[ "${gpus[0]}" == *Intel* && "${gpus[1]}" == *Intel* ]] && unset -v "gpus[0]"

            for gpu in "${gpus[@]}"; do
                # GPU shorthand tests.
                [[ "$gpu_type" == "dedicated" && "$gpu" == *Intel* ]] || \
                [[ "$gpu_type" == "integrated" && ! "$gpu" == *Intel* ]] && \
                    { unset -v gpu; continue; }

                case $gpu in
                    *"Advanced"*)
                        brand="${gpu/*AMD*ATI*/AMD ATI}"
                        brand="${brand:-${gpu/*AMD*/AMD}}"
                        brand="${brand:-${gpu/*ATI*/ATi}}"

                        gpu="${gpu/\[AMD\/ATI\] }"
                        gpu="${gpu/\[AMD\] }"
                        gpu="${gpu/OEM }"
                        gpu="${gpu/Advanced Micro Devices, Inc.}"
                        gpu="${gpu/*\[}"
                        gpu="${gpu/\]*}"
                        gpu="$brand $gpu"
                    ;;

                    *"NVIDIA"*)
                        gpu="${gpu/*\[}"
                        gpu="${gpu/\]*}"
                        gpu="NVIDIA $gpu"
                    ;;

                    *"Intel"*)
                        gpu="${gpu/*Intel/Intel}"
                        gpu="${gpu/\(R\)}"
                        gpu="${gpu/Corporation}"
                        gpu="${gpu/ \(*}"
                        gpu="${gpu/Integrated Graphics Controller}"
                        gpu="${gpu/*Xeon*/Intel HD Graphics}"

                        [[ -z "$(trim "$gpu")" ]] && gpu="Intel Integrated Graphics"
                    ;;

                    *"MCST"*)
                        gpu="${gpu/*MCST*MGA2*/MCST MGA2}"
                    ;;

                    *"VirtualBox"*)
                        gpu="VirtualBox Graphics Adapter"
                    ;;

                    *) continue ;;
                esac

                if [[ "$gpu_brand" == "off" ]]; then
                    gpu="${gpu/AMD }"
                    gpu="${gpu/NVIDIA }"
                    gpu="${gpu/Intel }"
                fi

                prin "${subtitle:+${subtitle}${gpu_name}}" "$gpu"
            done

            return
        ;;

        "Mac OS X"|"macOS")
            if [[ -f "${cache_dir}/neofetch/gpu" ]]; then
                source "${cache_dir}/neofetch/gpu"

            else
                gpu="$(system_profiler SPDisplaysDataType |\
                       awk -F': ' '/^\ *Chipset Model:/ {printf $2 ", "}')"
                gpu="${gpu//\/ \$}"
                gpu="${gpu%,*}"

                cache "gpu" "$gpu"
            fi
        ;;

        "iPhone OS")
            case $kernel_machine in
                "iPhone1,"[1-2]):                             "PowerVR MBX Lite 3D" ;;
                "iPhone2,1" | "iPhone3,"[1-3] | "iPod3,1" | "iPod4,1" | "iPad1,1"):
                    "PowerVR SGX535"
                ;;
                "iPhone4,1" | "iPad2,"[1-7] | "iPod5,1"):     "PowerVR SGX543MP2" ;;
                "iPhone5,"[1-4]):                             "PowerVR SGX543MP3" ;;
                "iPhone6,"[1-2] | "iPad4,"[1-9]):             "PowerVR G6430" ;;
                "iPhone7,"[1-2] | "iPod7,1" | "iPad5,"[1-2]): "PowerVR GX6450" ;;
                "iPhone8,"[1-4] | "iPad6,1"[12]):             "PowerVR GT7600" ;;
                "iPhone9,"[1-4] | "iPad7,"[5-6]):             "PowerVR GT7600 Plus" ;;
                "iPhone10,"[1-6]):                            "Apple Designed GPU (A11)" ;;
                "iPhone11,"[2468] | "iPad11,"[67]):           "Apple Designed GPU (A12)" ;;
                "iPhone12,"[1358]):                           "Apple Designed GPU (A13)" ;;
                "iPhone13,"[1234] | "iPad13,"[12]):           "Apple Designed GPU (A14)" ;;

                "iPad3,"[1-3]):     "PowerVR SGX534MP4" ;;
                "iPad3,"[4-6]):     "PowerVR SGX554MP4" ;;
                "iPad5,"[3-4]):     "PowerVR GXA6850" ;;
                "iPad6,"[3-8]):     "PowerVR 7XT" ;;

                "iPod1,1" | "iPod2,1")
                    : "PowerVR MBX Lite"
                ;;
            esac
            gpu="$_"
        ;;

        "Windows")
            wmic path Win32_VideoController get caption | while read -r line; do
                line=$(trim "$line")

                case $line in
                    *Caption*|'')
                        continue
                    ;;

                    *)
                        prin "${subtitle:+${subtitle}${gpu_name}}" "$line"
                    ;;
                esac
            done
        ;;

        "Haiku")
            gpu="$(listdev | grep -A2 -F 'device Display controller' |\
                   awk -F':' '/device beef/ {print $2}')"
        ;;

        *)
            case $kernel_name in
                "FreeBSD"* | "DragonFly"*)
                    gpu="$(pciconf -lv | grep -B 4 -F "VGA" | grep -F "device")"
                    gpu="${gpu/*device*= }"
                    gpu="$(trim_quotes "$gpu")"
                ;;

                *)
                    gpu="$(glxinfo -B | grep -F 'OpenGL renderer string')"
                    gpu="${gpu/OpenGL renderer string: }"
                ;;
            esac
        ;;
    esac

    if [[ "$gpu_brand" == "off" ]]; then
        gpu="${gpu/AMD}"
        gpu="${gpu/NVIDIA}"
        gpu="${gpu/Intel}"
    fi
}

get_memory() {
    case $os in
        "Linux" | "Windows")
            # MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
            # Source: https://github.com/KittyKatt/screenFetch/issues/386#issuecomment-249312716
            while IFS=":" read -r a b; do
                case $a in
                    "MemTotal") ((mem_used+=${b/kB})); mem_total="${b/kB}" ;;
                    "Shmem") ((mem_used+=${b/kB}))  ;;
                    "MemFree" | "Buffers" | "Cached" | "SReclaimable")
                        mem_used="$((mem_used-=${b/kB}))"
                    ;;

                    # Available since Linux 3.14rc (34e431b0ae398fc54ea69ff85ec700722c9da773).
                    # If detected this will be used over the above calculation for mem_used.
                    "MemAvailable")
                        mem_avail=${b/kB}
                    ;;
                esac
            done < /proc/meminfo

            if [[ $mem_avail ]]; then
                mem_used=$(((mem_total - mem_avail) / 1024))
            else
                mem_used="$((mem_used / 1024))"
            fi

            mem_total="$((mem_total / 1024))"
        ;;

        "Mac OS X" | "macOS" | "iPhone OS")
            hw_pagesize="$(sysctl -n hw.pagesize)"
            mem_total="$(($(sysctl -n hw.memsize) / 1024 / 1024))"
            pages_app="$(($(sysctl -n vm.page_pageable_internal_count) - $(sysctl -n vm.page_purgeable_count)))"
            pages_wired="$(vm_stat | awk '/ wired/ { print $4 }')"
            pages_compressed="$(vm_stat | awk '/ occupied/ { printf $5 }')"
            pages_compressed="${pages_compressed:-0}"
            mem_used="$(((${pages_app} + ${pages_wired//.} + ${pages_compressed//.}) * hw_pagesize / 1024 / 1024))"
        ;;

        "BSD" | "MINIX")
            # Mem total.
            case $kernel_name in
                "NetBSD"*) mem_total="$(($(sysctl -n hw.physmem64) / 1024 / 1024))" ;;
                *) mem_total="$(($(sysctl -n hw.physmem) / 1024 / 1024))" ;;
            esac

            # Mem free.
            case $kernel_name in
                "NetBSD"*)
                    mem_free="$(($(awk -F ':|kB' '/MemFree:/ {printf $2}' /proc/meminfo) / 1024))"
                ;;

                "FreeBSD"* | "DragonFly"*)
                    hw_pagesize="$(sysctl -n hw.pagesize)"
                    mem_inactive="$(($(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize))"
                    mem_unused="$(($(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize))"
                    mem_cache="$(($(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize))"
                    mem_free="$(((mem_inactive + mem_unused + mem_cache) / 1024 / 1024))"
                ;;

                "MINIX")
                    mem_free="$(top -d 1 | awk -F ',' '/^Memory:/ {print $2}')"
                    mem_free="${mem_free/M Free}"
                ;;

                "OpenBSD"*) ;;
                *) mem_free="$(($(vmstat | awk 'END {printf $5}') / 1024))" ;;
            esac

            # Mem used.
            case $kernel_name in
                "OpenBSD"*)
                    mem_used="$(vmstat | awk 'END {printf $3}')"
                    mem_used="${mem_used/M}"
                ;;

                *) mem_used="$((mem_total - mem_free))" ;;
            esac
        ;;

        "Solaris" | "AIX")
            hw_pagesize="$(pagesize)"
            case $os in
                "Solaris")
                    pages_total="$(kstat -p unix:0:system_pages:pagestotal | awk '{print $2}')"
                    pages_free="$(kstat -p unix:0:system_pages:pagesfree | awk '{print $2}')"
                ;;

                "AIX")
                    IFS=$'\n'"| " read -d "" -ra mem_stat <<< "$(svmon -G -O unit=page)"
                    pages_total="${mem_stat[11]}"
                    pages_free="${mem_stat[16]}"
                ;;
            esac
            mem_total="$((pages_total * hw_pagesize / 1024 / 1024))"
            mem_free="$((pages_free * hw_pagesize / 1024 / 1024))"
            mem_used="$((mem_total - mem_free))"
        ;;

        "Haiku")
            mem_total="$(($(sysinfo -mem | awk -F '\\/ |)' '{print $2; exit}') / 1024 / 1024))"
            mem_used="$(sysinfo -mem | awk -F '\\/|)' '{print $2; exit}')"
            mem_used="$((${mem_used/max} / 1024 / 1024))"
        ;;

        "IRIX")
            IFS=$'\n' read -d "" -ra mem_cmd <<< "$(pmem)"
            IFS=" " read -ra mem_stat <<< "${mem_cmd[0]}"

            mem_total="$((mem_stat[3] / 1024))"
            mem_free="$((mem_stat[5] / 1024))"
            mem_used="$((mem_total - mem_free))"
        ;;

        "FreeMiNT")
            mem="$(awk -F ':|kB' '/MemTotal:|MemFree:/ {printf $2, " "}' /kern/meminfo)"
            mem_free="${mem/*  }"
            mem_total="${mem/$mem_free}"
            mem_used="$((mem_total - mem_free))"
            mem_total="$((mem_total / 1024))"
            mem_used="$((mem_used / 1024))"
        ;;

    esac

    [[ "$memory_percent" == "on" ]] && ((mem_perc=mem_used * 100 / mem_total))

    case $memory_unit in
        gib)
            mem_used=$(awk '{printf "%.2f", $1 / $2}' <<< "$mem_used 1024")
            mem_total=$(awk '{printf "%.2f", $1 / $2}' <<< "$mem_total 1024")
            mem_label=GiB
        ;;

        kib)
            mem_used=$((mem_used * 1024))
            mem_total=$((mem_total * 1024))
            mem_label=KiB
        ;;
    esac

    memory="${mem_used}${mem_label:-MiB} / ${mem_total}${mem_label:-MiB} ${mem_perc:+(${mem_perc}%)}"

    # Bars.
    case $memory_display in
        "bar")     memory="$(bar "${mem_used}" "${mem_total}")" ;;
        "infobar") memory="${memory} $(bar "${mem_used}" "${mem_total}")" ;;
        "barinfo") memory="$(bar "${mem_used}" "${mem_total}")${info_color} ${memory}" ;;
    esac
}

get_disk() {
    type -p df &>/dev/null ||
        { err "Disk requires 'df' to function. Install 'df' to get disk info."; return; }

    df_version=$(df --version 2>&1)

    case $df_version in
        *IMitv*)   df_flags=(-P -g) ;; # AIX
        *befhikm*) df_flags=(-P -k) ;; # IRIX
        *hiklnP*)  df_flags=(-h)    ;; # OpenBSD

        *Tracker*) # Haiku
            err "Your version of df cannot be used due to the non-standard flags"
            return
        ;;

        *) df_flags=(-P -h) ;;
    esac

    # Create an array called 'disks' where each element is a separate line from
    # df's output. We then unset the first element which removes the column titles.
    IFS=$'\n' read -d "" -ra disks <<< "$(df "${df_flags[@]}" "${disk_show[@]:-/}")"
    unset "disks[0]"

    # Stop here if 'df' fails to print disk info.
    [[ ${disks[*]} ]] || {
        err "Disk: df failed to print the disks, make sure the disk_show array is set properly."
        return
    }

    for disk in "${disks[@]}"; do
        # Create a second array and make each element split at whitespace this time.
        IFS=" " read -ra disk_info <<< "$disk"
        disk_perc=${disk_info[${#disk_info[@]} - 2]/\%}

        case $disk_percent in
            off) disk_perc=
        esac

        case $df_version in
            *befhikm*)
                disk=$((disk_info[${#disk_info[@]} - 4] / 1024 / 1024))G
                disk+=" / "
                disk+=$((disk_info[${#disk_info[@]} - 5] / 1024/ 1024))G
                disk+=${disk_perc:+ ($disk_perc%)}
            ;;

            *)
                disk=${disk_info[${#disk_info[@]} - 4]/i}
                disk+=" / "
                disk+=${disk_info[${#disk_info[@]} - 5]/i}
                disk+=${disk_perc:+ ($disk_perc%)}
            ;;
        esac

        case $disk_subtitle in
            name)
                disk_sub=${disk_info[*]::${#disk_info[@]} - 5}
            ;;

            dir)
                disk_sub=${disk_info[${#disk_info[@]} - 1]/*\/}
                disk_sub=${disk_sub:-${disk_info[${#disk_info[@]} - 1]}}
            ;;

            none) ;;

            *)
                disk_sub=${disk_info[${#disk_info[@]} - 1]}
            ;;
        esac

        case $disk_display in
            bar)     disk="$(bar "$disk_perc" "100")" ;;
            infobar) disk+=" $(bar "$disk_perc" "100")" ;;
            barinfo) disk="$(bar "$disk_perc" "100")${info_color} $disk" ;;
            perc)    disk="${disk_perc}% $(bar "$disk_perc" "100")" ;;
        esac

        # Append '(disk mount point)' to the subtitle.
        if [[ "$subtitle" ]]; then
            prin "$subtitle${disk_sub:+ ($disk_sub)}" "$disk"
        else
            prin "$disk_sub" "$disk"
        fi
    done
}

get_battery() {
    case $os in
        "Linux")
            # We use 'prin' here so that we can do multi battery support
            # with a single battery per line.
            for bat in "/sys/class/power_supply/"{BAT,axp288_fuel_gauge,CMB}*; do
                capacity="$(< "${bat}/capacity")"
                status="$(< "${bat}/status")"

                if [[ "$capacity" ]]; then
                    battery="${capacity}% [${status}]"

                    case $battery_display in
                        "bar")     battery="$(bar "$capacity" 100)" ;;
                        "infobar") battery+=" $(bar "$capacity" 100)" ;;
                        "barinfo") battery="$(bar "$capacity" 100)${info_color} ${battery}" ;;
                    esac

                    bat="${bat/*axp288_fuel_gauge}"
                    prin "${subtitle:+${subtitle}${bat: -1}}" "$battery"
                fi
            done
            return
        ;;

        "BSD")
            case $kernel_name in
                "FreeBSD"* | "DragonFly"*)
                    battery="$(acpiconf -i 0 | awk -F ':\t' '/Remaining capacity/ {print $2}')"
                    battery_state="$(acpiconf -i 0 | awk -F ':\t\t\t' '/State/ {print $2}')"
                ;;

                "NetBSD"*)
                    battery="$(envstat | awk '\\(|\\)' '/charge:/ {print $2}')"
                    battery="${battery/\.*/%}"
                ;;

                "OpenBSD"* | "Bitrig"*)
                    battery0full="$(sysctl -n   hw.sensors.acpibat0.watthour0\
                                                hw.sensors.acpibat0.amphour0)"
                    battery0full="${battery0full%% *}"

                    battery0now="$(sysctl -n    hw.sensors.acpibat0.watthour3\
                                                hw.sensors.acpibat0.amphour3)"
                    battery0now="${battery0now%% *}"

                    state="$(sysctl -n hw.sensors.acpibat0.raw0)"
                    state="${state##? (battery }"
                    state="${state%)*}"

                    [[ "${state}" == "charging" ]] && battery_state="charging"
                    [[ "$battery0full" ]] && \
                    battery="$((100 * ${battery0now/\.} / ${battery0full/\.}))%"
                ;;
            esac
        ;;

        "Mac OS X"|"macOS")
            battery="$(pmset -g batt | grep -o '[0-9]*%')"
            state="$(pmset -g batt | awk '/;/ {print $4}')"
            [[ "$state" == "charging;" ]] && battery_state="charging"
        ;;

        "Windows")
            battery="$(wmic Path Win32_Battery get EstimatedChargeRemaining)"
            battery="${battery/EstimatedChargeRemaining}"
            battery="$(trim "$battery")%"
            state="$(wmic /NameSpace:'\\root\WMI' Path BatteryStatus get Charging)"
            state="${state/Charging}"
            [[ "$state" == *TRUE* ]] && battery_state="charging"
        ;;

        "Haiku")
            battery0full="$(awk -F '[^0-9]*' 'NR==2 {print $4}' /dev/power/acpi_battery/0)"
            battery0now="$(awk -F '[^0-9]*' 'NR==5 {print $4}' /dev/power/acpi_battery/0)"
            battery="$((battery0full * 100 / battery0now))%"
        ;;
    esac

    [[ "$battery_state" ]] && battery+=" Charging"

    case $battery_display in
        "bar")     battery="$(bar "${battery/\%*}" 100)" ;;
        "infobar") battery="${battery} $(bar "${battery/\%*}" 100)" ;;
        "barinfo") battery="$(bar "${battery/\%*}" 100)${info_color} ${battery}" ;;
    esac
}

get_local_ip() {
    case $os in
        "Linux" | "BSD" | "Solaris" | "AIX" | "IRIX")
            if [[ "${local_ip_interface[0]}" == "auto" ]]; then
                local_ip="$(ip route get 1 | awk -F'src' '{print $2; exit}')"
                local_ip="${local_ip/uid*}"
                [[ "$local_ip" ]] || local_ip="$(ifconfig -a | awk '/broadcast/ {print $2; exit}')"
            else
                for interface in "${local_ip_interface[@]}"; do
                    local_ip="$(ip addr show "$interface" 2> /dev/null |
                        awk '/inet / {print $2; exit}')"
                    local_ip="${local_ip/\/*}"
                    [[ "$local_ip" ]] ||
                        local_ip="$(ifconfig "$interface" 2> /dev/null |
                        awk '/broadcast/ {print $2; exit}')"
                    if [[ -n "$local_ip" ]]; then
                        prin "$interface" "$local_ip"
                    else
                        err "Local IP: Could not detect local ip for $interface"
                    fi
                done
            fi
        ;;

        "MINIX")
            local_ip="$(ifconfig | awk '{printf $3; exit}')"
        ;;

        "Mac OS X" | "macOS" | "iPhone OS")
            if [[ "${local_ip_interface[0]}" == "auto" ]]; then
                interface="$(route get 1 | awk -F': ' '/interface/ {printf $2; exit}')"
                local_ip="$(ipconfig getifaddr "$interface")"
            else
                for interface in "${local_ip_interface[@]}"; do
                    local_ip="$(ipconfig getifaddr "$interface")"
                    if [[ -n "$local_ip" ]]; then
                        prin "$interface" "$local_ip"
                    else
                        err "Local IP: Could not detect local ip for $interface"
                    fi
                done
            fi
        ;;

        "Windows")
            local_ip="$(ipconfig | awk -F ': ' '/IPv4 Address/ {printf $2 ", "}')"
            local_ip="${local_ip%\,*}"
        ;;

        "Haiku")
            local_ip="$(ifconfig | awk -F ': ' '/Bcast/ {print $2}')"
            local_ip="${local_ip/, Bcast}"
        ;;
    esac
}

get_public_ip() {
    if [[ ! -n "$public_ip_host" ]] && type -p dig >/dev/null; then
        public_ip="$(dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com)"
       [[ "$public_ip" =~ ^\; ]] && unset public_ip
    fi

    if [[ ! -n "$public_ip_host" ]] && [[ -z "$public_ip" ]] && type -p drill >/dev/null; then
        public_ip="$(drill myip.opendns.com @resolver1.opendns.com | \
                     awk '/^myip\./ && $3 == "IN" {print $5}')"
    fi

    if [[ -z "$public_ip" ]] && type -p curl >/dev/null; then
        public_ip="$(curl -L --max-time "$public_ip_timeout" -w '\n' "$public_ip_host")"
    fi

    if [[ -z "$public_ip" ]] && type -p wget >/dev/null; then
        public_ip="$(wget -T "$public_ip_timeout" -qO- "$public_ip_host")"
    fi
}

get_users() {
    users="$(echo $ROS_MASTER_URI | awk '{print $0}')"
    users="${users%\,*}"
}
get_users1() {
    users1="$(sensors | grep "Tctl" | awk '{print $2 $3}')"
    users1="${users1%\,*}"
}
get_users2() {
    users2="$(sensors | grep "in0" | awk '{print $2 $3}')"
    users2="${users2%\,*}"
}


get_cols() {
    local blocks blocks2 cols

    if [[ "$color_blocks" == "on" ]]; then
        # Convert the width to space chars.
        printf -v block_width "%${block_width}s"

        # Generate the string.
        for ((block_range[0]; block_range[0]<=block_range[1]; block_range[0]++)); do
            case ${block_range[0]} in
                [0-7])
                    printf -v blocks  '%b\e[3%bm\e[4%bm%b' \
                        "$blocks" "${block_range[0]}" "${block_range[0]}" "$block_width"
                ;;

                *)
                    printf -v blocks2 '%b\e[38;5;%bm\e[48;5;%bm%b' \
                        "$blocks2" "${block_range[0]}" "${block_range[0]}" "$block_width"
                ;;
            esac
        done

        # Convert height into spaces.
        printf -v block_spaces "%${block_height}s"

        # Convert the spaces into rows of blocks.
        [[ "$blocks"  ]] && cols+="${block_spaces// /${blocks}[mnl}"
        [[ "$blocks2" ]] && cols+="${block_spaces// /${blocks2}[mnl}"

        # Add newlines to the string.
        cols=${cols%%nl}
        cols=${cols//nl/
[${text_padding}C${zws}}

        # Add block height to info height.
        ((info_height+=block_range[1]>7?block_height+2:block_height+1))

        case $col_offset in
            "auto") printf '\n\e[%bC%b\n' "$text_padding" "${zws}${cols}" ;;
            *) printf '\n\e[%bC%b\n' "$col_offset" "${zws}${cols}" ;;
        esac
    fi

    unset -v blocks blocks2 cols

    # Tell info() that we printed manually.
    prin=1
}

# IMAGES

image_backend() {
    [[ "$image_backend" != "off" ]] && ! type -p convert &>/dev/null && \
        { image_backend="ascii"; err "Image: Imagemagick not found, falling back to ascii mode."; }

    case ${image_backend:-off} in
        "ascii") print_ascii ;;
        "off") image_backend="off" ;;

        "caca" | "catimg" | "chafa" | "jp2a" | "iterm2" | "termpix" |\
        "tycat" | "w3m" | "sixel" | "pixterm" | "kitty" | "pot", | "ueberzug" |\
         "viu")
            get_image_source

            [[ ! -f "$image" ]] && {
                to_ascii "Image: '$image_source' doesn't exist, falling back to ascii mode."
                return
            }
            [[ "$image_backend" == "ueberzug" ]] && wait=true;

            get_window_size

            ((term_width < 1)) && {
                to_ascii "Image: Failed to find terminal window size."
                err "Image: Check the 'Images in the terminal' wiki page for more info,"
                return
            }

            printf '\e[2J\e[H'
            get_image_size
            make_thumbnail
            display_image || to_off "Image: $image_backend failed to display the image."
        ;;

        *)
            err "Image: Unknown image backend specified '$image_backend'."
            err "Image: Valid backends are: 'ascii', 'caca', 'catimg', 'chafa', 'jp2a', 'iterm2',
                                            'kitty', 'off', 'sixel', 'pot', 'pixterm', 'termpix',
                                            'tycat', 'w3m', 'viu')"
            err "Image: Falling back to ascii mode."
            print_ascii
        ;;
    esac

    # Set cursor position next image/ascii.
    [[ "$image_backend" != "off" ]] && printf '\e[%sA\e[9999999D' "${lines:-0}"
}

print_ascii() {
    if [[ -f "$image_source" && ! "$image_source" =~ (png|jpg|jpeg|jpe|svg|gif) ]]; then
        ascii_data="$(< "$image_source")"
    elif [[ "$image_source" == "ascii" || $image_source == auto ]]; then
        :
    else
        ascii_data="$image_source"
    fi

    # Set locale to get correct padding.
    LC_ALL="$sys_locale"

    # Calculate size of ascii file in line length / line count.
    while IFS=$'\n' read -r line; do
        line=${line//\\\\/\\}
        line=${line//█/ }
        ((++lines,${#line}>ascii_len)) && ascii_len="${#line}"
    done <<< "${ascii_data//\$\{??\}}"

    # Fallback if file not found.
    ((lines==1)) && {
        lines=
        ascii_len=
        image_source=auto
        get_distro_ascii
        print_ascii
        return
    }

    # Colors.
    ascii_data="${ascii_data//\$\{c1\}/$c1}"
    ascii_data="${ascii_data//\$\{c2\}/$c2}"
    ascii_data="${ascii_data//\$\{c3\}/$c3}"
    ascii_data="${ascii_data//\$\{c4\}/$c4}"
    ascii_data="${ascii_data//\$\{c5\}/$c5}"
    ascii_data="${ascii_data//\$\{c6\}/$c6}"

    ((text_padding=ascii_len+gap))
    printf '%b\n' "$ascii_data${reset}"
    LC_ALL=C
}

get_image_source() {
    case $image_source in
        "auto" | "wall" | "wallpaper")
            get_wallpaper
        ;;

        *)
            # Get the absolute path.
            image_source="$(get_full_path "$image_source")"

            if [[ -d "$image_source" ]]; then
                shopt -s nullglob
                files=("${image_source%/}"/*.{png,jpg,jpeg,jpe,gif,svg})
                shopt -u nullglob
                image="${files[RANDOM % ${#files[@]}]}"

            else
                image="$image_source"
            fi
        ;;
    esac

    err "Image: Using image '$image'"
}

get_w3m_img_path() {
    # Find w3m-img path.
    shopt -s nullglob
    w3m_paths=({/usr/{local/,},~/.nix-profile/}{lib,libexec,lib64,libexec64}/w3m/w3mi*)
    shopt -u nullglob

    [[ -x "${w3m_paths[0]}" ]] && \
        { w3m_img_path="${w3m_paths[0]}"; return; }

    err "Image: w3m-img wasn't found on your system"
}

get_window_size() {
    # This functions gets the current window size in
    # pixels.
    #
    # We first try to use the escape sequence "\033[14t"
    # to get the terminal window size in pixels. If this
    # fails we then fallback to using "xdotool" or other
    # programs.

    # Tmux has a special way of reading escape sequences
    # so we have to use a slightly different sequence to
    # get the terminal size.
    if [[ "$image_backend" == "tycat" ]]; then
        printf '%b' '\e}qs\000'

    elif [[ -z $VTE_VERSION ]]; then
        case ${TMUX:-null} in
            "null") printf '%b' '\e[14t' ;;
            *)      printf '%b' '\ePtmux;\e\e[14t\e\\ ' ;;
        esac
    fi

    # The escape codes above print the desired output as
    # user input so we have to use read to store the out
    # -put as a variable.
    # The 1 second timeout is required for older bash
    #
    # False positive.
    # shellcheck disable=2141
    case $bash_version in
        4|5) IFS=';t' read -d t -t 0.05 -sra term_size ;;
        *)   IFS=';t' read -d t -t 1 -sra term_size ;;
    esac
    unset IFS

    # Split the string into height/width.
    if [[ "$image_backend" == "tycat" ]]; then
        term_width="$((term_size[2] * term_size[0]))"
        term_height="$((term_size[3] * term_size[1]))"

    else
        term_height="${term_size[1]}"
        term_width="${term_size[2]}"
    fi

    # Get terminal width/height.
    if (( "${term_width:-0}" < 50 )) && [[ "$DISPLAY" && $os != "Mac OS X" && $os != "macOS" ]]; then
        if type -p xdotool &>/dev/null; then
            IFS=$'\n' read -d "" -ra win \
                <<< "$(xdotool getactivewindow getwindowgeometry --shell %1)"
            term_width="${win[3]/WIDTH=}"
            term_height="${win[4]/HEIGHT=}"

        elif type -p xwininfo &>/dev/null; then
            # Get the focused window's ID.
            if type -p xdo &>/dev/null; then
                current_window="$(xdo id)"

            elif type -p xprop &>/dev/null; then
                current_window="$(xprop -root _NET_ACTIVE_WINDOW)"
                current_window="${current_window##* }"

            elif type -p xdpyinfo &>/dev/null; then
                current_window="$(xdpyinfo | grep -F "focus:")"
                current_window="${current_window/*window }"
                current_window="${current_window/,*}"
            fi

            # If the ID was found get the window size.
            if [[ "$current_window" ]]; then
                term_size=("$(xwininfo -id "$current_window")")
                term_width="${term_size[0]#*Width: }"
                term_width="${term_width/$'\n'*}"
                term_height="${term_size[0]/*Height: }"
                term_height="${term_height/$'\n'*}"
            fi
        fi
    fi

    term_width="${term_width:-0}"
}


get_term_size() {
    # Get the terminal size in cells.
    read -r lines columns <<< "$(stty size)"

    # Calculate font size.
    font_width="$((term_width / columns))"
    font_height="$((term_height / lines))"
}

get_image_size() {
    # This functions determines the size to make the thumbnail image.
    get_term_size

    case $image_size in
        "auto")
            image_size="$((columns * font_width / 2))"
            term_height="$((term_height - term_height / 4))"

            ((term_height < image_size)) && \
                image_size="$term_height"
        ;;

        *"%")
            percent="${image_size/\%}"
            image_size="$((percent * term_width / 100))"

            (((percent * term_height / 50) < image_size)) && \
                image_size="$((percent * term_height / 100))"
        ;;

        "none")
            # Get image size so that we can do a better crop.
            read -r width height <<< "$(identify -format "%w %h" "$image")"

            while ((width >= (term_width / 2) || height >= term_height)); do
                ((width=width/2,height=height/2))
            done

            crop_mode="none"
        ;;

        *)  image_size="${image_size/px}" ;;
    esac

    # Check for terminal padding.
    [[ "$image_backend" == "w3m" ]] && term_padding

    width="${width:-$image_size}"
    height="${height:-$image_size}"
    text_padding="$(((width + padding + xoffset) / font_width + gap))"
}

make_thumbnail() {
    # Name the thumbnail using variables so we can
    # use it later.
    image_name="${crop_mode}-${crop_offset}-${width}-${height}-${image//\/}"

    # Handle file extensions.
    case ${image##*.} in
        "eps"|"pdf"|"svg"|"gif"|"png")
            image_name+=".png" ;;
        *)  image_name+=".jpg" ;;
    esac

    # Create the thumbnail dir if it doesn't exist.
    mkdir -p "${thumbnail_dir:=${XDG_CACHE_HOME:-${HOME}/.cache}/thumbnails/neofetch}"

    if [[ ! -f "${thumbnail_dir}/${image_name}" ]]; then
        # Get image size so that we can do a better crop.
        [[ -z "$size" ]] && {
            read -r og_width og_height <<< "$(identify -format "%w %h" "$image")"
            ((og_height > og_width)) && size="$og_width" || size="$og_height"
        }

        case $crop_mode in
            "fit")
                c="$(convert "$image" \
                    -colorspace srgb \
                    -format "%[pixel:p{0,0}]" info:)"

                convert \
                    -background none \
                    "$image" \
                    -trim +repage \
                    -gravity south \
                    -background "$c" \
                    -extent "${size}x${size}" \
                    -scale "${width}x${height}" \
                    "${thumbnail_dir}/${image_name}"
            ;;

            "fill")
                convert \
                    -background none \
                    "$image" \
                    -trim +repage \
                    -scale "${width}x${height}^" \
                    -extent "${width}x${height}" \
                    "${thumbnail_dir}/${image_name}"
            ;;

            "none")
                cp "$image" "${thumbnail_dir}/${image_name}"
            ;;

            *)
                convert \
                    -background none \
                    "$image" \
                    -strip \
                    -gravity "$crop_offset" \
                    -crop "${size}x${size}+0+0" \
                    -scale "${width}x${height}" \
                    "${thumbnail_dir}/${image_name}"
            ;;
        esac
    fi

    # The final image.
    image="${thumbnail_dir}/${image_name}"
}

display_image() {
    case $image_backend in
        "caca")
            img2txt \
                -W "$((width / font_width))" \
                -H "$((height / font_height))" \
                --gamma=0.6 \
            "$image"
        ;;


        "ueberzug")
            if [ "$wait" = true ];then
                wait=false;
            else
                ueberzug layer --parser bash 0< <(
                    declare -Ap ADD=(\
                        [action]="add"\
                        [identifier]="neofetch"\
                        [x]=$xoffset [y]=$yoffset\
                        [path]=$image\
                    )
                    read -rs
                )
            fi
        ;;

        "catimg")
            catimg -w "$((width*catimg_size / font_width))" -r "$catimg_size" "$image"
        ;;

        "chafa")
            chafa --stretch --size="$((width / font_width))x$((height / font_height))" "$image"
        ;;

        "jp2a")
            jp2a \
                --colors \
                --width="$((width / font_width))" \
                --height="$((height / font_height))" \
            "$image"
        ;;

        "kitty")
            kitty +kitten icat \
                --align left \
                --place "$((width/font_width))x$((height/font_height))@${xoffset}x${yoffset}" \
            "$image"
        ;;

        "pot")
            pot \
                "$image" \
                --size="$((width / font_width))x$((height / font_height))"
        ;;

        "pixterm")
            pixterm \
                -tc "$((width / font_width))" \
                -tr "$((height / font_height))" \
            "$image"
        ;;

        "sixel")
            img2sixel \
                -w "$width" \
                -h "$height" \
            "$image"
        ;;

        "termpix")
            termpix \
                --width "$((width / font_width))" \
                --height "$((height / font_height))" \
            "$image"
        ;;

        "iterm2")
            printf -v iterm_cmd '\e]1337;File=width=%spx;height=%spx;inline=1:%s' \
                "$width" "$height" "$(base64 < "$image")"

            # Tmux requires an additional escape sequence for this to work.
            [[ -n "$TMUX" ]] && printf -v iterm_cmd '\ePtmux;\e%b\e'\\ "$iterm_cmd"

            printf '%b\a\n' "$iterm_cmd"
        ;;

        "tycat")
            tycat \
                -g "${width}x${height}" \
            "$image"
        ;;

        "viu")
            viu \
                -t -w "$((width / font_width))" -h "$((height / font_height))" \
            "$image"
        ;;

        "w3m")
            get_w3m_img_path
            zws='\xE2\x80\x8B\x20'

            # Add a tiny delay to fix issues with images not
            # appearing in specific terminal emulators.
            ((bash_version>3)) && sleep 0.05
            printf '%b\n%s;\n%s\n' "0;1;$xoffset;$yoffset;$width;$height;;;;;$image" 3 4 |\
            "${w3m_img_path:-false}" -bg "$background_color" &>/dev/null
        ;;
    esac
}

to_ascii() {
    err "$1"
    image_backend="ascii"
    print_ascii

    # Set cursor position next image/ascii.
    printf '\e[%sA\e[9999999D' "${lines:-0}"
}

to_off() {
    err "$1"
    image_backend="off"
    text_padding=
}


# TEXT FORMATTING

info() {
    # Save subtitle value.
    [[ "$2" ]] && subtitle="$1"

    # Make sure that $prin is unset.
    unset -v prin

    # Call the function.
    "get_${2:-$1}"

    # If the get_func function called 'prin' directly, stop here.
    [[ "$prin" ]] && return

    # Update the variable.
    if [[ "$2" ]]; then
        output="$(trim "${!2}")"
    else
        output="$(trim "${!1}")"
    fi

    if [[ "$2" && "${output// }" ]]; then
        prin "$1" "$output"

    elif [[ "${output// }" ]]; then
        prin "$output"

    else
        err "Info: Couldn't detect ${1}."
    fi

    unset -v subtitle
}

prin() {
    # If $2 doesn't exist we format $1 as info.
    if [[ "$(trim "$1")" && "$2" ]]; then
        [[ "$json" ]] && { printf '    %s\n' "\"${1}\": \"${2}\","; return; }

        string="${1}${2:+: $2}"
    else
        string="${2:-$1}"
        local subtitle_color="$info_color"
    fi

    string="$(trim "${string//$'\e[0m'}")"
    length="$(strip_sequences "$string")"
    length="${#length}"

    # Format the output.
    string="${string/:/${reset}${colon_color}${separator:=:}${info_color}}"
    string="${subtitle_color}${bold}${string}"

    # Print the info.
    printf '%b\n' "${text_padding:+\e[${text_padding}C}${zws}${string//\\n}${reset} "

    # Calculate info height.
    ((++info_height))

    # Log that prin was used.
    prin=1
}

get_underline() {
    [[ "$underline_enabled" == "on" ]] && {
        printf -v underline "%${length}s"
        printf '%b%b\n' "${text_padding:+\e[${text_padding}C}${zws}${underline_color}" \
                        "${underline// /$underline_char}${reset} "
    }

    ((++info_height))
    length=
    prin=1
}

get_bold() {
    case $ascii_bold in
        "on")  ascii_bold='\e[1m' ;;
        "off") ascii_bold="" ;;
    esac

    case $bold in
        "on")  bold='\e[1m' ;;
        "off") bold="" ;;
    esac
}

trim() {
    set -f
    # shellcheck disable=2048,2086
    set -- $*
    printf '%s\n' "${*//[[:space:]]/}"
    set +f
}

trim_quotes() {
    trim_output="${1//\'}"
    trim_output="${trim_output//\"}"
    printf "%s" "$trim_output"
}

strip_sequences() {
    strip="${1//$'\e['3[0-9]m}"
    strip="${strip//$'\e['[0-9]m}"
    strip="${strip//\\e\[[0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9]m}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9][0-9]m}"

    printf '%s\n' "$strip"
}

# COLORS

set_colors() {
    c1="$(color "$1")${ascii_bold}"
    c2="$(color "$2")${ascii_bold}"
    c3="$(color "$3")${ascii_bold}"
    c4="$(color "$4")${ascii_bold}"
    c5="$(color "$5")${ascii_bold}"
    c6="$(color "$6")${ascii_bold}"

    [[ "$color_text" != "off" ]] && set_text_colors "$@"
}

set_text_colors() {
    if [[ "${colors[0]}" == "distro" ]]; then
        title_color="$(color "$1")"
        at_color="$reset"
        underline_color="$reset"
        subtitle_color="$(color "$2")"
        colon_color="$reset"
        info_color="$reset"

        # If the ascii art uses 8 as a color, make the text the fg.
        ((${1:-1} == 8)) && title_color="$reset"
        ((${2:-7} == 8)) && subtitle_color="$reset"

        # If the second color is white use the first for the subtitle.
        ((${2:-7} == 7)) && subtitle_color="$(color "$1")"
        ((${1:-1} == 7)) && title_color="$reset"
    else
        title_color="$(color "${colors[0]}")"
        at_color="$(color "${colors[1]}")"
        underline_color="$(color "${colors[2]}")"
        subtitle_color="$(color "${colors[3]}")"
        colon_color="$(color "${colors[4]}")"
        info_color="$(color "${colors[5]}")"
    fi

    # Bar colors.
    if [[ "$bar_color_elapsed" == "distro" ]]; then
        bar_color_elapsed="$(color fg)"
    else
        bar_color_elapsed="$(color "$bar_color_elapsed")"
    fi

    case ${bar_color_total}${1} in
        distro[736]) bar_color_total=$(color "$1") ;;
        distro[0-9]) bar_color_total=$(color "$2") ;;
        *)           bar_color_total=$(color "$bar_color_total") ;;
    esac
}

color() {
    case $1 in
        [0-6])    printf '%b\e[3%sm'   "$reset" "$1" ;;
        7 | "fg") printf '\e[37m%b'    "$reset" ;;
        *)        printf '\e[38;5;%bm' "$1" ;;
    esac
}

# OTHER

stdout() {
    image_backend="off"
    unset subtitle_color colon_color info_color underline_color bold title_color at_color \
          text_padding zws reset color_blocks bar_color_elapsed bar_color_total \
          c1 c2 c3 c4 c5 c6 c7 c8
}

err() {
    err+="$(color 1)[!]${reset} $1
"
}

get_full_path() {
    # This function finds the absolute path from a relative one.
    # For example "Pictures/Wallpapers" --> "/home/dylan/Pictures/Wallpapers"

    # If the file exists in the current directory, stop here.
    [[ -f "${PWD}/${1}" ]] && { printf '%s\n' "${PWD}/${1}"; return; }

    ! cd "${1%/*}" && {
        err "Error: Directory '${1%/*}' doesn't exist or is inaccessible"
        err "       Check that the directory exists or try another directory."
        exit 1
    }

    local full_dir="${1##*/}"

    # Iterate down a (possible) chain of symlinks.
    while [[ -L "$full_dir" ]]; do
        full_dir="$(readlink "$full_dir")"
        cd "${full_dir%/*}" || exit
        full_dir="${full_dir##*/}"
    done

    # Final directory.
    full_dir="$(pwd -P)/${1/*\/}"

    [[ -e "$full_dir" ]] && printf '%s\n' "$full_dir"
}

get_user_config() {
    # --config /path/to/config.conf
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        err "Config: Sourced user config. (${config_file})"
        return

    elif [[ -f "${XDG_CONFIG_HOME}/neofetch/config.conf" ]]; then
        source "${XDG_CONFIG_HOME}/neofetch/config.conf"
        err "Config: Sourced user config.    (${XDG_CONFIG_HOME}/neofetch/config.conf)"

    elif [[ -f "${XDG_CONFIG_HOME}/neofetch/config" ]]; then
        source "${XDG_CONFIG_HOME}/neofetch/config"
        err "Config: Sourced user config.    (${XDG_CONFIG_HOME}/neofetch/config)"

    elif [[ -z "$no_config" ]]; then
        config_file="${XDG_CONFIG_HOME}/neofetch/config.conf"

        # The config file doesn't exist, create it.
        mkdir -p "${XDG_CONFIG_HOME}/neofetch/"
        printf '%s\n' "$config" > "$config_file"
    fi
}

bar() {
    # Get the values.
    elapsed="$(($1 * bar_length / $2))"

    # Create the bar with spaces.
    printf -v prog  "%${elapsed}s"
    printf -v total "%$((bar_length - elapsed))s"

    # Set the colors and swap the spaces for $bar_char_.
    bar+="${bar_color_elapsed}${prog// /${bar_char_elapsed}}"
    bar+="${bar_color_total}${total// /${bar_char_total}}"

    # Borders.
    [[ "$bar_border" == "on" ]] && \
        bar="$(color fg)[${bar}$(color fg)]"

    printf "%b" "${bar}${info_color}"
}

cache() {
    if [[ "$2" ]]; then
        mkdir -p "${cache_dir}/neofetch"
        printf "%s" "${1/*-}=\"$2\"" > "${cache_dir}/neofetch/${1/*-}"
    fi
}

get_cache_dir() {
    case $os in
        "Mac OS X"|"macOS") cache_dir="/Library/Caches" ;;
        *)          cache_dir="/tmp" ;;
    esac
}

kde_config_dir() {
    # If the user is using KDE get the KDE
    # configuration directory.
    if [[ "$kde_config_dir" ]]; then
        return

    elif type -p kf5-config &>/dev/null; then
        kde_config_dir="$(kf5-config --path config)"

    elif type -p kde4-config &>/dev/null; then
        kde_config_dir="$(kde4-config --path config)"

    elif type -p kde-config &>/dev/null; then
        kde_config_dir="$(kde-config --path config)"

    elif [[ -d "${HOME}/.kde4" ]]; then
        kde_config_dir="${HOME}/.kde4/share/config"

    elif [[ -d "${HOME}/.kde3" ]]; then
        kde_config_dir="${HOME}/.kde3/share/config"
    fi

    kde_config_dir="${kde_config_dir/$'/:'*}"
}

term_padding() {
    # Get terminal padding to properly align cursor.
    [[ -z "$term" ]] && get_term

    case $term in
        urxvt*|rxvt-unicode)
            [[ $xrdb ]] || xrdb=$(xrdb -query)

            [[ $xrdb != *internalBorder:* ]] &&
                return

            padding=${xrdb/*internalBorder:}
            padding=${padding/$'\n'*}

            [[ $padding =~ ^[0-9]+$ ]] ||
                padding=
        ;;
    esac
}

dynamic_prompt() {
    [[ "$image_backend" == "off" ]]   && { printf '\n'; return; }
    [[ "$image_backend" != "ascii" ]] && ((lines=(height + yoffset) / font_height + 1))
    [[ "$image_backend" == "w3m" ]]   && ((lines=lines + padding / font_height + 1))

    # If the ascii art is taller than the info.
    ((lines=lines>info_height?lines-info_height+1:1))

    printf -v nlines "%${lines}s"
    printf "%b" "${nlines// /\\n}"
}

cache_uname() {
    # Cache the output of uname so we don't
    # have to spawn it multiple times.
    IFS=" " read -ra uname <<< "$(uname -srm)"

    kernel_name="${uname[0]}"
    kernel_version="${uname[1]}"
    kernel_machine="${uname[2]}"

    if [[ "$kernel_name" == "Darwin" ]]; then
        # macOS can report incorrect versions unless this is 0.
        # https://github.com/dylanaraps/neofetch/issues/1607
        export SYSTEM_VERSION_COMPAT=0

        IFS=$'\n' read -d "" -ra sw_vers <<< "$(awk -F'<|>' '/key|string/ {print $3}' \
                            "/System/Library/CoreServices/SystemVersion.plist")"
        for ((i=0;i<${#sw_vers[@]};i+=2)) {
            case ${sw_vers[i]} in
                ProductName)          darwin_name=${sw_vers[i+1]} ;;
                ProductVersion)       osx_version=${sw_vers[i+1]} ;;
                ProductBuildVersion)  osx_build=${sw_vers[i+1]}   ;;
            esac
        }
    fi
}

get_ppid() {
    # Get parent process ID of PID.
    case $os in
        "Windows")
            ppid="$(ps -p "${1:-$PPID}" | awk '{printf $2}')"
            ppid="${ppid/PPID}"
        ;;

        "Linux")
            ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
            ppid="$(trim "${ppid/PPid:}")"
        ;;

        *)
            ppid="$(ps -p "${1:-$PPID}" -o ppid=)"
        ;;
    esac

    printf "%s" "$ppid"
}

get_process_name() {
    # Get PID name.
    case $os in
        "Windows")
            name="$(ps -p "${1:-$PPID}" | awk '{printf $8}')"
            name="${name/COMMAND}"
            name="${name/*\/}"
        ;;

        "Linux")
            name="$(< "/proc/${1:-$PPID}/comm")"
        ;;

        *)
            name="$(ps -p "${1:-$PPID}" -o comm=)"
        ;;
    esac

    printf "%s" "$name"
}

decode_url() {
    decode="${1//+/ }"
    printf "%b" "${decode//%/\\x}"
}

get_simple() {
    while [[ "$1" ]]; do
        [[ "$(type -t "get_$1")" == "function" ]] && {
            get_distro
            stdout
            simple=1
            info "$1" "$1"
        }
        shift
    done
    ((simple)) && exit
}

old_functions() {
    get_line_break() { :; }
    get_cpu_usage() { :; }
}

get_distro_ascii() {

    case $(trim "$ascii_distro") in
            "Ubuntu"* | "i3buntu"*)
            set_colors 1 7 3
            read -rd '' ascii_data <<'EOF'
${c1}                                  =--:::::=                             
                                =--=      =:                            
                               :=:          :                           
                   ***        -=             :                          
              =:==**#**==    -=               :                         
             -:    ***    ==-=:               :                         
            --             ==: ====            =                        
            --             ==      ===     ====-=====-***              
            ==            :==      =:-:--:=====-:====**#**---=          
             -=           =========     =:=    :=     ***  =-==:        
              ==       ==:=:              ::= ==            :==-       
               -=  ====  -=    :++++++++:   :::=            ====       
                -=-      ==  ==++++++++++=     :-=           -===       
             === ==-    ==:   :----------:     ::=-=       =====        
           ==      -=:  :=:   -:-hhN--hhN-::     :=  :-    =-==:          
         =:         =-=:-==   -:-==--==-:-     -     -::===:            
        :=            =====    :--------=      -   =:===-               
       ==               -==-   =:------:=     :-:-==-: ==               
       ==               -=:-=-=  ======   ==:-==-:=     :==             
        :-:             :==  :==:    =:--==-::-          :=             
          :---::====  ==:=-=::-======-:==    -=           ==            
             ==::--------==-:::=  =-==:=    =-            ===           
                         ===         =-===-===           ====           
                         :=-             :-====-:======:-===            
                          ==:             -- =:-=========-:             
                          ====           --                             
                           :==:       ***                              
                            :==-:    **#**                              
                             =-=======***                               
                                =::=
EOF
      ;;

            esac
        
    

    # Overwrite distro colors if '$ascii_colors' doesn't
    # equal 'distro'.
    [[ ${ascii_colors[0]} != distro ]] && {
        color_text=off
        set_colors "${ascii_colors[@]}"
    }
}

main() {
    cache_uname
    get_os
    
    eval "$config"

    [[ $verbose != on ]] && exec 2>/dev/null
    get_simple "$@"
    get_distro
    get_bold
    get_distro_ascii
    [[ $stdout == on ]] && stdout

    # Minix doesn't support these sequences.
    [[ $TERM != minix && $stdout != on ]] && {
        # If the script exits for any reason, unhide the cursor.
        trap 'printf "\e[?25h\e[?7h"' EXIT

        # Hide the cursor and disable line wrap.
        printf '\e[?25l\e[?7l'
    }

    image_backend
    get_cache_dir
    old_functions
    print_info
    dynamic_prompt

    # w3m-img: Draw the image a second time to fix
    # rendering issues in specific terminal emulators.
    [[ $image_backend == *w3m* ]] && display_image
    [[ $image_backend == *ueberzug* ]] && display_image

    # Add neofetch info to verbose output.
    err "Neofetch command: $0 $*"
    err "Neofetch version: $version"

    [[ $verbose == on ]] && printf '%b\033[m' "$err" >&2

    # If `--loop` was used, constantly redraw the image.
    while [[ $image_loop == on && $image_backend == w3m ]]; do
        display_image
        sleep 1
    done

    return 0
}

main "$@"