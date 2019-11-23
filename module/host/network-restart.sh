#!/bin/bash
restart_network () {
	systemctl restart NetworkManager.service
	systemctl restart network.service
}
restart_network 
