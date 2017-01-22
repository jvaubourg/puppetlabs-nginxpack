# == Class: nginxpack::php::cgi
#
# Install a FastCGI wrapper (fcgiwrap) to run legacy CGI scripts.
#
# Should be used through the main nginxpack class.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*enable*]
#   False to be sure that fcgiwrap is uninstalled.
#   Default: true
#
# === Examples
#
#   class { 'nginxpack::legacycgi': }
#
# More examples: https://forge.puppetlabs.com/jvaubourg/nginxpack
#
# === Authors
#
# Julien Vaubourg
# http://julien.vaubourg.com
#
# === Copyright
#
# Copyright (C) 2017 Julien Vaubourg
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class nginxpack::legacycgi (
  $enable = true
) {

  if $enable {

    package { 'fcgiwrap':
      ensure => present,
    }

    service { 'fcgiwrap':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }

  } else {

    package { 'fcgiwrap':
      ensure => absent,
    }
  }
}
