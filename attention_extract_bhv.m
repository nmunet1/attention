function [] = attention_extract_bhv(session, bhv_dir, bhv_out)

% extract useful trial info from bhv2 and save as .mat file:
fname = [bhv_out,session,'_trial-info.mat'];
if exist(fname,'file') % done!
    disp('--- preprocess bhv: SKIP! .mat file already exists ---')
else
    % data labels
    bhv_headers = {'trial', 'block', 'trialtype', 'target_x', 'target_y', ...
        'choice', 'rt', 'error_code', 'reward'};
    eye_headers = ['eye_x', 'eye_y', 'bhv_codes', 'bhv_times'];
    
    % data across trials
    bhv_info = [];
    eye_info = {};
    
    bhv2files = dir([bhv_dir, session, '*.bhv2']);
    bhv2files = {bhv2files.name};
    
    last_trial = 0; % last trial number
    
    % extract trial info for all data files
    for f = 1:length(bhv2files)
        % load data
        data = mlread([bhv_dir, bhv2files{f}]);
        
        % init output
        n_trials = length(data);
        bhv_info_subset = nan(n_trials, length(bhv_headers));
        eye_info_subset = num2cell(nan(n_trials, length(eye_headers)));
        
        % trial number
        bhv_info_subset(:,1) = [data.Trial]'+last_trial;
        last_trial = bhv_info_subset(end,1); % update trial count
        
        % block number
        bhv_info_subset(:,2) = [data.Block]';
        
        % trial type (forced = 1, free = 2)
        if ~isempty(data(1).TaskObject.CurrentConditionInfo)
            bhv_info_subset(:,3) = cellfun(@(x) x.CurrentConditionInfo.type, {data.TaskObject})';
        else
            bhv_info_subset(:,3) = ones(n_trials,1);
        end
        
        % x position of target (up = 1, down = -1)
        bhv_info_subset(:,4) = cellfun(@(x) sign(x.Attribute{2}{5}), {data.TaskObject})';
        
        % y position of target (right = 1, left = -1)
        bhv_info_subset(:,5) = cellfun(@(x) sign(x.Attribute{2}{6}), {data.TaskObject})';
        
        % chosen stimulus (target = 1, nontarget = 2)
        bhv_info_subset(cellfun(@(x) any(x.CodeNumbers==32), {data.BehavioralCodes}), 6) = 1;
        bhv_info_subset(cellfun(@(x) any(x.CodeNumbers==33), {data.BehavioralCodes}), 6) = 2;
        
        % rt (response time)
        t_choice = cellfun(@(x) x.CodeTimes(find(ismember(x.CodeNumbers,[32,33]),1)), ...
            {data.BehavioralCodes}, 'UniformOutput',0);
        t_choice(cellfun(@isempty, t_choice)) = {NaN};
        
        t_stim = cellfun(@(x) x.CodeTimes(find(x.CodeNumbers==20,1)), ...
            {data.BehavioralCodes}, 'UniformOutput',0);
        t_stim(cellfun(@isempty, t_stim)) = {NaN};
        
        bhv_info_subset(:,7) = [t_choice{:}]' - [t_stim{:}]';
        
        % error/outcome code
        bhv_info_subset(:,8) = [data.TrialError]';
        
        % was rewarded (bool)
        bhv_info_subset(:,9) = cellfun(@(x) any(x.CodeNumbers==40), {data.BehavioralCodes})';
        
        % x- and y-axis eye-tracking data
        eye_info_subset(:,1) = cellfun(@(x) x.Eye(:,1)', {data.AnalogData}, ...
            'UniformOutput',0)';
        eye_info_subset(:,2) = cellfun(@(x) x.Eye(:,2)', {data.AnalogData}, ...
            'UniformOutput',0)';
        
        % behavior codes and timestamps
        eye_info_subset(:,3) = cellfun(@(x) x.CodeNumbers', {data.BehavioralCodes}, ...
            'UniformOutput',0)';
        eye_info_subset(:,4) = cellfun(@(x) x.CodeTimes', {data.BehavioralCodes}, ...
            'UniformOutput',0)';
        
        % concatenate onto full data structure
        bhv_info = cat(1, bhv_info, bhv_info_subset);
        eye_info = cat(1, eye_info, eye_info_subset);
    end
    
    % save to .mat file
    save(fname,'bhv_headers','bhv_info','eye_headers','eye_info');
    disp('--- preprocess bhv: *.mat saved ---')
end

end