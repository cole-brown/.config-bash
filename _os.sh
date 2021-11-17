
_os_setup() {
  #--------------
  # OS
  #--------------
  eval $(source /etc/os-release;
         echo ps1_os_version_id="$VERSION_ID";
         echo ps1_os_version_name="$VERSION_CODENAME";)

  ps1_deb_chroot="${debian_chroot:+($debian_chroot)}"
  ps1_os="${ps1_os_version_id}(${ps1_os_version_name})"
}
