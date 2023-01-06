{ lib, stdenv, fetchurl, jdk19, runtimeShell, unzip, chromium, proVersion ? false }:

stdenv.mkDerivation rec {
  pname = "burpsuite";
  product = if proVersion then "pro" else "community";
  sha = if proVersion then "sha256-LiLXWbztWv74fuVfKhAgPCTGK6NoS+/iJ2phCCs27ic=" else "sha256-rJ3Runuelg+wJfut6e5L0uVGeYoAkNK+VGRn1BsLnXM=";
  version = "2022.12.5";

  src = fetchurl {
    name = "burpsuite.jar";
    urls = [
      "https://portswigger.net/Burp/Releases/Download?product=${product}&version=${version}&type=Jar"
      "https://web.archive.org/web/https://portswigger.net/Burp/Releases/Download?product=${product}&version=${version}&type=Jar"
    ];
    sha256 = sha;
  };

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    echo '#!${runtimeShell}
    eval "$(${unzip}/bin/unzip -p ${src} chromium.properties)"
    mkdir -p "$HOME/.BurpSuite/burpbrowser/$linux64"
    ln -sf "${chromium}/bin/chromium" "$HOME/.BurpSuite/burpbrowser/$linux64/chrome"
    exec ${jdk19}/bin/java -jar ${src} "$@"' > $out/bin/burpsuite
    chmod +x $out/bin/burpsuite

    runHook postInstall
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "An integrated platform for performing security testing of web applications";
    longDescription = ''
      Burp Suite is an integrated platform for performing security testing of web applications.
      Its various tools work seamlessly together to support the entire testing process, from
      initial mapping and analysis of an application's attack surface, through to finding and
      exploiting security vulnerabilities.
    '';
    homepage = "https://portswigger.net/burp/";
    downloadPage = "https://portswigger.net/burp/releases";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    platforms = jdk19.meta.platforms;
    hydraPlatforms = [];
    maintainers = with maintainers; [ bennofs bamhm182 ];
  };
}
