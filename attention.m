% Display free or forced trials with Gabor stimuli
% Stimulus changes occur in periphery, after random intervals
% Use saccades to make choices

if ~ML_eyepresent, error('no eye signal'); end

showcursor(false); % remove joystick cursor

% behavioral codes
bhv_code(10,'fix cue on', 11,'fix cue off', 12,'fix start', ...
    20,'stim on', 21,'unchosen stim off', 22,'all stim off', ...
    30,'stim change', 31,'break fix', 32,'target chosen', 33,'nontarget chosen', ...
    40,'reward start', 41,'reward stop')

% define task objects
fix_point = 1;
target = 2;
nontarget = 3;

% define time intervals (ms)
fix_wait = 7500;
fix_hold = 650;
delay_min = 500;
delay_max = 800;
choice_interval = 750;
saccade_interval = 500;
choice_hold = 500;
reward_interval = 1000;
timeout = 500;

% define fixation windows (deg)
fix_radius = 2.5;
choice_radius = 2.5;

% set default stimulus info
contrast = 1; % stimulus contrast
frequency = 0.85; % stimulus frequency
rotation_size = 15; % deg
target_bias = 0.75; % probability of rotation at target

editable('fix_radius', 'choice_radius', 'delay_min', 'delay_max', ...
    'choice_interval', 'saccade_interval', 'timeout', 'contrast', 'frequency', ...
    'rotation_size', 'target_bias');

% get trial info
info = TrialRecord.CurrentConditionInfo;
trialtype = info.trial; % 1 = forced, 2 = free
target_on = info.target;
nontarget_on = info.nontarget;

% define which stim are presented
stims = [];
if target_on, stims = target; end
if nontarget_on, stims = [stims nontarget]; end
all_obj = [fix_point stims];

% ----- TASK SEQUENCE -----

% FIXATION EPOCH
toggleobject(fix_point, 'eventmarker',10); % turn on fix point

% wait for fix acquisition and hold
wait_start = trialtime;
while trialtime < wait_start + fix_wait
    adjust = trialtime - wait_start;
    
    ontarget = eyejoytrack('acquirefix', fix_point, fix_radius, fix_wait-adjust);
    eventmarker(12);
    
    if ontarget
        if eyejoytrack('holdfix', fix_point, fix_radius, fix_hold), break; end
    end
end

if ~ontarget % central fixation not held
    toggleobject(fix_point, 'status','off', 'eventmarker',11);
    trialerror(4); % no fixation
    
    set_bgcolor([0.75 0.75 0.75]); % grey error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% STIM PRESENTATION EPOCH
delay_to_change = rand*(delay_max-delay_min) + delay_min;
toggleobject(stims, 'eventmarker',20);

ontarget = eyejoytrack('holdfix', fix_point, fix_radius, delay_to_change);
if ~ontarget % central fixation not maintained during stim presentation
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    trialerror(5); % early response
    
    set_bgcolor([0.75 0.75 0.75]); % grey error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% STIM CHANGE
if target_on && (~nontarget_on || rand < target_bias)
    rotated = target;
else
    rotated = nontarget;
end

if rand < 0.5
    rotate_object(rotated, rotation_size);
else
    rotate_object(rotated, -rotation_size);
end
eventmarker(30);
response_start = trialtime;


% RESPONSE EPOCH
% time limit to break central fixation
change_time = trialtime;
breakfix = ~eyejoytrack('holdfix', fix_point, fix_radius, choice_interval);
if ~breakfix
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    trialerror(1); % no response (i.e. miss)
    
    set_bgcolor([1 0 0]); % red error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end
toggleobject(fix_point, 'eventmarker',11) % turn off fix point


waitstart = trialtime;
while trialtime < waitstart + saccade_interval
    adjust = trialtime - waitstart;
    
    % saccade to choose within time limit
    choice = eyejoytrack('acquirefix', stims, fix_radius, saccade_interval-adjust);
    eventmarker(12);
    rt = trialtime - response_start;

    % hold fixation on choice to confirm selection
    if choice > 0
        ontarget = eyejoytrack('holdfix', stims(choice), fix_radius, choice_hold);
    else
        ontarget = 0;
    end
end

% check if fixation was held in time
if ~ontarget
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    trialerror(4); % no fixation
    
    set_bgcolor([1 0 0]); % red error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end

% turn off unchosen stim on free trials
if trialtype == 2
    if choice == 2
        toggleobject(target, 'status','off', 'eventmarker',21);
    else
        toggleobject(nontarget, 'status','off', 'eventmarker',21);
    end
end

% REWARD EPOCH
if stims(choice) == rotated
    trialerror(0); % correct
    
    amnt = 6 - 5*rt/(choice_interval+saccade_interval);
    goodmonkey(reward_interval, 'triggerval',amnt, 'eventmarker',40);
    eventmarker(41);
    
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
else
    trialerror(6); % incorrect
    
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    set_bgcolor([1 0 0]); % red error screen
    idle(timeout); % timeout
    set_bgcolor([]);
end
