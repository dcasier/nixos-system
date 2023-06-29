{ pkgs? import <nixpkgs> {} }:

with pkgs; stdenv.mkDerivation rec {
  pname = "openvswitch";
  version = "3.1.1";

  src = fetchurl {
    url = "https://www.openvswitch.org/releases/${pname}-${version}.tar.gz";
    hash = "sha256-YEiRg6RNO5WlUiQHIhfF9tN6oRvhKnV2JRDO25Ok4gQ=";
  };

  outputs = [
    "out"
  ];

  patches = [
    # 8: vsctl-bashcomp - argument completion FAILED (completion.at:664)
    ./patches/disable-bash-arg-completion-test.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
    installShellFiles
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

  preConfigure = "./boot.sh";

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

  postInstall = ''
    installShellCompletion --bash utilities/ovs-appctl-bashcomp.bash
    installShellCompletion --bash utilities/ovs-vsctl-bashcomp.bash
  '';

  # TODO :  testsuite: 169 170 171 173 174 175 176 177 178 179 180 498 499 500 501 503 failed
  # doCheck = true;

  nativeCheckInputs = [
    iproute2
  ] ++ (with python3.pkgs; [
    netaddr
    pyparsing
    pytest
  ]);

  meta = with lib; {
    changelog = "https://www.openvswitch.org/releases/NEWS-${version}.txt";
    description = "A multilayer virtual switch";
    longDescription = ''
      Open vSwitch is a production quality, multilayer virtual switch
      licensed under the open source Apache 2.0 license. It is
      designed to enable massive network automation through
      programmatic extension, while still supporting standard
      management interfaces and protocols (e.g. NetFlow, sFlow, SPAN,
      RSPAN, CLI, LACP, 802.1ag). In addition, it is designed to
      support distribution across multiple physical servers similar
      to VMware's vNetwork distributed vswitch or Cisco's Nexus 1000V.
    '';
    homepage = "https://www.openvswitch.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ netixx kmcopper ];
    platforms = platforms.linux;
  };
}
