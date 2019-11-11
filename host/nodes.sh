#!/bin/bash
#################################################################################
# Logging Function
echo_log () {
  if [[ $1 == "0" ]]; then
	  echo "STAT>> $2 ..."
  elif [[ $1 == "2" ]]; then
	  echo "WARN>> $2 ..."
  elif [[ $1 == "1" ]]; then
	  echo "ERROR>> $2"
	  echo "ERROR>> Critical Exiting!"
          exit 1
  fi
}

#################################################################################
# Priviledge Check
[[ $EUID -ne 0 ]] && echo_log 1 "This script must be run as root!"

#################################################################################
# Virtual Machine Variables
name_BASE="ocp4.braincraft.io"
vm_CPU=2           # CPU Count
vm_RAM=4096        # in Megabytes
root_DISK=120      # in Gigabytes
bstrap_COUNT=01    # Set Bootstrap Build
master_COUNT=03    # Set VM spawn count
worker_COUNT=02    # Set VM spawn count
storage_POOL="/var/lib/libvirt/images"

#################################################################################
run_boot_all () {
  for guest_TARGET in $(virsh list --all | grep ${name_BASE} | awk '{print $2}'); do
	  virsh start ${guest_TARGET}
	  sleep 5
  done
}
#################################################################################
# Prompt for cluster start
req_boot () {

  echo_log 0 "All nodes ready to boot for cloud ${name_BASE}"

  if [[ ${safety_BOOL} == "0" ]]; then
    while true; do
      read -rp "       Would you like to start this cluster now? " yn
        case $yn in
          [Yy]* ) echo_log 0 "Booting cluster now" ; 
                  run_boot_all
                  break
                  ;;
          [Nn]* ) echo_log 2 "Exiting without cluster up due to user input"
		  exit 0
                  ;;
              * ) echo "$SEP_2 Please answer yes or no." ;;
        esac
      break
    done
  fi
}

#################################################################################
# Load DHCP/DNS/PXE Config Files
config_runner () {

  echo_log 0 "Loading pxelinux bootstrap & master role cores boot menus"
  # load alphaHex pxe boot config files
  for i in $(ls /tmp/ocp4pxe/); do 
    lxc file push /tmp/ocp4pxe/$i \
	    tftp/tftpboot/pxelinux.cfg/
  done

  echo_log 0 "Loading \{hwaddr/ipaddr/hostname\} tables"
  # Load etc/ethers mac/ip/hostname tables
  lxc file push /tmp/ethers \
	    dnsmasq/etc/ethers
  lxc exec dnsmasq -- sh -c 'chmod 644 /etc/ethers'

  echo_log 0 "Restarting dnsmasq service on \'dnsmasq\' container"
  # Reload dnsmasq
  lxc exec dnsmasq -- \
	  /bin/bash -c 'systemctl restart dnsmasq 2>/dev/null'

}

#################################################################################
spawn_build () {
echo_log 0 "Creating Libvirt VM ${name_FULL}"

  # Define Virtual Machine
  virt-install \
    --pxe \
    --hvm \
    --cpu host \
    --graphics none \
    --cpu host-passthrough \
    --noautoconsole \
    --vcpus=${vm_CPU} \
    --memory=${vm_RAM} \
    --name=${name_FULL} \
    --boot 'hd,network,useserial=on' \
    --description "RHCOS OCP4 ${node_ROLE}" \
    --network network=openshift,model=virtio,mac=${eth0_HWADDR} \
    --disk path=${storage_POOL}/${name_FULL}_vda.qcow2,format=qcow2,bus=virtio,sparse=true,cache=unsafe,size=${root_DISK}

  # Halt System (will boot manually later)
  sleep 1 && virsh destroy ${name_FULL} 2>/dev/null

}

#################################################################################
stage_pxe_cfg () {
eth0_HEXIP=$(gethostip -x ${eth0_IP})
echo_log 0 "Generating pxelinux.cfg master boot file for host: ${eth0_IP} ${eth0_HEXIP}"

cat <<EOF >/tmp/ocp4pxe/${eth0_HEXIP}
default coreos
prompt 0
label coreos
  menu default
  kernel  http://httpd.ocp4.braincraft.io/boot/rhcos-4.2.0-x86_64-installer-kernel ip=dhcp rd.neednet=1 initrd=http://httpd.ocp4.braincraft.io/boot/rhcos-4.2.0-x86_64-installer-initramfs.img console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=vda coreos.inst.image_url=http://httpd.ocp4.braincraft.io/boot/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://httpd.ocp4.braincraft.io/ignition/bootstrap.ign
  append coreos.first_boot=1 coreos.config.url=https://httpd.ocp4.braincraft.io/master.ign
EOF
}

