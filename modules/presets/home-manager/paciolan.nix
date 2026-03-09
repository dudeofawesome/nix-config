{
  lib,
  pkgs,
  pkgs-unstable,
  machine-class,
  ...
}:
with pkgs.stdenv.targetPlatform;
{
  home.packages =
    with pkgs;
    lib.flatten [
      # Utilities
      awscli2
      glab
      k6
      terraform
      (lib.optionals (machine-class == "pc") [
        # ansible
        gitlab-runner
        postman

        (lib.optionals isDarwin [
          pkgs-unstable.tableplus
        ])
      ])
    ];

  programs = {
    slack = {
      enable = lib.mkDefault (machine-class == "pc");
      package = pkgs-unstable.slack;
    };
    zoom-us = {
      enable = lib.mkDefault (machine-class == "pc");
      package = pkgs-unstable.zoom-us;
    };
    podman-desktop = {
      enable = lib.mkDefault (machine-class == "pc");
      extraConfig = {
        "telemetry.enabled" = false;
        "preferences.login.start" = false;
        "podman.setting.rosetta" = true;
        "preferences.update.reminder" = "never";
      };
    };
  };

  home.file.maven_settings = {
    enable = true;
    target = ".m2/settings.xml";
    text = ''
      <settings>
          <mirrors>
              <mirror>
                  <!--This sends everything else to /public -->
                  <id>nexus</id>
                  <mirrorOf>*,!confluent</mirrorOf>
                  <url>http://nexus.paciolan.info:8081/nexus/content/groups/public</url>
              </mirror>
          </mirrors>
          <servers>
              <server>
                  <id>releases</id>
                  <username>admin</username>
                  <password>admin123</password>
              </server>
              <server>
                  <id>snapshots</id>
                  <username>admin</username>
                  <password>admin123</password>
              </server>
          </servers>
          <pluginGroups>
              <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
          </pluginGroups>
          <profiles>
              <profile>
                  <id>nexus</id>
                  <!--Enable snapshots for the built in central repo to direct -->
                  <!--all requests to nexus via the mirror -->
                  <repositories>
                      <repository>
                          <id>central</id>
                          <url>http://central</url>
                          <releases>
                              <enabled>true</enabled>
                          </releases>
                          <snapshots>
                              <enabled>true</enabled>
                          </snapshots>
                      </repository>
                      <repository>
                          <id>spring-milestone</id>
                          <name>Spring Maven MILESTONE Repository</name>
                          <url>http://repo.spring.io/libs-milestone</url>
                      </repository>
                      <repository>
                          <id>repository.springframework.maven.release</id>
                          <name>Spring Framework Maven Release Repository</name>
                          <url>http://maven.springframework.org/milestone/</url>
                      </repository>
                  </repositories>
                  <pluginRepositories>
                      <pluginRepository>
                          <id>central</id>
                          <url>http://central</url>
                          <releases>
                              <enabled>true</enabled>
                          </releases>
                          <snapshots>
                              <enabled>true</enabled>
                              <updatePolicy>always</updatePolicy>
                          </snapshots>
                      </pluginRepository>
                      <pluginRepository>
                          <id>spring-milestones</id>
                          <url>http://repo.spring.io/milestone</url>
                      </pluginRepository>
                  </pluginRepositories>
              </profile>
              <profile>
                  <id>sonar</id>
                  <activation>
                      <activeByDefault>true</activeByDefault>
                  </activation>
                  <properties>
                      <!-- Optional URL to server. Default value is http://localhost:9000 -->
                      <sonar.host.url>
                          http://sonarqube.paciolan.info:9000
                      </sonar.host.url>
                  </properties>
              </profile>
          </profiles>
          <activeProfiles>
              <!--make the profile active all the time -->
              <activeProfile>nexus</activeProfile>
          </activeProfiles>
      </settings>
    '';
  };
}
