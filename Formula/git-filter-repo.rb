class GitFilterRepo < Formula
  include Language::Python::Shebang

  desc "Quickly rewrite git repository history"
  homepage "https://github.com/newren/git-filter-repo"
  url "https://github.com/newren/git-filter-repo/releases/download/v2.27.0/git-filter-repo-2.27.0.tar.xz"
  sha256 "41edbb53eb83fce292eb28f044002dc772849ce72053c74715e882c8f1053eef"

  bottle :unneeded

  # ignore git dependency audit:
  #  * Don't use git as a dependency (it's always available)
  # But we require Git 2.22.0+
  # https://github.com/Homebrew/homebrew-core/pull/46550#issuecomment-563229479
  depends_on "git"
  depends_on "python@3.8"

  def install
    rewrite_shebang detected_python_shebang, "git-filter-repo"
    bin.install "git-filter-repo"
    man1.install "Documentation/man1/git-filter-repo.1"
  end

  test do
    system "#{bin}/git-filter-repo", "--version"

    system "git", "init"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@example.com"

    touch "foo"
    system "git", "add", "foo"
    system "git", "commit", "-m", "foo"
    # Use --force to accept non-fresh clone run:
    # Aborting: Refusing to overwrite repo history since this does not look like a fresh clone.
    # (expected freshly packed repo)
    system "#{bin}/git-filter-repo", "--path-rename=foo:bar", "--force"

    assert_predicate testpath/"bar", :exist?
  end
end
