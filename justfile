# Test a host in a virtual machine
vm HOST:
    nix run {{justfile_directory()}}#nixosConfigurations.{{HOST}}.config.system.build.vm

# Initialize a remote host using nixos-anywhere
deploy HOST REMOTE: 
    NIX_SSHOPTS="-i ~/.ssh/lab_key";
    cd {{justfile_directory()}}
    mkdir -p target/{{HOST}}/etc/
    cp -r {{HOST}}/host_keys/ target/{{HOST}}/etc/ssh
    nixos-anywhere --flake .#{{HOST}} --extra-files target/{{HOST}} --generate-hardware-config nixos-generate-config {{HOST}}/hardware-configuration.nix --target-host {{REMOTE}}
    rm -r target

# Build and activate a configuration on an existing remote host
switch HOST REMOTE:
    NIX_SSHOPTS="-i ~/.ssh/lab_key";
    nixos-rebuild switch --flake {{justfile_directory()}}#{{HOST}} --ask-sudo-password --target-host {{REMOTE}}

