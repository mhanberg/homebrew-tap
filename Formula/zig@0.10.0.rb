class ZigAT0100 < Formula
  desc "Programming language designed for robustness, optimality, and clarity"
  homepage "https://ziglang.org/"
  license "MIT"
  revision 1
  head "https://github.com/ziglang/zig.git", branch: "master"

  stable do
    url "https://ziglang.org/download/0.10.0/zig-0.10.0.tar.xz"
    sha256 "d8409f7aafc624770dcd050c8fa7e62578be8e6a10956bca3c86e8531c64c136"

    on_macos do
      # We need to make sure there is enough space in the MachO header when we rewrite install names.
      patch :DATA
    end
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "z3"
  depends_on "zstd"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  fails_with gcc: "5" # LLVM is built with GCC

  def install
    system "cmake", "-S", ".", "-B", "build", "-DZIG_STATIC_LLVM=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"hello.zig").write <<~EOS
      const std = @import("std");
      pub fn main() !void {
          const stdout = std.io.getStdOut().writer();
          try stdout.print("Hello, world!", .{});
      }
    EOS
    system "#{bin}/zig", "build-exe", "hello.zig"
    assert_equal "Hello, world!", shell_output("./hello")

    # error: 'TARGET_OS_IPHONE' is not defined, evaluates to 0
    ENV.delete "CPATH"
    (testpath/"hello.c").write <<~EOS
      #include <stdio.h>
      int main() {
        fprintf(stdout, "Hello, world!");
        return 0;
      }
    EOS
    system "#{bin}/zig", "cc", "hello.c", "-o", "hello"
    assert_equal "Hello, world!", shell_output("./hello")
  end
end

__END__
diff --git a/build.zig b/build.zig
index e5e80b4..1da6892 100644
--- a/build.zig
+++ b/build.zig
@@ -154,6 +154,7 @@ pub fn build(b: *Builder) !void {
 
     exe.stack_size = stack_size;
     exe.strip = strip;
+    exe.headerpad_max_install_names = true;
     exe.sanitize_thread = sanitize_thread;
     exe.build_id = b.option(bool, "build-id", "Include a build id note") orelse false;
     exe.install();
