# storm cookbook
This cookbook installs and configures [Storm](http://storm-project.net/)

# Requirements
Zookeeper cluster, should be installed using the zookeeper cookbook (see berksfile). The `zookeeper_cluster_name` attribute should match Zookeeper's `node["zookeeper"]["cluster_name"]` attribute.

# Usage
`include_recipe "storm::supervisor"` on the supervisor nodes, `include_recipe "storm::nimbus"` on the nimbus node.

# Attributes

# Recipes
storm::default - Installs storm files, configures directories, etc.
storm::nimbus - nimbus and UI services
storm::supervisor - supervisor daemon

# Author
Some parts (templates and attributes) have been copied from Webtrends' cookbook (https://github.com/Webtrends/Cookbooks/blob/master/storm); Credit is due.

Author:: Avishai Ish-Shalom (<avishai@fewbytes.com>)
