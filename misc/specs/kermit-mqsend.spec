%define gitrev 0b3db2f 

Name:      kermit-mqsend
Summary:   A custom queue publisher using the MCollective framework 
Version:   1.0
Release:   5%{?dist}
License:   GPLv3
Group:     System Tools 
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mqrecv-%{gitrev}.tar.gz 
Requires:  mcollective-common, rubygem-inifile
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch

%description
A custom queue publisher reusing all the mc transport wrappers, with a receiving
daemon.
MCollective uses topics, but here we use a queue that makes the system very
resilient and scalable, suited specifically for handling lots of larger chunks
of data.
We use it to send big messages (50k-200k) with some inventory information.


%prep
%setup -n thinkfr-mqrecv-%{gitrev}

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/local/bin/kermit/queue/
install send.rb %{buildroot}/usr/local/bin/kermit/queue
install sendlog.rb %{buildroot}/usr/local/bin/kermit/queue

%clean
rm -rf %{buildroot}

%pre
mkdir -p /usr/local/bin/kermit/queue

%files
%defattr(0644,root,root,-)
/usr/local/bin/kermit/queue/send.rb
/usr/local/bin/kermit/queue/sendlog.rb

%changelog
* Tue Dec 13 2011 Louis Coilliot
- send all in raw mode 
* Fri Nov 11 2011 Louis Coilliot
- 2 send queues : inventory and log
* Fri Sep  9 2011 Louis Coilliot
- Don't depend on the configuration files of MCollective
* Mon Aug 29 2011 Louis Coilliot
- With SSL and specific keys
* Thu Aug 18 2011 Louis Coilliot
- Initial build

