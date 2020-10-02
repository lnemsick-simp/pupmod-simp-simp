# @summary Configure yum to use the internet public repository for SIMP servers
#
# @note If a system is not intended to be a SIMP server, it probably doesn't need
#       this profile.
#
# @param simp_release_version
#
#  The Major(X), Minor(Y), or Patch(Z) release of SIMP you want.
#
#  * The format is 'X', 'X.Y', 'X.Y.Z', or 'X.Y.Z-iteration. For example,
#    '6', '6.5', '6.5.0', or '6.5.0-0'.
#  * Setting this to a 'X' will install the latest release for that
#    SIMP Major version and grab updates for all future minor and patch
#    releases in that Major version of SIMP. This is the appropriate setting
#    if you want all SIMP releases as they are tested and released.
#  * Setting this to 'X.Y' will install the latest X.Y release and grab updates
#    for all future patches to that X.Y version, but never update to the next
#    Minor version. This is the appropriate setting if you want a specific Minor
#    version of SIMP, but don't want to install new Minor version.
#  * Setting this to 'X.Y.Z' or 'X.Y.Z-iteration' will install that specific
#    SIMP release and never grab any updates. This is the appropriate setting,
#    along with `$simp_release_type = 'releases'`, if you want only a specific
#    release of SIMP, and no future updates.
#
# @param simp_release_type
#
#   Type of release you want:
#
#   * 'releases': Packages from fully tested SIMP releases. This is the
#     recommended setting.
#   * 'rolling': Packages that have not yet made it into a SIMP release,
#     but have been tested and released individually with confidence.
#   * 'unstable/6': Packages in the unstable repository for SIMP 6.
#     This is extremely dangerous and not recommended for production
#     environments.
#
# @param simp_release_slug
#
#   DEPRECATED The unique release URL "slug" of SIMP for the target release.
#   Use `$simp_release_version` and `$simp_release_type` instead.
#
# @param enable
#
#   Whether to enable the repository
#
class simp::yum::repo::internet_simp_server (
  Boolean                 $enable               = true,
  String                  $simp_release_type    = 'releases',
  Optional[Simp::Version] $simp_release_version = undef,
  Optional[String]        $simp_release_slug    = undef
){

  simplib::module_metadata::assert($module_name, { 'blacklist' => ['Windows'] })

  if $simp_release_slug {
    $_release_slug = simp::yum::repo::sanitize_simp_release_slug( $simp_release_slug )
    yumrepo { "simp-project_${_release_slug}": ensure => absent }
    warning('$simp_release_slug is deprecated and will be removed in the next major release. Please use $simp_release_version and $simp_release_type instead.')
  }

  $_simp_release_version = simp::yum::repo::simp_release_version($simp_release_version)
  $_release = $facts['os']['release']['major']
  $_arch = $facts['architecture']

  yumrepo { 'simp-project-simp':
    baseurl         => "https://download.simp-project.com/simp/yum/${simp_release_type}/${_simp_release_version}/el/${_release}/${_arch}/simp",
    descr           => 'The main SIMP repository',
    enabled         => $enabled ? { true => '1', default => '0' },
    enablegroups    => 0,
    gpgcheck        => 1,
    gpgkey          => [
      'https://raw.githubusercontent.com/NationalSecurityAgency/SIMP/master/GPGKEYS/RPM-GPG-KEY-SIMP',
      'https://download.simp-project.com/simp/GPGKEYS/RPM-GPG-KEY-SIMP-6'
    ],
    sslverify       => 0,
    keepalive       => 0,
    metadata_expire => 3600
  }

}
