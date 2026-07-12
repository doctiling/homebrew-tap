# Homebrew formula for the doctiling tap.
# Publish: copy into doctiling/homebrew-tap repo as Formula/doctiling.rb and
# update url/sha256/version per release (the release workflow prints the
# sha256; a tap-bump automation can come later).
#   brew tap doctiling/tap && brew install doctiling && brew services start doctiling
class Doctiling < Formula
  desc "Editorial studio for documents and the AI agents that read them — self-hosted"
  homepage "https://doctiling.app"
  url "https://github.com/doctiling/releases/releases/download/v0.1.0/doctiling-standalone.tar.gz"
  sha256 "b3e8b0e7b1bd1d9ac64fa433d33888a208d5e820463f33c6f4fda2ab6f2116cb"
  version "0.1.0"
  license "UNLICENSED"

  depends_on "node@20"

  def install
    libexec.install Dir["*", ".next"]

    node = Formula["node@20"].opt_bin/"node"
    (bin/"doctiling").write <<~SH
      #!/bin/sh
      set -eu
      export DOCTILING_HOME="${DOCTILING_HOME:-$HOME/.doctiling}"
      export DOCTILING_NODE="#{node}"
      export DOCTILING_APP="#{libexec}"
      sh "#{libexec}/scripts/self-host/setup-env.sh" "#{node}" "#{libexec}"
      exec sh "#{libexec}/scripts/self-host/doctiling" "$@"
    SH
  end

  service do
    run [opt_bin/"doctiling", "run"]
    keep_alive true
    log_path var/"log/doctiling.log"
    error_log_path var/"log/doctiling.log"
  end

  def caveats
    <<~EOS
      First run generates ~/.doctiling/.env with every secret (local AI defaults).
      Start now:            doctiling start
      Start at login:       brew services start doctiling
      Then open http://127.0.0.1:3000 and install it as an app.
      Local AI needs LM Studio or Ollama serving http://127.0.0.1:1234/v1
      (edit LLM_BASE_URL in ~/.doctiling/.env for a different port).
    EOS
  end

  test do
    assert_predicate libexec/"server.js", :exist?
  end
end
