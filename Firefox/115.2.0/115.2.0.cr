class Target < ISM::Software

    def prepare
        super

        mozconfigData = <<-CODE
        ac_add_options --target=#{Ism.settings.systemTarget}
        ac_add_options --with-toolchain-prefix=#{Ism.settings.systemTarget}-
        ac_add_options --enable-bootstrap
        ac_add_options #{option("Wireless-Tools") ? "--enable-necko-wifi" : "--disable-necko-wifi"}
        ac_add_options --enable-pulseaudio
        ac_add_options --disable-alsa
        ac_add_options #{option("Elf-Hack") ? "--enable-elf-hack" : "--disable-elf-hack"}
        ac_add_options --with-system-libevent
        ac_add_options --with-system-webp
        ac_add_options --with-system-libvpx
        ac_add_options --with-system-nspr
        ac_add_options --with-system-nss
        ac_add_options --with-system-icu
        ac_add_options --enable-official-branding
        ac_add_options --disable-debug-symbols
        ac_add_options --prefix=/usr
        ac_add_options --enable-application=browser
        ac_add_options --disable-crashreporter
        ac_add_options --disable-updater
        ac_add_options --disable-tests
        ac_add_options --enable-optimize
        ac_add_options --enable-system-ffi
        ac_add_options --enable-system-pixman
        ac_add_options --with-system-jpeg
        ac_add_options --with-system-png
        ac_add_options --with-system-zlib
        ac_add_options --without-wasm-sandboxed-libraries
        unset MOZ_TELEMETRY_REPORTING
        mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-build-dir
        CODE
        fileWriteData("#{buildDirectoryPath}/mozconfig",mozconfigData)
    end
    
    def configure
        super

        runPythonCommand(   arguments:      "./mach configure",
                            path:           buildDirectoryPath,
                            environment:    {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                                "MOZBUILD_STATE_PATH" => "mozbuild"},
                                                "RUST_TARGET" => "#{Ism.settings.systemTarget}")
    end

    def build
        super

        runPythonCommand(   arguments:      "./mach build",
                            path:           buildDirectoryPath,
                            environment:    {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                                "MOZBUILD_STATE_PATH" => "mozbuild"},
                                                "RUST_TARGET" => "#{Ism.settings.systemTarget}")
    end
    
    def prepareInstallation
        super

        runPythonCommand(   arguments:      "./mach install",
                            path:           buildDirectoryPath,
                            environment:    {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                                "MOZBUILD_STATE_PATH" => "mozbuild",
                                                "DESTDIR" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"},
                                                "RUST_TARGET" => "#{Ism.settings.systemTarget}")

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/applications")

        firefoxData = <<-CODE
        [Desktop Entry]
        Encoding=UTF-8
        Name=Firefox Web Browser
        Comment=Browse the World Wide Web
        GenericName=Web Browser
        Exec=firefox %u
        Terminal=false
        Type=Application
        Icon=firefox
        Categories=GNOME;GTK;Network;WebBrowser;
        MimeType=text/xml;text/mml;text/html;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;
        StartupNotify=true
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/applications/firefox.desktop",firefoxData)

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/pixmaps")

        makeLink(   target: "/usr/lib/firefox/browser/chrome/icons/default/default128.png",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/share/pixmaps/firefox.png",
                    type:   :symbolicLinkByOverwrite)
    end

end
