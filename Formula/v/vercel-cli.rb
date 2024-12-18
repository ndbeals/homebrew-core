class VercelCli < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-39.0.5.tgz"
  sha256 "1493e390a388ed42d381e1c3c1aa2f74625418684a4a3ff6532d37e6f4ac1ce9"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "590ccf757aa062bfd49d53a0aa02908e0cfeb9737068a0990a0be2f97c61fae1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "590ccf757aa062bfd49d53a0aa02908e0cfeb9737068a0990a0be2f97c61fae1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "590ccf757aa062bfd49d53a0aa02908e0cfeb9737068a0990a0be2f97c61fae1"
    sha256 cellar: :any_skip_relocation, sonoma:        "f2f4c936ef37ea80f174e1ab9cb87aee7791127b0a2cc72f522118217a8b023b"
    sha256 cellar: :any_skip_relocation, ventura:       "f2f4c936ef37ea80f174e1ab9cb87aee7791127b0a2cc72f522118217a8b023b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "75f1a47fc337147cfaced46224c01b08ab26f71d62c50b1085f955df0ad60769"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "${await getUpdateCommand()}",
                               "brew upgrade vercel-cli"
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible deasync modules
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/vercel/node_modules"
    node_modules.glob("deasync/bin/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }
  end

  test do
    system bin/"vercel", "init", "jekyll"
    assert_predicate testpath/"jekyll/_config.yml", :exist?, "_config.yml must exist"
    assert_predicate testpath/"jekyll/README.md", :exist?, "README.md must exist"
  end
end
