class Sundials27OctaveApp2700 < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computation.llnl.gov/casc/sundials/main.html"
  # The official download site is always really slow, so use a mirror instead
  url "https://github.com/octave-app/homebrew-octave-app-bases/releases/download/v0.1/sundials-2.7.0.tar.gz"
  # This is actually the official download
  mirror "https://computation.llnl.gov/projects/sundials/download/sundials-2.7.0.tar.gz"
  sha256 "d39fcac7175d701398e4eb209f7e92a5b30a78358d4a0c0fcc23db23c11ba104"

  keg_only "conflicts with regular sundials"

  option "with-openmp", "Enable OpenMP multithreading"
  option "without-mpi", "Do not build with MPI"

  depends_on "cmake_3.12.4_0" => :build
  depends_on "python_3.7.1_0" => :build
  depends_on "gcc_8.2.0_0" # for gfortran
  depends_on "open-mpi_3.1.3_0" if build.with? "mpi"
  depends_on "suite-sparse_5.3.0_0"
  depends_on "openblas_0.3.3_0"

  fails_with :clang if build.with? "openmp"

  def install
    blas = "-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    args = std_cmake_args + %W[
      -DCMAKE_C_COMPILER=#{ENV["CC"]}
      -DBUILD_SHARED_LIBS=ON
      -DKLU_ENABLE=ON
      -DKLU_LIBRARY_DIR=#{Formula["suite-sparse_5.3.0_0"].opt_lib}
      -DKLU_INCLUDE_DIR=#{Formula["suite-sparse_5.3.0_0"].opt_include}
      -DLAPACK_ENABLE=ON
      -DLAPACK_LIBRARIES=#{blas};#{blas}
    ]
    args << "-DOPENMP_ENABLE=ON" if build.with? "openmp"
    args << "-DMPI_ENABLE=ON" if build.with? "mpi"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    cp Dir[prefix/"examples/nvector/serial/*"], testpath
    system ENV.cc, "-I#{include}", "test_nvector.c", "sundials_nvector.c",
                   "test_nvector_serial.c", "-L#{lib}", "-lsundials_nvecserial", "-lm"
    assert_match "SUCCESS: NVector module passed all tests",
                 shell_output("./a.out 42 0")
  end
end
