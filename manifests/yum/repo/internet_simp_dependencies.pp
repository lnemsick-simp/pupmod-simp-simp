# @summary Configure yum to use the internet public repositories for SIMP dependencies
#
# Configures repositories for EPEL, PostgreSQL, and Puppet packages. These
# repositories will only contain packages needed by SIMP and tested with SIMP.
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
#   DEPRECATED The unique release URL "slug" of SIMP for the target release.
#   Use `$simp_release_version` and `$simp_release_type` instead.
#
# @param enable_simp_epel
#
#   Whether to enable the SIMP repository for EPEL dependencies
#
# @param enable_simp_postgresl
#
#   Whether to enable the SIMP repository for PostgreSQL dependencies
#
# @param enable_simp_puppet
#
#   Whether to enable the SIMP repository for Puppet dependencies
#
class simp::yum::repo::internet_simp_dependencies (
  Boolean $enable_simp_epel              = true,
  Boolean $enable_simp_postgresql        = true,
  Boolean $enable_simp_puppet            = true,
  String $simp_release_type              = 'releases',
  Optional[String] $simp_release_version = undef,
  Optional[String] $simp_release_slug    = undef
){

  simplib::module_metadata::assert($module_name, { 'blacklist' => ['Windows'] })

  if $simp_release_slug {
    $_release_slug = simp::yum::repo::sanitize_simp_release_slug( $simp_release_slug )
    yumrepo { "simp-project_${_release_slug}_Dependencies": ensure => absent }
    warning('$simp_release_slug is deprecated and will be removed in the next major release. Please use $simp_release_version and $simp_release_type instead.')
  }

  $_simp_release_version = simp::yum::repo::simp_release_version($simp_release_version)
  $_release = $facts['os']['release']['major']
  $_arch = $facts['architecture']

  yumrepo { 'simp-project-epel':
    baseurl         => "https://download.simp-project.com/simp/yum/${simp_release_type}/${_simp_release_version}/el/${_release}/${_arch}/epel",
    enabled         => $enabled ? { true => '1', default => '0' },
  }

  yumrepo { 'simp-project-postgresql':
    baseurl         => "https://download.simp-project.com/simp/yum/${simp_release_type}/${_simp_release_version}/el/${_release}/${_arch}/postgresl",
  }

  yumrepo { 'simp-project-puppet':
    baseurl         => "https://download.simp-project.com/simp/yum/${simp_release_type}/${_simp_release_version}/el/${_release}/${_arch}/puppet",
  }

  $_dependency_gpg_keys = [
    'https://raw.githubusercontent.com/NationalSecurityAgency/SIMP/master/GPGKEYS/RPM-GPG-KEY-SIMP',
    'https://download.simp-project.com/simp/GPGKEYS/RPM-GPG-KEY-SIMP-6',
    'https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
    'https://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
    'https://apt.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-94',
    'https://apt.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-96',
    'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$releasever'
  ]

  $_release = $facts['os']['release']['major']
  $_arch = $facts['architecture']

  yumrepo { "simp-project_${_release_slug}_Dependencies":
    baseurl         => "https://packagecloud.io/simp-project/${_release_slug}_Dependencies/el/${_release}/${_arch}",
    descr           => 'Dependencies for the SIMP project',
    enabled         => 1,
    enablegroups    => 0,
    gpgcheck        => 1,
    gpgkey          => join($_dependency_gpg_keys,"\n   "),
    sslverify       => 0,
    keepalive       => 0,
    metadata_expire => 3600
  }
}
