class Doxygen18150 < Formula
  desc "Generate documentation for several programming languages"
  homepage "http://www.doxygen.org/"
  url "http://doxygen.nl/files/doxygen-1.8.15.src.tar.gz"
  mirror "https://downloads.sourceforge.net/project/doxygen/rel-1.8.15/doxygen-1.8.15.src.tar.gz"
  sha256 "bd9c0ec462b6a9b5b41ede97bede5458e0d7bb40d4cfa27f6f622eb33c59245d"
  head "https://github.com/doxygen/doxygen.git"

  

  option "with-graphviz", "Build with dot command support from Graphviz."
  option "with-qt", "Build GUI frontend with Qt support."
  option "with-llvm", "Build with libclang support."

  deprecated_option "with-dot" => "with-graphviz"
  deprecated_option "with-doxywizard" => "with-qt"
  deprecated_option "with-libclang" => "with-llvm"
  deprecated_option "with-qt5" => "with-qt"

  depends_on "cmake_3.13.2_0" => :build
  depends_on "graphviz_2.40.1_0" => :optional
  depends_on "llvm_7.0.1_0" => :optional
  depends_on "qt_5.12.0_0" => :optional

  def install
    args = std_cmake_args << "-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=#{MacOS.version}"
    args << "-Dbuild_wizard=ON" if build.with? "qt"
    args << "-Duse_libclang=ON -DLLVM_CONFIG=#{Formula["llvm_7.0.1_0"].opt_bin}/llvm-config" if build.with? "llvm"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
    end
    bin.install Dir["build/bin/*"]
    man1.install Dir["doc/*.1"]
  end

  test do
    system "#{bin}/doxygen", "-g"
    system "#{bin}/doxygen", "Doxyfile"
  end
end
