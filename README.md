# haenawa 環境構築手順

## 環境
CentOS7

Ruby-2.3.8

## Package install
```
$ sudo yum -y install chrpath mariadb mariadb-server mariadb-devel systemd-devel unixODBC-devel
$ curl -sL https://rpm.nodesource.com/setup_8.x | sudo bash -
$ sudo yum install -y nodejs
```

## Gems install
```
$ sudo rm -f /usr/local/bin/update_rubygems
$ sudo gem update --system --no-document
$ sudo gem install -f rdoc --no-document
$ sudo gem install -f rake --no-document -v=12.3.1
$ sudo gem install bundler --quiet --no-document -v=1.16.6
```

## Setup mysql
mysqlのポートをデフォルトから変更する場合、本手順を実施。
```
$ sudo vi /etc/my.cnf
```
* /etc/my.cnf
```
[mysqld]
port=13306 # add
```

## Start mysql
mysql(mariadb)を起動。
```
$ sudo systemctl enable mariadb
$ sudo systemctl start mariadb
```

## Grant for app user
```
$ mysql -u root -p mysql
MariaDB [mysql]> GRANT ALL PRIVILEGES ON *.* TO haenawa@'%' IDENTIFIED BY '{password}' WITH GRANT OPTION;
```

## Start haenawa
```
$ cd [haenawa_root]
$ bundle install
$ rake db:reset
$ rails s
```
`localhost:3000`でアクセスする。
