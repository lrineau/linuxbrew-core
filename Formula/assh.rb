class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  url "https://github.com/moul/advanced-ssh-config/archive/v2.9.3.tar.gz"
  sha256 "d700a23a97b579aa48ee8ecc6d30878acc0840d368c7a0089c7c20f6fa028c71"
  head "https://github.com/moul/assh.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "4e652381a62b966d3b90ba2cdcb7aaedf9676f3054e97dd52ed06be509aee560" => :catalina
    sha256 "3ee9c68e116a26eb1c771777dbf67f7e0a15090eddf842c549fbaa564d05304b" => :mojave
    sha256 "8199f891c20cd044bc6a3ff818416bf6822b0af84bfde9cc38a272e47acd6eff" => :high_sierra
    sha256 "c0ab4b3eb22d6d429a630f4f4a31806aadba019430119134d0f458e7f29b4511" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w", "-trimpath", "-o", bin/"assh"
    prefix.install_metafiles
  end

  test do
    assh_config = testpath/"assh.yml"
    assh_config.write <<~EOS
      hosts:
        hosta:
          Hostname: 127.0.0.1
      asshknownhostfile: /dev/null
    EOS

    output = "hosta assh ping statistics"
    assert_match output, shell_output("#{bin}/assh --config #{assh_config} ping -c 4 hosta 2>&1")
  end
end
