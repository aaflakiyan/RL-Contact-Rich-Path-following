function agent = createDDPGAgent(numObs, obsInfo, numAct, actInfo, Ts, useGPU)
% Walking Robot -- DDPG Agent Setup Script
% Copyright 2020 The MathWorks, Inc.

%% Create the actor and critic networks using the createNetworks helper function
[criticNetwork,~,actorNetwork] = createNetworks(numObs,numAct);

%% Specify options for the critic and actor representations using rlRepresentationOptions
criticOptions = rlRepresentationOptions('Optimizer','adam','LearnRate',5e-4,... 
                                        'GradientThreshold',1,'L2RegularizationFactor',2e-4);
actorOptions = rlRepresentationOptions('Optimizer','adam','LearnRate',5e-4,...
                                       'GradientThreshold',1,'L2RegularizationFactor',1e-5);
                                   
if useGPU
   criticOptions.UseDevice = 'gpu';
   actorOptions.UseDevice = 'gpu'; 
end

%% Create critic and actor representations using specified networks and
% options
critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'observation'},'Action',{'action'},criticOptions);
actor  = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'observation'},'Action',{'ActorTanh1'},actorOptions);

%% Specify DDPG agent options
agentOptions = rlDDPGAgentOptions;
agentOptions.SampleTime = Ts;
agentOptions.DiscountFactor = 0.99;
agentOptions.MiniBatchSize = 128;
agentOptions.ExperienceBufferLength = 1e6;
agentOptions.SaveExperienceBufferWithAgent = true;
agentOptions.ResetExperienceBufferBeforeTraining = false;
agentOptions.TargetSmoothFactor = 1e-3;
agentOptions.NoiseOptions.MeanAttractionConstant = 2.5;
agentOptions.NoiseOptions.Variance = 0.5;
agentOptions.NoiseOptions.VarianceDecayRate = 4.62e-6;

%% Create agent using specified actor representation, critic representation and agent options
agent = rlDDPGAgent(actor,critic,agentOptions);
