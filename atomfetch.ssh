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
    info "Package id 0" users3
    info "Core 0" users4
    info "Core 1" users5
    info "Core 2" users6
    info "Core 3" users7

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
    Linux | GNU*)
        os=Linux
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
    Linux | BSD | MINIX)
        if [[ -f /bedrock/etc/bedrock-release && -z $BEDROCK_RESTRICT ]]; then
            case $distro_shorthand in
            on | tiny) distro="Bedrock Linux" ;;
            *) distro=$(</bedrock/etc/bedrock-release) ;;
            esac

        elif [[ -f /etc/redstar-release ]]; then
            case $distro_shorthand in
            on | tiny) distro="Red Star OS" ;;
            *) distro="Red Star OS $(awk -F'[^0-9*]' '$0=$2' /etc/redstar-release)" ;;
            esac

        elif [[ -f /etc/armbian-release ]]; then
            . /etc/armbian-release
            distro="Armbian $DISTRIBUTION_CODENAME (${VERSION:-})"

        elif [[ -f /etc/siduction-version ]]; then
            case $distro_shorthand in
            on | tiny) distro=Siduction ;;
            *) distro="Siduction ($(lsb_release -sic))" ;;
            esac

        elif [[ -f /etc/mcst_version ]]; then
            case $distro_shorthand in
            on | tiny) distro="OS Elbrus" ;;
            *) distro="OS Elbrus $(</etc/mcst_version)" ;;
            esac

        elif type -p pveversion >/dev/null; then
            case $distro_shorthand in
            on | tiny) distro="Proxmox VE" ;;
            *)
                distro=$(pveversion)
                distro=${distro#pve-manager/}
                distro="Proxmox VE ${distro%/*}"
                ;;
            esac

        elif type -p lsb_release >/dev/null; then
            case $distro_shorthand in
            on) lsb_flags=-si ;;
            tiny) lsb_flags=-si ;;
            *) lsb_flags=-sd ;;
            esac
            distro=$(lsb_release "$lsb_flags")

        elif [[ -f /etc/os-release ||
            -f /usr/lib/os-release ||
            -f /etc/openwrt_release ||
            -f /etc/lsb-release ]]; then

            # Source the os-release file
            for file in /etc/lsb-release /usr/lib/os-release \
                /etc/os-release /etc/openwrt_release; do
                source "$file" && break
            done

            # Format the distro name.
            case $distro_shorthand in
            on) distro="${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}" ;;
            tiny) distro="${NAME:-${DISTRIB_ID:-${TAILS_PRODUCT_NAME}}}" ;;
            off) distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}" ;;
            esac

        elif [[ -f /etc/GoboLinuxVersion ]]; then
            case $distro_shorthand in
            on | tiny) distro=GoboLinux ;;
            *) distro="GoboLinux $(</etc/GoboLinuxVersion)" ;;
            esac

        elif [[ -f /etc/SDE-VERSION ]]; then
            distro="$(</etc/SDE-VERSION)"
            case $distro_shorthand in
            on | tiny) distro="${distro% *}" ;;
            esac

        elif type -p crux >/dev/null; then
            distro=$(crux)
            case $distro_shorthand in
            on) distro=${distro//version/} ;;
            tiny) distro=${distro//version*/} ;;
            esac

        elif type -p tazpkg >/dev/null; then
            distro="SliTaz $(</etc/slitaz-release)"

        elif type -p kpt >/dev/null &&
            type -p kpm >/dev/null; then
            distro=KSLinux

        elif [[ -d /system/app/ && -d /system/priv-app ]]; then
            distro="Android $(getprop ro.build.version.release)"

.
        elif [[ -f /etc/lsb-release && $(</etc/lsb-release) == *CHROMEOS* ]]; then
            distro='Chrome OS'

        elif type -p guix >/dev/null; then
            case $distro_shorthand in
            on | tiny) distro="Guix System" ;;
            *) distro="Guix System $(guix -V | awk 'NR==1{printf $4}')" ;;
            esac

        elif [[ $kernel_name = OpenBSD ]]; then
            read -ra kernel_info <<<"$(sysctl -n kern.version)"
            distro=${kernel_info[*]:0:2}

        else
            for release_file in /etc/*-release; do
                distro+=$(<"$release_file")
            done

            if [[ -z $distro ]]; then
                case $distro_shorthand in
                on | tiny) distro=$kernel_name ;;
                *) distro="$kernel_name $kernel_version" ;;
                esac

                distro=${distro/DragonFly/DragonFlyBSD}

                # Workarounds for some BSD based distros.
                [[ -f /etc/pcbsd-lang ]] && distro=PCBSD
                [[ -f /etc/trueos-lang ]] && distro=TrueOS
                [[ -f /etc/pacbsd-release ]] && distro=PacBSD
                [[ -f /etc/hbsd-update.conf ]] && distro=HardenedBSD
            fi
        fi

        if [[ $(</proc/version) == *Microsoft* || $kernel_version == *Microsoft* ]]; then
            windows_version=$(wmic.exe os get Version)
            windows_version=$(trim "${windows_version/Version/}")

            case $distro_shorthand in
            on) distro+=" [Windows $windows_version]" ;;
            tiny) distro="Windows ${windows_version::2}" ;;
            *) distro+=" on Windows $windows_version" ;;
            esac

        elif [[ $(</proc/version) == *chrome-bot* || -f /dev/cros_ec ]]; then
            [[ $distro != *Chrome* ]] &&
                case $distro_shorthand in
                on) distro+=" [Chrome OS]" ;;
                tiny) distro="Chrome OS" ;;
                *) distro+=" on Chrome OS" ;;
                esac
            distro=${distro## on }
        fi

        distro=$(trim_quotes "$distro")
        distro=${distro/NAME=/}

        # Get Ubuntu flavor.
        if [[ $distro == "Ubuntu"* ]]; then
            case $XDG_CONFIG_DIRS in
            *"studio"*) distro=${distro/Ubuntu/Ubuntu Studio} ;;
            *"plasma"*) distro=${distro/Ubuntu/Kubuntu} ;;
            *"mate"*) distro=${distro/Ubuntu/Ubuntu MATE} ;;
            *"xubuntu"*) distro=${distro/Ubuntu/Xubuntu} ;;
            *"Lubuntu"*) distro=${distro/Ubuntu/Lubuntu} ;;
            *"budgie"*) distro=${distro/Ubuntu/Ubuntu Budgie} ;;
            *"cinnamon"*) distro=${distro/Ubuntu/Ubuntu Cinnamon} ;;
            esac
        fi
        ;;
    esac

    distro=${distro//Enterprise Server/}

    [[ $distro ]] || distro="$os (Unknown)"

    # Get OS architecture.
    case $os in
    Solaris | AIX | Haiku | IRIX | FreeMiNT)
        machine_arch=$(uname -p)
        ;;

    *) machine_arch=$kernel_machine ;;
    esac

    [[ $os_arch == on ]] &&
        distro+=" $machine_arch"

    [[ ${ascii_distro:-auto} == auto ]] &&
        ascii_distro=$(trim "$distro")
}

get_title() {
    user=${USER:-$(id -un || printf %s "${HOME/*\//}")}

    case $title_fqdn in
    on) hostname=$(hostname -f) ;;
    *) hostname=${HOSTNAME:-$(hostname)} ;;
    esac

    title=${title_color}${bold}${user}${at_color}@${title_color}${bold}${hostname}
    length=$((${#user} + ${#hostname} + 1))
}

get_kernel() {
    [[ $os =~ (AIX|IRIX) ]] && return
    case $kernel_shorthand in
    on) kernel=$kernel_version ;;
    off) kernel="$kernel_name $kernel_version" ;;
    esac
}

get_uptime() {
    # Get uptime in seconds.
    case $os in
    Linux | Windows | MINIX)
        if [[ -r /proc/uptime ]]; then
            s=$(</proc/uptime)
            s=${s/.*/}
        else
            boot=$(date -d"$(uptime -s)" +%s)
            now=$(date +%s)
            s=$((now - boot))
        fi
        ;;
    esac

    d="$((s / 60 / 60 / 24)) days"
    h="$((s / 60 / 60 % 24)) hours"
    m="$((s / 60 % 60)) minutes"

    # Remove plural if < 2.
    ((${d/ */} == 1)) && d=${d/s/}
    ((${h/ */} == 1)) && h=${h/s/}
    ((${m/ */} == 1)) && m=${m/s/}

    # Hide empty fields.
    ((${d/ */} == 0)) && unset d
    ((${h/ */} == 0)) && unset h
    ((${m/ */} == 0)) && unset m

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
        uptime=${uptime//,/}
        ;;
    esac
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
            [[ "$(<"${temp_dir}/name")" =~ (cpu_thermal|coretemp|fam15h_power|k10temp) ]] && {
                temp_dirs=("$temp_dir"/temp*_input)
                temp_dir=${temp_dirs[0]}
                break
            }
        done

        # Get CPU speed.
        if [[ -d "$speed_dir" ]]; then
            # Fallback to bios_limit if $speed_type fails.
            speed="$(<"${speed_dir}/${speed_type}")" ||
                speed="$(<"${speed_dir}/bios_limit")" ||
                speed="$(<"${speed_dir}/scaling_max_freq")" ||
                speed="$(<"${speed_dir}/cpuinfo_max_freq")"
            speed="$((speed / 1000))"

        else
            case $kernel_machine in
            "sparc"*)
                # SPARC systems use a different file to expose clock speed information.
                speed_file="/sys/devices/system/cpu/cpu0/clock_tick"
                speed="$(($(<"$speed_file") / 1000000))"
                ;;

            *)
                speed="$(awk -F ': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' "$cpu_file")"
                speed="${speed/MHz/}"
                ;;
            esac
        fi

        # Get CPU temp.
        [[ -f "$temp_dir" ]] && deg="$(($(<"$temp_dir") * 100 / 10000))"

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
    esac

    # Remove un-needed patterns from cpu output.
    cpu="${cpu//(TM)/}"
    cpu="${cpu//(tm)/}"
    cpu="${cpu//(R)/}"
    cpu="${cpu//(r)/}"
    cpu="${cpu//CPU/}"
    cpu="${cpu//Processor/}"
    cpu="${cpu//Dual-Core/}"
    cpu="${cpu//Quad-Core/}"
    cpu="${cpu//Six-Core/}"
    cpu="${cpu//Eight-Core/}"
    cpu="${cpu//[1-9][0-9]-Core/}"
    cpu="${cpu//[0-9]-Core/}"
    cpu="${cpu//, * Compute Cores/}"
    cpu="${cpu//Core / }"
    cpu="${cpu//(\"AuthenticAMD\"*)/}"
    cpu="${cpu//with Radeon * Graphics/}"
    cpu="${cpu//, altivec supported/}"
    cpu="${cpu//FPU*/}"
    cpu="${cpu//Chip Revision*/}"
    cpu="${cpu//Technologies, Inc/}"
    cpu="${cpu//Core2/Core 2}"

    # Trim spaces from core and speed output
    cores="${cores//[[:space:]]/}"
    speed="${speed//[[:space:]]/}"

    # Remove CPU brand from the output.
    if [[ "$cpu_brand" == "off" ]]; then
        cpu="${cpu/AMD /}"
        cpu="${cpu/Intel /}"
        cpu="${cpu/Core? Duo /}"
        cpu="${cpu/Qualcomm /}"
    fi

    # Add CPU cores to the output.
    [[ "$cpu_cores" != "off" && "$cores" ]] &&
        case $os in
        "Mac OS X" | "macOS") cpu="${cpu/@/(${cores}) @}" ;;
        *) cpu="$cpu ($cores)" ;;
        esac

    # Add CPU speed to the output.
    if [[ "$cpu_speed" != "off" && "$speed" ]]; then
        if ((speed < 1000)); then
            cpu="$cpu @ ${speed}MHz"
        else
            [[ "$speed_shorthand" == "on" ]] && speed="$((speed / 100))"
            speed="${speed:0:1}.${speed:1}"
            cpu="$cpu @ ${speed}GHz"
        fi
    fi

    # Add CPU temp to the output.
    if [[ "$cpu_temp" != "off" && "$deg" ]]; then
        deg="${deg//./}"

        # Convert to Fahrenheit if enabled
        [[ "$cpu_temp" == "F" ]] && deg="$((deg * 90 / 50 + 320))"

        # Format the output
        deg="[${deg/${deg: -1}/}.${deg: -1}°${cpu_temp:-C}]"
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
        IFS=$'\n' read -d "" -ra gpus <<<"$gpu_cmd"

        
        [[ "${gpus[0]}" == *Intel* && "${gpus[1]}" == *Intel* ]] && unset -v "gpus[0]"

        for gpu in "${gpus[@]}"; do
            # GPU shorthand tests.
            [[ "$gpu_type" == "dedicated" && "$gpu" == *Intel* ]] ||
                [[ "$gpu_type" == "integrated" && ! "$gpu" == *Intel* ]] &&
                {
                    unset -v gpu
                    continue
                }

            case $gpu in
            *"Advanced"*)
                brand="${gpu/*AMD*ATI*/AMD ATI}"
                brand="${brand:-${gpu/*AMD*/AMD}}"
                brand="${brand:-${gpu/*ATI*/ATi}}"

                gpu="${gpu/\[AMD\/ATI\] /}"
                gpu="${gpu/\[AMD\] /}"
                gpu="${gpu/OEM /}"
                gpu="${gpu/Advanced Micro Devices, Inc./}"
                gpu="${gpu/*\[/}"
                gpu="${gpu/\]*/}"
                gpu="$brand $gpu"
                ;;

            *"NVIDIA"*)
                gpu="${gpu/*\[/}"
                gpu="${gpu/\]*/}"
                gpu="NVIDIA $gpu"
                ;;

            *"Intel"*)
                gpu="${gpu/*Intel/Intel}"
                gpu="${gpu/\(R\)/}"
                gpu="${gpu/Corporation/}"
                gpu="${gpu/ \(*/}"
                gpu="${gpu/Integrated Graphics Controller/}"
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
                gpu="${gpu/AMD /}"
                gpu="${gpu/NVIDIA /}"
                gpu="${gpu/Intel /}"
            fi

            prin "${subtitle:+${subtitle}${gpu_name}}" "$gpu"
        done

        return
        ;;
    esac

    if [[ "$gpu_brand" == "off" ]]; then
        gpu="${gpu/AMD/}"
        gpu="${gpu/NVIDIA/}"
        gpu="${gpu/Intel/}"
    fi
}

