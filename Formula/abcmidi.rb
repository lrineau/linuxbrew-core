class Abcmidi < Formula
  desc "Converts abc music notation files to MIDI files"
  homepage "https://ifdo.ca/~seymour/runabc/top.html"
  url "https://ifdo.ca/~seymour/runabc/abcMIDI-2020.06.07.zip"
  sha256 "33f36c450d106b5a4ee1e9f975ea0c65615004d68c950011c391d15002974814"

  bottle do
    cellar :any_skip_relocation
    sha256 "533ba913faf663b26068b7de5fadee1041cac7e728766fcc95191b134f122118" => :catalina
    sha256 "2cb73cc0fcd7991a2b138c5d4408fd9bb80a1d164f359489d3af9cd3b77ca319" => :mojave
    sha256 "d28f189377ad0d00f3bc54edd138188becfec754de817b7db36291c61f093c7d" => :high_sierra
    sha256 "69ecc2c142f2e3ae1aa8b6b557b18b3c5754ad43419e59e8841036fc616eafd7" => :x86_64_linux
  end

  def install
    # configure creates a "Makefile" file. A "makefile" file already exist in
    # the tarball. On case-sensitive file-systems, the "makefile" file won't
    # be overridden and will be chosen over the "Makefile" file.
    rm_f "makefile"

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    (testpath/"balk.abc").write <<~EOS
      X: 1
      T: Abdala
      F: https://www.youtube.com/watch?v=YMf8yXaQDiQ
      L: 1/8
      M: 2/4
      K:Cm
      Q:1/4=180
      %%MIDI bassprog 32 % 32 Acoustic Bass
      %%MIDI program 23 % 23 Tango Accordian
      %%MIDI bassvol 69
      %%MIDI gchord fzfz
      |:"G"FDEC|D2C=B,|C2=B,2 |C2D2   |\
        FDEC   |D2C=B,|C2=B,2 |A,2G,2 :|
      |:=B,CDE |D2C=B,|C2=B,2 |C2D2   |\
        =B,CDE |D2C=B,|C2=B,2 |A,2G,2 :|
      |:C2=B,2 |A,2G,2| C2=B,2|A,2G,2 :|
    EOS

    system "#{bin}/abc2midi", (testpath/"balk.abc")
  end
end
