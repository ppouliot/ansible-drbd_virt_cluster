docker run --net=host -v `pwd`:/image danderson/pixiecore \
boot https://github.com/rancher/os/releases/download/v1.4.0/vmlinuz \
https://github.com/rancher/os/releases/download/v1.4.0/initrd  \
--cmdline='rancher.state.dev=LABEL=RANCHER_STATE rancher.state.autoformat=[/dev/sda] \
rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]'rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]'
