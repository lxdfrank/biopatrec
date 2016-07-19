% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec © which is open and free software under 
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for 
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and 
% Chalmers University of Technology. All authorsí contributions must be kept
% acknowledged below in the section "Updates % Contributors". 
%
% Would you like to contribute to science and sum efforts to improve 
% amputeesí quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file 
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
% ------------------- Function Description ------------------
% Function to Record Exc Sessions
%
% --------------------------Updates--------------------------
% 2015-1-12 / Enzo Mastinu / Divided the RecordingSession function into
                            % several functions: ConnectDevice(),
                            % SetDeviceStartAcquisition(),
                            % Acquire_tWs(), StopAcquisition(). This functions 
                            % has been moved to COMM/AFE folder, into this new script.
% 2015-1-19 / Enzo Mastinu / The ADS1299 part has been modified in way to be 
                            % compatible with the new ADS1299 acquisition mode (DSP + FPU)
% 2015-4-10 / Enzo Mastinu / The ADS1299_DSP acquisition has been optimized, only desired
                            % channels are transmitted to PC, not all as
                            % before. To do that PC sends start command
                            % followed by the number of channels requested
% 2016-5-9 / Enzo Mastinu / The ADS_BP acquisition has been optimized. Now
%                           % sF will be set before starting the recording.
%                           % Only some values of sF are allowed. 

% 20xx-xx-xx / Author  / Comment



% it sets the chosen device and sends start acquisition command
function SetDeviceStartAcquisition(handles, obj) 

    deviceName  = handles.deviceName;
    nCh         = handles.nCh;
    sTall       = handles.sTall;
    sF          = handles.sF;
     
    %%%%% INTAN RHA2216 %%%%%
    if strcmp(deviceName, 'RHA2216')

        % Setup the selected channels
        vCh = 0:nCh'-1;  
        fwrite(obj,'C','char');
        fwrite(obj,nCh,'uint8');
        for i = 1 : nCh    
            fwrite(obj,vCh(i),'uint8');
        end     
        replay = char(fread(obj,1,'char'));
        if ~strcmp(replay,'O')
            set(handles.t_msg,'String','Error setting the vector of channels'); 
            fclose(obj);        
            return
        else    
            set(handles.t_msg,'String','Channel vector set'); 
        end    

        % Set up frequency in the microcontroller    
        fwrite(obj,'F','char');
        fwrite(obj,sF,'uint16');    
        replay = char(fread(obj,1,'char'));
        if ~strcmp(replay,'O')
            set(handles.t_msg,'String','Error setting the frequency'); 
            fclose(obj);        
            return
        else    
            set(handles.t_msg,'String','Frequency set'); 
        end

        % Set sampling time
        fwrite(obj,sTall,'uint8');
        replay = char(fread(obj,1,'char'));
        if ~strcmp(replay,'O')
            set(handles.t_msg,'String','Error setting sampling time'); 
            fclose(obj);        
            return
        else    
            set(handles.t_msg,'String','Sampling time set'); 
        end

        % Start the aquisition    
        fwrite(obj,'S','char'); 
        set(handles.t_msg,'String','Start'); 
    end         
   
    %%%%% TI ADS1299 %%%%%
    if strcmp(deviceName, 'ADS1299')
        % Start the acquisition
        fwrite(obj,'G','char');
        replay = char(fread(obj,1,'char'));
        if strcmp(replay,'G')
            set(handles.t_msg,'String','Start');
        else
            set(handles.t_msg,'String','Error Start'); 
            fclose(obj);
            return
        end
    end
    if strcmp(deviceName, 'ADS_BP')
        % Set the ADS_BP datarate output
        if(sF~=500 && sF~=1000 && sF~=2000)
            disp('The selected sampling frequency is not valid for the ADS_BP. Errors may occur!');
            errordlg('The selected sampling frequency is not valid for the ADS_BP. Errors may occur!','Erroneous sampling frequency');
        end
        fwrite(obj,'T','char');
        % Read available data and discard it
        if obj.BytesAvailable > 1
            fread(obj,obj.BytesAvailable,'uint8');       
        end
        fwrite(obj,'r','char');
        replay = char(fread(obj,1,'char'));
        if strcmp(replay,'r')
            fwrite(obj,sF,'uint32');
            replay = char(fread(obj,1,'char'));
            if strcmp(replay,'r');
                set(handles.t_msg,'String','sampling frequency set');
            else
                set(handles.t_msg,'String','Error Setting sampling frequency'); 
                fclose(obj);
                return
            end
        else
            set(handles.t_msg,'String','Error Setting sampling frequency'); 
            fclose(obj);
            return
        end
        % Send the START command
        fwrite(obj,'G','char');
        fwrite(obj,nCh,'char');
        replay = char(fread(obj,1,'char'));
        switch replay
            case 'G'
                set(handles.t_msg,'String','EMG Start');
            case 'L'
                set(handles.t_msg,'String','Error: Neuromotus locked');
                fclose(obj);
                return
            case 'B'
                set(handles.t_msg,'String','Error: Battery Low!');
                fclose(obj);
                return
        end
        % the digital filtering introduce a transient not needed in recording
        % session. To avoid that transient we can just skip the first
        % samples coming from the device
        settlingTime = 1;
        settlingSamples = settlingTime*sF;
        for sampleNr = 1:settlingSamples
            fread(obj,nCh,'float32');
        end
    end
         
end
