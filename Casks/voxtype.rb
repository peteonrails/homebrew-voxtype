cask "voxtype" do
  version "0.6.3"
  sha256 "fa98228944f414a51bc3a7e0456d16349aaf56825b92267b4c499d64afba72e7"

  url "https://github.com/peteonrails/voxtype/releases/download/v#{version}/Voxtype-#{version}-macos-arm64.dmg"
  name "Voxtype"
  desc "Push-to-talk voice-to-text"
  homepage "https://voxtype.io"

  depends_on macos: ">= :ventura"
  depends_on arch: :arm64

  app "Voxtype.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Voxtype.app"],
                   sudo: false

    binary = "#{appdir}/Voxtype.app/Contents/MacOS/voxtype-bin"
    if File.exist?(binary)
      FileUtils.ln_sf(binary, "#{HOMEBREW_PREFIX}/bin/voxtype")
    end
  end

  uninstall quit: "io.voxtype.daemon",
            login_item: "Voxtype"

  zap trash: [
    "~/.config/voxtype",
    "~/Library/Logs/voxtype",
  ]

  caveats <<~EOS
    Open Voxtype to get started:
      open /Applications/Voxtype.app

    Voxtype will automatically:
      - Download a speech model on first launch
      - Prompt for Microphone and Accessibility permissions

    Default hotkey: fn (Globe key)
    More info: voxtype --help
  EOS
end
