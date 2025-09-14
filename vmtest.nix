{ nixosTest, config }:
nixosTest {
  name = "musl-vmtest";
  nodes = {
    vm = config;
  };

  testScript = ''
    start_all()
    vm.wait_for_unit("multi-user.target")
    vm.succeed("echo hello")
    vm.shutdown()
  '';
}

