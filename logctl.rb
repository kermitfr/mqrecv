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

require 'rubygems'
require 'daemons'

$LOAD_PATH << '/usr/local/bin/kermit/queue/'
require 'recv'

PIDDIR='/var/run'

app_options = {
      :dir_mode => :normal,
      :dir => PIDDIR,
}

def setid(uname,gname)
  uid = Etc.getpwnam(uname).uid
  gid = Etc.getgrnam(gname).gid
  Process::Sys.setgid(gid)
  Process::Sys.setuid(uid)
end

Daemons.run_proc('kermit-log', app_options) do
  setid('nobody','nobody')
  r=Recv.new(source='/queue/kermit.log')
  r.mainloop
end
