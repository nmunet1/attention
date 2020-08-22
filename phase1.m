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
all_obj = [fix_point distractor];

% define time intervals (ms)
fix_wait = 7500;
fix_hold = 750;
fixed_delay = 500; % goal: 750ms
mean_rand_delay = 100; % goal: 500ms
reward_interval = 1000;
timeout = 500;

% define fixation windows (deg)
fix_radius = 2;

editable('fix_radius', 'fixed_delay', 'mean_rand_delay', 'timeout');

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
    
    set_bgcolor([1 1 1]); % white error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% STIM PRESENTATION EPOCH
toggleobject(distractor, 'eventmarker',20);
delay_to_change = fixed_delay + exprnd(mean_rand_delay);

ontarget = eyejoytrack('holdfix', fix_point, fix_radius, delay_to_change);
if ~ontarget % central fixation not maintained during stim presentation
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    trialerror(5); % early response
    
    set_bgcolor([1 1 1]); % white error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% REWARD EPOCH
trialerror(0); % correct

amnt = 3; % amount of reward
goodmonkey(reward_interval, 'triggerval',amnt, 'eventmarker',40);
eventmarker(41);

toggleobject(all_obj, 'status','off', 'eventmarker',22);
    