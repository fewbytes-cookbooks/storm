#
# Cookbook Name:: storm
# Recipe:: supervisor
#
# Copyright (C) 2013 Fewbytes
# 

include_recipe "storm"

runit_service "storm-supervisor" do
	run_template_name "storm"
	log_template_name "storm"
	options :daemon => "supervisor"
	subscribes :restart, "template[#{::File.join(node["storm"]["conf_dir"], "storm.yaml")}]"
end