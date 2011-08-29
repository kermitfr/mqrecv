#!/usr/bin/ruby
# Copyright (C) 2011 Louis Coilliot (louis.coilliot at gmail.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# You may need to set ACLs for the resource
# Check :
# rabbitmqctl list_user_permissions -p '/' mcollective 
# rabbitmqctl set_permissions -p '/' mcollective ".*" ".*" ".*"

require 'mcollective'
require 'json'

uid = Etc.getpwnam("nobody").uid
Process::Sys.setuid(uid)

TMPDIR='/tmp'

source = "/queue/inventory.custom"

oparser = MCollective::Optionparser.new
options = oparser.parse

config = MCollective::Config.instance
config.loadconfig(options[:config])
# We need this to be able to pick the key to decode what's sent : 
config.pluginconf['ssl_client_cert_dir']='/etc/mcollective/ssl/clients/'
# !!!DON'T!!! put the private key used to encode the sent message on this node.
# Only the public key, to decode the message.

security = MCollective::PluginManager["security_plugin"]
security.initiated_by = :node

connector = MCollective::PluginManager["connector_plugin"]
connector.connect
connector.connection.subscribe(source)

loop do
    msg = connector.receive
    msg = security.decodemsg(msg)
    fileout="#{TMPDIR}/#{msg[:requestid]}"
    File.open(fileout, 'w') {|f| f.write(msg[:body].to_json) }
    puts fileout
end

