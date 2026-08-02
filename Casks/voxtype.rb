cask "voxtype" do
  version "0.7.5"
  sha256 "c3edb9791ba8b39bb3dcdc2d6f482383041b2196461bfef9f7de1f4fe90a0db6"

  url "https://github.com/peteonrails/voxtype/releases/download/v#{version}/voxtype-#{version}-macos-universal.dmg"
  name "Voxtype"
  desc "Push-to-talk voice-to-text"
  homepage "https://voxtype.io"

  # Since 0.7.2 the macOS release ships a single universal CLI daemon (no .app
  # bundle). The app bundle, Login Item, and permission prompts are built from
  # the installed binary at install time via `voxtype setup app-bundle`.
  depends_on macos: :ventura

  binary "voxtype"

  postflight do
    voxtype_bin = "#{HOMEBREW_PREFIX}/bin/voxtype"

    # The binary is adhoc-signed (not notarized), so clear quarantine before it
    # runs or Gatekeeper will block the generated bundle.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", voxtype_bin],
                   sudo: false

    # Build /Applications/Voxtype.app from the installed binary, register it as
    # a Login Item, and trigger the Accessibility / Input Monitoring / Microphone
    # permission flow. Non-interactive and idempotent.
    system_command voxtype_bin,
                   args: ["setup", "app-bundle"],
                   sudo: false

    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Voxtype.app"],
                   sudo: false
  end

  # The daemon forks and reparents to launchd, so `quit` (an Apple Event) only
  # catches the GUI app. Delegate full teardown to voxtype itself, which stops
  # the daemon, removes the Login Item, and deletes the app bundle. `quit` and
  # `delete` are fallbacks if the binary is already gone.
  uninstall early_script: {
             executable: "#{HOMEBREW_PREFIX}/bin/voxtype",
             args:       ["setup", "app-bundle", "--uninstall"],
             sudo:       false,
           },
           quit: "io.voxtype.daemon",
           delete: "#{appdir}/Voxtype.app"

  zap trash: [
    "~/.config/voxtype",
    "~/Library/Logs/voxtype",
  ]

  caveats <<~EOS
    Voxtype 0.7.x is installed as the `voxtype` CLI and wired up as a macOS
    Login Item (Voxtype.app) during install.

    On first launch, grant in System Settings > Privacy & Security:
      - Accessibility       (required for the push-to-talk hotkey)
      - Input Monitoring
      - Microphone

    Default hotkey: fn (Globe key)
    Re-run setup:   voxtype setup macos
    CLI help:       voxtype --help
  EOS
end
