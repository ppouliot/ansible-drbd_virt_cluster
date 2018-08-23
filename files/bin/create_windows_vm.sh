#!/usr/bin/env bash
WINDOWS_ISO_NAME=en_windows_server_2016_updated_feb_2018_x64_dvd_11636692.iso

if [ !  -f /var/lib/libvirt/images/iso/w_floppy.img ]; then
  echo "Unattended.xml Floopy not found, Creating unattended.xml for local installations."
  mkdir -p /var/lib/libvirt/images/w_floppy.tmp
  dd bs=512 count=2880 if=/dev/zero of=/var/lib/libvirt/images/iso/w_floppy.img
  mkfs.msdos /var/lib/libvirt/images/iso/w_floppy.img
  mount -o loop /var/lib/libvirt/images/iso/w_floppy.img /var/lib/libvirt/images/w_floppy.tmp
  cat << EOF > /var/lib/libvirt/images/w_floppy.tmp/autounattend.xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <WillShowUI>OnError</WillShowUI>
                <Disk wcm:action="add">
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Size>100</Size>
                            <Type>Primary</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Extend>true</Extend>
                            <Type>Primary</Type>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Active>true</Active>
                            <Label>Boot</Label>
                            <Format>NTFS</Format>
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Format>NTFS</Format>
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                            <Label>System</Label>
                        </ModifyPartition>
                    </ModifyPartitions>
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <PartitionID>2</PartitionID>
                        <DiskID>0</DiskID>
                    </InstallTo>
                    <InstallToAvailablePartition>false</InstallToAvailablePartition>
                    <WillShowUI>OnError</WillShowUI>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/NAME</Key>
                            <Value>Windows Server 2012 R2 SERVERSTANDARD</Value>
                        </MetaData>
                    </InstallFrom>
                </OSImage>
            </ImageInstall>
            <UserData>
                <AcceptEula>true</AcceptEula>
                <!--
                <ProductKey>
                    <Key>XXXXX-XXXXX-XXXXX-XXXXX-XXXXX</Key>
                    <WillShowUI>OnError</WillShowUI>
                </ProductKey>
                -->
            </UserData>
        </component>
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <UILanguage>en-US</UILanguage>
            <SystemLocale>en-US</SystemLocale>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <VisualEffects>
                <FontSmoothing>ClearType</FontSmoothing>
            </VisualEffects>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <!--
                    ProtectYourPC:
                    1 Specifies the recommended level of protection for your computer.
                    2 Specifies that only updates are installed.
                    3 Specifies that automatic protection is disabled.
                -->
                <ProtectYourPC>3</ProtectYourPC>
                <NetworkLocation>Work</NetworkLocation>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <!-- Comment the following three options on Windows Vista / 7 and Windows Server 2008 / 2008 R2 -->
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <!--
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
                -->
            </OOBE>
            <!-- Use FirstLogonCommands instead of LogonCommands if you don't need to install Windows Updates -->
            <LogonCommands>
                <AsynchronousCommand wcm:action="add">
                    <CommandLine>%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell -NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -File %SystemDrive%\UnattendResources\Logon.ps1</CommandLine>
                    <Order>1</Order>
                </AsynchronousCommand>
            </LogonCommands>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell -NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -File %SystemDrive%\UnattendResources\FirstLogon.ps1</CommandLine>
                    <Order>1</Order>
                </SynchronousCommand>
            </FirstLogonCommands>
            <UserAccounts>
                <!--
                    Password to be used only during initial provisioning.
                    Must be reset with final Sysprep.
                -->
                <AdministratorPassword>
                    <Value>Passw0rd</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <!-- The following is needed on a client OS -->
                <!--
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Description>Admin user</Description>
                        <DisplayName>Admin</DisplayName>
                        <Group>Administrators</Group>
                        <Name>Admin</Name>
                    </LocalAccount>
                </LocalAccounts>
                -->
            </UserAccounts>
            <AutoLogon>
                <Password>
                    <Value>Passw0rd</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>50</LogonCount>
                <Username>Administrator</Username>
            </AutoLogon>
            <ComputerName>*</ComputerName>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>en-US</InputLocale>
            <UILanguage>en-US</UILanguage>
            <UILanguageFallback>en-us</UILanguageFallback>
            <SystemLocale>en-US</SystemLocale>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAuthentication>1</UserAuthentication>
        </component>
        <component name="Networking-MPSSVC-Svc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <FirewallGroups>
                <FirewallGroup wcm:action="add" wcm:keyValue="RemoteDesktop">
                    <Active>true</Active>
                    <Profile>all</Profile>
                    <Group>@FirewallAPI.dll,-28752</Group>
                </FirewallGroup>
            </FirewallGroups>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="NonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <TimeZone>UTC</TimeZone>
            <ComputerName>*</ComputerName>
            <!--
            <ProductKey>XXXXX-XXXXX-XXXXX-XXXXX-XXXXX</ProductKey>
            -->
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Path>powershell -NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -File %SystemDrive%\UnattendResources\Specialize.ps1</Path>
                    <Description>Run Specialize script</Description>
                </RunSynchronousCommand>
            </RunSynchronous>
            <ExtendOSPartition>
                <Extend>true</Extend>
            </ExtendOSPartition>
        </component>
        <component name="Microsoft-Windows-SQMApi" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="NonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <CEIPEnabled>0</CEIPEnabled>
        </component>
    </settings>
</unattend>
EOF
umount /var/lib/libvirt/images/w_floppy.tmp
rm -rf /var/lib/libvirt/images/w_floppy.tmp
fi

if [ !  -f /var/lib/libvirt/images/iso/virtio-win.iso ]; then
  wget -cv https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.160-1/virtio-win.iso -O /var/lib/libvirt/images/iso/virtio-win.iso
fi
cat << EOF > /etc/libvirt/qemu/$1.crm
primitive $1 VirtualDomain \
        params config="/etc/libvirt/qemu/$1.xml" hypervisor="qemu:///system" migration_transport=ssh \
        meta allow-migrate=true target-role=Started \
        op start timeout=120s interval=0 \
        op stop timeout=120s interval=0 \
        op monitor timeout=30 interval=10 depth=0 \
        utilization cpu=2 hv_memory=4096
commit
EOF

virt-install \
        --name $1 \
        --os-type windows \
        --os-variant win2k12 \
        --hvm \
        --virt-type kvm \
        --connect=qemu:///system \
        --accelerate \
        --vcpus 2 \
        --ram 4096 \
        --network bridge=br0,model=virtio \
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=$2,bus=virtio \
        --disk path=/var/lib/libvirt/images/iso/virtio-win.iso,device=cdrom \
        --nographics \
        --cdrom /var/lib/libvirt/images/iso/$WINDOWS_ISO_NAME

#    --extra-args="
#    console=ttyS0,115200n9 serial
#    rancher.state.dev=LABEL=RANCHER_STATE
#    rancher.state.autoformat=[/dev/sda,/dev/vda]
#    rancher.password=rancher
#    rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]" 
