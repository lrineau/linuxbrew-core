class Flawfinder < Formula
  desc "Examines code and reports possible security weaknesses"
  homepage "https://www.dwheeler.com/flawfinder/"
  url "https://www.dwheeler.com/flawfinder/flawfinder-2.0.11.tar.gz"
  sha256 "9b4929fca5c6703880d95f201e470b7f19262ff63e991b3ac4ea3257f712f5ec"
  head "https://github.com/david-a-wheeler/flawfinder.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "db9c5f0ba0292c17e40eafb1b26f8ec45aa56265797a6af6b23242c5f81f538e" => :catalina
    sha256 "db9c5f0ba0292c17e40eafb1b26f8ec45aa56265797a6af6b23242c5f81f538e" => :mojave
    sha256 "db9c5f0ba0292c17e40eafb1b26f8ec45aa56265797a6af6b23242c5f81f538e" => :high_sierra
    sha256 "e015e43006ca2cd317c2bbc9199b80afa4f0594528b4adbe8612e46fec7dd697" => :x86_64_linux
  end

  depends_on "python@3.8" unless OS.mac?

  resource "flaws" do
    url "https://www.dwheeler.com/flawfinder/test.c"
    sha256 "4a9687a091b87eed864d3e35a864146a85a3467eb2ae0800a72e330496f0aec3"
  end

  def install
    inreplace "flawfinder", "#!/usr/bin/env python", "#!#{Formula["python@3.8"].opt_bin/"python3"}" unless OS.mac?
    system "make", "prefix=#{prefix}", "install"
  end

  test do
    resource("flaws").stage do
      assert_match "Hits = 36",
                   shell_output("#{bin}/flawfinder test.c")
    end
  end
end
