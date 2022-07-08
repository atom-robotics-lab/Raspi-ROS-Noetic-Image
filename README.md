# Raspi-ROS-Noetic-Image
A ready to use raspberry pi image for ROS noetic based on Rasbian Buster 64 bit version. 

# Pre Installed features:
 * [virtualenv](https://virtualenv.pypa.io/en/latest/) & [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) to allow you to create and manage python virtual environments easily
 * OpenCV comes pre-installed in a python3.8 virtual environment (cv). The image also comes with ROS [cv_bridge](http://wiki.ros.org/cv_bridge) installed so you can just start using OpenCV with ROS.
 * [workon_ros](https://github.com/jasmeet0915/workon_ros) to help you easily work with multiple workspaces
 * Basic ROS packages like joint-state-publisher, robot-state-publisher, move-base etc. which can help get up and running with a mobile base as quick as possible.

# About Pishrink
 * We use the [pishrink](https://github.com/Drewsif/PiShrink) utility to shrink the image after copying the data from the SD card using `dd` command.

 * We were facing some issues in SSHing to the pi after using the `-p` option of the `pishrink` as the hostkeys were not regenerating on the first boot even after creating an empty `ssh` file in the boot partition. So this repo contains a different version of `pishrink` based on [this](https://github.com/Drewsif/PiShrink/pull/176) PR. 
 
 * We have added further functionality to the script to unset the global git config from the image as well.
