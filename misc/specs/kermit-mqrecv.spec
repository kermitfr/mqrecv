%define gitrev e915c6a 

Name:      kermit-mqrecv 
Summary:   A custom queue consumer using the mcollective framework 
Version:   1.0
Release:   1%{?dist}
License:   GPLv3
Group:     System Tools 
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mqrecv-%{gitrev}.tar.gz 
Requires:  rubygem-daemons, rubygem-json, mcollective-common
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch

%description
A custom queue consumer reusing all the mc transport wrappers, with a receiving
daemon.
Mcollective uses topics, but here we use a queue that makes the system very
resilient and scalable, suited specifically for handling lots of larger chunks
of data.
We use it to send big messages (50k-200k) with some inventory information.


%prep
%setup -n thinkfr-mqrecv-%{gitrev}

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/usr/local/bin/kermit/queue/
install -d -m 755 %{buildroot}/etc/init.d
install recv.rb %{buildroot}/usr/local/bin/kermit/queue
install recvctl.rb  %{buildroot}/usr/local/bin/kermit/queue
install send.rb %{buildroot}/usr/local/bin/kermit/queue
install service/kermit-mqrecv %{buildroot}/etc/init.d 

%clean
rm -rf %{buildroot}

%pre
mkdir -p /usr/local/bin/kermit/queue

%files
%defattr(0644,root,root,-)
%attr(0755, root, root) /usr/local/bin/kermit/queue/recvctl.rb
/usr/local/bin/kermit/queue/recv.rb
/usr/local/bin/kermit/queue/send.rb
%attr(0755,root,root) /etc/init.d/kermit-mqrecv

%changelog
* Thu Aug 18 2011 Louis Coilliot
- Initial build

