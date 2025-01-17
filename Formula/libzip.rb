class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "https://libzip.org/download/libzip-1.7.3.tar.xz"
  sha256 "a60473ffdb7b4260c08bfa19c2ccea0438edac11193c3afbbb1f17fbcf6c6132"
  license "BSD-3-Clause"

  livecheck do
    url "https://libzip.org/download/"
    regex(/href=.*?libzip[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_big_sur: "e58c6e33b3a74dc3cae81e1b3ab482e0df007fe65c561a62e4750e206c068688"
    sha256 big_sur:       "261afbcf4c391242a760158dd337e0bc24dc4b34f764e5b8ae197580bc94db38"
    sha256 catalina:      "e5a16cd6fef05a7f6f44852f1008a3e5d27796e661079278643d9c1f0912672c"
    sha256 mojave:        "3554c0ba2bd6f663a10a1791b474d3634d8b72f9ee6d4ed818cca7fd17c40737"
    sha256 high_sierra:   "b629e96fde8b5d27235d11a176c674630036cc9e8541e076d5ae4945a9b2cdf1"
    sha256 x86_64_linux:  "e9754616df40905a6510b7ce1062c4d2b634a84f74e69bea86dd7d53e836ae19"
  end

  depends_on "cmake" => :build
  unless OS.mac?
    depends_on "openssl@1.1"
    depends_on "xz" # For LZMA
  end

  uses_from_macos "zip" => :test
  uses_from_macos "bzip2"
  uses_from_macos "openssl@1.1"
  uses_from_macos "xz"
  uses_from_macos "zlib"

  conflicts_with "libtcod", "minizip-ng",
    because: "libtcod, libzip and minizip-ng install a `zip.h` header"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    zip = OS.mac? ? "/usr/bin/zip" : which("zip")
    if zip.nil?
      opoo "Not testing unzip, because it requires zip, which is unavailable."
      return
    end

    touch "file1"
    system "zip", "file1.zip", "file1"
    touch "file2"
    system "zip", "file2.zip", "file1", "file2"
    assert_match(/\+.*file2/, shell_output("#{bin}/zipcmp -v file1.zip file2.zip", 1))
  end
end
