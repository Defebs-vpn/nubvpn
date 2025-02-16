#!/bin/bash
# NUBVPN Management Menu
# Author: Defebs-vpn
# Date: 2025-02-16

clear
echo "=============================="
echo "     NUBVPN MANAGEMENT       "
echo "=============================="
echo "1. Add User"
echo "2. Delete User"
echo "3. Show Users"
echo "4. Monitor Usage"
echo "5. System Status"
echo "6. Change Ports"
echo "7. Restart Services"
echo "8. Update Script"
echo "9. Exit"
echo "=============================="
read -p "Select an option [1-9]: " option

case $option in
    1) bash tools/add-user.sh ;;
    2) bash tools/delete-user.sh ;;
    3) bash tools/list-users.sh ;;
    4) bash tools/monitor.sh ;;
    5) bash tools/system-status.sh ;;
    6) bash tools/change-ports.sh ;;
    7) bash tools/restart-services.sh ;;
    8) bash tools/update.sh ;;
    9) exit 0 ;;
    *) echo "Invalid option" ;;
esac