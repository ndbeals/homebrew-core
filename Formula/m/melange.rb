class Melange < Formula
  desc "Build APKs from source code"
  homepage "https://github.com/chainguard-dev/melange"
  url "https://github.com/chainguard-dev/melange/archive/refs/tags/v0.15.11.tar.gz"
  sha256 "387864d312613cf623c6cdcac5fdcd0359e8e13bffc2c3bc2453ede69d27493a"
  license "Apache-2.0"
  head "https://github.com/chainguard-dev/melange.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a8fa6a2c9027cb7b83815e9f0115360fcdd07949981ea262ffb22720715644b2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a8fa6a2c9027cb7b83815e9f0115360fcdd07949981ea262ffb22720715644b2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a8fa6a2c9027cb7b83815e9f0115360fcdd07949981ea262ffb22720715644b2"
    sha256 cellar: :any_skip_relocation, sonoma:        "37acb3b8361848e81bf91a18d9e5b70bb5281e37e0a98f3d5fba4c43d64a5ac6"
    sha256 cellar: :any_skip_relocation, ventura:       "37acb3b8361848e81bf91a18d9e5b70bb5281e37e0a98f3d5fba4c43d64a5ac6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f0b98a1397c68dfe2c508146b4eb7c5f483616b5d194191624bf3054a203d62a"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X sigs.k8s.io/release-utils/version.gitVersion=#{version}
      -X sigs.k8s.io/release-utils/version.gitCommit=brew
      -X sigs.k8s.io/release-utils/version.gitTreeState=clean
      -X sigs.k8s.io/release-utils/version.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"melange", "completion")
  end

  test do
    (testpath/"test.yml").write <<~YAML
      package:
        name: hello
        version: 2.12
        epoch: 0
        description: "the GNU hello world program"
        copyright:
          - paths:
            - "*"
            attestation: |
              Copyright 1992, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2005,
              2006, 2007, 2008, 2010, 2011, 2013, 2014, 2022 Free Software Foundation,
              Inc.
            license: GPL-3.0-or-later
        dependencies:
          runtime:

      environment:
        contents:
          repositories:
            - https://dl-cdn.alpinelinux.org/alpine/edge/main
          packages:
            - alpine-baselayout-data
            - busybox
            - build-base
            - scanelf
            - ssl_client
            - ca-certificates-bundle

      pipeline:
        - uses: fetch
          with:
            uri: https://ftp.gnu.org/gnu/hello/hello-${{package.version}}.tar.gz
            expected-sha256: cf04af86dc085268c5f4470fbae49b18afbc221b78096aab842d934a76bad0ab
        - uses: autoconf/configure
        - uses: autoconf/make
        - uses: autoconf/make-install
        - uses: strip
    YAML

    assert_equal "hello-2.12-r0", shell_output("#{bin}/melange package-version #{testpath}/test.yml")

    system bin/"melange", "keygen"
    assert_predicate testpath/"melange.rsa", :exist?

    assert_match version.to_s, shell_output(bin/"melange version 2>&1")
  end
end
