name             "backup"
maintainer       "Cramer Development, Inc."
maintainer_email "sysadmin@cramerdev.com"
license          "Apache 2.0"
description      "Installs/Configures backup"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.3.1"

depends          "cron"
depends          "apt"
depends          "backup"
