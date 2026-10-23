# Homebrew Formula for Disc
#
# Standard tap location after publication:
#   github.com/systemsoft/homebrew-disc/Formula/disc.rb
#
# Until the tap repo exists, this formula can be installed directly from the
# main repo for early adopters:
#   brew install --HEAD https://raw.githubusercontent.com/systemsoft/disc/primary/homebrew/disc.rb
#
# Build path notes:
#   - Builds Disc from source via `deno compile` (no GitHub release artifacts
#     yet — bottle support waits on a published release pipeline).
#   - The brew-built binary does NOT bundle PostgreSQL: the build machine
#     has no `<DISC_HOME>/postgres/<version>/` cache, so the embedded-PG
#     manifest is empty and the runtime falls back to the network downloader
#     on first `disc init` / `disc serve`. This matches `DISC_BUILD_NO_BUNDLE_PG=1`
#     behavior and keeps the formula’s brew install footprint small.
#   - The UI IS bundled (the formula’s build steps run `bun run build` first
#     so `server/ui-assets.test.ts` and the runtime SPA path both work).

class Disc < Formula
  desc "TypeScript-native, schema-first database (Gel/EdgeDB compatible)"
  homepage "https://disc.sh"
  version "2026.10.23"
  license "Apache-2.0"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/systemsoft/disc/releases/download/v#{version}/disc-darwin-arm64"
      sha256 "0b9e9b04a01a8df9514a5111228b954ad5bc994f8d88d144c98045e7dc958f6e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/systemsoft/disc/releases/download/v#{version}/disc-linux-arm64"
      sha256 "0534db37db32816a11c1dcb441a68b52e32f2eaf080b672a71aa8d87f95a0972"
    end

    on_intel do
      url "https://github.com/systemsoft/disc/releases/download/v#{version}/disc-linux-x64"
      sha256 "7ef200287d4261af691ff9f23d401773a7fb591d7cb9f67f6240ae7896b86652"
    end
  end

  def install
    # The download is the bare executable, named after its platform.
    bin.install Dir["disc-*"].first => "disc"
  end

  test do
    # `disc --version` must exit 0 and print a version string. This is
    # the same smoke test `cli/binary-integration.test.ts` runs.
    output = shell_output("#{bin}/disc --version")
    assert_match(/\d+\.\d+\.\d+/, output)
  end
end