#################################################################################
spawn_prep () {
echo_log 0 "Generating interface profile"

  # Generate unique repeatable eth0 MAC address
  eth0_HWADDR=$(echo "${name_FULL} openshift eth0 libvirt" | md5sum \
    | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')

}

#################################################################################
run_spawn () {
node_ROLE=$1
echo_log 0 "Initializing Nodes: ${node_ROLE}"

  # Build bootstrap
  if [[ ${node_ROLE} == "bootstrap" ]]; then

      # Set VM Name & Declare Build
      name_FULL="${node_ROLE}${count}.${name_BASE}"
      echo_log 0 "Initializing .. ${name_FULL}"

      # Generate node variables
      spawn_prep

      # Log to /etc/ethers & write pxelinux menu seed files
      eth0_IP='172.30.0.30'
      echo "${eth0_HWADDR} ${name_FULL}" | sed 's/\\//g' | tee -a /tmp/ethers
      echo "${eth0_HWADDR} ${eth0_IP}"   | sed 's/\\//g' | tee -a /tmp/ethers
      stage_pxe_cfg 


      # Init node
      spawn_build

  # Build Masters
  elif [[ ${node_ROLE} == "master" ]]; then
    for count in $(seq -w 01 ${master_COUNT}); do

      # Set VM Name & Declare Build
      name_FULL="${node_ROLE}${count}.${name_BASE}"
      echo_log 0 "Initializing .. ${name_FULL}"
       
      # Generate node variables
      spawn_prep

      # Log to /etc/ethers & write pxelinux menu seed files
      eth0_IP=$(echo 172.30.0.$(echo ${count} | sed 's/0/3/g'))
      echo "${eth0_HWADDR} ${name_FULL}" | sed 's/\\//g' | tee -a /tmp/ethers
      echo "${eth0_HWADDR} ${eth0_IP}"   | sed 's/\\//g' | tee -a /tmp/ethers
      stage_pxe_cfg 

      # Init node
      spawn_build

    done
    
  # Build Workers
  elif [[ ${node_ROLE} == "worker" ]]; then
    for count in $(seq -w 01 ${worker_COUNT}); do

      # Set VM Name & Declare Build
      name_FULL="${node_ROLE}${count}.${name_BASE}"
      echo_log 0 "Initializing .. ${name_FULL}"

      # Generate node variables
      spawn_prep

      # Log to /etc/ethers
      eth0_IP=$(echo 172.30.1.$(echo ${count} | sed 's/0/4/g'))
      echo "${eth0_HWADDR} ${name_FULL}" | sed 's/\\//g' | tee -a /tmp/ethers
      echo "${eth0_HWADDR} ${eth0_IP}"   | sed 's/\\//g' | tee -a /tmp/ethers

      # Init node
      spawn_build

    done
  fi
}

#################################################################################
# Purge / Clean / Prep
run_clean () {
  echo_log 0 "Executing PreRun Cleanup/Prep Routine"

  for guest_TARGET in $(virsh list --all | grep ${name_BASE}); do
	  virsh destroy  ${guest_TARGET} 2>/dev/null
	  virsh undefine ${guest_TARGET} 2>/dev/null
  done
  rm    -rf /var/lib/libvirt/*.${name_BASE} 2>/dev/null

  for i in $(ovs-vsctl show | awk '/error: /{print $7}'); do
    ovs-vsctl del-port $i;
  done
  
  rm    -rf /tmp/ocp4pxe 2>/dev/null
  mkdir -p  /tmp/ocp4pxe
  
  echo '' > /tmp/ethers
}

#################################################################################
safety_check () {
safety_BOOL=$(virsh list --all | grep ${name_BASE} 2>&1 1>/dev/null; echo $?)

  echo_log 0 "Executing PreRun Safety Check"

  if [[ ${safety_BOOL} == "0" ]]; then
  echo_log 2 "Detected previous build for local cloud: ${name_BASE}"
  echo_log 2 "Continuing will destroy the preexisting cluster..."
    while true; do
      read -rp "Are you sure you want to continue?" yn
        case $yn in
          [Yy]* ) echo_log 2 "Continuing with purge and cleanup" ; 
                  run_clean
                  break
                  ;;
          [Nn]* ) echo_log 1 "Aborting due to user input!"
                  ;;
              * ) echo "$SEP_2 Please answer yes or no." ;;
        esac
      break
    done
  fi
}

#################################################################################
run_core () {
safety_check
run_clean
run_spawn bootstrap
run_spawn master
run_spawn worker
config_runner
req_boot
}

run_core
