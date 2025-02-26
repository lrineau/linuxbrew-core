class Cairo < Formula
  desc "Vector graphics library with cross-device output support"
  homepage "https://cairographics.org/"
  url "https://cairographics.org/releases/cairo-1.16.0.tar.xz"
  sha256 "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331"
  revision 3

  bottle do
    sha256 "6a23a68837269a8410a54950fdc8883feda091f221118370f1bfd3adbf5ee89c" => :catalina
    sha256 "0984045234fb22fa3e54a337137e9e43a1bf997f5d77692ed02249dfdee2b1bf" => :mojave
    sha256 "5c383ad4625fb1bd15e44e99fba1201490fa478b26178abaca5abb0fdb51510e" => :high_sierra
    sha256 "2ff97b7c8abbb95791c1dc1e28b42e8f007adaf4f649cb46732c8140ad19dfd1" => :x86_64_linux
  end

  head do
    url "https://anongit.freedesktop.org/git/cairo.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "glib"
  depends_on "libpng"
  depends_on "lzo"
  depends_on "pixman"
  unless OS.mac?
    depends_on "zlib"
    depends_on "linuxbrew/xorg/libxext"
    depends_on "linuxbrew/xorg/libxrender"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-gobject=yes
      --enable-svg=yes
      --enable-tee=yes
      --enable-quartz-image=#{OS.mac? ? "yes" : "no"}
      --enable-xcb=#{OS.mac? ? "no" : "yes"}
      --enable-xlib=#{OS.mac? ? "no" : "yes"}
      --enable-xlib-xrender=#{OS.mac? ? "no" : "yes"}
      --enable-valgrind=no
    ]

    if build.head?
      ENV["NOCONFIGURE"] = "1"
      system "./autogen.sh"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cairo.h>

      int main(int argc, char *argv[]) {

        cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 600, 400);
        cairo_t *context = cairo_create(surface);

        return 0;
      }
    EOS
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/cairo
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -L#{lib}
      -lcairo
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
