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
require 'inifile'
require 'json'

def publish(msg, security, connector, config, queuename)
   target = queuename 
   reqid = Digest::MD5.hexdigest(
                    "#{config.identity}-#{Time.now.to_f.to_s}-#{target}")
   reqid << "-" << File.basename(ARGV[0])
   if MCollective.version.split('.').first.to_i > 1
     req = security.encoderequest(config.identity, msg, reqid, "",
                                "kermit", "mcollective")
   else
     req = security.encoderequest(config.identity, target, msg, reqid, {},
                                "kermit", "mcollective")
   end

   Timeout.timeout(2) do
      begin
          # Newer stomp rubygem :
          connector.connection.publish(target, req)
      rescue
          # Older stomp rubygem :
          connector.connection.send(target, req)
      end
   end
end


# Kermit parameters
SECTION = 'amqpqueue'
MAINCONF = '/etc/kermit/kermit.cfg'
ini=IniFile.load(MAINCONF, :comment => '#')
params = ini[SECTION]
amqpcfg = params['amqpcfg']
queuename = params['logqueuename'] 


# default mcollective client options like --config etc will be valid
oparser = MCollective::Optionparser.new
options = oparser.parse
options[:config] = amqpcfg 

config = MCollective::Config.instance
config.loadconfig(options[:config])

security = MCollective::PluginManager["security_plugin"]
security.initiated_by = :client

connector = MCollective::PluginManager["connector_plugin"]
connector.connect

#data = "Louis was here"
#publish(data, security, connector, config)


ficname = ARGV[0] || raise("Argument required")
fic = File.open(ficname, 'r')
publish(fic.read, security, connector, config, queuename)


