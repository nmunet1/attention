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
distractor = 2;
target = 3;
all_nogo = [fix_point distractor];
all_go = [fix_point target];

% define time intervals (ms)
fix_wait = 7500;
fix_hold = 650;
delay_min = 250; % goal: 500
delay_max = 350; % goal: 800
choice_interval = 2000; % goal: 750
saccade_interval = 750; % goal: 500 (or less if possible)
choice_hold = 500; % goal: 500
reward_interval = 1000;
timeout = 50;

% define fixation windows (deg)
fix_radius = 2;

editable('fix_radius', 'fix_hold', 'delay_min', 'delay_max', 'timeout');

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
toggleobject(distractor, 'eventmarker',20);

ontarget = eyejoytrack('holdfix', fix_point, fix_radius, delay_to_change-stim_flash);
if ~ontarget % central fixation not maintained during stim presentation
    toggleobject(all_nogo, 'status','off', 'eventmarker',22);
    trialerror(5); % early response
    
    set_bgcolor([0.75 0.75 0.75]); % grey error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% STIM CHANGE
toggleobject(distractor, 'status','off')
toggleobject(target, 'status','on')
eventmarker(30);
response_start = trialtime;


% RESPONSE EPOCH
% time limit to break central fixation
change_time = trialtime;
breakfix = ~eyejoytrack('holdfix', fix_point, fix_radius, choice_interval);
if ~breakfix
    toggleobject(all_go, 'status','off', 'eventmarker',22);
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
    choice = eyejoytrack('acquirefix', target, fix_radius, saccade_interval-adjust);
    eventmarker(12);
    rt = trialtime - response_start;

    % hold fixation on choice to confirm selection
    if choice > 0
        ontarget = eyejoytrack('holdfix', target, fix_radius, choice_hold);
    else
        ontarget = 0;
    end
end

% check if fixation was held in time
if ~ontarget
    toggleobject(all_go, 'status','off', 'eventmarker',22);
    trialerror(4); % no fixation
    
    set_bgcolor([1 0 0]); % red error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% REWARD EPOCH
trialerror(0); % correct

amnt = 3.1; % amount of reward (V)
goodmonkey(reward_interval, 'triggerval',amnt, 'eventmarker',40);
eventmarker(41);

toggleobject(all_go, 'status','off', 'eventmarker',22);
