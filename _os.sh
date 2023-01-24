# Source this file.

bap_os_setup() {
    #--------------
    # OS
    #--------------
    eval $(source /etc/os-release;
           echo bap_ps1_os_version_id="$VERSION_ID";
           echo bap_ps1_os_version_name="$VERSION_CODENAME";
           echo bap_ps1_os_distro_name="$ID")

    bap_ps1_chroot="${debian_chroot:+($debian_chroot)}"
    bap_ps1_os_distro="${bap_ps1_os_distro_name}-${bap_ps1_os_version_id}"
    bap_ps1_os_code="${bap_ps1_os_version_name}"
}
