# WooCommerce Installer on your desktop.

WooCommerce development environment with PHP built-in web server + WP-CLI.
fork by [miya0001/wp-instant-setup: WordPress desktop installer](https://github.com/miya0001/wp-instant-setup)


## Requires

* OSX
* php 5.4 or later
* MySQL
* wget

### Recommend

* [Mailcatcher](http://mailcatcher.me/)

## Uage

```
$ curl https://.../run.sh | bash -s <db-name> <db-user> <db-pass>
```

or

```
$ ./run.sh <db-name> <db-user> <db-pass>
```

### Defaults

* db-name: `woodev`
* db-user: `root`
* db-pass: (empty)

## How to use

```
$ mkdir ~/Desktop/wordpress && cd $_
$ curl https://raw.githubusercontent.com/musus/woo-instant-setup/master/run.sh | bash
```

Or

```
$ git clone git@github.com:musus/woo-instant-setup.git && cd wp-instant-setup
$ ./run.sh
```


## Default Account

* User: `admin`
* Password: `admin`
