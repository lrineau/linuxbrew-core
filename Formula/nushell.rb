class Nushell < Formula
  desc "Modern shell for the GitHub era"
  homepage "https://www.nushell.sh"
  url "https://github.com/nushell/nushell/archive/0.15.0.tar.gz"
  sha256 "f19e580b645ff047e3b7cb2e0823654e020cd5c62b22e601caf6be579204dc2a"
  head "https://github.com/nushell/nushell.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a516b3eb630fde82b8bb1d4ee84870bded2609ed2ea61844174edbd064cec0cf" => :catalina
    sha256 "e76db1897d9c612c7cc00d291257f83ad3204f67720cadd65e4ece60f35e531e" => :mojave
    sha256 "3a3e49fff0d9431348555acc8b7c909186a7e00df53ff6d80de70c7e66316898" => :high_sierra
    sha256 "d12c73a7761c17363dd43fe1ee52dcef7df9a96ed594f890617bbc4496bc8a31" => :x86_64_linux
  end

  depends_on "rust" => :build
  depends_on "openssl@1.1"

  uses_from_macos "zlib"

  on_linux do
    depends_on "pkg-config" => :build
  end

  unless OS.mac?
    depends_on "linuxbrew/xorg/libxcb"
    depends_on "linuxbrew/xorg/libx11"
  end

  def install
    system "cargo", "install", "--features", "stable", "--locked", "--root", prefix, "--path", "."
  end

  test do
    if OS.mac?
      assert_equal pipe_output("#{bin}/nu", 'echo \'{"foo":1, "bar":2}\' | from-json | get bar | echo $it'),
      "Welcome to Nushell #{version} (type 'help' for more info)\n~ \n❯ 2~ \n❯ "
    else
      assert_match "Welcome to Nushell #{version} (type 'help' for more info)\n",
      pipe_output("#{bin}/nu", 'echo \'{"foo":1, "bar":2}\' | from-json | get bar | echo $it')
    end
  end
end
