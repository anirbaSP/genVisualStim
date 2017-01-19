%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% copyright (c) 2016 Pei Sabrina Xu
%
% this program is free software: you can redistribute it and/or modify it
% under the terms of the gnu general public license as published by the
% free software foundation, either version 3 of the license, or at your
% option) any later version.
%
% this program is distributed in the hope that it will be useful, but
% without any warranty; without even the implied warranty of
% merchantability or fitness for a particular purpose.  see the gnu general
% public license for more details.
%
% you should have received a copy of the gnu general public license along
% with this program.  if not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = stimGenforBeh(varargin)
% STIMGENFORBEH MATLAB code for stimGenforBeh.fig
%      STIMGENFORBEH, by itself, creates a new STIMGENFORBEH or raises the
%      existing singleton*.
%
%      H = STIMGENFORBEH returns the handle to a new STIMGENFORBEH or the
%      handle to the existing singleton*.
%
%      STIMGENFORBEH('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in STIMGENFORBEH.M with the given
%      input arguments.
%
%      STIMGENFORBEH('Property','Value',...) creates a new STIMGENFORBEH or
%      raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before stimGenforBeh_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop.  All inputs are passed to
%      stimGenforBeh_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimGenforBeh

% Last Modified by GUIDE v2.5 21-Oct-2016 22:17:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGenforBeh_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGenforBeh_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFAULT SETTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before stimGenforBeh is made visible.
function stimGenforBeh_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn. hObject    handle to
% figure eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) varargin
% command line arguments to stimGenforBeh (see VARARGIN)

% Choose default command line output for stimGenforBeh
handles.output = hObject;

% Call the function stimGenInit to initialize the user defined choices in
% the gui
initState = stimGenInit();

%%%%%%%%%%%%%%%%%%%%% setup COMMUNICATION to the HOST %%%%%%%%%%%%%%%%%%%%%
% % For a behavior task, set up a communication with the host computer; we
% % need to set up the connection at this initial stage, because some data
% % communication like UDP requires ALL the computers completely get ready
% % for sending and recieving data before the first packet. In order to
% give % the flexibility for host computer to send out data any time, it's
% beter % to get the vs computer ready as early as possible.

% connectionR = commu2host('initiateReceiveConnection'); 
% connectionS =commu2host('initiateSendConnection');
% 
% handles.connection.receive = connectionR; 
% handles.connection.send = connectionS;
handles.connection = [];

set(handles.hostConnected, 'Value', 0);

% during debug, connection is not working, use sudoTrial instead
handles.sudoTrial = initState.sudoTrial; 

%%%%%%%%%%%%%%%%%%%%% setup the default STIMULUS TYPES %%%%%%%%%%%%%%%%%%%%
set(handles.stimTypeBox,'string', initState.defaultStimTypes);
% locate the default stimulus type among all the types and set the proper
% value of the list
listVal = find(...
        strcmp(initState.defaultStimTypes,initState.defaultStimType));
set(handles.stimTypeBox,'Value',listVal);

handles.stimType = initState.defaultStimType;

% and set the corresponding default table
% set(handles.stimParams,'data',initState.defaultTable);

%set the default tag
% set(handles.tagBox,'String',initState.tag)

handles.vsPool = [];
handles.vsTrial = [];
handles.header = initState.header;
handles.sudoHeader = initState.sudoHeader;

handles.delay = initState.delay;
handles.duration = initState.duration;
set(handles.durationBox, 'String', initState.duration)
set(handles.delayBox, 'String', initState.delay)

%%%%%%%%%%%%%%%%%%%%%%%%% setup auto SAVE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set the default auto save state
set(handles.autoSave,'Value',initState.autoSave);

handles.autoSave = initState.autoSave;

dirInformation;

set(handles.filePathBox, 'String', dirInfo.vstimDataLoc);
set(handles.fileNameBox, 'String', initState.fileName);

handles.filePath = dirInfo.vstimDataLoc;
handles.fileName = initState.fileName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initiate TRIAL INFO %%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.curTrialNumBox, 'String', num2str(0))

