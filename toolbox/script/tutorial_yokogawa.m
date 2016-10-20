function tutorial_yokogawa(tutorial_dir)
% TUTORIAL_YOKOGAWA: Script that reproduces the results of the online tutorials "Yokogawa recordings".
%
% CORRESPONDING ONLINE TUTORIALS:
%     http://neuroimage.usc.edu/brainstorm/Tutorials/Yokogawa
%
% INPUTS: 
%     tutorial_dir: Directory where the sample_yokogawa.zip file has been unzipped

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2016 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Author: Francois Tadel, 2014-2016


% ======= FILES TO IMPORT =======
% You have to specify the folder in which the tutorial dataset is unzipped
if (nargin == 0) || isempty(tutorial_dir) || ~file_exist(tutorial_dir)
    error('The first argument must be the full path to the tutorial dataset folder.');
end
% Build the path of the files to import
AnatDir = fullfile(tutorial_dir, 'sample_yokogawa', 'anatomy', 'freesurfer');
RawFile = fullfile(tutorial_dir, 'sample_yokogawa', 'data', 'SEF_000-export.con');
% Check if the folder contains the required files
if ~file_exist(RawFile)
    error(['The folder ' tutorial_dir ' does not contain the folder from the file sample_yokogawa.zip.']);
end

% ======= CREATE PROTOCOL =======
% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'TutorialYokogawa';
% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);
% Start a new report
bst_report('Start');


% ===== IMPORT ANATOMY =====
% Subject name
SubjectName = 'Subject01';
% Process: Import anatomy folder
bst_process('CallProcess', 'process_import_anatomy', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {AnatDir, 'FreeSurfer'}, ...
    'nvertices',   15000, ...
    'nas', [128, 227,  93], ...
    'lpa', [ 48, 130,  69], ...
    'rpa', [214, 130,  76]);

% ===== ACCESS RECORDINGS =====
% Process: Create link to raw file
sFileRaw = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
    'subjectname',    SubjectName, ...
    'datafile',       {RawFile, 'KIT'}, ...
    'channelreplace', 0, ...
    'channelalign',   0);
% Process: Set channels types
bst_process('CallProcess', 'process_channel_settype', sFileRaw, [], ...
    'sensortypes', 'EO1, EO2', ...
    'newtype',     'EOG');
bst_process('CallProcess', 'process_channel_settype', sFileRaw, [], ...
    'sensortypes', 'EKG+', ...
    'newtype',     'ECG');
bst_process('CallProcess', 'process_channel_settype', sFileRaw, [], ...
    'sensortypes', 'E', ...
    'newtype',     'MISC');
% Process: Events: Read from channel
bst_process('CallProcess', 'process_evt_read', sFileRaw, [], ...
    'stimchan',  'Trigger01', ...
    'trackmode', 3, ...  % TTL: detect peaks of 5V/12V on an analog channel (baseline=0V)
    'zero',      0);
% Process: Snapshot: Sensors/MRI registration
bst_process('CallProcess', 'process_snapshot', sFileRaw, [], ...
    'target',   1, ...  % Sensors/MRI registration
    'modality', 1, ...  % MEG (All)
    'orient',   1, ...  % left
    'comment',  'MEG/MRI Registration');
% Process: Snapshot: Sensors/MRI registration
bst_process('CallProcess', 'process_snapshot', sFileRaw, [], ...
    'target',   1, ...  % Sensors/MRI registration
    'modality', 4, ...  % EEG
    'orient',   1, ...  % left
    'comment',  'EEG/MRI Registration');


% ===== FREQUENCY FILTERS =====
% Process: Band-pass:0.5Hz-200Hz
sFileClean = bst_process('CallProcess', 'process_bandpass', sFileRaw, [], ...
    'sensortypes', 'MEG, EEG', ...
    'highpass',    0.5, ...
    'lowpass',     200, ...
    'attenuation', 'strict', ...  % 60dB
    'mirror',      0, ...
    'read_all',    0);
% Process: Notch filter: 60Hz 120Hz 180Hz
sFileClean = bst_process('CallProcess', 'process_notch', sFileClean, [], ...
    'freqlist',    [60, 120, 180], ...
    'sensortypes', 'MEG, EEG', ...
    'read_all',    0);
