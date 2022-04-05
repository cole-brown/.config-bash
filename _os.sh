
bap_os_setup() {
  #--------------
  # OS
  #--------------
  eval $(source /etc/os-release;
         echo bap_ps1_os_version_id="$VERSION_ID";
         echo bap_ps1_os_version_name="$VERSION_CODENAME";)

  bap_ps1_chroot="${debian_chroot:+($debian_chroot)}"
  bap_ps1_os="${bap_ps1_os_version_id}(${bap_ps1_os_version_name})"
}
