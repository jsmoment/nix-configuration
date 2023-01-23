{config, pkgs, ... }:
{  
  # enable iommu
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
  programs.dconf.enable = true;
 
  # enable the libvirtd service 
  systemd.services.libvirtd.path = [ pkgs.bash ];
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull pkgs.OVMFFull.fd ];
      swtpm.enable = true;
    };
  };

  # secureboot
  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
      mode = "0644";
      user = "libvirtd";
    };
  };
  # add users to the libvirtd group
  users.groups.libvirtd.members = [ "root" "js" ];
  
  # scuffed hooks setup
  systemd.services.libvirtd.preStart = ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    cp -rf /home/js/.config/nixpkgs/nixosconf/pci-passthrough/* /var/lib/libvirt/hooks/

    # Make them executable
    chmod +x /var/lib/libvirt/hooks/qemu
  '';
}
