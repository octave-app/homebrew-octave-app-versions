class Libomp7000 < Formula
  desc "LLVM's OpenMP runtime library"
  homepage "https://openmp.llvm.org/"
  url "https://releases.llvm.org/7.0.0/openmp-7.0.0.src.tar.xz"
  sha256 "30662b632f5556c59ee9215c1309f61de50b3ea8e89dcc28ba9a9494bba238ff"

  

  depends_on "cmake_3.13.2_0" => :build
  depends_on :macos => :yosemite

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    system "cmake", ".", "-DLIBOMP_ENABLE_SHARED=OFF", *std_cmake_args
    system "make", "install"
  end

  def caveats; <<~EOS
    On Apple Clang, you need to add several options to use OpenMP's front end
    instead of the standard driver option. This usually looks like
      -Xpreprocessor -fopenmp -lomp

    You might need to make sure the lib and include directories are discoverable
    if #{HOMEBREW_PREFIX} is not searched:

      -L#{opt_lib} -I#{opt_include}

    For CMake, the following flags will cause the OpenMP::OpenMP_CXX target to
    be set up correctly:
      -DOpenMP_CXX_FLAGS="-Xpreprocessor -fopenmp -I#{opt_include}" -DOpenMP_CXX_LIB_NAMES="omp" -DOpenMP_omp_LIBRARY=#{opt_lib}/libomp.dylib
  EOS
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <omp.h>
      #include <array>
      int main (int argc, char** argv) {
        std::array<size_t,2> arr = {0,0};
        #pragma omp parallel num_threads(2)
        {
            size_t tid = omp_get_thread_num();
            arr.at(tid) = tid + 1;
        }
        if(arr.at(0) == 1 && arr.at(1) == 2)
            return 0;
        else
            return 1;
      }
    EOS
    system ENV.cxx, "-Werror", "-Xpreprocessor", "-fopenmp", "test.cpp",
                    "-L#{lib}", "-lomp", "-o", "test"
    system "./test"
  end
end