% Process: Power spectrum density (Welch)
sFilesPsd = bst_process('CallProcess', 'process_psd', [sFileRaw sFileClean], [], ...
    'timewindow',  [0, 50], ...
    'win_length',  4, ...
    'win_overlap', 50, ...
    'clusters',    {}, ...
    'sensortypes', 'MEG, EEG', ...
    'edit', struct(...
         'Comment',         'Power', ...
         'TimeBands',       [], ...
         'Freqs',           [], ...
         'ClusterFuncTime', 'none', ...
         'Measure',         'power', ...
         'Output',          'all', ...
         'SaveKernel',      0));
% Process: Snapshot: Frequency spectrum
bst_process('CallProcess', 'process_snapshot', sFilesPsd, [], ...
    'target',   10, ...  % Frequency spectrum
    'comment',  'Power spectrum density');


% ===== BAD CHANNELS AND AVERAGE REF =====
% Process: Set bad channels
bst_process('CallProcess', 'process_channel_setbad', sFileClean, [], ...
    'sensortypes', 'LC11');
% Process: Re-reference EEG
bst_process('CallProcess', 'process_eegref', sFileClean, [], ...
    'eegref',      'AVERAGE', ...
    'sensortypes', 'EEG');

% ===== DETECT HEARTBEATS AND BLINKS =====
% Process: Detect heartbeats
bst_process('CallProcess', 'process_evt_detect_ecg', sFileClean, [], ...
    'channelname', 'EKG+', ...
    'timewindow',  [0, 119.9995], ...
    'eventname',   'cardiac');
% Process: Detect eye blinks
bst_process('CallProcess', 'process_evt_detect_eog', sFileClean, [], ...
    'channelname', 'EO2', ...
    'timewindow',  [0, 119.9995], ...
    'eventname',   'blink');
% Process: Remove simultaneous
bst_process('CallProcess', 'process_evt_remove_simult', sFileClean, [], ...
    'remove', 'cardiac', ...
    'target', 'blink', ...
    'dt',     0.25, ...
    'rename', 0);

% ===== ICA: MEG/EEG =====
% Process: ICA components: Infomax
bst_process('CallProcess', 'process_ica', sFileClean, [], ...
    'timewindow',   [0, 119.9995], ...
    'eventname',    '', ...
    'eventtime',    [-0.1992, 0.1992], ...
    'bandpass',     [0, 0], ...
    'nicacomp',     0, ...
    'sensortypes',  'EEG', ...
    'usessp',       0, ...
    'ignorebad',    1, ...
    'saveerp',      0, ...
    'method',       1, ...  % Infomax:    EEGLAB / RunICA
    'select',       [1 2 6]);
% Process: ICA components: Infomax
bst_process('CallProcess', 'process_ica', sFileClean, [], ...
    'timewindow',   [0, 119.9995], ...
    'eventname',    '', ...
    'eventtime',    [-0.1992, 0.1992], ...
    'bandpass',     [0, 0], ...
    'nicacomp',     40, ...
    'sensortypes',  'MEG', ...
    'usessp',       0, ...
    'ignorebad',    1, ...
    'saveerp',      0, ...
    'method',       1, ...  % Infomax:    EEGLAB / RunICA
    'select',       [1 2]);
% Process: Snapshot: SSP projectors
bst_process('CallProcess', 'process_snapshot', sFileClean, [], ...
    'target',  2, ...  % SSP projectors
    'comment', 'SSP projectors');


% ===== IMPORT EVENTS =====
% Process: Import MEG/EEG: Events
sFilesEpochs = bst_process('CallProcess', 'process_import_data_event', sFileClean, [], ...
    'subjectname', SubjectName, ...
    'condition',   '', ...
    'eventname',   'Trigger01', ...
    'timewindow',  [], ...
    'epochtime',   [-0.050, 0.250], ...
    'createcond',  1, ...
    'ignoreshort', 1, ...
    'usectfcomp',  1, ...
    'usessp',      1, ...
    'freq',        [], ...
    'baseline',    [-0.050, -0.010]);
% Process: Average: By trial group (folder average)
sFilesAvg = bst_process('CallProcess', 'process_average', sFilesEpochs, [], ...
    'avgtype',    5, ...  % By trial group (folder average)
    'avg_func',   1, ...  % Arithmetic average:  mean(x)
    'weighted',   0, ...
    'keepevents', 0);

