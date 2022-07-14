# Raspi-ROS-Noetic-Image
A ready to use raspberry pi image for ROS noetic based on Rasbian Buster 64 bit version. 

# Pre Installed features:
 * [virtualenv](https://virtualenv.pypa.io/en/latest/) & [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) to allow you to create and manage python virtual environments easily
 * OpenCV comes pre-installed in a python3.8 virtual environment (cv). The image also comes with ROS [cv_bridge](http://wiki.ros.org/cv_bridge) installed so you can just start using OpenCV with ROS.
 * [workon_ros](https://github.com/jasmeet0915/workon_ros) to help you easily work with multiple workspaces
 * Basic ROS packages like joint-state-publisher, robot-state-publisher, move-base etc. which can help get up and running with a mobile base as quick as possible.
 
# Steps to update the image:
 * Take a SD card and flash it with the latest version of the image.
 * Make the required changes in the image like installing packages etc. while running it in a Raspberry Pi (we generally use Pi 4B. Image generation not yet tested with Pi 3B or older version)
 * After you are satisfied with the changes, take out the SD card and connect it with your laptop using a reader. Then we'll use the `dd` command to copy all the data from the SD card to a `.img` file with the following command: (considering the sd card is mounted at `/dev/sdb`)
 ```bash
 sudo dd if=/dev/sdb of=raspbian_ros_noetic_vxx.img status=progress
 ```
 > Note: You can check where the SD card is mounted by using the `lsblk` command and looking for the block device which same memory as your SD card.
 Also, this step may take some time to complete depending on the SD card size and block size used with `dd`. In our case we generally use a 32 GB SD card with no block size specified in dd and it takes around 30 min to completely copy the contents of the SD card to the `.img` file. 
 
 * After this you should see a file name `raspbian_ros_noetic_vxx.img` in you current directory. This file will the same size as your SD card so it won't pr practical to share this file as it is. Therefore, we use `Pishrink` to shrink the image to a sharable size. 
 * To use `Pishrink`, first clone this repo as it contains a copy of Pishrink with custom changes:
 ```bash
 git clone git@github.com:atom-robotics-lab/Raspi-ROS-Noetic-Image.git
 ```
 * `cd` into the cloned directory and make sure the `Pishrink` script is executable. If yes then run the script on the image with the following command:
 ```bash
 sudo pishrink.sh -vZp path/to/uncompressed/file.img path/to/compressed/file.img.xz
 ```
 This should create a compressed image with a size of around 2~3 GB and extension `.img.xz`.

# About Pishrink
 * We use the [pishrink](https://github.com/Drewsif/PiShrink) utility to shrink the image after copying the data from the SD card using `dd` command.

 * We were facing some issues in SSHing to the pi after using the `-p` option of the `pishrink` as the hostkeys were not regenerating on the first boot even after creating an empty `ssh` file in the boot partition. So this repo contains a different version of `pishrink` based on [this](https://github.com/Drewsif/PiShrink/pull/176) PR. 
 
 * We have added further functionality to the script to unset the global git config from the image as well.
