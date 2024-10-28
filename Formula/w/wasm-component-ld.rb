class WasmComponentLd < Formula
  desc "Linker for creating WebAssembly components"
  homepage "https://wasi.dev"
  url "https://github.com/bytecodealliance/wasm-component-ld/archive/refs/tags/v0.5.10.tar.gz"
  sha256 "aa049a93da595e4dacf742865f13e7fb1cec1ab47de9258f0a11d81ad6c7a77b"
  license "Apache-2.0"
  head "https://github.com/bytecodealliance/wasm-component-ld.git", branch: "main"

  depends_on "rust" => :build
  depends_on "lld" => :test
  depends_on "llvm" => :test
  depends_on "wasi-libc" => :test
  depends_on "wasmtime" => :test

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    resource "builtins" do
      url "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-24/libclang_rt.builtins-wasm32-wasi-24.0.tar.gz"
      sha256 "7e33c0df758b90469b1de3ca158e2d0a7f71934d5884525ba6a372de0b3b0ec7"
    end

    ENV.remove_macosxsdk if OS.mac?
    ENV.remove_cc_etc

    (testpath/"test.c").write <<~C
      #include <stdio.h>
      volatile int x = 42;
      int main(void) {
        printf("the answer is %d", x);
        return 0;
      }
    C

    clang = Formula["llvm"].opt_bin/"clang"
    clang_resource_dir = Pathname.new(shell_output("#{clang} --print-resource-dir").chomp)
    testpath.install_symlink clang_resource_dir/"include"
    resource("builtins").stage testpath/"lib/wasm32-unknown-wasip2"
    (testpath/"lib/wasm32-unknown-wasip2").install_symlink "libclang_rt.builtins-wasm32.a" => "libclang_rt.builtins.a"
    wasm_args = %W[--target=wasm32-wasip2 --sysroot=#{Formula["wasi-libc"].opt_share}/wasi-sysroot]
    system clang, *wasm_args, "-v", "test.c", "-o", "test", "-resource-dir=#{testpath}"
    assert_equal "the answer is 42", shell_output("wasmtime #{testpath}/test")
  end
end
