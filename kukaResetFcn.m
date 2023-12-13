
function in = kukaResetFcn(in,pub,path_pub,rand_client,update_client,stop_physics_client,move_object_client,start_physics_client)
    
    % Ridiculous workaround for joints in wrong position after collision
    %req = rosmessage(client);
    %req.BodyName = 'iiwa_link_7';
    %req.Wrench.Force.X = -200000.0;
    %req.Wrench.Force.Y = -200000.0;
    %req.Duration.Nsec = 5000000;
    %call(client, req);
    %pause(0.2);
    %object_in_cutting_position = 'object_1';
    persistent object_in_cutting_position
    if isempty (object_in_cutting_position)
    object_in_cutting_position = 'object_1';
    end
    % Send a request to the DR node to randomise the surface properties
    rand_req = rosmessage(rand_client);
    call(rand_client, rand_req);
    
    % Send a request to the DR node to update the range of the randomised
    % parameters
    update_req = rosmessage(update_client);
    call(update_client, update_req);

    % Reset robot to start position
    q0 = [-0.8706, 0.1348, 0.6560, -1.7221, -0.0873, 1.3219, -0.1965]';
    %q0 = [2.05019, -1.01604, 1.79952, 1.48971, 2.12243, 1.80771, 0.53108]';
    msg = rosmessage(pub);
    msg.Data = q0;
    send(pub,msg);
    
    %% Moving the heightmaps
    % Stop the physics engine to allow the objects to be moved correctly.
    stop_physics_msg = rosmessage(stop_physics_client);
    call(stop_physics_client, stop_physics_msg);
    
    % Move the object in the cutting position back off to the side
    %object_in_cutting_position = 'object_1';
    move_req = rosmessage(move_object_client);
    % CHANGE TO new_model
    move_req.ModelState.ModelName = object_in_cutting_position;
    % SET TO NEW POSE OF OBJECT
    move_req.ModelState.Pose.Position.X = 1.0;
    move_req.ModelState.Pose.Position.Y = 1.0;
    move_req.ModelState.Pose.Position.Z = 0.5;
    move_req.ModelState.Pose.Orientation.W = 1.0;
    move_req.ModelState.Pose.Orientation.X = 0.0;
    move_req.ModelState.Pose.Orientation.Y = 0.0;
    move_req.ModelState.Pose.Orientation.Z = 0.0;
    move_req.ModelState.ReferenceFrame = 'world';
    %call(srv, move_req);
    call(move_object_client, move_req);

    
    % Take a random object from the list of heightmaps and move it into the
    % cutting position as the new object
     model_names = {'object_1','object_2','object_3','object_4'};
     % model_names = {'object_1'};

    object_in_cutting_position = string(randsample(model_names, 1));
    move_req = rosmessage(move_object_client);
    % CHANGE TO new_model
    move_req.ModelState.ModelName = object_in_cutting_position;
    % SET TO NEW POSE OF OBJECT
    move_req.ModelState.Pose.Position.X = 0.4;
    move_req.ModelState.Pose.Position.Y = 0.0;
    move_req.ModelState.Pose.Position.Z = 0.32;
    move_req.ModelState.Pose.Orientation.W = 1.0;
    move_req.ModelState.Pose.Orientation.X = 0.0;
    move_req.ModelState.Pose.Orientation.Y = 0.0;
    move_req.ModelState.Pose.Orientation.Z = 0.0;
    move_req.ModelState.ReferenceFrame = 'world';
    call(move_object_client, move_req);
    
    % Restart the physics engine
    start_physics_msg = rosmessage(start_physics_client);
   % call(srv_start_physics, start_physics_msg);
    call(start_physics_client, start_physics_msg);

    
    %% Publishing the path for the module tracker
    % kukaResetFcn: Make a nav_msgs/Path that has the start and end position of the linear path, 
    % which will be published at the start of each episode. 
    % Look at line 252 of cutting_orchestrator.cpp to see how path is defined in C++ code.
    % Can just hardcode it or get it from simulink somehow
    path_msg = rosmessage(path_pub);
    path_msg.Header.FrameId = "world";
    path_msg.Header.Stamp = rostime("now");
    % All positions are hardcoded, would be better to get them from the
    % Simulink model
    start_pos = rosmessage("geometry_msgs/PoseStamped");
    start_pos.Header.FrameId = "world";
    start_pos.Header.Stamp = rostime("now");
    start_pos.Pose.Position.X = 0.41;
    start_pos.Pose.Position.Y = -0.12;
    start_pos.Pose.Position.Z = 0.30;
    start_pos.Pose.Orientation.W = 1.;
    end_pos = rosmessage("geometry_msgs/PoseStamped");
    end_pos.Header.FrameId = "world";
    end_pos.Header.Stamp = rostime("now");
    end_pos.Pose.Position.X = 0.41;
    end_pos.Pose.Position.Y = 0.12;
    end_pos.Pose.Position.Z = 0.30;
    end_pos.Pose.Orientation.W = 1.;
    path_msg.Poses = [start_pos, end_pos];
    send(path_pub, path_msg);
    pause(0.01);

end