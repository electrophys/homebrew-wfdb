class Wfdb < Formula
  desc "WaveForm Database library and tools for physiologic signals"
  homepage "https://physionet.org/"
  url "https://github.com/electrophys/wfdb/archive/1e7b18059ce44e8d11a02a56a7ebb441aebb3341.tar.gz"
  version "10.7.0"
  sha256 "42c87b0d367a15f45fea2dda778e0ea44feec9e6f79cfc425e7f84292cc8b0a0"
  license "LGPL-2.0-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "gcc" => :build unless OS.mac?
  depends_on "curl"
  depends_on "expat"
  depends_on "flac"

  def install
    system "meson", "setup", "build", *std_meson_args,
           "-Dnetfiles=enabled", "-Dflac=enabled",
           "-Dexpat=enabled", "-Dwave=disabled", "-Ddocs=disabled"
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <wfdb/wfdb.h>
      #include <stdio.h>
      int main(void) {
        printf("WFDB %d.%d.%d\\n", WFDB_MAJOR, WFDB_MINOR, WFDB_RELEASE);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test",
           *shell_output("pkg-config --cflags --libs wfdb").chomp.split
    assert_match "WFDB 10.7.0", shell_output("./test")
  end
end
