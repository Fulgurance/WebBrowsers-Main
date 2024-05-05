class Target < ISM::Software

    def prepare
        super

        mozconfigData = <<-CODE
        ac_add_options #{option("Wireless-Tools") ? "--enable-necko-wifi" : "--disable-necko-wifi"}
        ac_add_options #{option("Pulseaudio") ? "--enable-pulseaudio" : "--disable-pulseaudio"}
        ac_add_options #{option("Alsa-Lib") ? "--enable-alsa" : "--disable-alsa"}
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
        fileWriteData("#{buildDirectoryPath(false)}/mozconfig",mozconfigData)
    end
    
    def configure
        super

        runPythonCommand(   ["./mach","configure"],
                            buildDirectoryPath,
                            {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                "MOZBUILD_STATE_PATH" => "mozbuild"})
    end

    def build
        super

        runPythonCommand(   ["./mach","build"],
                            buildDirectoryPath,
                            {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                "MOZBUILD_STATE_PATH" => "mozbuild"})
    end
    
    def prepareInstallation
        super

        runPythonCommand(   ["./mach","install"],
                            buildDirectoryPath,
                            {   "MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE" => "none",
                                "MOZBUILD_STATE_PATH" => "mozbuild",
                                "DESTDIR" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"})

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/share/applications")

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
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/share/applications/firefox.desktop",firefoxData)

        makeLink("/usr/lib/firefox/browser/chrome/icons/default/default128.png","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}usr/share/pixmaps/firefox.png",:symbolicLinkByOverwrite)
    end

end
