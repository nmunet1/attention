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
fix_hold = 500;
delay_min = 250;
delay_max = 350;
stim_flash = 0;
reward_interval = 1000;
timeout = 50;

% define fixation windows (deg)
fix_radius = 2;

editable('fix_radius', 'fix_hold', 'delay_min', 'delay_max', 'stim_flash', 'timeout');
if stim_flash < 0, stim_flash = 0; end

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
delay_to_change = rand*(delay_max-delay_min) + delay_min;
toggleobject(distractor, 'eventmarker',20);
if stim_flash > 0
    ontarget = eyejoytrack('holdfix', fix_point, fix_radius, stim_flash);
    if ~ontarget % central fixation not maintained during stim presentation
        toggleobject(all_obj, 'status','off', 'eventmarker',22);
        trialerror(5); % early response
        
        set_bgcolor([0.75 0.75 0.75]); % grey error screen
        idle(timeout);
        set_bgcolor([]);
        return
    end
    toggleobject(distractor, 'eventmarker',20);
end

ontarget = eyejoytrack('holdfix', fix_point, fix_radius, delay_to_change-stim_flash);
if ~ontarget % central fixation not maintained during stim presentation
    toggleobject(all_obj, 'status','off', 'eventmarker',22);
    trialerror(5); % early response
    
    set_bgcolor([0.75 0.75 0.75]); % grey error screen
    idle(timeout); % timeout
    set_bgcolor([]);
    return
end


% REWARD EPOCH
trialerror(0); % correct

amnt = 3.5; % amount of reward
goodmonkey(reward_interval, 'triggerval',amnt, 'eventmarker',40);
eventmarker(41);

toggleobject(all_obj, 'status','off', 'eventmarker',22);
    