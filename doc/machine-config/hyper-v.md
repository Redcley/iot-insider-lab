- Reboot and enter BIOS setup and make sure VTx and VTd are both enabled

  ![image](hyper-v-0.jpg)

- Press Win-X to bring up quick menu and choose Control Panel

  ![image](hyper-v-1.png)

- Enter ```add remove`` in search control and click "Add or remove programs" link

  ![image](hyper-v-2.png)
  
- Click "Turn Windows features on or off" link on left side of window

  ![image](hyper-v-3.png)

- Check Hyper-V and all of its children nodes

  ![image](hyper-v-4.png)

- Click "Restart now"

  ![image](hyper-v-5.png)

- Launch Hyper-V Manager, click your machine name in the tree on the left and select Virtual Switch Manager from the Action menu.

  ![image](hyper-v-6.png)

- Make sure External is selected and click Create Virtual Switch

  ![image](hyper-v-7.png)

- Name the switch anything you like and press Apply

  ![image](hyper-v-8.png)

  *Be sure that your virtual switch is bound to a connected physical adapter. If the adapter your VM is bound to is not connected then vagrant may timeout without connecting. This requirement is applicable to any automatically created virtual network switches as well.*
  
- Click Yes to interupt your network, it's worth it.

  ![image](hyper-v-9.png)

