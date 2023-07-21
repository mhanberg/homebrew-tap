class Lazyasdf < Formula
  desc "TUI for the asdf version manager"
  homepage "https://github.com/mhanberg/lazyasdf"
  url "https://github.com/mhanberg/lazyasdf/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0d94926354a1c42dc50f4db98cdb80d62f63d9e25731b2afd4cff05479965dfd"
  license "MIT"

  bottle do
    root_url "https://github.com/mhanberg/homebrew-tap/releases/download/lazyasdf-0.2.0"
    sha256 cellar: :any_skip_relocation, monterey: "8db8abf40f5578c2e3239be95c155bceecb0ff9ed5187e81a13f2013de5f0733"
  end

  depends_on "elixir" => :build
  depends_on "erlang" => :build
  depends_on "gcc" => :build
  depends_on "make" => :build
  depends_on "python@3.9" => :build
  depends_on "xz" => :build

  depends_on "asdf"

  on_macos do
    on_arm do
      resource "zig" do
        url "https://ziglang.org/download/0.10.0/zig-macos-aarch64-0.10.0.tar.xz"
        sha256 "02f7a7839b6a1e127eeae22ea72c87603fb7298c58bc35822a951479d53c7557"
      end
    end

    on_intel do
      resource "zig" do
        url "https://ziglang.org/download/0.10.0/zig-macos-x86_64-0.10.0.tar.xz"
        sha256 "3a22cb6c4749884156a94ea9b60f3a28cf4e098a69f08c18fbca81c733ebfeda"
      end
    end
  end

  def install
    zig_install_dir = buildpath/"zig"
    mkdir zig_install_dir
    resources.each do |r|
      r.fetch

      system "tar", "xvC", zig_install_dir, "-f", r.cached_download
      zig_dir =
        if Hardware::CPU.arm?
          zig_install_dir/"zig-macos-aarch64-0.10.0"
        else
          zig_install_dir/"zig-macos-x86_64-0.10.0"
        end

      ENV["PATH"] = "#{zig_dir}:" + ENV["PATH"]
    end

    ENV["PATH"] = (Formula["python@3.9"].opt_libexec/"bin:") + ENV["PATH"]

    system "mix", "local.hex", "--force"
    system "mix", "local.rebar", "--force"

    ENV["BURRITO_TARGET"] = if Hardware::CPU.arm?
      "macos_m1"
    else
      "macos"
    end

    ENV["MIX_ENV"] = "prod"
    system "mix", "deps.get"
    system "mix", "release"

    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "burrito_out/lazyasdf_macos_m1" => "lazyasdf"
      else
        bin.install "burrito_out/lazyasdf_macos" => "lazyasdf"
      end
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test lazyasdf`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
