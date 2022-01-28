class Cli < Formula
  desc "Motch CLI"
  homepage "https://github.com/mhanberg/cli"
  url "https://github.com/mhanberg/cli/archive/refs/tags/v0.1.0-alpha.2.tar.gz"
  sha256 "8665964991c400a69499737205ad9c19801d0b6b96f5ab976b22222a2ee4309a"
  license "MIT"

  depends_on "ruby" => :build
  depends_on "bash"

  resource "bashly" do
    url "https://rubygems.org/downloads/bashly-0.7.2.gem"
    sha256 "d2a68adc3ff37355a8afde91a987a3e731208a6129c8250d26a22b21206ccd48"
  end

  def install
    gem_install_dir = buildpath/"bashly"
    mkdir gem_install_dir

    ENV["GEM_HOME"] = gem_install_dir

    resources.each do |r|
      r.fetch
      system "gem", "install", r.cached_download, "--no-document",
        "--install-dir", gem_install_dir
    end

    system gem_install_dir/"bin/bashly", "generate"

    bin.install "motch"
    bin.install Dir["external-scripts/*"]
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test cli`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
