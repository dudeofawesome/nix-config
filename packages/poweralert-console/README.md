# PowerAlert console

Packages the Java console from Tripp Lite's SNMPWEBCARD bundle with Zulu Java. The Windows installer is extracted during the build; its bundled Windows JRE is discarded.

```sh
nix run .#poweralert-console -- -a 192.168.1.20
nix run .#poweralert-console -- -a 192.168.1.20 -p 3664
```

`legacy-tls.security` preserves the original launcher's TLS 1.0 and legacy certificate compatibility settings. These overrides apply only to the packaged Java process. PowerAlert stores its logs under `~/paconsole2/logs`.
