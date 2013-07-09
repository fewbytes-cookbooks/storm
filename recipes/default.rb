#
# Cookbook Name:: storm
# Recipe:: default
#
# Copyright (C) 2013 Fewbytes
# 

package "zip"
include_recipe "java"
include_recipe "zeromq"
include_recipe "maven"

group node["storm"]["group"]

user node["storm"]["user"] do
	gid node["storm"]["group"]
end

ark "storm" do
	version node["storm"]["version"]
	url node["storm"]["download_url"]
	checksum node["storm"]["checksum"]
	home_dir node["storm"]["home_dir"]
	action :install
end

execute "delete log and conf dirs" do
	command "rm -rf logs conf"
	cwd node["storm"]["home_dir"]
	not_if { %w(logs conf).inject(true) { |a, dir| a and
		::File.symlink?(::File.join(node["storm"]["home_dir"], dir))}}
end

maven "jzmq" do
	group_id "org.zeromq"
	artifact_id "jzmq"
	version "2.2.0"
	dest ::File.join(node["storm"]["home_dir"], "lib")
end

[node["storm"]["local_dir"], node["storm"]["log_dir"]].each do |dir|
	directory dir do
		owner node["storm"]["user"]
		group node["storm"]["group"]
		mode 00755
		action :create
	end
end

directory node["storm"]["conf_dir"] do
	mode 00755
	action :create
end

link ::File.join(node["storm"]["home_dir"], "conf") do
	to node["storm"]["conf_dir"]
end

link ::File.join(node["storm"]["home_dir"], "logs") do
	to node["storm"]["log_dir"]
end

if Chef::Config[:solo]
	Chef::Log.warn "Chef solo does not support search, assuming Zookeeper and Nimbus are on this node"
	nimbus = node
	zk_nodes = [node]
else
	nimbus = if node.recipe? "storm::nimbus"
		node
	else
		nimbus_nodes = search(:node, "recipes:storm\\:\\:nimbus AND storm_cluster_name:#{node["storm"]["cluster_name"]} AND chef_environment:#{node.chef_environment}")
		raise RuntimeError, "Nimbus node not found" if nimbus_nodes.empty?
		nimbus_nodes.sort.first
	end
	zk_nodes = search(:node, "zookeeper_cluster_name:#{node["storm"]["zookeeper"]["cluster_name"]} AND chef_environment:#{node.chef_environment}").sort
	raise RuntimeError, "No zookeeper nodes nodes found" if zk_nodes.empty?
end

template ::File.join(node["storm"]["home_dir"], "conf", "storm.yaml") do
	mode 00644
	variables :zookeeper_nodes => zk_nodes, :nimbus => nimbus
end
