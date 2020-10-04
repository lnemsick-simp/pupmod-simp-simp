# Returns the SIMP release version for use in SIMP internet yum repositories.
#
# When `$simp_release_version` is specified, this value is simply returned.
# Otherwise, attempts to determine the SIMP release version automatically.
# When this automatic detection fails, this function fails.
#
# @param simp_release_version
#   Optional desired SIMP release version.
#
# @return [Simp::Version]
#
function simp::yum::repo::simp_release_version(
  Optional[Simp::Version] $simp_release_version = undef
) {
  if $simp_release_version !~ Undef {
    $_release_version = $simp_release_version
  }
  else {
    $_simp_version = simplib::simp_version()
    if $_simp_version == 'unknown' {
      # We get here if the simp.version file (in /etc/simp or
      # C:/ProgramData/SIMP) is not available or the pupmod-simp-simp
      # RPM is not installed.
      fail('Unable to determine SIMP version automatically.')
    }
    else {
      $_release_version = $_simp_version 
    }
  }
  $_release_version
}
