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

require 'mcollective'
require 'json'

def publish(msg, security, connector, config)
   target = "/queue/inventory.custom"
   reqid = Digest::MD5.hexdigest("#{config.identity}-#{Time.now.to_f.to_s}-#{target}")
   reqid << "-" << File.basename(ARGV[0])
   req = security.encoderequest(config.identity, target, msg, reqid, {}, "custominventory", "mcollective")

   Timeout.timeout(2) do
      # Newer stomp rubygem :
      # connector.connection.publish(target, req)
      # Older stomp rubygem :
      connector.connection.send(target, req)
   end
end

# default mcollective client options like --config etc will be valid
oparser = MCollective::Optionparser.new
options = oparser.parse

config = MCollective::Config.instance
# We read client.cfg (readable for a standard user) :
config.loadconfig(options[:config])
# We override the mcollective keys to use a new pair specific to the queue
# !!!!DON'T!!!! really put the q-public.pem in the ssl/clients/ folder on the
# sending nodes.
# We just need this to send the name of the decoding key to the receiver
config.pluginconf['ssl_client_public']='/etc/mcollective/ssl/clients/q-public.pem'
# This key is used to encode and needed on the nodes in ssl/clients/ :
config.pluginconf['ssl_client_private']='/etc/mcollective/ssl/clients/q-private.pem'
# !!!!DON'T!!!! put the q-private.pem key on the receiver node.

security = MCollective::PluginManager["security_plugin"]
security.initiated_by = :client

connector = MCollective::PluginManager["connector_plugin"]
connector.connect


#data = "Louis was here"
#publish(data, security, connector, config)


ficname = ARGV[0] || raise("Argument required")
fic = File.open(ficname, 'r')
data = JSON.parse(fic.readlines.to_s)
publish(data, security, connector, config)


