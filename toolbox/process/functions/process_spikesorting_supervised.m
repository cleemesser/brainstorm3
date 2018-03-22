function varargout = process_spikesorting_supervised( varargin )
% PROCESS_SPIKESORTING_SUPERVISED:
% This process opens up a supervised Spike Sorting program allowing for
% manual correction of unsupervised spike sorted events.
%
% USAGE: OutputFiles = process_spikesorting_supervised('Run', sProcess, sInputs)

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2018 University of Southern California & McGill University
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
% Authors: Martin Cousineau, 2018

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Supervised spike sorting';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Electrophysiology';
    sProcess.Index       = 1202;
    sProcess.Description = 'www.in.gr';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'raw'};
    sProcess.OutputTypes = {'raw'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 1;
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end


%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
    global GlobalData;
    OutputFiles = {};
    ProtocolInfo = bst_get('ProtocolInfo');
    
    % Compute on each raw input independently
    for i = 1:length(sInputs)
        sInput = sInputs(i);
        DataMat = in_bst_data(sInput.FileName);
        
        % Make sure spikes exist and were generated by WaveClus
        if ~isfield(DataMat, 'Spikes') || ~isstruct(DataMat.Spikes) ...
                || ~isfield(DataMat, 'Parent') ...
                || exist(DataMat.Parent, 'dir') ~= 7 ...
                || isempty(dir(DataMat.Parent))
            bst_report('Error', sProcess, sInput, ...
                'No spikes found. Make sure to run the unsupervised Spike Sorter first.');
            return;
        end

        switch lower(DataMat.Device)
            case 'waveclus'
                % Ensure we are including the WaveClus folder in the Matlab path
                waveclusDir = bst_fullfile(bst_get('BrainstormUserDir'), 'waveclus');
                if exist(waveclusDir, 'file')
                    addpath(genpath(waveclusDir));
                end

                % Install WaveClus if missing
                if ~exist('wave_clus_font', 'file')
                    rmpath(genpath(waveclusDir));
                    isOk = java_dialog('confirm', ...
                        ['The WaveClus spike-sorter is not installed on your computer.' 10 10 ...
                             'Download and install the latest version?'], 'WaveClus');
                    if ~isOk
                        bst_report('Error', sProcess, sInputs, 'This process requires the WaveClus spike-sorter.');
                        return;
                    end
                    process_spikesorting_unsupervised('downloadAndInstallWaveClus');
                end

            otherwise
                bst_error('The chosen spike sorter is currently unsupported by Brainstorm.');
        end
        
        CloseFigure();
        
        GlobalData.SpikeSorting = struct();
        GlobalData.SpikeSorting.Data = DataMat;
        GlobalData.SpikeSorting.Selected = 0;
        GlobalData.SpikeSorting.Fig = -1;
        
        gui_brainstorm('ShowToolTab', 'Spikes');
        OpenFigure();
        panel_spikes('UpdatePanel');
    end
    
end

function OpenFigure()
    global GlobalData;
    
    bst_progress('start', 'Spike Sorting', 'Loading spikes...');
    CloseFigure();
    
    GlobalData.SpikeSorting.Selected = GetNextElectrode();
    
    electrodeFile = bst_fullfile(...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).Path, ...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).File);
    
    switch lower(GlobalData.SpikeSorting.Data.Device)
        case 'waveclus'
            GlobalData.SpikeSorting.Fig = wave_clus(electrodeFile);
            
            % Some Wave Clus visual hacks
            load_button = findall(GlobalData.SpikeSorting.Fig, 'Tag', 'load_data_button');
            if ishandle(load_button)
                load_button.Visible = 'off';
            end
            save_button = findall(GlobalData.SpikeSorting.Fig, 'Tag', 'save_clusters_button');
            if ishandle(save_button)
                save_button.Visible = 'off';
            end
            
        otherwise
            bst_error('This spike sorting structure is currently unsupported by Brainstorm.');
    end
    
    panel_spikes('UpdatePanel');
    LoadElectrode();
    bst_progress('stop');
end

function isOpen = FigureIsOpen()
    global GlobalData;
    isOpen = isfield(GlobalData, 'SpikeSorting') ...
        && isfield(GlobalData.SpikeSorting, 'Fig') ...
        && ishandle(GlobalData.SpikeSorting.Fig);
end

function CloseFigure()
    global GlobalData;
    if ~FigureIsOpen()
        return;
    end
    
    close(GlobalData.SpikeSorting.Fig);
    panel_spikes('UpdatePanel');
end

function LoadElectrode()
    global GlobalData;
    if ~FigureIsOpen()
        return;
    end
    
    electrodeFile = bst_fullfile(...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).Path, ...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).File);
    
    switch lower(GlobalData.SpikeSorting.Data.Device)
        case 'waveclus'
            wave_clus('load_data_button_Callback', GlobalData.SpikeSorting.Fig, ...
                electrodeFile, guidata(GlobalData.SpikeSorting.Fig));
            
            name_text = findall(GlobalData.SpikeSorting.Fig, 'Tag', 'file_name');
            if ishandle(name_text)
                name_text.String = panel_spikes('GetSpikeName', GlobalData.SpikeSorting.Selected); 
            end
            
        otherwise
            bst_error('This spike sorting structure is currently unsupported by Brainstorm.');
    end
end

function SaveElectrode()
    global GlobalData;
    
    if ~FigureIsOpen()
        return;
    end
    
    electrodeFile = bst_fullfile(...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).Path, ...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).File);
    
    % Save through Spike Sorting software
    switch lower(GlobalData.SpikeSorting.Data.Device)
        case 'waveclus'
            save_button = findall(GlobalData.SpikeSorting.Fig, 'Tag', 'save_clusters_button');
            wave_clus('save_clusters_button_Callback', save_button, ...
                [], guidata(GlobalData.SpikeSorting.Fig), 0);

        otherwise
            bst_error('This spike sorting structure is currently unsupported by Brainstorm.');
    end
    
    % Save updated brainstorm file
    GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).Mod = 1;
    bst_save(GlobalData.SpikeSorting.Data.Name, GlobalData.SpikeSorting.Data, 'v6');
    
    % Add event to linked raw file    
    process_spikesorting_unsupervised('CreateSpikeEvents', ...
        GlobalData.SpikeSorting.Data.RawFile, ...
        GlobalData.SpikeSorting.Data.Device, ...
        electrodeFile, ...
        GlobalData.SpikeSorting.Data.Spikes(GlobalData.SpikeSorting.Selected).Name, ...
        1)
end

function nextElectrode = GetNextElectrode()
    global GlobalData;
    if ~isfield(GlobalData, 'SpikeSorting') ...
            || ~isfield(GlobalData.SpikeSorting, 'Selected') ...
            || isempty(GlobalData.SpikeSorting.Selected)
        GlobalData.SpikeSorting.Selected = 0;
    end
    
    numSpikes = length(GlobalData.SpikeSorting.Data.Spikes);
    
    if GlobalData.SpikeSorting.Selected < numSpikes
        nextElectrode = GlobalData.SpikeSorting.Selected + 1;
        while nextElectrode <= numSpikes && ...
                isempty(GlobalData.SpikeSorting.Data.Spikes(nextElectrode).File)
            nextElectrode = nextElectrode + 1;
        end
    end
    if nextElectrode > numSpikes || isempty(GlobalData.SpikeSorting.Data.Spikes(nextElectrode).File)
        nextElectrode = GlobalData.SpikeSorting.Selected;
    end
end

