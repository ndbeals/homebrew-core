class Atuin < Formula
  desc "Improved shell history for zsh, bash, fish and nushell"
  homepage "https://github.com/atuinsh/atuin"
  url "https://github.com/atuinsh/atuin/archive/refs/tags/v18.3.0.tar.gz"
  sha256 "d05d978d1f1b6a633ac24a9ac9bde3b1dfb7416165b053ef54240fff898aded3"
  license "MIT"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "814e4fe86a9a97c51bc4e08b75a1f6663aceefa11f4a14d9e02030afea0f05ba"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a2422402545ce8f8933c78842c9f4e881a8d97bdfc9c229a7ecb62608cccbc9a"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "07f39301da5bc6bf5ca8001cb5337812234bc0a72ea48d078f7edb3e39410d59"
    sha256 cellar: :any_skip_relocation, sonoma:        "1f8a53dbda7d4c5a4cc520dc6b431d4da5008aba18231965b46b50da16966717"
    sha256 cellar: :any_skip_relocation, ventura:       "1581c91f8d3c71485be43b2f9e09b8173b51dd3f2edd44663730383e4585a5ea"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a421a99d8cb19622bdb90deb960db8f55ef66a934e3449fff05a4f55c5ae1d00"
  end

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/atuin")

    generate_completions_from_executable(bin/"atuin", "gen-completion", "--shell")
  end

  service do
    run [opt_bin/"atuin", "daemon"]
    keep_alive true
    log_path var/"log/atuin.log"
    error_log_path var/"log/atuin.log"
  end

  test do
    # or `atuin init zsh` to setup the `ATUIN_SESSION`
    ENV["ATUIN_SESSION"] = "random"
    assert_match "autoload -U add-zsh-hook", shell_output("#{bin}/atuin init zsh")
    assert shell_output("#{bin}/atuin history list").blank?
  end
end
