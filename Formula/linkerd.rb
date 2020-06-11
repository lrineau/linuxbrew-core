class Linkerd < Formula
  desc "Command-line utility to interact with linkerd"
  homepage "https://linkerd.io"

  url "https://github.com/linkerd/linkerd2.git",
    :tag      => "stable-2.8.0",
    :revision => "7a9527bf005710bf90db4b15c35e1f7b059f497d"

  bottle do
    cellar :any_skip_relocation
    sha256 "28e387d5b1d4cc66b3b369039518ce0d1d66c31a05632c1b47cec1dc8dac1ff7" => :catalina
    sha256 "612b408760782dd81b6c8a15f212a1f03cf8aa1f92d9dd6788a741544765dcdf" => :mojave
    sha256 "aecfbb497cb5b4f39e7525ba113eeb1627c4dd88b039fa6daa8076083bcb0482" => :high_sierra
    sha256 "54f24e1e99f84b1e19711af5f1290cddb5f0193efb72e9f36470ead68ecbde88" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["CI_FORCE_CLEAN"] = "1"

    os = if OS.mac?
      "darwin"
    else
      "linux"
    end

    system "bin/build-cli-bin"
    bin.install "target/cli/#{os}/linkerd"

    # Install zsh completion
    output = Utils.popen_read("#{bin}/linkerd completion zsh")
    (zsh_completion/"linkerd").write output

    prefix.install_metafiles
  end

  test do
    run_output = shell_output("#{bin}/linkerd 2>&1")
    assert_match "linkerd manages the Linkerd service mesh.", run_output

    version_output = shell_output("#{bin}/linkerd version --client 2>&1")
    assert_match "Client version: ", version_output
    stable_resource = stable.instance_variable_get(:@resource)
    assert_match stable_resource.instance_variable_get(:@specs)[:tag], version_output if build.stable?

    system "#{bin}/linkerd", "install", "--ignore-cluster"
  end
end
