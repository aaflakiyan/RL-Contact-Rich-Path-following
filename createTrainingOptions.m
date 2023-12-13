function trainingOptions = createTrainingOptions(Ts, Tf, useParallel)

%% Training Options

trainingOptions = rlTrainingOptions;
trainingOptions.MaxEpisodes = 5000;
trainingOptions.MaxStepsPerEpisode = Tf/Ts;
trainingOptions.ScoreAveragingWindowLength = 100;
trainingOptions.StopTrainingCriteria = 'EpisodeCount';
trainingOptions.StopTrainingValue = 5000;

% trainingOptions.StopTrainingCriteria = "AverageReward";
% trainingOptions.StopTrainingValue = 0;
trainingOptions.ScoreAveragingWindowLength = 20;
trainingOptions.SaveAgentCriteria = 'EpisodeCount';
trainingOptions.SaveAgentValue = 4999;
% trainingOptions.SaveAgentCriteria = "AverageReward";
% trainingOptions.SaveAgentValue = 0;
trainingOptions.SaveAgentDirectory = 'savedAgents';

trainingOptions.Plots = 'training-progress';
trainingOptions.Verbose = true;
if useParallel
    trainingOptions.Parallelization = 'async';
    trainingOptions.ParallelizationOptions.StepsUntilDataIsSent = 32;
end
