class DhallBash < Formula
  desc "Compile Dhall to Bash"
  homepage "https://github.com/dhall-lang/dhall-haskell/tree/master/dhall-bash"
  url "https://hackage.haskell.org/package/dhall-bash-1.0.29/dhall-bash-1.0.29.tar.gz"
  sha256 "3ca8c0e6802d7c002d9e1553135fe47431eae91f0acfd065fe3a645ca998b042"
  head "https://github.com/dhall-lang/dhall-haskell.git"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "7b82ee43dbd713fc74ca614e277045fa75682fa4ab8a08fab44901d2f2bafbbb" => :catalina
    sha256 "b603fc69730a8a2aed62bba04b0e56e68b3f97ffb95353b44743619e368132b1" => :mojave
    sha256 "eb1db8a7bf06d612f47e9271c78cafd04e4042ae8131258487e2b1cc67f1846b" => :high_sierra
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    assert_match "true", pipe_output("#{bin}/dhall-to-bash", "Natural/even 100", 0)
    assert_match "unset FOO", pipe_output("#{bin}/dhall-to-bash --declare FOO", "None Natural", 0)
  end
end
