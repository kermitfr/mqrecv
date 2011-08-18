%define gitrev 0b3db2f 

Name:      kermit-mqsend
Summary:   A custom queue publisher using the Mcollective framework 
Version:   1.0
Release:   1%{?dist}
License:   GPLv3
Group:     System Tools 
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mqrecv-%{gitrev}.tar.gz 
Requires:  mcollective-common
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch

%description
A custom queue publisher reusing all the mc transport wrappers, with a receiving
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
install send.rb %{buildroot}/usr/local/bin/kermit/queue

%clean
rm -rf %{buildroot}

%pre
mkdir -p /usr/local/bin/kermit/queue

%files
%defattr(0644,root,root,-)
/usr/local/bin/kermit/queue/send.rb

%changelog
* Thu Aug 18 2011 Louis Coilliot
- Initial build

