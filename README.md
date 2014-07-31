#Nginxpack [![Build Status](https://travis-ci.org/jvaubourg/puppetlabs-nginxpack.png)](https://travis-ci.org/jvaubourg/puppetlabs-nginxpack)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [What nginxpack affects](#what-nginxpack-affects)
4. [Usage](#usage)
    * [Beginning with nginxpack](#beginning-with-nginxpack)
        * [Webserver](#webserver)
        * [Basic Vhost](#basic-vhost)
        * [Proxy Vhost](#proxy-vhost)
        * [Redirection Vhost](#redirection-vhost)
    * [Documentation](#documentation)
    * [Default Vhosts](#default-vhosts)
        * [Automatic Blackholes](#automatic-blackholes)
        * [Well-known problem with SSL](#well-known-problem-with-ssl)
5. [Common Use Cases](#common-use-cases)
    * [Reverse-proxy with IPv4](#reverse-proxy-with-ipv4)
        * [Multiple servers and a single IPv4](#multiple-servers-and-a-single-ipv4)
        * [With usable IPv6 addresses](#with-usable-ipv6-addresses)
        * [Without IPv6 addresses](#without-ipv6-addresses)
    * [Usage of *www.*](#usage-of-www)
    * [Port Redirection](#port-redirection)
        * [Seamlessly](#seamlessly)
        * [Not Seamlessly](#not-seamlessly)
    * [HTTPS Redirection](#https-redirection)
    * [IPv6/IPv4 Proxy](#ipv6ipv4-proxy)
5. [Limitations (only Debian-likes)](#limitations)
6. [Development](#development)

##Overview

This module installs and configures Nginx (lightweight and robust webserver). It's a pack because you can **optionally** install and configure PHP5 at the same time. There are three types of vhost available (basic, proxy and redirection) and some smart options for Nginx and PHP. This module is full IPv6 compliant because we are in 2013.

* [PuppetLabs Forge](https://forge.puppetlabs.com/jvaubourg/nginxpack)
* [GitHub Repository](https://github.com/jvaubourg/puppetlabs-nginxpack/)

##Module Description

Features available:

* Install and configure Nginx
* Optionally: install and configure PHP5-FastCGI
* Optionally: install PHP-MySQL connector and/or others PHP5 modules
* Basic vhosts
* Proxy vhosts
* 301 Redirection vhosts
* SSL support
* SNI support
* AcceptPathInfo support
* Full IPv6 compliant (and still IPv4...) including IPv6-Only
* Automatic blackhole for non-existent domains
* Several options (upload limits with Nginx/PHP, timezone, logrotate, 
default SSL certificate, htpasswd, XSS injection protection, etc.)
* Custom configuration option for non-supported features

##What nginxpack affects

Installed packages:

* *nginx*
* With `enable_php`: *php5-cgi*, *spawn-fcgi*
* With `php_mysql`: *php5-mysql*
* With `logrotate`: *logrotate*, *psmisc* (if not already present)

*logrotate* is used with a configuration file in */etc/logrotate.d/nginx* allowing it to daily rotate vhost logs. The configuration uses *killall* from *psmisc* in order to force nginx to update his inodes (this is the classic way). *killall* is also used in `nginxpack::php::cgi` to ensure that PHP is not still running.

Use `nginxpack::php::mod { 'foo' }` involves installing *php5-foo*.

Added services:

* Use `/etc/init.d/nginx`
* Add `/etc/init.d/php-fastcgi` (and associated script `/usr/bin/php-fastcgi.sh`)

Added files:

* Vhosts: _/etc/nginx/sites-{available,enabled}/*_ and _/etc/nginx/include/*_
* Logs: */var/log/nginx/&lt;vhostname&gt;/{access,error}.log*
* Certificates: _/etc/nginx/ssl/*_
* Script for automatic blackholes: */etc/nginx/find_default_listen.sh*

Use `php_timezone`, `php_upload_max_filesize` and/or `php_upload_max_files` affects */etc/php5/cgi/php.ini* (but not overrides it).

##Usage

###Beginning with nginxpack

####Webserver

If you just want a webserver installing with the default options and without PHP you can run:

    include 'nginxpack'

And with PHP:

    class { 'nginxpack':
      enable_php => true,
    }

With PHP-MySQL connector:

    class { 'nginxpack':
      enable_php => true,
      php_mysql  => true,
    }

Others options for PHP:

    class { 'nginxpack':
      enable_php              => true,
      php_timezone            => 'Antarctica/Vostok',
      php_upload_max_filesize => '1G',
      php_upload_max_files    => 5,
    }

With this example, you will be able to propose uploads of 5 files of 1G max each together. In this case, the POST-data size limit (from PHP) will automatically be configured to accept until 5G.

You can also configure default https configuration here. See the [first common use case](#reverse-proxy-with-ipv4).

####Basic Vhost

Standard vhost.

Listen on all IPv6/IPv4 available with port 80, no PHP and no SSL:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
    }

Using aliases:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com', 'www.foobar.example.com' ]
    }

With PHP:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
      use_php => true,
    }

Since you use `use_php` for at least one vhost, you have to use `enable_php` with the webserver. For activating [AcceptPathInfo](https://httpd.apache.org/docs/2.2/mod/core.html#AcceptPathInfo), add `php_AcceptPathInfo => true` to the vhost (e.g. */foo/index.php/bar/* with *PATH_INFO=/bar/*).

Listen on a specific IPv6 and all IPv4 available:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
      ipv6    => '2001:db8::42',
    }

You can use the `ipv4` option to listen on a specific IPv4 address. And if you don't want listening on IPv4 you can set `ipv6only => true` (and `ipv4only` for not listening on IPv6, when it's **strictly** necessary).

Listen on a specific port:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
      port    => 8080,
    }

With SSL (https://):

    nginxpack::vhost::basic { 'foobar':
      domains         => [ 'foobar.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/foobar.pem',
      ssl_key_source  => 'puppet:///certificates/foobar.key',
    }

Generate *pem* (*crt*) and *key* files (put your full qualified domain name in *Common Name*):

    $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout foobar.key -out foobar.pem

You also could use `ssl_cert_content` and `ssl_key_content` to define the certificate from a string (useful if you use hiera to store your certificates: `ssl_cert_content => hiera('foobar-cert')`).

The default listening port becomes 443 but you still could force a different one with `port`.

Other options:

    nginxpack::vhost::basic { 'foobar':
      domains            => [ 'foobar.example.com' ],
      enable             => false,
      files_dir          => '/srv/websites/foobar/',
      injectionsafe      => true,
      upload_max_size    => '5G',
      htpasswd           => 'user1:$apr1$EUoQVU1i$kcGRxeBAJaMuWYud6fxZL/',
      forbidden          => [ '^/logs/', '^/tmp/', '\.inc$' ],
      add_config_content => 'location @barfoo { rewrite ^(.+)$ /files/$1; }',
      try_files          => '@barfoo',
    }

`files_dir` (*DocumentRoot*) default value is */var/www/&lt;name&gt;/* (e.g. */var/www/foobar/*).

`injectionsafe` applies [these protections](http://www.howtoforge.com/nginx-how-to-block-exploits-sql-injections-file-injections-spam-user-agents-etc) against XSS injections. These restrictions might be incompatible with your applications.

`upload_max_size` should be in line with `php_upload_max_filesize` *x* `php_upload_max_files`

`htpasswd`'s value can be generated from a command line tool (*apache2-utils*):

    $ htpasswd -nb user1 secretpassword

If you want to use a specific configuration for a specific vhost, you can use `add_config_source` or `add_config_content` to inject custom Nginx instructions directly in `server { }`.

####Proxy Vhost

Reverse-proxy vhost allowing you to seamlessly redirect the traffic to a remote webserver.

Default listen identical to basic vhosts and remote server reached on port 80 without using SSL:

    nginxpack::vhost::proxy { 'foobarlan':
      domains   => [ 'foobar.example.com' ],
      to_domain => 'foobar.lan',
    }

Remote SSL and different remote port:

    nginxpack::vhost::proxy { 'foobarlan':
      domains   => [ 'foobar.example.com' ],
      to_domain => 'foobar.lan',
      to_https  => true,
      to_port   => 8080,
    }

Default remote port is 80. In this case it would have been 443 due to `to_https`.

SSL (https://) is usable in the same manner as [basic vhosts](#basic-vhost).

Options `ipv6`, `ipv4`, `ipv6only`, `ipv4only`, `port`, `enable`, `add_config_source`, `add_config_content` and `upload_max_size` are also available in the same way as [basic vhosts](#basic-vhost).

####Redirection Vhost

General redirection (using 301 http code) allowing you to officially redirect any requests to a remote domain. In short: _http://foobar.example.com/(.*) => http://foobar.com/$1_.

Default listen identical to basic vhosts, and remote domain reached on port 80 without using SSL:

    nginxpack::vhost::redirection { 'foobarlan':
      domains   => [ 'foobar.example.com' ],
      to_domain => 'www.foobar.com',
    }

Options `to_https` and `to_port` are available in the same way as [proxy vhosts](#proxy-vhost).

Options `ipv6`, `ipv4`, `ipv6only`, `ipv4only`, `port`, `enable`, `add_config_source` and `add_config_content` are available in the same way as [basic vhosts](#basic-vhost).

###Documentation

The [previous section](#beginning-with-nginxpack) should be clear enough to understand the possibilities of nginxpack.

If you want a detailed documentation of types and options, there is a full documentation in the headers of the [Puppet files](https://github.com/jvaubourg/puppetlabs-nginxpack/tree/master/manifests).

###Default Vhosts

####Automatic Blackholes

Have a determinist way to access to the vhosts is a good practice in web security. If you say that a vhost can be reached via *my.example.com*, any request using another domain should not success. If you do not have a *default vhost* with a listen line for each port used on the webserver, Nginx will use a doubful algorithm to determine which vhost is usable in the case of an unknown domain.

Good news! Nginxpack creates this default vhost for you and redirects any request out of your scopes to a blackhole.

You can disable the https blackhole with `default_https_blackhole => false` (useful if you have no https vhosts and you don't want Nginx listening on 443).

####Well-known problem with SSL

The full circle is easy to understand:

1. Nginx chooses the correct vhost (among those who are listening on the correct port and IP) thanks to the *host* field (HTTP 1.1).
2. When a client initiates a SSL connection, this field is encrypted, until Nginx decrypts the request.
3. Informations about decryption (e.g. certificate location) are in the correct vhost. Back to *1*.

Thus, if you have several vhosts listening on the same port with the same IP (or *all* IP) and using SSL, you have a problem.

With Nginx >= 0.7.62 and OpenSSL >= 0.9.8j, you can use [SNI](http://en.wikipedia.org/wiki/Server_Name_Indication), the modern way to solve this problem. You have nothing to do, but your visitors must have recent browsers:

* Opera 8.0;
* MSIE 7.0 (but only on Windows Vista or higher);
* Firefox 2.0 and other browsers using Mozilla Platform rv:1.8.1;
* Safari 3.2.1 (Windows version supports SNI on Vista or higher);
* or Chrome (Windows version supports SNI on Vista or higher, too).

The other constraint is that you cannot use specific addresses (`ipv6` and `ipv4` options) with SNI.

If you don't want to restrict compatible browsers or you want use specific addresses or you want to manage only one wildcard certificate, the good solution is to use a default vhost, listening on all ports and IP used by SSL vhosts on the webserver and containing the decryption informations. When Nginx will receive a SSL request, it will use this vhost, and so, will be able to decrypt it. Once the *host* field is readable, it can chose the correct vhost. The latter don't have to propose SSL but it absolutely must listen on port 443 (or another if you use SSL with another one).

Nginxpack creates this default vhost for you, with a default certificate. To replace the default certificate, you can use `ssl_default_cert_source` (or `ssl_default_cert_key`) and `ssl_default_key_source` (or `ssl_default_key_source`) options. This certificate should be valid for all domains used, so it will probably be at least a wildcard certificate. 

The [first common use case](#reverse-proxy-with-ipv4) in the next section provides an example with this solution.

##Common Use Cases

###Reverse-proxy with IPv4

####Multiple servers and a single IPv4

You are in charge of servers in the wrong decade: there is almost no more IPv4 but you still can't use only IPv6. Thus, your provider has provided you as many IPv6 addresses as there are grains of sand on earth, but only one poor IPv4.

If you have various webservers (on remote machines or in containers beside) behind this access, you need to have a *reverse-proxy*. In the following examples, we consider that your firewall redirects ports 80 and 443 to the server corresponding to your reverse-proxy for any incoming IPv4 flux (probably by configuring your NATPT on your CPE if you are at home) .

The first example considers that your ISP provides you IPv6 addresses and that you are able to use it. Second example considers that you have a crappy ISP and so no IPv6 addresses available. In both examples, we want a blog (http), a wiki (https) and a members panel (https). For the sake of cleanliness and security reasons, each website must have its own webserver on its own machine/container.

####With usable IPv6 addresses

Goals:

* 1 webserver (1 machine/container) by website and 1 for the reverse-proxy.
* IPv6 clients reach websites directly and can't use the reverse-proxy.
* IPv4 clients reach websites only through the reverse-proxy and can't reach them directly.
* Therefore, communications between the reverse-proxy and the remote websites use IPv6, but it's seamless for (IPv4) clients and there is no problem with IPv6 over the internal network.

The certificat location is provided on the reverse-proxy for IPv4 clients (see [previous section](#well-known-problem-with-ssl)), and on the vhosts for IPv6 clients. Proxy vhosts listen on port 443 but not have SSL capabilities (see again the [previous section](#well-known-problem-with-ssl)).

Webserver hosting the reverse-proxy:

    # Could be replaced by an internal DNS server
    host {
      'blog.lan':
        ip => '2001:db8::a';
      'wiki.lan':
        ip => '2001:db8::b';
      'members.lan':
        ip => '2001:db8::c';
    }

    # Wildcard certificate (*.example.com)
    class { 'nginxpack':
      ssl_default_cert_source => 'puppet:///certificates/default.pem',
      ssl_default_key_source  => 'puppet:///certificates/default.key',
    }

    nginxpack::vhost::proxy { 'blog':
      domains   => [ 'blog.example.com' ],
      ipv4only  => true,
      to_domain => 'blog.lan',
    }

    nginxpack::vhost::proxy { 'wiki':
      domains   => [ 'wiki.example.com' ],
      port      => 443,
      ipv4only  => true,
      to_domain => 'wiki.lan',
      to_https  => true,
    }

    nginxpack::vhost::proxy { 'members':
      domains   => [ 'members.example.com' ],
      port      => 443,
      ipv4only  => true,
      to_domain => 'members.lan',
      to_https  => true,
    }

Webserver hosting *blog.example.com*:

    nginxpack::vhost::basic { 'blog':
      domains  => [ 'blog.example.com' ],
      ipv6only => true,
      use_php  => true,
    }

Webserver hosting *wiki.example.com*:

    nginxpack::vhost::basic { 'wiki':
      domains         => [ 'wiki.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/default.pem',
      ssl_key_source  => 'puppet:///certificates/default.key',
      ipv6only        => true,
      use_php         => true,
    }

Webserver hosting *members.example.com*:

    nginxpack::vhost::basic { 'members':
      domains         => [ 'members.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/default.pem',
      ssl_key_source  => 'puppet:///certificates/default.key',
      ipv6only        => true,
      use_php         => true,
    }

####Without IPv6 addresses

Goals:

* 1 webserver (1 machine/container) by website and 1 for the reverse-proxy.
* Clients reach websites only through the reverse-proxy and can't reach them directly.
* We trust in the internal network so communications between the reverse-proxy and the websites are never encrypted.

Webserver hosting the reverse-proxy:

    # Could be replaced by an internal DNS server
    host {
      'blog.lan':
        ip => '10.0.0.10';
      'wiki.lan':
        ip => '10.0.0.20';
      'members.lan':
        ip => '10.0.0.30';
    }

    # Wildcard certificate (*.example.com)
    class { 'nginxpack':
      ssl_default_cert_source => 'puppet:///certificates/default.pem',
      ssl_default_key_source  => 'puppet:///certificates/default.key',
    }

    nginxpack::vhost::proxy { 'blog':
      domains   => [ 'blog.example.com' ],
      to_domain => 'blog.lan',
    }

    nginxpack::vhost::proxy { 'wiki':
      domains   => [ 'wiki.example.com' ],
      port      => 443,
      to_domain => 'wiki.lan',
    }

    nginxpack::vhost::proxy { 'members':
      domains   => [ 'members.example.com' ],
      port      => 443,
      to_domain => 'members.lan',
    }

Webserver hosting *blog.example.com*:

    nginxpack::vhost::basic { 'blog':
      domains => [ 'blog.example.com' ],
      use_php => true,
    }

Webserver hosting *wiki.example.com*:

    nginxpack::vhost::basic { 'wiki':
      domains => [ 'wiki.example.com' ],
      use_php => true,
    }

Webserver hosting *members.example.com*:

    nginxpack::vhost::basic { 'members':
      domains => [ 'members.example.com' ],
      use_php => true,
    }

###Usage of *www.*

Using *www.example.com* is so 2005 and you want automatically redirect all requests from _http://www.example.com/.*_ to *http://example.com/$1*.

    nginxpack::vhost::basic { 'eatmytux':
      domains => [ 'example.com' ],
      use_php => true,
    }
    
    nginxpack::vhost::redirection { 'www-eatmytux':
      domains   => [ 'www.example.com' ],
      to_domain => 'example.com',
    }

###Port Redirection

Proxy and redirection vhosts use the first value of `domains` when `to_domain` is absent.

####Seamlessly

Your out-of-the-box webapp listens on port 8080 but you want use it on port 80 without modifying its configuration:

    nginxpack::vhost::proxy { 'mywebapp':
      domains => [ 'example.com' ],
      to_port => 8080,
    }

####Not Seamlessly

Visible location switching (the client will see his URL transformation: _http://example.com/.*_ => *http://example.com:8080/$1*) means redirection:

    nginxpack::vhost::redirection { 'mywebapp':
      domains => [ 'example.com' ],
      to_port => 8080,
    }

####HTTPS Redirection

Spontaneous switching from *http* to *https*:

    nginxpack::vhost::basic { 'wiki':
      domains         => [ 'wiki.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/wiki.pem',
      ssl_key_source  => 'puppet:///certificates/wiki.key',
    }
    
    nginxpack::vhost::redirection { 'https-wiki':
      domains  => [ 'wiki.example.com' ],
      to_https => true,
    }

####IPv6/IPv4 Proxy

You own a website not available in IPv6 and you cannot have an IPv6 address on its machine. A way to solving this problem is to create a proxy on a dual-stack machine (listening on IPv6 to accept incoming requests and listening on IPv4 to contact the remote webserver):

    nginxpack::vhost::proxy { 'foobar':
      domains   => [ 'example.com' ],
      to_domain => 'ip4.example.com',
      ipv6only  => true,
    }

DNS configuration:

    example.com
        AAAA proxy
        A    webserver
    ip4.example.com
        A    webserver

This trick could also be used in the opposite case.

##Dependencies

* [puppetlabs/stdlib](http://forge.puppetlabs.com/puppetlabs/stdlib) &gt;= 3.x (`file_line` is used to edit *php.ini* and `ensure_packages` to install *logrotate* and *psmisc*)

##Limitations

This module is **only available for Debian-likes**.

Tests are made with:

* Debian Wheezy 7.1
* Puppet 3.2.4 ([Build Tests](https://travis-ci.org/jvaubourg/puppetlabs-nginxpack))
* Nginx 1.2.1
* PHP 5.4.4

This does not mean that this module can't be used with other versions but I have no idea about the compatibility.

##Development

I developed this module for my own needs but I think it's generic enough to be useful for someone else.

[Feel free to contribute](https://github.com/jvaubourg/puppetlabs-nginxpack/). I'm not a big fan of centralized services like GitHub but I used it to permit easy pull-requests, so show me that's a good idea!

Thank [Lorraine Data Network](http://ldn-fai.net) for testing the module.
