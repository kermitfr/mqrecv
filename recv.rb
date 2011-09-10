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
require 'inifile'
require 'fileutils'

uid = Etc.getpwnam("nobody").uid
Process::Sys.setuid(uid)

# Kermit parameters
SECTION = 'amqpqueue'
MAINCONF = '/etc/kermit/kermit.cfg'
ini=IniFile.load(MAINCONF, :comment => '#')
params = ini[SECTION]

amqpcfg = params['amqpcfg']
source = params['queuename']
outputdir = params['outputdir']

oparser = MCollective::Optionparser.new
options = oparser.parse
options[:config] = amqpcfg

config = MCollective::Config.instance
config.loadconfig(options[:config])


security = MCollective::PluginManager["security_plugin"]
security.initiated_by = :node

connector = MCollective::PluginManager["connector_plugin"]
connector.connect
connector.connection.subscribe(source)

loop do
    msg = connector.receive
    begin
        msg = security.decodemsg(msg)
    rescue RuntimeError, TypeError
        next
    end
    fileout="#{outputdir}/#{msg[:requestid]}"
    basefile = msg[:requestid].gsub(/[a-f0-9]{32}-/,'\1')
    Dir.foreach(outputdir) do |f|
        if f =~ /[a-f0-9]{32}-#{basefile}/
            # Delete previous versions
            FileUtils.rm( "#{outputdir}//#{f}" )
        end
    end
    File.open(fileout, 'w') {|f| f.write(msg[:body].to_json) }
end

