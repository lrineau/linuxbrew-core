class Bmake < Formula
  desc "Portable version of NetBSD make(1)"
  homepage "http://www.crufty.net/help/sjg/bmake.html"
  url "http://www.crufty.net/ftp/pub/sjg/bmake-20200606.tar.gz"
  sha256 "67a3a27b3156e7d07dd5cd3501c64c69d50ed6752a59e616f50820f3d10b7002"

  bottle do
    sha256 "886b5ffb2e30376d34055f5be095492bd2785d0db40f6e8614a7e7a5b44959db" => :catalina
    sha256 "ff919e5a081fc27c0b4ebc93c1a44ec096b1dcf2818faa4fe79e220b5c3ae1d7" => :mojave
    sha256 "c2dc9c5f51d0114a4402192f43bf3bf634e819c796c98e90d81e4d6ee35ecbe5" => :high_sierra
    sha256 "af74aceab75306b244c2715c8d2cecaf012e27a180748504700d6089cc0d40f2" => :x86_64_linux
  end

  def install
    # Don't pre-roff cat pages.
    inreplace "mk/man.mk", "MANTARGET?", "MANTARGET"

    # -DWITHOUT_PROG_LINK means "don't symlink as bmake-VERSION."
    args = ["--prefix=#{prefix}", "-DWITHOUT_PROG_LINK", "--install"]
    system "sh", "boot-strap", *args

    chmod "u+w", man1/"bmake.1"
    man1.install "bmake.1"
  end

  test do
    (testpath/"Makefile").write <<~EOS
      all: hello

      hello:
      \t@echo 'Test successful.'

      clean:
      \trm -rf Makefile
    EOS
    system bin/"bmake"
    system bin/"bmake", "clean"
  end
end
