{ pkgs? import <nixpkgs> {} }:

with pkgs; stdenv.mkDerivation rec {
  pname = "ovn";
  version = "23.06.0";

  src = fetchFromGitHub {
    owner = "ovn-org";
    repo = "ovn";
    sha256 = "stll+dtSyeBOtM+YYdQz5qxBOKq8IZtsQ2bmDJ2rgEA=";
    rev = "638de44d53a3f7c8387ae980fd3e99ce1c9e47d9";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
  ];


  nativeBuildInputs = [
    autoconf
    automake
    breakpointHook
    libtool
    pkg-config
  ];

  buildInputs = [
    libcap_ng
    openssl
    perl
    procps
    python3
    util-linux
    which
  ];

  preConfigure = ''
    ./boot.sh
    cd ovs
    ./boot.sh
    ./configure
    make -j 4
    cd ..
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sharedstatedir=/var"
    "--sbindir=$(out)/bin"
  ];

  # Leave /var out of this!
  installFlags = [
    "LOGDIR=$(TMPDIR)/dummy"
    "RUNDIR=$(TMPDIR)/dummy"
    "PKIDIR=$(TMPDIR)/dummy"
  ];

  enableParallelBuilding = true;

  # TODO 176 failed
  # doCheck = true;

  nativeCheckInputs = [
    iproute2
  ] ++ (with python3.pkgs; [
    netaddr
    pyparsing
    pytest
  ]);

  meta = with lib; {
    changelog = "https://www.ovn.org/en/releases/release_${version}/";
    description = "Series of daemons for the Open vSwitch that translate virtual network configurations into OpenFlow";
    longDescription = ''
      OVN provides a higher-layer of abstraction than Open vSwitch, working with logical routers and logical switches,
      rather than flows. OVN is intended to be used by cloud management software (CMS).
      For details about the architecture of OVN, see the ovn-architecture manpage.
      Some high-level features offered by OVN include:
        Distributed virtual routers
        Distributed logical switches
        Access Control Lists
        DHCP
        DNS server
      Like Open vSwitch, OVN is written in platform-independent C.
      OVN runs entirely in userspace and therefore requires no kernel modules to be installed.
    '';
    homepage = "https://www.ovn.org";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
