class Cli < Formula
  desc "Motch CLI"
  homepage "https://github.com/mhanberg/cli"
  url "https://github.com/mhanberg/cli/archive/refs/tags/v0.1.0-alpha.3.tar.gz"
  sha256 "2b682073201d2eb0a5f54b8f9830cab0649d82ec3e75242f5da06b9ce2759922"
  license "MIT"

  bottle do
    root_url "https://github.com/mhanberg/homebrew-tap/releases/download/cli-0.1.0-alpha.3"
    sha256 cellar: :any_skip_relocation, big_sur:      "48eb68d074e672638e969dc259b6172271e35ac9eef65c58b173573f64c158c5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a132f731da6d082071c03eaf82ab8373c243f01499ae302558f6f4879993f367"
  end

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

    bin.install "mctl"
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