handles.curTrialNum = 0;
handles.lastKey = '';
handles.lastStimIdx = [];

set(handles.start, 'Value', 0);
set(handles.stop, 'Value', 0);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = stimGenforBeh_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT); hObject
% handle to figure eventdata  reserved - to be defined in a future version
% of MATLAB handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% EXECUTES ON SELECTION CHANGE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STIMULUS TYPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function stimTypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimTypeBox (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stimTypeBox_Callback(hObject, eventdata, handles)
% When the user selects a new stimulus, we want to update the current
% stimulus type

%First Get the index of the stimulus type that has been chosen in the
%listbox
index = get(handles.stimTypeBox,'Value');
% Get the cell array of all strings in the listbox
stimStrings = get(handles.stimTypeBox,'String');
%Get the string of the particular stimulus chosen
handles.stimType = stimStrings{index};

% % Call VisGenDefaultTable to supply a default table for this stimulus
% table = StimGenDefaultTable(handles.stimTypeBox); % Set the handle to the
% stimParams object to the new default data table
% set(handles.stimParams,'data',table);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stimGenforBeh wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes during object creation, after setting all properties.
function gen_vs_pool_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_vs_pool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in gen_vs_pool. --- Executes on button press
% in gen_vs_pool.
function handles = gen_vs_pool_Callback(hObject, eventdata, handles)
% hObject    handle to gen_vs_pool (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

if isfield(handles, 'screenInfo')
    screenInfo = handles.screenInfo;
else
    screenInfo = initializeScreen;
    handles.screenInfo = screenInfo;
end
    
vsPool = genVSPool(screenInfo); 
% to do: add front pannel to specify what will be in the stimulus pool

handles.vsPool = vsPool;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function durationBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function durationBox_Callback(hObject, eventdata, handles)
% hObject    handle to durationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of durationBox as text
%        str2double(get(hObject,'String')) returns contents of durationBox as a double

duration = get(handles.durationBox, 'String');
handles.duration = duration;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function delayBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function delayBox_Callback(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text10 as text
%        str2double(get(hObject,'String')) returns contents of text10 as a double

delay = get(handles.delayBox, 'String');
handles.delay = delay;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function filePathBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepathbox (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filePathBox_Callback(hObject, eventdata, handles)
% hObject    handle to filepathbox (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepathbox as text
%        str2double(get(hObject,'String')) returns contents of filepathbox as
%        a double

% Get the string of the file name
filePath = get(handles.filePathBox,'String');

handles.filePath = filePath;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fileNameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenamebox (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fileNameBox_Callback(hObject, eventdata, handles)
% hObject    handle to filenamebox (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenamebox as text
%        str2double(get(hObject,'String')) returns contents of filenamebox as
%        a double

fileName = get(handles.fileNameBox,'String');

handles.fileName = fileName;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in autoSave.
function autoSave_Callback(hObject, eventdata, handles)
% hObject    handle to autoSave (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoSave
% guidata(hObject, handles);
handles.saveFile = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in savefile.
function savefile_Callback(hObject, eventdata, handles, warningOrNot)
% hObject    handle to savefile (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
if nargin == 3
    warningOrNot = 1;
end
if warningOrNot
    if isempty(handles.vsTrial)
        warndlg('Trial information is empty.')
    end
end

if isempty(handles.header)
    warndlg('header from host is empty')
end
if isempty(handles.vsPool)
    warndlg('vs Pool is empty.')
end

header = handles.header;
vsPool = handles.vsPool;
vsTrial = handles.vsTrial;
fullname = [handles.filePath filesep handles.fileName '.m'];
if handles.autoSave
    save(fullname, 'header', 'vsPool', 'vsTrial', '-mat'); % save vsPool
end

%%%%%%%%%%%%%%%%%%%%%%%%%% initialize the SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function initScreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes on button press in initScreen.

function initScreen_Callback(hObject, eventdata, handles)
% hObject    handle to initScreen (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of initScreen
screenInfo = initializeScreen;
handles.screenInfo = screenInfo;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in bgScreen.
function bgScreen_Callback(hObject, eventdata, handles)
% hObject    handle to bgScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'screenInfo')
    screenInfo = handles.screenInfo;
else
    screenInfo = initializeScreen;
    handles.screenInfo = screenInfo;
end

% just breifly refresh the screen to gray for 100ms
drawMultiTextures(screenInfo, 0.1)

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%% display HOST CONNECTION status %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function hostConnected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hostConnected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in hostConnected.
function hostConnected_Callback(hObject, eventdata, handles)
% hObject    handle to hostConnected (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hostConnected

% --- Executes during object creation, after setting all properties.
function curTrialNumBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curtrialnumbox (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Continous RUNNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of start

if isempty(handles.vsPool)
    handles = gen_vs_pool_Callback(hObject, eventdata, handles);
end

% get header from the host, and update stimType and to-be-saved fileName

handles = getHeaderFromHost(handles);
handles = updateStimTypeFileNameDelayfromHeader(hObject, handles);

% starting saving file
savefile_Callback(hObject, eventdata, handles, 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try to open a binary file to save trial info in real time
fileID = fopen([handles.filePath 'debug_Trial.vstim'], 'w');

% MAIN LOOP OVER TRIALS
while ~get(handles.stop, 'Value')
    handles = runRealTimeVisualStimuliSingleTrial(handles);
    
    % SAVE VISUAL STIMULUS INFORMATION
    fwrite(fileID, [handles.curTrialNum handles.lastStimIdx], 'uint8');

    % update current trial number display
    set(handles.curTrialNumBox, 'String', num2str(handles.curTrialNum));
    % update current delay time
    set(handles.delayBox, 'String', handles.delay)
    % Update handles structure
    guidata(hObject, handles);
end

fclose(fileID);

savefile_Callback(hObject, eventdata, handles)

set(handles.stop, 'Value', 0)
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER function %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = getHeaderFromHost(handles)
% get header from the host, header includes information about stimType,
% fileName, etc. as needed.
if ~isempty(handles.connection)
    header = commu2host('getHeader', handles.connection.receive);
else header = handles.sudoHeader;
end
if isempty(header)
    set(handles.hostConnected, 'Value', 0);
else
    set(handles.hostConnected, 'Value', 1);
end
handles.header = header;

function h = readHeader(header, fields)
% read the specified fields from the header. Header is a originally a string
% pre-define the start/stop flag for all fields in the header
startflag = '&'; 
stopflag = '&&';

% bread the header into string cell array according to stopflag
idx = strfind(header, stopflag);
n = length(idx);
s = cell(1,n);
pos = 1-length(stopflag);
for i = 1:n
    pos = pos+length(stopflag);
    s{i} = header(pos:idx(i)-1);
    pos = idx(i);
end

% for each inquired fields, scan them in each cell array entry 
n_field = length(fields);
h = struct;
for i = 1:n_field
    thisfield = fields{i};
    len = length(thisfield);
    tmp = strncmp(s, [thisfield startflag], len+length(startflag));
    if sum(tmp) > 1
        error(['header contains conflict value for ' thisfiled]);
    end
    if sum(tmp) == 1
        v = s{tmp}(len+length(startflag)+1:end);
    else v = [];
    end
    h = setfield(h, thisfield, v);   
end

function handles = ...
    updateStimTypeFileNameDelayfromHeader(hObject, handles)
header = handles.header;
h = readHeader(header, {'stimType', 'fileName', 'delay'});

% update stimTypeBox
% Get the cell array of all strings in the listbox
stimStrings = get(handles.stimTypeBox,'String');
%Get the idx of the stimulus chosen
idx = strcmp(stimStrings, h.stimType);
set(handles.stimTypeBox, 'Value', find(idx));
handles.stimType = h.stimType;

% update filenamebox
set(handles.fileNameBox, 'String', h.fileName);
handles.fileName = h.fileName;

% update delay
handles.delay = str2num(h.delay);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STOP and QUIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)
Screen('CloseAll')
Screen('Preference', 'Verbosity',3);
temp = instrfindall;
delete(temp)
close(handles.figure1)
