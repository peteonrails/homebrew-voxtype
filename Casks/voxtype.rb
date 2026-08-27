cask "voxtype" do
  version "0.7.5"
  sha256 "c3edb9791ba8b39bb3dcdc2d6f482383041b2196461bfef9f7de1f4fe90a0db6"

  url "https://github.com/peteonrails/voxtype/releases/download/v#{version}/voxtype-#{version}-macos-universal.dmg"
  name "Voxtype"
  desc "Push-to-talk voice-to-text"
  homepage "https://voxtype.io/"

  depends_on macos: :ventura

  binary "voxtype"

  # The published DMG is not yet signed or notarized, so Homebrew's quarantine
  # flag would make Gatekeeper refuse to run it. Drop this once the release
  # pipeline signs and notarizes the artifact.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{staged_path}/voxtype"],
                   sudo: false
  end

  uninstall quit: "io.voxtype.daemon"

  zap trash: [
    "~/.config/voxtype",
    "~/Library/Logs/voxtype",
  ]

  caveats <<~EOS
    Voxtype installs as a command-line tool. To get started:
      voxtype configure

    Voxtype will prompt for Microphone and Accessibility permissions on first
    run, and download a speech model if one is not already present.

    Default hotkey: fn (Globe key)
    More info: voxtype --help
  EOS
end
