# Patches for Qt must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class Qt < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz"
  mirror "https://mirrors.dotsrc.org/qtproject/archive/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz"
  sha256 "22b63d7a7a45183865cc4141124f12b673e7a17b1fe2b91e433f6547c5d548c3"

  head "https://code.qt.io/qt/qt5.git", :branch => "dev", :shallow => false

  bottle do
    cellar :any
    sha256 "c1094fb3e2c5efa2580f4ad36f240a83b08a5118aa8f12a526f08fca27e6d6c7" => :catalina
    sha256 "86674d9e61e1f75a20029974a01804a9fa0e6ea2fdc8fe10cb964ab8aea2a4e4" => :mojave
    sha256 "c579327b288cfe0f23d6bd41e6e3b672538b6f19fbc0379322ce5c0ba422e794" => :high_sierra
  end

  keg_only "Qt 5 has CMake issues when linked"

  disable! if ENV["CI"]

  depends_on "pkg-config" => :build
  depends_on :xcode => :build if OS.mac?
  depends_on :macos => :sierra if OS.mac?

  unless OS.mac?
    depends_on "fontconfig"
    depends_on "glib"
    depends_on "gperf"
    depends_on "icu4c"
    depends_on "libproxy"
    depends_on "libxkbcommon"
    depends_on "linuxbrew/xorg/libdrm"
    depends_on "linuxbrew/xorg/libice"
    depends_on "linuxbrew/xorg/libsm"
    depends_on "linuxbrew/xorg/libxcomposite"
    depends_on "linuxbrew/xorg/wayland"
    depends_on "linuxbrew/xorg/xcb-util"
    depends_on "linuxbrew/xorg/xcb-util-image"
    depends_on "linuxbrew/xorg/xcb-util-keysyms"
    depends_on "linuxbrew/xorg/xcb-util-renderutil"
    depends_on "linuxbrew/xorg/xcb-util-wm"
    depends_on "mesa"
    depends_on "pulseaudio"
    depends_on "python"
    depends_on "systemd"
    depends_on "zstd"
  end

  uses_from_macos "bison"
  uses_from_macos "flex"
  uses_from_macos "sqlite"

  # Fix build on Linux when the build system has AVX2
  # Patch submitted at https://codereview.qt-project.org/c/qt/qt3d/+/303993
  patch do
    url "https://codereview.qt-project.org/gitweb?p=qt/qt3d.git;a=patch;h=b456a7d47a36dc3429a5e7bac7665b12d257efea"
    sha256 "e47071f5feb6f24958b3670d83071502fe87243456b29fdc731c6eba677d9a59"
    directory "qt3d"
  end

  def install
    # Workaround for disk space issues on github actions
    # https://github.com/Homebrew/linuxbrew-core/pull/19595
    system "/home/linuxbrew/.linuxbrew/bin/brew", "cleanup", "--prune=0" if ENV["CI"]

    args = %W[
      -verbose
      -prefix #{prefix}
      -release
      -opensource -confirm-license
      -qt-libpng
      -qt-libjpeg
      -qt-freetype
      -qt-pcre
      -nomake examples
      -nomake tests
      -pkg-config
      -dbus-runtime
      -proprietary-codecs
    ]

    if OS.mac?
      args << "-no-rpath"
      args << "-system-zlib"
    elsif OS.linux?
      args << "-R#{lib}"
      # https://bugreports.qt.io/browse/QTBUG-71564
      args << "-no-avx2"
      args << "-no-avx512"
      args << "-qt-zlib"
      # https://bugreports.qt.io/browse/QTBUG-60163
      # https://codereview.qt-project.org/c/qt/qtwebengine/+/191880
      args += %w[-skip qtwebengine]
      args -= ["-proprietary-codecs"]
    end

    inreplace %w[qtdeclarative/qtdeclarative.pro qtdeclarative/src/3rdparty/masm/masm.pri] do |s|
      s.gsub! "python ", "python3 "
    end

    system "./configure", *args

    # Remove reference to shims directory
    inreplace "qtbase/mkspecs/qmodule.pri",
              /^PKG_CONFIG_EXECUTABLE = .*$/,
              "PKG_CONFIG_EXECUTABLE = #{Formula["pkg-config"].opt_bin/"pkg-config"}"
    system "make"
    ENV.deparallelize
    system "make", "install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # Move `*.app` bundles into `libexec` to expose them to `brew linkapps` and
    # because we don't like having them in `bin`.
    # (Note: This move breaks invocation of Assistant via the Help menu
    # of both Designer and Linguist as that relies on Assistant being in `bin`.)
    libexec.mkpath
    Pathname.glob("#{bin}/*.app") { |app| mv app, libexec }
  end

  def caveats
    <<~EOS
      We agreed to the Qt open source license for you.
      If this is unacceptable you should uninstall.
    EOS
  end

  test do
    (testpath/"hello.pro").write <<~EOS
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<~EOS
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert_predicate testpath/"hello", :exist?
    assert_predicate testpath/"main.o", :exist?
    system "./hello"
  end
end
