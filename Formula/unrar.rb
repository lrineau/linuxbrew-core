class Unrar < Formula
  desc "Extract, view, and test RAR archives"
  homepage "https://www.rarlab.com/"
  url "https://www.rarlab.com/rar/unrarsrc-5.9.3.tar.gz"
  sha256 "28c176c29da86d7efe3cb9a227255d8340f761ba95969195982ec87c8eb2dd69"

  bottle do
    cellar :any
    sha256 "7d9bc5d2dc49f1a007df7be45e6c2273dd9bedcfaa1f3c7ee04f9becfeb51974" => :catalina
    sha256 "4024ac60f589ac416b3ff229b468d2fff0c03dc6ecf88bafcdba03ffb2df39d4" => :mojave
    sha256 "8d16bf1854a72f4ae902426142bea57c3b3d98fa8a849c97fa4d926acfc101f3" => :high_sierra
    sha256 "29a5acca1a54c614491a78dc538d53be1084f83348b431dce8cce7737653b4c1" => :x86_64_linux
  end

  def install
    # upstream doesn't particularly care about their unix targets,
    # so we do the dirty work of renaming their shared objects to
    # dylibs for them.
    inreplace "makefile", "libunrar.so", "libunrar.dylib" if OS.mac?

    system "make"
    bin.install "unrar"

    # Explicitly clean up for the library build to avoid an issue with an
    # apparent implicit clean which confuses the dependencies.
    system "make", "clean"
    system "make", "lib"

    lib.install "libunrar.#{OS.mac? ? "dylib" : "so"}"
  end

  test do
    contentpath = "directory/file.txt"
    rarpath = testpath/"archive.rar"
    data =  "UmFyIRoHAM+QcwAADQAAAAAAAACaCHQggDIACQAAAAkAAAADtPej1LZwZE" \
            "QUMBIApIEAAGRpcmVjdG9yeVxmaWxlLnR4dEhvbWVicmV3CsQ9ewBABwA="

    rarpath.write data.unpack1("m")
    assert_equal contentpath, `#{bin}/unrar lb #{rarpath}`.strip
    assert_equal 0, $CHILD_STATUS.exitstatus

    system "#{bin}/unrar", "x", rarpath, testpath
    assert_equal "Homebrew\n", (testpath/contentpath).read
  end
end
