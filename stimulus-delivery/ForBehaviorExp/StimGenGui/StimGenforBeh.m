function varargout = StimGenforBeh(varargin)
% STIMGENFORBEH MATLAB code for StimGenforBeh.fig
%      STIMGENFORBEH, by itself, creates a new STIMGENFORBEH or raises the existing
%      singleton*.
%
%      H = STIMGENFORBEH returns the handle to a new STIMGENFORBEH or the handle to
%      the existing singleton*.
%
%      STIMGENFORBEH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMGENFORBEH.M with the given input arguments.
%
%      STIMGENFORBEH('Property','Value',...) creates a new STIMGENFORBEH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StimGenforBeh_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StimGenforBeh_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StimGenforBeh

% Last Modified by GUIDE v2.5 26-Aug-2015 12:33:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StimGenforBeh_OpeningFcn, ...
                   'gui_OutputFcn',  @StimGenforBeh_OutputFcn, ...
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


% --- Executes just before StimGenforBeh is made visible.
function StimGenforBeh_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StimGenforBeh (see VARARGIN)

% Choose default command line output for StimGenforBeh
handles.output = hObject;

% Call the function stimGenInit to initialize the user defined choices in
% the gui
initState = stimGenInit();

% set the user of the rig
% set(handles.userBox,'String',initState.user);

% set the default "Is it for a behavior task or not?"
handles.behaviorOrNot = initState.behaviorOrNot;
set(handles.Behavior, 'Value', handles.behaviorOrNot);
% if it's a behavior task, set up a communication with the host computer;
% we need to set up the connection at this initial stage, because some data
% communication like UDP requires the ALL the computers completely get ready
% for sending and recieving data before the first packet. In order
% to give the flexibility for host computer to send out data any time, it's
% beter to get the vs computer ready as early as possible.
connectionR = commu2host('initiateReceiveConnection');
connectionS = commu2host('initiateSendConnection');
if handles.behaviorOrNot   
    handles.connection.receive = connectionR;
    handles.connection.send = connectionS;
end

%set the default stimulus type
handles.stimType = initState.defaultStimType;
% Set the default stimulus types
set(handles.stimTypeBox,'string', initState.defaultStimTypes);
% locate the default stimulus type among all the types and set the proper
% value of the list
listVal = find(...
        strcmp(initState.defaultStimTypes,initState.defaultStimType));
% now set the value of the stimTypeBox to match the default stimTypeBox
set(handles.stimTypeBox,'Value',listVal);

% and set the corresponding default table
% set(handles.stimParams,'data',initState.defaultTable);

%set the default tag
% set(handles.tagBox,'String',initState.tag)

%set the default save state
set(handles.saveTrials,'Value',1)

% set start button
setStartButton(handles)

% Update handles structure
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = StimGenforBeh_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% EXECUTES ON SELECTION CHANGE IN STIMTYPEBOX. %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimTypeBox_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% When the user selects a new stimulus, we want to update the stimParams 
%object with new fields and default values that are pertinent for the 
%particular stimulus type chosen. These defaults are set by the 
%VisGenDefaultTable function

%First Get the index of the stimulus type that has been chosen in the
%listbox
index = get(handles.stimTypeBox,'Value');
% Get the cell array of all strings in the listbox
stimStrings = get(handles.stimTypeBox,'String');
%Get the string of the particular stimulus chosen
handles.stimTypeBox = stimStrings{index};
%Call VisGenDefaultTable to supply a default table for this stimulus
%table = StimGenDefaultTable(handles.stimTypeBox);
%Set the handle to the stimParams object to the new default data table
%set(handles.stimParams,'data',table);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StimGenforBeh wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes during object creation, after setting all properties.
function stimTypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimTypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveTrials.
function saveTrials_Callback(hObject, eventdata, handles)
% hObject    handle to saveTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveTrials

% --- Executes on button press in trialKeysStatus.
function trialKeysStatus_Callback(hObject, eventdata, handles)
% hObject    handle to trialKeysStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trialKeysStatus

% --- Executes on button press in genTrials.
function genTrials_Callback(hObject, eventdata, handles)
% hObject    handle to genTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of genTrials
stimType = handles.stimType;
if handles.behaviorOrNot
    trialKeys = commu2host('getTrialKeys', handles.connection.receive);
    % update in the front pannel that the trialkeys are recieved or not
    if isempty(trialKeys)
        set(handles.trialKeysStatus, 'Value', 0);
    else
        set(handles.trialKeysStatus, 'Value', 1);
        %=========================== to be done ===========================
        %guidata(hObject, handles); % necessary?
        %=========================== to be done ===========================
    end
    trials = genTrialforBeh(stimType, trialKeys);
else
    trials = trialStruct(handles);
end
handles.trials = trials;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in initScreen.
function initScreen_Callback(hObject, eventdata, handles)
% hObject    handle to initScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of initScreen
screenInfo = initializeScreen;
handles.screenInfo = screenInfo;
% Update handles structure
guidata(hObject, handles);

%===============================to do======================================
% To do: do we need to keep playing the background screen?
%===============================to do======================================

% --- Executes on button press in startstopbutton.
function startstopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startstopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startstopbutton
curString = get(handles.startstopbutton, 'String');
switch curString
    case 'Start'
        if ~isfield(handles, 'screenInfo')
            screenInfo = initializeScreen;
            handles.screenInfo = screenInfo;
        end
        screenInfo = handles.screenInfo;
        trials = handles.trials;
        connection = handles.connection;
        setStopButton(handles);
        
        runBatchVisualStimuli(trials, screenInfo, connection)
        
        setStartButton(handles);
        
    case 'Stop'     
        setStartButton(handles);
end

function setStartButton(handles)
set(handles.startstopbutton, 'BackgroundColor', 'green')
set(handles.startstopbutton, 'BackgroundColor', 'black')
set(handles.startstopbutton, 'String', 'Start')

function setStopButton(handles)
set(handles.startstopbutton, 'BackgroundColor', 'red')
set(handles.startstopbutton, 'BackgroundColor', 'white')
set(handles.startstopbutton, 'String', 'Stop')

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stop


% --- Executes on button press in hideCursor.
function hideCursor_Callback(hObject, eventdata, handles)
% hObject    handle to hideCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hideCursor

% The mouse cursor will always be hiden when playing visual stimulus, and
% pressing any key on the keyboard will stop the trials (this is because we
% will set the highest priority to drawing the screen, which may
% unavoidablely ignore/delaly responses to other tasks during that period,
% except for 'KbCheck' to terminate the trials. Therefore, using mouse
% during that period is not recommended). However, we will choose to show
% the cursor (and automatically turn off KbCheck) before and after trials
% when screen priority is set back to normal, which enable us to click and
% type.

% handles.hideCursor = get(hObject,'Value');
% if isfield(handles, 'screenInfo')
%     handles.screenInfo.hideCursor = handles.hideCursor;
%     if screenInfo.hideCursor
%         HideCursor;
%         handles.screenInfo.KbCheckOn = 1;
%     else
%         ShowCursor;
%         handles.screenInfo.KbCheckOn = 0;
%     end
% end


% --- Executes on button press in Behavior.
function Behavior_Callback(hObject, eventdata, handles)
% hObject    handle to Behavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Behavior

guidata(hObject, handles);
handles.Behavior = get(hObject, 'Value');


% --- Executes during object creation, after setting all properties.
function Behavior_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Behavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Screen('CloseAll')
temp = instrfindall;
delete(temp)
close(handles.figure1)
