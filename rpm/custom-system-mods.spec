Name:       custom-system-mods
Version:    1.0.0
Release:    1
Summary:    Full custom overrides for Sailfish OS
License:    GPLv2
BuildArch:  noarch

%description
Complete system overrides mirroring /usr, /etc, and /opt.

%prep

%build

%install
# Erstelle Zielordner im Paket
mkdir -p %{buildroot}/usr %{buildroot}/etc %{buildroot}/opt

# Kopiere Ordner nur, wenn sie im Repo existieren
[ -d %{_sourcedir}/../usr ] && cp -r %{_sourcedir}/../usr/* %{buildroot}/usr/ || true
[ -d %{_sourcedir}/../etc ] && cp -r %{_sourcedir}/../etc/* %{buildroot}/etc/ || true
[ -d %{_sourcedir}/../opt ] && cp -r %{_sourcedir}/../opt/* %{buildroot}/opt/ || true

%files
/usr/*
/etc/*
/opt/*