% Process: Snapshot: Recordings time series (MEG + EEG)
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',   5, ...  % Recordings time series
    'modality', 1, ...  % MEG (All)
    'comment',  'Evoked response (MEG)');
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',   5, ...  % Recordings time series
    'modality', 4, ...  % EEG
    'comment',  'Evoked response (EEG)');
% Process: Snapshot: Recordings topography (one time, MEG + EEG)
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',   6, ...  % Recordings topography (one time)
    'modality', 1, ...  % MEG (All)
    'orient',   1, ...  % left
    'time',     0.0190, ...
    'comment', 'Evoked response (MEG topography)');
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',   6, ...  % Recordings topography (one time)
    'modality', 4, ...  % EEG
    'orient',   1, ...  % left
    'time',     0.0190, ...
    'comment', 'Evoked response (EEG topography)');


% ===== SOURCE MODELING =====
% Process: Generate BEM surfaces
bst_process('CallProcess', 'process_generate_bem', [], [], ...
    'subjectname', SubjectName, ...
    'nscalp',      1922, ...
    'nouter',      1922, ...
    'ninner',      1922, ...
    'thickness',   4);
% Process: Compute head model
bst_process('CallProcess', 'process_headmodel', sFilesAvg, [], ...
    'comment', '', ...
    'sourcespace', 1, ...
    'meg',  3, ...  % Overlapping spheres
    'eeg',  3, ...  % OpenMEEG BEM
    'openmeeg', struct(...
         'BemSelect',    [1, 1, 1], ...
         'BemCond',      [1, 0.0125, 1], ...
         'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
         'BemFiles',     {{}}, ...
         'isAdjoint',    1, ...
         'isAdaptative', 1, ...
         'isSplit',      0, ...
         'SplitLength',  4000));
% Process: Compute noise covariance
bst_process('CallProcess', 'process_noisecov', sFilesEpochs, [], ...
    'baseline', [-0.050, -0.010], ...
    'dcoffset', 1, ...
    'identity', 0, ...
    'copycond', 0, ...
    'copysubj', 0);
% Process: Compute sources (MEG)
sFilesSrcMeg = bst_process('CallProcess', 'process_inverse', sFilesAvg, [], ...
    'Comment',     '', ...
    'method',      2, ...  % dSPM
    'wmne',        struct(...
         'SourceOrient', {{'fixed'}}, ...
         'loose',        0.2, ...
         'SNR',          3, ...
         'pca',          1, ...
         'diagnoise',    0, ...
         'regnoise',     1, ...
         'magreg',       0.1, ...
         'gradreg',      0.1, ...
         'eegreg',       0.1, ...
         'depth',        1, ...
         'weightexp',    0.5, ...
         'weightlimit',  10), ...
    'sensortypes', 'MEG', ...
    'output',      1);  % Kernel only: shared
% Process: Compute sources (EEG)
sFilesSrcEeg = bst_process('CallProcess', 'process_inverse', sFilesAvg, [], ...
    'Comment',     '', ...
    'method',      2, ...  % dSPM
    'wmne',        struct(...
         'SourceOrient', {{'fixed'}}, ...
         'loose',        0.2, ...
         'SNR',          3, ...
         'pca',          1, ...
         'diagnoise',    0, ...
         'regnoise',     1, ...
         'magreg',       0.1, ...
         'gradreg',      0.1, ...
         'eegreg',       0.1, ...
         'depth',        1, ...
         'weightexp',    0.5, ...
         'weightlimit',  10), ...
    'sensortypes', 'EEG', ...
    'output',      1);  % Kernel only: shared

% Process: Snapshot: Sources (one time)
bst_process('CallProcess', 'process_snapshot', sFilesSrcMeg, [], ...
    'target',   8, ...  % Sources (one time)
    'orient',   3, ...  % top
    'time',     0.019, ...
    'comment',  'Source maps at 19ms (MEG)');
bst_process('CallProcess', 'process_snapshot', sFilesSrcEeg, [], ...
    'target',   8, ...  % Sources (one time)
    'orient',   3, ...  % top
    'time',     0.019, ...
    'comment',  'Source maps at 19ms (EEG)');


% Save and display report
ReportFile = bst_report('Save');
bst_report('Open', ReportFile);



