# RL-Contact-Rich-Path-following
This repository showcases the use of a simulated cutter on a KUKA robot, coupled with vision, to instruct a Reinforcement Learning (RL) agent in following a contact-rich path across various surfaces (The gazebo simulation part is not included).

![cutting](https://github.com/aaflakiyan/RL-Contact-Rich-Path-following/assets/48828461/9a77b855-ba6a-41e6-94ac-945db1853238)

##Installation 
The environment of interest should be cloned, and ROS Topics and ROS services and functionalities should be updated respectively in all the files.  

##Usage 

Run your simulation: 
```
roslaunch relib_cutting_moveit moveit_planning_execution.launch sim:="true"
```
Run the domain randomization node:
```
rosrun relib_gazebo domain_randomisation
```
Run the module tracker and vision node: 
```
rosrun relib_cutting module_tracker  
```
Switch the controller to position controller:
```
roscd relib_cutting
./switch_to_position_controller.sh
```
run createAgent.m file. 

To verify the trained agent run the following in the Matlab command prompt in the same Matlab folder:
```
verify in simulation
experinece = sim(env,agent)
```

