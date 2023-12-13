%% Reinforcement Learning (RL) parameters
Ts = 0.02; % Agent sample time
Tf = 10;    % Simulation end time

object_in_cutting_position = 'object_1';

%% SET UP ENVIRONMENT
% Speedup options
useFastRestart = false;
useGPU = false;
useParallel = false;
agentSelection = 'TD3';

% observation
numObs = 17;
observationInfo = rlNumericSpec([numObs 1]);
observationInfo.Name = 'observations';

% action
numAct = 3;
actionInfo = rlNumericSpec([numAct 1]);
% actionInfo.LowerLimit = -1;
% actionInfo.UpperLimit = 1;
actionInfo.Name = 'cart_vel';

% ROS initialisation
pub = rospublisher('/iiwa/PositionJointInterface_group_controller/command','std_msgs/Float64MultiArray');
path_pub = rospublisher('/iiwa/cutting_path','nav_msgs/Path');
randomiser_client = rossvcclient('/domain_randomisation/randomise_surface');
range_client = rossvcclient('/domain_randomisation/update_range');
stop_physics_client = rossvcclient('/gazebo/pause_physics');
move_object_client = rossvcclient('/gazebo/set_model_state');
start_physics_client = rossvcclient('/gazebo/unpause_physics');

% Environment
mdl = 'CuttingSim';
load_system(mdl);
blk = [mdl,'/RL Agent'];
env = rlSimulinkEnv(mdl,blk,observationInfo,actionInfo);
%env.ResetFcn = @(in)kukaResetFcn(in,pub,path_pub,randomiser_client,range_client);
env.ResetFcn = @(in)kukaResetFcn(in,pub,path_pub,randomiser_client,range_client,stop_physics_client,move_object_client,start_physics_client);
if ~useFastRestart
   env.UseFastRestart = 'off';
end

%% CREATE AGENT

switch agentSelection
    case 'DDPG'
        agent = createDDPGAgent(numObs,observationInfo,numAct,actionInfo,Ts,useGPU);
    case 'TD3'
        agent = createTD3Agent(numObs,observationInfo,numAct,actionInfo,Ts,useGPU);
    otherwise
        disp('Enter DDPG or TD3 for agentSelection')
end

%% TRAIN AGENT
trainingOptions = createTrainingOptions(Ts, Tf, useParallel);
trainingResults = train(agent,env,trainingOptions)

%% SAVE AGENT
%reset(agent); % Clears the experience buffer
curDir = pwd;
saveDir = 'savedAgents';
cd(saveDir)
save(['trainedAgent_VSRL' datestr(now,'mm_DD_YYYY_HHMM')],'agent');
save(['trainingResults_VSRL' datestr(now,'mm_DD_YYYY_HHMM')],'trainingResults');
cd(curDir)