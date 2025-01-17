class CmarkGfm < Formula
  desc "C implementation of GitHub Flavored Markdown"
  homepage "https://github.com/github/cmark-gfm"
  url "https://github.com/github/cmark-gfm/archive/0.29.0.gfm.0.tar.gz"
  version "0.29.0.gfm.0"
  sha256 "6a94aeaa59a583fadcbf28de81dea8641b3f56d935dda5b2447a3c8df6c95fea"
  license "BSD-2-Clause"
  revision 2

  bottle do
    sha256               arm64_big_sur: "b72e66bbd58fdb81dac3c52cb9274e08cdb8f791239c80444798c171c998324e"
    sha256 cellar: :any, big_sur:       "3e26c1d17fc758db9384e87ae0fb9c14bf72131e907999f3df7e92e82db9f740"
    sha256 cellar: :any, catalina:      "f7d1e82fce11d59440842e86065a21ec244b85159e091528dca7e004a32615ba"
    sha256 cellar: :any, mojave:        "e203ca97951abc32dc20dede8c504df44a6972f8cb03df7a0e597bc7caeb20f5"
    sha256 cellar: :any, high_sierra:   "461d5443abc76191e65b3df9f2448072107e31211017e38bbb461842b523ee43"
    sha256 cellar: :any, x86_64_linux:  "aee58de3471bafe7c3dceba885539612a20909a60f87554e43a0d0dd7b367f36"
  end

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build

  conflicts_with "cmark", because: "both install a `cmark.h` header"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{opt_lib}"
      system "make", "install"
    end
  end

  test do
    output = pipe_output("#{bin}/cmark-gfm --extension autolink", "https://brew.sh")
    assert_equal '<p><a href="https://brew.sh">https://brew.sh</a></p>', output.chomp
  end
end
