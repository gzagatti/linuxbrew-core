class Grpc < Formula
  desc "Next generation open source RPC library and framework"
  homepage "https://grpc.io/"
  url "https://github.com/grpc/grpc.git",
      tag:      "v1.36.4",
      revision: "3e53dbe8213137d2c731ecd4d88ebd2948941d75",
      shallow:  false
  license "Apache-2.0"
  revision 1
  head "https://github.com/grpc/grpc.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256                               arm64_big_sur: "9b067833fdc4ec3f6bf087410b774e81e1ed906b1ae3fc882421bd553712f42a"
    sha256                               big_sur:       "17531240482c6f10c02582cb8597ca423d952a3cb42af86219f7a93c68742006"
    sha256                               catalina:      "bb505054689cc41935a3f9d6980d4e8225a2413262dcf77dda850d15852b0cf1"
    sha256                               mojave:        "d23ab851339dafacbc72f066719980f1df87251956cfa269a4ac34de018b43ed"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d6278cebd62a861901867fa9bc7ec85950a592335dd7fef0b1832d9c5c384d14"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :test
  depends_on "abseil"
  depends_on "c-ares"
  depends_on "openssl@1.1"
  depends_on "protobuf"
  depends_on "re2"

  uses_from_macos "zlib"

  def install
    mkdir "cmake/build" do
      args = %W[
        ../..
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=TRUE
        -DCMAKE_INSTALL_RPATH=#{lib}
        -DBUILD_SHARED_LIBS=ON
        -DgRPC_BUILD_TESTS=OFF
        -DgRPC_INSTALL=ON
        -DgRPC_ABSL_PROVIDER=package
        -DgRPC_CARES_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_RE2_PROVIDER=package
      ] + std_cmake_args

      system "cmake", *args
      system "make", "install"

      # grpc_cli does not build correctly with a non-/usr/local prefix.
      # Reported upstream at https://github.com/grpc/grpc/issues/25176
      # When removing the `unless` block, make sure to do the same for
      # the test block.
      unless Hardware::CPU.arm?
        args = %W[
          ../..
          -DCMAKE_INSTALL_RPATH=#{lib}
          -DBUILD_SHARED_LIBS=ON
          -DgRPC_BUILD_TESTS=ON
        ] + std_cmake_args
        system "cmake", *args
        system "make", "grpc_cli"
        bin.install "grpc_cli"
        lib.install Dir[shared_library("libgrpc++_test_config", "*")]
      end
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <grpc/grpc.h>
      int main() {
        grpc_init();
        grpc_shutdown();
        return GRPC_STATUS_OK;
      }
    EOS
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["openssl@1.1"].opt_lib/"pkgconfig"
    pkg_config_flags = shell_output("pkg-config --cflags --libs libcares protobuf re2 grpc++").chomp.split
    system ENV.cc, "test.cpp", "-L#{Formula["abseil"].opt_lib}", *pkg_config_flags, "-o", "test"
    system "./test"
    unless Hardware::CPU.arm?
      output = shell_output("grpc_cli ls localhost:#{free_port} 2>&1", 1)
      assert_match "Received an error when querying services endpoint.", output
    end
  end
end
