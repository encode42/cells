{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cells";
  version = "4.4.9";

  src = fetchFromGitHub {
    owner = "pydio";
    repo = "cells";
    tag = "v${version}";
    hash = "sha256-8KgGnmPNUmROkssDSc2tYPSifi4A+jXB+rX1UpNXQQw=";
  };

  vendorHash = "sha256-dx9IIFq0w+Tlm2W5w1HDEEhp0FiNCIx4rMX/uGL6Hpw=";

  ldflags = [ "-s" "-w" "-X github.com/pydio/cells/v4/common.version=${src.tag}" "-X github.com/pydio/cells/v4/common.BuildRevision=${version}" "-X github.com/pydio/cells/v4/common.BuildStamp=1970-01-01T00:00:00" ];

  excludedPackages = [ "cmd/cells-fuse" "cmd/protoc-gen-go-client-stub" "cmd/protoc-gen-go-enhanced-grpc" ];

  checkFlags =
    let
      skippedTests = [
        # Skip tests that require network access
        "TestWGetAction_Run"
        "TestGetTimeFromNtp"

        # This test takes a *very* long time to complete
        "TestConcurrentReceivesGetAllTheMessages"
      ];
    in
    [ "-v" "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  meta = {
    description = "Future-proof content collaboration platform";
    homepage = "https://github.com/pydio/cells";
    changelog = "https://github.com/pydio/cells/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "cells";
  };
}
