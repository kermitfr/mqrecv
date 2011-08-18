%define gitrev 0b3db2f 

Name:      kermit-mqrecv 
Summary:   A custom queue consumer using the Mcollective framework 
Version:   1.0
Release:   2%{?dist}
License:   GPLv3
Group:     System Tools 
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mqrecv-%{gitrev}.tar.gz 
Requires:  rubygem-daemons, mcollective-common
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch

%description
A custom queue consumer reusing all the mc transport wrappers, with a receiving
daemon.
Mcollective uses topics, but here we use a queue that makes the system very
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
install recvctl.rb  %{buildroot}/usr/local/bin/kermit/queue
install service/kermit-mqrecv %{buildroot}/etc/init.d 

%clean
rm -rf %{buildroot}

%pre
mkdir -p /usr/local/bin/kermit/queue

%files
%defattr(0644,root,root,-)
%attr(0755, root, root) /usr/local/bin/kermit/queue/recvctl.rb
/usr/local/bin/kermit/queue/recv.rb
%attr(0755,root,root) /etc/init.d/kermit-mqrecv

%changelog
* Thu Aug 18 2011 Louis Coilliot
- package splited in two : publisher and consumer
- no need of rubygem-json (Mcollective provides a JSON parser)
* Thu Aug 18 2011 Louis Coilliot
- Initial build