get_memory() {
    case $os in
    "Linux" | "Windows")
        
        while IFS=":" read -r a b; do
            case $a in
            "MemTotal")
                ((mem_used += ${b/kB/}))
                mem_total="${b/kB/}"
                ;;
            "Shmem") ((mem_used += ${b/kB/})) ;;
            "MemFree" | "Buffers" | "Cached" | "SReclaimable")
                mem_used="$((mem_used -= ${b/kB/}))"
                ;;
            "MemAvailable")
                mem_avail=${b/kB/}
                ;;
            esac
        done </proc/meminfo

        if [[ $mem_avail ]]; then
            mem_used=$(((mem_total - mem_avail) / 1024))
        else
            mem_used="$((mem_used / 1024))"
        fi

        mem_total="$((mem_total / 1024))"
        ;;
    esac

    [[ "$memory_percent" == "on" ]] && ((mem_perc = mem_used * 100 / mem_total))

    case $memory_unit in
    gib)
        mem_used=$(awk '{printf "%.2f", $1 / $2}' <<<"$mem_used 1024")
        mem_total=$(awk '{printf "%.2f", $1 / $2}' <<<"$mem_total 1024")
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
    "bar") memory="$(bar "${mem_used}" "${mem_total}")" ;;
    "infobar") memory="${memory} $(bar "${mem_used}" "${mem_total}")" ;;
    "barinfo") memory="$(bar "${mem_used}" "${mem_total}")${info_color} ${memory}" ;;
    esac
}

