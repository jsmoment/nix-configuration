{config, pkgs, ... }:
{  
  # enable iommu
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    
  # enable the vfio kernel modules
  # boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  
  # define the pci ids
  # boot.extraModprobeConfig ="options vfio-pci ids=10de:2487,10de:228b";
  
  # install the required packages
  environment.systemPackages = with pkgs; [
    virt-manager
    qemu
    OVMF
  ];
  programs.dconf.enable = true;
 
  # enable the libvirtd service 
  systemd.services.libvirtd.path = [ pkgs.bash ];
  virtualisation.libvirtd.enable = true;
  
  # add users to the libvirtd group
  users.groups.libvirtd.members = [ "root" "js"];
  
  # i don't know what this does
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    nvram = [
      "/nix/store/a61rzm6kiny2pzk5fjn5yhblgjn7sh0f-OVMF-202202-fd/FV/OVMF.fd:/nix/store/a61rzm6kiny2pzk5fjn5yhblgjn7sh0f-OVMF-202202-fd/FV/OVMF_VARS.fd"
    ]
  '';
  
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
