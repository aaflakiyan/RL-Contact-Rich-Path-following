function PosePublisher(p)

      Pose = rospublisher('/iiwa/PositionJointInterface_cutting_controller/CartesianPose','geometry_msgs/PoseStamped');
      msg = rosmessage(Pose);
      
      msg.Header.FrameId = "world";
      msg.Header.Stamp = rostime("now");
      msg.Pose.Position.X = p(1);
      msg.Pose.Position.Y = p(2);
      msg.Pose.Position.Z = p(3);
      msg.Pose.Orientation.W = 1.;
      
      send(Pose,msg);
      
end