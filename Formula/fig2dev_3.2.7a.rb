class Fig2dev327a < Formula
  desc "Translates figures generated by xfig to other formats"
  homepage "https://mcj.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/mcj/fig2dev-3.2.7a.tar.xz"
  sha256 "bda219a15efcdb829e6cc913a4174f5a4ded084bf91565c783733b34a89bfb28"

  

  depends_on "ghostscript_9.23"
  depends_on "libpng_1.6.34"
  depends_on "netpbm_10.73.19"
  depends_on :x11 => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-transfig
    ]

    if build.with? "x11"
      args << "--with-xpm" << "--with-x"
    else
      args << "--without-xpm" << "--without-x"
    end

    system "./configure", *args
    system "make", "install"

    # Install a fig file for testing
    pkgshare.install "fig2dev/tests/data/patterns.fig"
  end

  test do
    system "#{bin}/fig2dev", "-L", "png", "#{pkgshare}/patterns.fig", "patterns.png"
    assert_predicate testpath/"patterns.png", :exist?, "Failed to create PNG"
  end
end
