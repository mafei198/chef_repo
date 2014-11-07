#
# Cookbook Name:: erlang_instance
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'mysql::server'
include_recipe 'mysql::client'
include_recipe 'monit-ng::default'

# template '/etc/mysql/conf.d/mysite.cnf' do
#   owner 'mysql'
#   owner 'mysql'
#   source 'mysite.cnf.erb'
#   notifies :restart, 'mysql_service[default]'
# end

mysql_service 'default' do
  version '5.5'
  port '3306'
  # data_dir '/data'
  # template_source 'custom.erb'
  action :create
end

monit_check 'nginx' do
  check_id  '/var/run/nginx.pid'
  start     '/etc/init.d/nginx start'
  stop      '/etc/init.d/nginx stop'
  tests [
    {
      'condition' => 'failed port 80',
      'action'    => 'restart'
    },
    {
      'condition' => '3 restarts within 5 cycles',
      'action'    => 'alert'
    }
  ]
end

monit_check 'redis' do
  check_id  '/var/run/redis/6379/redis_6379.pid'
  start     '/etc/init.d/redis6379 start'
  stop      '/etc/init.d/redis6379 stop'
  tests [
    {
      'condition' => 'failed host 127.0.0.1 port 6379
                     send "SET MONIT-TEST value\r\n" expect "OK"
                     send "EXISTS MONIT-TEST\r\n" expect ":1"',
      'action'    => 'restart'
    },
    {
      'condition' => '3 restarts within 5 cycles',
      'action'    => 'alert'
    },
  ]
end

monit_check 'mysql' do
  check_id '/var/run/mysqld/mysql.pid'
  start    '/etc/init.d/mysql start'
  stop     '/etc/init.d/mysql stop'
  tests [
    {
      'condition' => 'failed port 3306',
      'action'    => 'restart'
    },
    {
      'condition' => '5 restarts within 5 cycles',
      'action'    => 'timeout'
    }
  ]
end

# monit_check 'mysql' do
#   id_type  'matching'
#   check_id 'mysqld'
#   start    '/etc/init.d/mysql start'
#   stop     '/etc/init.d/mysql stop'
#   tests [
#     {
#       'condition' => 'failed port 3306',
#       'action'    => 'restart'
#     },
#     {
#       'condition' => '5 restarts within 5 cycles',
#       'action'    => 'timeout'
#     }
#   ]
# end

# FIXME reload not working
service 'monit' do
  action :restart
end

directory "/home/ubuntu/redis_db_data" do
  action :create
end

package "ruby1.9.3"
package "git-core"
package "nodejs"

gem_package "rails" do
  version "3.2"
  action  :install
end
