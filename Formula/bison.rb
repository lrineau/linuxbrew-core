class Bison < Formula
  desc "Parser generator"
  homepage "https://www.gnu.org/software/bison/"
  # X.Y.9Z are beta releases that sometimes get accidentally uploaded to the release FTP
  url "https://ftp.gnu.org/gnu/bison/bison-3.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/bison/bison-3.6.tar.xz"
  sha256 "e16f26baa2ebff141333e452c3cc5d8ea26bda6d2cd8b0b7a5604faa3a4ad47b"
  version_scheme 1

  bottle do
    sha256 "799ec8d8a93f120f39f2d3c823a127dae606353cc0bd6f8b1499fc952668bce9" => :catalina
    sha256 "c71edfc81bdf589d9b011de46a7c8033142fbf494133c5f37f17aaf9006d36aa" => :mojave
    sha256 "d9149cc4cbe753326941388f5656e84e3e7402090b4590ea8ca6a62781c3fdec" => :high_sierra
    sha256 "fbd51882371605a3fa2bca1c415965d4e75a860c49897e270b174339a1f62b6a" => :x86_64_linux
  end

  keg_only :provided_by_macos

  uses_from_macos "m4"

  def install
    # https://www.mail-archive.com/bug-guix@gnu.org/msg13512.html
    ENV.deparallelize unless OS.mac?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.y").write <<~EOS
      %{ #include <iostream>
         using namespace std;
         extern void yyerror (char *s);
         extern int yylex ();
      %}
      %start prog
      %%
      prog:  //  empty
          |  prog expr '\\n' { cout << "pass"; exit(0); }
          ;
      expr: '(' ')'
          | '(' expr ')'
          |  expr expr
          ;
      %%
      char c;
      void yyerror (char *s) { cout << "fail"; exit(0); }
      int yylex () { cin.get(c); return c; }
      int main() { yyparse(); }
    EOS
    system "#{bin}/bison", "test.y"
    system ENV.cxx, "test.tab.c", "-o", "test"
    assert_equal "pass", shell_output("echo \"((()(())))()\" | ./test")
    assert_equal "fail", shell_output("echo \"())\" | ./test")
  end
end
