class Xrootd < Formula
  desc "High performance, scalable, fault-tolerant access to data"
  homepage "https://xrootd.slac.stanford.edu/"
  url "https://xrootd.slac.stanford.edu/download/v4.12.2/xrootd-4.12.2.tar.gz"
  sha256 "29f7bc3ea51b9d5d310eabd177152245d4160223325933c67f938ed5120f67bb"
  head "https://github.com/xrootd/xrootd.git"

  bottle do
    cellar :any
    sha256 "f9a922afe472fcf2ce7b4573d2de625678b255e5842131bea9a5715235bf08fc" => :catalina
    sha256 "1bc74c8c780accb18e79a2b61493bd49fec96028a714ccbee9b4699b882757b5" => :mojave
    sha256 "d3c2eb3205f316d173cff000a6a4c6692ca81636ff232299e6e011ea4b8aeed4" => :high_sierra
    sha256 "835f41aec2b2042f9f1e8355ea6bbefcfec86d3ad13158682abe803d695d4fb5" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"
  depends_on "readline"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_linux do
    depends_on "util-linux"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DENABLE_PYTHON=OFF"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/xrootd", "-H"
  end
end
