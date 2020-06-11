class Dwatch < Formula
  desc "Watch programs and perform actions based on a configuration file"
  homepage "https://siag.nu/dwatch/"
  url "https://siag.nu/pub/dwatch/dwatch-0.1.1.tar.gz"
  sha256 "ba093d11414e629b4d4c18c84cc90e4eb079a3ba4cfba8afe5026b96bf25d007"

  bottle do
    rebuild 2
    sha256 "c79f51f4329569d682357a97014bd67a14ac1444e4fb983abd3a9e96339ba87a" => :catalina
    sha256 "69b3cb7cc60c1635c3134a0cd5e9dd884b3e28f52955e62da9beb0605e43cff5" => :mojave
    sha256 "fdf97f373c4bb18a3025d0f4acd9e16c826eca19cb60c9abd59d59bee8741c0f" => :high_sierra
    sha256 "1d0a738bdfb6cf47f3b6d582d3e0bf8607689334cf80948c2b903e1c6f189199" => :x86_64_linux
  end

  def install
    # Makefile uses cp, not install
    bin.mkpath
    man1.mkpath

    system "make", "install",
                   "CC=#{ENV.cc}",
                   "PREFIX=#{prefix}",
                   "MANDIR=#{man}",
                   "ETCDIR=#{etc}"

    etc.install "dwatch.conf"
  end

  test do
    # '-h' is not actually an option, but it exits 0
    system "#{bin}/dwatch", "-h"
  end
end
