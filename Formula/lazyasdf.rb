class Lazyasdf < Formula
  desc "TUI for the asdf version manager"
  homepage "https://github.com/mhanberg/lazyasdf"
  url "https://github.com/mhanberg/lazyasdf/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "07d4c48333c24916b8255f02ac65b48fa5a9831ce5b1eef1d8d94747eaba04cc"
  license "MIT"

  bottle do
    root_url "https://github.com/mhanberg/homebrew-tap/releases/download/lazyasdf-0.1.0"
    sha256 cellar: :any_skip_relocation, monterey: "65257bc76dca68824cce181c60208404b34fb681f6d999ef3cbefaf66f0dae95"
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
