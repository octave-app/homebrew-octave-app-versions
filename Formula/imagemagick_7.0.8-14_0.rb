class Imagemagick708140 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/imagemagick--7.0.8-14.tar.xz"
  mirror "https://www.imagemagick.org/download/ImageMagick-7.0.8-14.tar.xz"
  sha256 "70c3d8c800cfd0282c0e0d9930b83f472f9593a882adc77532aa82c0d7ca0bb1"
  head "https://github.com/ImageMagick/ImageMagick.git"

  

  option "with-fftw", "Compile with FFTW support"
  option "with-hdri", "Compile with HDRI support"
  option "with-libheif", "Compile with HEIF support"
  option "with-perl", "Compile with PerlMagick"

  deprecated_option "enable-hdri" => "with-hdri"
  deprecated_option "with-libde265" => "with-libheif"

  depends_on "pkg-config_0.29.2_0" => :build

  depends_on "freetype_2.9.1_0"
  depends_on "jpeg_9c_0"
  depends_on "libpng_1.6.35_0"
  depends_on "libtiff_4.0.9_5"
  depends_on "libtool_2.4.6_1"
  depends_on "little-cms2_2.9_0"
  depends_on "openjpeg_2.3.0_0"
  depends_on "webp_1.0.0_0"
  depends_on "xz_5.2.4_0"

  depends_on "fftw_3.3.8_0" => :optional
  depends_on "fontconfig_2.13.1_0" => :optional
  depends_on "ghostscript_9.25_0" => :optional
  depends_on "libheif_1.3.2_1" => :optional
  depends_on "liblqr_0.4.2_0" => :optional
  depends_on "librsvg_2.44.8_0" => :optional
  depends_on "libwmf_0.2.8.4_2" => :optional
  depends_on "little-cms_1.19_1" => :optional
  depends_on "openexr_2.2.0_1" => :optional
  depends_on "pango_1.42.4_0" => :optional
  depends_on "perl_5.28.0_0" => :optional
  depends_on :x11 => :optional

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --disable-openmp
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-openjp2
      --with-webp=yes
    ]

    args << "--without-gslib" if build.without? "ghostscript"
    args << "--with-perl" << "--with-perl-options='PREFIX=#{prefix}'" if build.with? "perl"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--enable-hdri=yes" if build.with? "hdri"
    args << "--without-fftw" if build.without? "fftw"
    args << "--without-pango" if build.without? "pango"
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-x" if build.without? "x11"
    args << "--with-fontconfig=yes" if build.with? "fontconfig"
    args << "--without-wmf" if build.without? "libwmf"

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  def caveats
    s = <<~EOS
      For full Perl support you may need to adjust your PERL5LIB variable:
        export PERL5LIB="#{HOMEBREW_PREFIX}/lib/perl5/site_perl":$PERL5LIB
    EOS
    s if build.with? "perl"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
