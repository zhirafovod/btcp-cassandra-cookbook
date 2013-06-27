#
# Cookbook Name::       btcp-cassandra
# Description::         BtCP specific configuration for Cassandra
# Recipe::              default
# Author::              Sergey Sergeev ( zhirafovod@gmail.com )
#
# Copyright 2013, Sergey Sergeev <zhirafovod@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# deploy required files
cookbook_file "/etc/apt/sources.list.d/cassandra.list" do
	source "cassandra.list"
	mode "0644"
  owner "root"
  group "root"
  action :create
end
cookbook_file "/var/tmp/create.data" do
	source "create.data"
	mode "0644"
  owner "root"
  group "root"
  action :create
end
cookbook_file "/var/tmp/recreate.data" do
	source "recreate.data"
	mode "0644"
  owner "root"
  group "root"
  action :create
end

# add remote repository keys to install Cassandra and Chef
execute "gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D"
execute "gpg --export --armor F758CE318D77295D | apt-key add -"
execute "gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00"
execute "gpg --export --armor 2B5C1B00 | apt-key add -"
execute "gpg --fetch-key http://apt.opscode.com/packages@opscode.com.gpg.key"
execute "gpg --export packages@opscode.com | tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null"
execute "aptitude update"

# install cassandra from the repository above
package 'cassandra'

# install cassandra configuration
service "cassandra" do
  action :stop
end
cookbook_file "/etc/cassandra/cassandra.yaml" do
	source "cassandra.yaml.erb"
	mode "0644"
  owner "root"
  group "root"
  action :create
end
service "cassandra" do
  action :restart
end

# init data on the master
execute "cassandra-cli -h localhost -f /var/tmp/create.data"
