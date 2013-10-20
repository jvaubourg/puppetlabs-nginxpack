#Nginxpack

**WARNING: This work is still under development.**

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [What nginxpack affects](#what-nginxpack-affects)
4. [Usage](#usage)
    * [Beginning with nginxpack](#beginning-with-nginxpack)
    * [Documentation](#documentation)
    * [Default vhosts](#default-vhosts)
5. [Common use cases](#common-use-cases)
    * [Reverse-proxy with IPv4](#reverse-proxy-with-ipv4)
    * [Usage of www](#usage-of-www)
    * [Port redirection](#port-redirection)
    * [Add IPv6/IPv4 access](#add-ipv6-ipv4-access)
5. [Limitations (only Debian)](#limitations)
6. [Development](#development)

##Overview

This module installs and configures Nginx (lightweight and robust webserver). It's a pack because you can directly (optionaly) installs and configures PHP5 at the same time. There are three types of vhost available and some smart options for Nginx and PHP. This module is full IPv6 compliant because we are in 2013.

##Module Description

Features available:

* Install and configure Nginx
* Optionally: install and configure PHP5-FastCGI
* Optionally: install PHP-MySQL connector and/or others PHP5 modules
* Basic vhosts
* Proxy vhosts
* 301 redirection vhosts
* SSL suport
* Full IPv6 compliant (and still IPv4...)
* Automatic blackhole for non-existent domains
* Several options (upload limits with Nginx/PHP, timezone, logrotate, 
default SSL certificate, htpasswd, XSS injection protection, etc.)
* Custom configuration option for non-supported features

##What nginxpack affects

Packages:

* *nginx*
* With `enable_php`: *php5-cgi*, *spawn-fcgi*
* With `php_mysql`: *php5-mysql*
* With `logrotate`: *logrotate*, *psmisc*

*logrotate* is used with a configuration file in */etc/logrotate.d/nginx* allowing it to daily rotate vhost logs. The configuration uses `killall` from *psmisc* in order to force nginx to update his inodes (this is the classic way).

Use `nginxpack::php::mod { 'foo' }` implies install *php5-foo*.

Services:

* Use `/etc/init.d/nginx`
* Add `/etc/init.d/php-fastcgi` (and associated script `/usr/bin/php-fastcgi.sh`)

Files:

* Vhosts: */etc/nginx/site-{available,enabled}/* and */etc/nginx/include/*
* Logs: */var/log/nginx/<vhostname>/{access,error}.log*
* Certificates: */etc/nginx/ssl/*
* Script for automatic blackholes: */files/nginx/find_default_listen.sh*

Use `php_timezone`, `php_upload_max_filesize` and/or `php_upload_max_files` affects */etc/php5/cgi/php.ini* (but not override it).

##Usage

###Beginning with nginxpack

####Webserver

If you just want a webserver installing with the default options and without PHP you can run:

    include 'nginxpack'

With PHP:

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

With this example, you will be able to propose uploads of 5 files of 1G max each in the same time. In this case, the POST-data size limit (from PHP) will automatically be configured to accept until 5G.

You can also configure default https configuration here. See the first common use case.

####Basic vhost

Standard vhost.

Listen on all IPv6/IPv4 available with port 80, no PHP and no SSL:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
    }

With PHP:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
      use_php => true,
    }

Since you use `use_php` for at least one vhost, you have to use `enable_php` with the webserver.

Listen on a specific IPv6 and all IPv4 available:

    nginxpack::vhost::basic { 'foobar':
      domains => [ 'foobar.example.com' ],
      ipv6    => '2001:db8::42',
    }

You can use the `ipv4` option to listen on a specific IPv4 address or disable it with *false* (real \_wo\_men do that). `ipv6` also can be set to false, but please don't do that...

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

Generate *pem* (*crt*) and *key* files (put your domain in *Common Name*):

    $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout foobar.key -out foobar.pem

You also could use `ssl_cert_content` and `ssl_key_content` to define the certificate from a string (useful if you use hiera to store your certificates: `ssl_cert_content => hiera('foobar-pem')`).

The default port to listen on becomes 443 but you still could force a different one.

Other options:

    nginxpack::vhost::basic { 'foobar':
      domains         => [ 'foobar.example.com' ],
      enable          => false,
      injectionsafe   => true,
      upload_max_size => '5G',
      htpasswd        => 'user1:$apr1$EUoQVU1i$kcGRxeBAJaMuWYud6fxZL/',
    }

`injectionsafe` applies [these protections](http://www.howtoforge.com/nginx-how-to-block-exploits-sql-injections-file-injections-spam-user-agents-etc) against XSS injections. These restrictions might be incompatible with your applications.

`upload_max_size` should be in line with `php_upload_max_filesize`x`php_upload_max_files`

`htpasswd`'s value can be generated with a tool of *apache2-utils*:

    $ htpasswd -nb user1 secretpassword

If you want to use a specific configuration for a specific vhost, you can use `add_config_source` or `add_config_content` to inject custom Nginx instructions directly in `server { }`.

####Proxy vhost

Reverse-proxy vhost allowing you to seamlessly redirect the traffic to a remote webserver.

Default listen identical to basic vhosts, and reach remote server on port 80 without using SSL:

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

SSL (https://) is usable in the same manner as basic vhosts.

Options `ipv6`, `ipv4`, `port`, `enable`, `add_config_source`, `add_config_content` and `upload_max_size` are available in the same way as basic vhosts.

####Redirection vhost

General redirection (using 301 http code) allowing you to officially redirect requests to a remote domain. In short: __http://foobar.example.com/(.*) => http://foobar.com/$1__.

Default listen identical to basic vhosts, and reach remote domain on port 80 without using SSL:

    nginxpack::vhost::redirection { 'foobarlan':
      domains   => [ 'foobar.example.com' ],
      to_domain => 'www.foobar.com',
    }

Options `to_https` and `to_port` are available in the same way as proxy vhosts.

Options `ipv6`, `ipv4`, `port`, `enable`, `add_config_source` and `add_config_content` are available in the same way as basic vhosts.

###Documentation

The previous section should be clear enough to understand the possibilities of nginxpack.

If you want a detailed documentation of types and options, there is a full documentation in the headers of the [Puppet files](https://github.com/jvaubourg/puppetlabs-nginxpack/tree/master/manifests).

###Default vhosts

####Blackhole

Have a determinist way to access to the vhosts is a good practice in web security. If you say that a vhost can be reached via *my.example.com*, any requests with another domain should not success. If you do not have a *default vhost* with a listen line for each port used on the webserver, Nginx will use a doubful algorithm to determine which vhost is usable in the case of an unknown domain.

Nginxpack creates the default vhost for you and redirects any request out of your scopes to a black hole.

If you use at least one vhost with SSL, you need to define `ssl_default_*` options. See the next section about SSL.

####Well-known problem with SSL

The full circle is easy to understand:

1. Nginx chooses the correct vhost (among those who listen on the correct port and IP) thanks to the *host* field of HTTP 1.1.
2. When a client initiates a SSL connection, this field is encrypted, until Nginx decrypts the request.
3. Informations about decryption (e.g. certificate location) are in the correct vhost. Go back to *1*.

Thus, if you have several vhost listening on the same port and the same IP (or all IP) and that use SSL, you have a problem.

The good solution is to use a default vhost, listening on all ports and IP used by SSL vhosts on the webserver and containing the decryption informations. When Nginx will receive a SSL request, it will use this vhost, and so, will be able to decrypt it. Once the *host* field is readable, it can chose the correct vhost. The latter don't have to propose SSL but it absolutely must listen on port 443 (or another if you use SSL with another one).

Nginx creates this default vhost for you if you use `ssl_default_cert_source` (or `ssl_default_cert_key`) and `ssl_default_key_source` (or `ssl_default_key_source`). This certificate must be valid for all domains used, so it will probably be a wildcard certificate.

The first common use case in the next section gives an example.

##Common use cases

###Reverse-proxy with IPv4

You are in charge of servers in the wrong decade: there is almost no more IPv4 but you still can't use only IPv6. Thus, your provider provided you as many IPv6 addresses as there are grains of sand on earth, but only one poor IPv4.

If you have various webservers (on remote machines or in containers beside) on the same net access, you need to have a reverse-proxy. In the following examples, we consider that your firewall is configured to redirect ports 80 and 443 to the server corresponding to your reverse-proxy for any incoming IPv4 flux.

First example considers that your ISP provides you IPv6 addresses and that you are able to use it. Second example considers that you have a crappy ISP and so no IPv6 addresses available. For both examples, we want a blog, a wiki (https) and a members panel (https). For the sake of cleanliness and security reasons, each website must have its own webserver on its own container.

####With usable IPv6 addresses

Goals:

* 1 webserver (1 machine/container) by website and 1 for the reverse-proxy.
* IPv6 clients reach websites directly and can't use the reverse-proxy.
* IPv4 clients reach websites only through the reverse-proxy and can't reach them directly.
* Therefore, communications between the reverse-proxy and the remote websites use IPv6, but it's seamless for (IPv4) clients and there is no problem with IPv6 over the internal network.

The certificat location is provided on the reverse-proxy for IPv4 clients (see previous section), and on the vhosts for IPv6 clients. Proxy vhosts listen on port 443 but not have SSL capabilities (see again the previous section).

Webserver hosting the reverse-proxy:

    # Can be replaced by a classic internal domain server
    host {
      'blog.lan':
        ip => '2001:db8::a';
      'wiki.lan':
        ip => '2001:db8::b';
      'members.lan':
        ip => '2001:db8::c';
    }

    class { 'nginxpack':
      ssl_default_cert_source => 'puppet:///certificates/default.pem',
      ssl_default_key_source  => 'puppet:///certificates/default.key',
    }

    nginxpack::vhost::proxy { 'blog':
      domains   => [ 'blog.example.com' ],
      ipv6      => false,
      to_domain => 'blog.lan',
    }

    nginxpack::vhost::proxy { 'wiki':
      domains   => [ 'wiki.example.com' ],
      port      => 443,
      ipv6      => false,
      to_domain => 'wiki.lan',
      to_https  => true,
    }

    nginxpack::vhost::proxy { 'members':
      domains   => [ 'members.example.com' ],
      port      => 443,
      ipv6      => false,
      to_domain => 'members.lan',
      to_https  => true,
    }

Webserver hosting *blog.example.com*:

    nginxpack::vhost::basic { 'blog':
      domains => [ 'blog.example.com' ],
      ipv4    => false,
      use_php => true,
    }

Webserver hosting *wiki.example.com*:

    nginxpack::vhost::basic { 'wiki':
      domains         => [ 'wiki.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/default.pem',
      ssl_key_source  => 'puppet:///certificates/default.key',
      ipv4            => false,
      use_php         => true,
    }

Webserver hosting *members.example.com*:

    nginxpack::vhost::basic { 'members':
      domains         => [ 'members.example.com' ],
      https           => true,
      ssl_cert_source => 'puppet:///certificates/default.pem',
      ssl_key_source  => 'puppet:///certificates/default.key',
      ipv4            => false,
      use_php         => true,
    }

####Without IPv6 addresses

Goals:

* 1 webserver (1 machine/container) by website and 1 for the reverse-proxy.
* Clients reach websites only through the reverse-proxy and can't reach them directly.
* We trust in the internal network so communications between the reverse-proxy and the websites are never encrypted.

Webserver hosting the reverse-proxy:

    # Can be replaced by a classic internal domain server
    host {
      'blog.lan':
        ip => '10.0.0.10';
      'wiki.lan':
        ip => '10.0.0.20';
      'members.lan':
        ip => '10.0.0.30';
    }

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

###Usage of www

Using *www.example.com* is so 2005 and you want automatically redirect all request from _www.example.com/.*_ to *example.com/$1*.

    nginxpack::vhost::redirection { 'blog':
      domains   => [ 'www.example.com' ],
      to_domain => 'example.com',
    }

###Port redirection

Proxy and redirection vhots use the first value of `domains` when `to_domain` is absent.

####Seamlessly

Your webapp listen on port 8080 but you want use it on port 80 without change its configuration:

    nginxpack::vhost::proxy { 'webapp':
      domains => [ 'example.com' ],
      to_port => 8080,
    }

####Not Seamlessly

Visible location switch (the client will see his URL transforming: _example.com/.*_ => *example.com:8080/$1*) means redirection:

    nginxpack::vhost::redirection { 'webapp':
      domains => [ 'example.com' ],
      to_port => 8080,
    }

####Add IPv6/IPv4 access

You have a website not available in IPv6 and you cannot have IPv6 on its machine. A way to solving this problem is to create a proxy that listens with IPv6 and have also an IPv4 address to contact the remote website:

    nginxpack::vhost::proxy { 'webapp':
      domains   => [ 'ip6.example.com' ],
      to_domain => 'example.com',
    }

This trick could also be used with the reverse case.

##Limitations

This module is **only available for Debian**.

Tests are made with:

* Debian Wheezy
* Puppet 3.2.4

This does not mean that this module can't be used with other versions but I have no idea about the compatibility.

##Development

I developed this module for my own needs but I think it's generic enough to be useful for someone else.

[Feel free to contribute](https://github.com/jvaubourg/puppetlabs-nginxpack/). I'm not a big fan of centralized services like GitHub but I used it to permit easy pull-requests, so show me that's a good idea!

Thank [Lorraine Data Network](http://ldn-fai.net) for testing the module.
