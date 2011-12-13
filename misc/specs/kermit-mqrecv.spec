%define gitrev cdd6f2f 

Name:      kermit-mqrecv 
Summary:   A custom queue consumer using the MCollective framework 
Version:   1.0
Release:   8%{?dist}
License:   GPLv3
Group:     System Tools 
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mqrecv-%{gitrev}.tar.gz 
Requires:  rubygem-daemons, rubygem-inifile, mcollective-common
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch

%description
A custom queue consumer reusing all the mc transport wrappers, with a receiving
daemon.
MCollective uses topics, but here we use a queue that makes the system very
resilient and scalable, suited specifically for handling lots of larger chunks
of data.
We use it to send big messages (50k-200k) with some inventory information.
You may need to :
rabbitmqctl set_permissions -p '/' mcollective ".*" ".*" ".*"


%prep
%setup -n thinkfr-mqrecv-%{gitrev}

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/local/bin/kermit/queue/
install -d -m 755 %{buildroot}/etc/init.d
install recv.rb %{buildroot}/usr/local/bin/kermit/queue
install inventoryctl.rb  %{buildroot}/usr/local/bin/kermit/queue
install logctl.rb %{buildroot}/usr/local/bin/kermit/queue
install genkey.sh  %{buildroot}/usr/local/bin/kermit/queue
install service/kermit-inventory %{buildroot}/etc/init.d 
install service/kermit-log %{buildroot}/etc/init.d 

%clean
rm -rf %{buildroot}

%pre
mkdir -p /usr/local/bin/kermit/queue

%files
%defattr(0644,root,root,-)
%attr(0755,root,root) /usr/local/bin/kermit/queue/inventoryctl.rb
%attr(0755,root,root) /usr/local/bin/kermit/queue/logctl.rb
%attr(0755,root,root) /usr/local/bin/kermit/queue/genkey.sh 
/usr/local/bin/kermit/queue/recv.rb
%attr(0755,root,root) /etc/init.d/kermit-inventory
%attr(0755,root,root) /etc/init.d/kermit-log


%changelog
* Tue Dec 13 2011 Louis Coilliot
- send all in raw mode, in the end
* Mon Nov 14 2011 Louis Coilliot
- to_json for inventories or not to_json for log files
* Fri Nov 11 2011 Louis Coilliot
- now there are 2 queues : inventory and log 
* Sat Sep 10 2011 Louis Coilliot
- Resilient with garbage messages
- Remove previous versions of sent files with the same name
* Fri Sep  9 2011 Louis Coilliot
- Don't depend on the configuration files of MCollective
* Mon Aug 29 2011 Louis Coilliot
- With SSL and specific keys
* Thu Aug 18 2011 Louis Coilliot
- Package splited in two : publisher and consumer
- No need of rubygem-json (MCollective provides a JSON parser)
* Thu Aug 18 2011 Louis Coilliot
- Initial build

