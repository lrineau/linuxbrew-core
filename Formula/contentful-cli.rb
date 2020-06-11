require "language/node"

class ContentfulCli < Formula
  desc "Contentful command-line tools"
  homepage "https://github.com/contentful/contentful-cli"
  url "https://registry.npmjs.org/contentful-cli/-/contentful-cli-1.4.8.tgz"
  sha256 "f6a9e4fd05eb19e88a741fff6ba8baa19ef0160ff3541a946fe6116df56bf24e"
  head "https://github.com/contentful/contentful-cli.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "283f67986b5869dadc5261531ff438f10d9aaf597d411c7f3f009ddf30065d22" => :catalina
    sha256 "26b31b30f1b8d94af09975451792d79b1ef39fe0bfcecdf154a85f546c4ad54f" => :mojave
    sha256 "74403fd58878d6888e6838e9465a07d82657076d8d571e54aecc4eb8c17c5eeb" => :high_sierra
    sha256 "0ab7f63632371bcf895d7dab99ca1dd290cd9a1215fd29bbe2fe68e350e8546a" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    output = shell_output("#{bin}/contentful space list 2>&1", 1)
    assert_match "🚨  Error: You have to be logged in to do this.", output
    assert_match "You can log in via contentful login", output
    assert_match "Or provide a managementToken via --management-Token argument", output
  end
end