get_disk() {
    type -p df &>/dev/null ||
        {
            err "Disk requires 'df' to function. Install 'df' to get disk info."
            return
        }

    df_version=$(df --version 2>&1)

    case $df_version in
    *IMitv*) df_flags=(-P -g) ;;   # AIX
    *befhikm*) df_flags=(-P -k) ;; # IRIX
    *hiklnP*) df_flags=(-h) ;;     # OpenBSD

    *Tracker*) # Haiku
        err "Your version of df cannot be used due to the non-standard flags"
        return
        ;;

    *) df_flags=(-P -h) ;;
    esac

    IFS=$'\n' read -d "" -ra disks <<<"$(df "${df_flags[@]}" "${disk_show[@]:-/}")"
    unset "disks[0]"

    [[ ${disks[*]} ]] || {
        err "Disk: df failed to print the disks, make sure the disk_show array is set properly."
        return
    }

    for disk in "${disks[@]}"; do
        IFS=" " read -ra disk_info <<<"$disk"
        disk_perc=${disk_info[${#disk_info[@]} - 2]/\%/}

        case $disk_percent in
        off) disk_perc= ;;
        esac

        case $df_version in
        *befhikm*)
            disk=$((disk_info[${#disk_info[@]} - 4] / 1024 / 1024))G
            disk+=" / "
            disk+=$((disk_info[${#disk_info[@]} - 5] / 1024 / 1024))G
            disk+=${disk_perc:+ ($disk_perc%)}
            ;;

        *)
            disk=${disk_info[${#disk_info[@]} - 4]/i/}
            disk+=" / "
            disk+=${disk_info[${#disk_info[@]} - 5]/i/}
            disk+=${disk_perc:+ ($disk_perc%)}
            ;;
        esac

        case $disk_subtitle in
        name)
            disk_sub=${disk_info[*]::${#disk_info[@]}-5}
            ;;

        dir)
            disk_sub=${disk_info[${#disk_info[@]} - 1]/*\//}
            disk_sub=${disk_sub:-${disk_info[${#disk_info[@]} - 1]}}
            ;;

        none) ;;

        *)
            disk_sub=${disk_info[${#disk_info[@]} - 1]}
            ;;
        esac

        case $disk_display in
        bar) disk="$(bar "$disk_perc" "100")" ;;
        infobar) disk+=" $(bar "$disk_perc" "100")" ;;
        barinfo) disk="$(bar "$disk_perc" "100")${info_color} $disk" ;;
        perc) disk="${disk_perc}% $(bar "$disk_perc" "100")" ;;
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
        
        for bat in "/sys/class/power_supply/"{BAT,axp288_fuel_gauge,CMB}*; do
            capacity="$(<"${bat}/capacity")"
            status="$(<"${bat}/status")"

            if [[ "$capacity" ]]; then
                battery="${capacity}% [${status}]"

                case $battery_display in
                "bar") battery="$(bar "$capacity" 100)" ;;
                "infobar") battery+=" $(bar "$capacity" 100)" ;;
                "barinfo") battery="$(bar "$capacity" 100)${info_color} ${battery}" ;;
                esac

                bat="${bat/*axp288_fuel_gauge/}"
                prin "${subtitle:+${subtitle}${bat: -1}}" "$battery"
            fi
        done
        return
        ;;
    esac

    [[ "$battery_state" ]] && battery+=" Charging"

    case $battery_display in
    "bar") battery="$(bar "${battery/\%*/}" 100)" ;;
    "infobar") battery="${battery} $(bar "${battery/\%*/}" 100)" ;;
    "barinfo") battery="$(bar "${battery/\%*/}" 100)${info_color} ${battery}" ;;
    esac
}

get_local_ip() {
    case $os in
    "Linux" | "BSD" | "Solaris" | "AIX" | "IRIX")
        if [[ "${local_ip_interface[0]}" == "auto" ]]; then
            local_ip="$(ip route get 1 | awk -F'src' '{print $2; exit}')"
            local_ip="${local_ip/uid*/}"
            [[ "$local_ip" ]] || local_ip="$(ifconfig -a | awk '/broadcast/ {print $2; exit}')"
        else
            for interface in "${local_ip_interface[@]}"; do
                local_ip="$(ip addr show "$interface" 2>/dev/null |
                    awk '/inet / {print $2; exit}')"
                local_ip="${local_ip/\/*/}"
                [[ "$local_ip" ]] ||
                    local_ip="$(ifconfig "$interface" 2>/dev/null |
                        awk '/broadcast/ {print $2; exit}')"
                if [[ -n "$local_ip" ]]; then
                    prin "$interface" "$local_ip"
                else
                    err "Local IP: Could not detect local ip for $interface"
                fi
            done
        fi
        ;;
    esac
}

get_public_ip() {
    if [[ ! -n "$public_ip_host" ]] && type -p dig >/dev/null; then
        public_ip="$(dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com)"
        [[ "$public_ip" =~ ^\; ]] && unset public_ip
    fi

    if [[ ! -n "$public_ip_host" ]] && [[ -z "$public_ip" ]] && type -p drill >/dev/null; then
        public_ip="$(drill myip.opendns.com @resolver1.opendns.com |
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
get_users3() {
    users3="$(sensors | grep "Package id 0" | awk '{print $2 $3}')"

    users3="${users3%\,*}"
}
get_users4() {
    users4="$(sensors | grep "Core 0" | awk '{print $2 $3}')"

    users4="${users4%\,*}"
}
get_users5() {
    users5="$(sensors | grep "Core 1" | awk '{print $2 $3}')"

    users5="${users5%\,*}"
}
get_users6() {
    users6="$(sensors | grep "Core 2" | awk '{print $2 $3}')"

    users6="${users6%\,*}"
}
get_users7() {
    users7="$(sensors | grep "Core 3" | awk '{print $2 $3}')"

    users7="${users7%\,*}"
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
        for ((block_range[0]; block_range[0] <= block_range[1]; block_range[0]++)); do
            case ${block_range[0]} in
            [0-7])
                printf -v blocks '%b\e[3%bm\e[4%bm%b' \
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
        [[ "$blocks" ]] && cols+="${block_spaces// /${blocks}[mnl}"
        [[ "$blocks2" ]] && cols+="${block_spaces// /${blocks2}[mnl}"

        # Add newlines to the string.
        cols=${cols%%nl}
        cols=${cols//nl/
[${text_padding}C${zws}}

        # Add block height to info height.
        ((info_height += block_range[1] > 7 ? block_height + 2 : block_height + 1))

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

    print_ascii

    [[ "$image_backend" != "off" ]] && printf '\e[%sA\e[9999999D' "${lines:-0}"
}

print_ascii() {
    ascii_data = "$image_source"
    # Calculate size of ascii file in line length / line count.
    while IFS=$'\n' read -r line; do
        line=${line//\\\\/\\}
        line=${line//█/ }
        ((++lines, ${#line} > ascii_len)) && ascii_len="${#line}"
    done <<<"${ascii_data//\$\{??\}/}"

    # Fallback if file not found.
    ((lines == 1)) && {
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

    ((text_padding = ascii_len + gap))
    printf '%b\n' "$ascii_data${reset}"
    LC_ALL=C
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

    if [[ "$2" && "${output// /}" ]]; then
        prin "$1" "$output"

    elif [[ "${output// /}" ]]; then
        prin "$output"

    else
        err "Info: Couldn't detect ${1}."
    fi

    unset -v subtitle
}

prin() {
    # If $2 doesn't exist we format $1 as info.
    if [[ "$(trim "$1")" && "$2" ]]; then
        [[ "$json" ]] && {
            printf '    %s\n' "\"${1}\": \"${2}\","
            return
        }

        string="${1}${2:+: $2}"
    else
        string="${2:-$1}"
        local subtitle_color="$info_color"
    fi

    string="$(trim "${string//$'\e[0m'/}")"
    length="$(strip_sequences "$string")"
    length="${#length}"

    # Format the output.
    string="${string/:/${reset}${colon_color}${separator:=:}${info_color}}"
    string="${subtitle_color}${bold}${string}"

    # Print the info.
    printf '%b\n' "${text_padding:+\e[${text_padding}C}${zws}${string//\\n/}${reset} "

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
    "on") ascii_bold='\e[1m' ;;
    "off") ascii_bold="" ;;
    esac

    case $bold in
    "on") bold='\e[1m' ;;
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
    trim_output="${1//\'/}"
    trim_output="${trim_output//\"/}"
    printf "%s" "$trim_output"
}

strip_sequences() {
    strip="${1//$'\e['3[0-9]m/}"
    strip="${strip//$'\e['[0-9]m/}"
    strip="${strip//\\e\[[0-9]m/}"
    strip="${strip//$'\e['38\;5\;[0-9]m/}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9]m/}"
    strip="${strip//$'\e['38\;5\;[0-9][0-9][0-9]m/}"

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
        subtitle_color="$(color "$1")"
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
    *) bar_color_total=$(color "$bar_color_total") ;;
    esac
}

color() {
    case $1 in
    [0-6]) printf '%b\e[3%sm' "$reset" "$1" ;;
    7 | "fg") printf '\e[37m%b' "$reset" ;;
    *) printf '\e[38;5;%bm' "$1" ;;
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
        printf '%s\n' "$config" >"$config_file"
    fi
}

bar() {
    # Get the values.
    elapsed="$(($1 * bar_length / $2))"

    # Create the bar with spaces.
    printf -v prog "%${elapsed}s"
    printf -v total "%$((bar_length - elapsed))s"

    # Set the colors and swap the spaces for $bar_char_.
    bar+="${bar_color_elapsed}${prog// /${bar_char_elapsed}}"
    bar+="${bar_color_total}${total// /${bar_char_total}}"

    # Borders.
    [[ "$bar_border" == "on" ]] &&
        bar="$(color fg)[${bar}$(color fg)]"

    printf "%b" "${bar}${info_color}"
}

cache() {
    if [[ "$2" ]]; then
        mkdir -p "${cache_dir}/neofetch"
        printf "%s" "${1/*-/}=\"$2\"" >"${cache_dir}/neofetch/${1/*-/}"
    fi
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

    kde_config_dir="${kde_config_dir/$'/:'*/}"
}

term_padding() {
    # Get terminal padding to properly align cursor.
    [[ -z "$term" ]] && get_term

    case $term in
    urxvt* | rxvt-unicode)
        [[ $xrdb ]] || xrdb=$(xrdb -query)

        [[ $xrdb != *internalBorder:* ]] &&
            return

        padding=${xrdb/*internalBorder:/}
        padding=${padding/$'\n'*/}

        [[ $padding =~ ^[0-9]+$ ]] ||
            padding=
        ;;
    esac
}

dynamic_prompt() {
    [[ "$image_backend" == "off" ]] && {
        printf '\n'
        return
    }
    [[ "$image_backend" != "ascii" ]] && ((lines = (height + yoffset) / font_height + 1))

    # If the ascii art is taller than the info.
    ((lines = lines > info_height ? lines - info_height + 1 : 1))

    printf -v nlines "%${lines}s"
    printf "%b" "${nlines// /\\n}"
}

cache_uname() {
    
    IFS=" " read -ra uname <<<"$(uname -srm)"

    kernel_name="${uname[0]}"
    kernel_version="${uname[1]}"
    kernel_machine="${uname[2]}"
}

get_ppid() {

    ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
    ppid="$(trim "${ppid/PPid:/}")"
    printf "%s" "$ppid"
}

get_process_name() {
    name="$(<"/proc/${1:-$PPID}/comm")"
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
        set_colors 1  3 4 6 7 8 9 
        read -rd '' ascii_data <<'EOF'
${c4}                            =--:::::=                             
${c4}                           =--=      :                           
${c4}              ${c5}***        ${c5}-=             :                          
${c4}         =:==${c5}**#**${c4}==    -=               :                         
${c4}        -:    ${c5}***    ${c4}==-=:               :                         
${c4}       --             ==: ====            =                        
${c4}       --             ==      ===     ====-=====-${c5}***              
${c4}       ==            :==      =:-:--:=====-:====${c5}**#**${c4}---=          
${c4}        -=           =========     =:=    :=     ${c5}***  ${c4}=-==:        
${c4}         ==       ==:=:              ::= ==            :==-       
${c4}          -=  ====  -     ${c5}:++++++++:   ${c4}:::=            ====       
${c4}           -=-      ==  ${c5}==++++++++++=     ${c4}:-=           -===       
${c4}        === ==-    ==:   ${c5}:----------:     ${c4}::=-=       =====        
${c4}      ==      -=:  :=:   ${c5}-${c4}:${c5}-${c4}==${c5}--${c4}==${c5}-${c4}:${c5}-     ${c4}:=  :-    =-==:          
${c4}    =:         =-=:-==   ${c5}-${c4}:${c5}-${c4}==${c5}--${c4}==${c5}-${c4}:${c5}-     ${c4}-     -::===:            
${c4}   :=            =====    ${c5}=--------=      ${c4}-   =:===-               
${c4}  ==               -==-   ${c5}=:------:=     ${c4}:-:-==-: ==               
${c4}  ==               -=:-=-=  ${c5}======   ${c4}==:-==-:=     :==             
${c4}   :-:             :==  :==:    =:--==-::-          :=             
${c4}     :---::====  ==:=-=::-======-:==    -=           ==            
${c4}        ==::--------==-:::=  =-==:=    =-            ===           
${c4}                    ===         =-===-===           ====           
${c4}                    :=-             :-====-:======:-===            
${c4}                     ==:             -- =:-=========-:             
${c4}                     ====           --                             
${c4}                      :==:       ${c5}***                              
${c4}                       :==-:    ${c5}**#**                              
${c4}                        =-=======${c5}***                               
${c4}                           =::=
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

    [[ $TERM != minix && $stdout != on ]] && {
        trap 'printf "\e[?25h\e[?7h"' EXIT

        printf '\e[?25l\e[?7l'
    }

    image_backend
    get_cache_dir
    old_functions
    print_info
    dynamic_prompt

    err "Neofetch command: $0 $*"
    err "Neofetch version: $version"

    [[ $verbose == on ]] && printf '%b\033[m' "$err" >&2

    return 0
}

main "$@"
