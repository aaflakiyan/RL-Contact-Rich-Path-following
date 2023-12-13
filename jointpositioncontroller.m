function jointpositioncontroller(q)
    
    pub = rospublisher('/iiwa/PositionJointInterface_group_controller/command','std_msgs/Float64MultiArray');
    msg = rosmessage(pub);
    msg.Data = q;
    send(pub,msg);
    
end