function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 10-Apr-2024 15:19:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible. 
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
ss=ones(256,256);
axes(handles.axes1);
imshow(ss);
axes(handles.axes3);
imshow(ss);
axes(handles.axes6);
imshow(ss);
axes(handles.axes7);
imshow(ss);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd TestImages
[file,path] = uigetfile('*.jpg;*.bmp;*.png;*tif','Pick an Image File');
a = imread(file);
cd ..
    input =imresize(a,[256 256]);  
    [r c p] = size(a);

    if p==3 
       B=input(:,:,3);
    else
        
       errordlg('Not Sufficient Bands of Image');
       return;
    end    
    axes(handles.axes1);
    imshow(input);
    title('input Image');
    axes(handles.axes3);
    imshow(B);
    title('B Plane Image');
    %encode_dna(B, principle_of_dna)
    handles.input =input;
    handles.B = B;
    guidata(hObject, handles);


% --- Executes on button press in Integertransform.
function Integertransform_Callback(hObject, eventdata, handles)
% hObject    handle to Integertransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.B;

%%%%%%%%%%dividing the image into 8x8 block and LWT%%%%%%
[r c]=size(a);
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_k=a(i:i+7,j:j+7);
        Y(i:i+7,j:j+7)=wdecomp(bloc_k);
    end
end
axes(handles.axes6);
imshow(Y,[]);
title('Wavelet Decomposition');
handles.Y=Y;
handles.a=a;
guidata(hObject, handles);

% --- Executes on button press in embedding.
function embedding_Callback(hObject, eventdata, handles)
% hObject    handle to embedding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Y=handles.Y;
%%%%%%%%%%%%%%% Key generation%%%%%%%%%%%
keygener=zeros(8,8);
key=[0 0 1 0 ;0 0 1 1 ;0 1 0 1; 0 1 1 1; 1 0 0 0; 1 0 1 0; 1 1 0 1; 1 0 1 1];
key1=[0 0 1 0 0 0 1 0 ;0 0 1 1 0 0 1 1 ;0 1 0 1 0 1 0 1; 0 1 1 1 0 1 1 1];
keygener(1:8,5:8)=key;
keygener(5:8,1:8)=key1;
orig_key=keygener;
Y1 =Y;
%%%%% Select the text file to conceal
[file path]=uigetfile('*.txt','choose txt file');

 data1=fopen(file,'r');
 F=fread(data1);
 F = F';
 fclose(data1);

[r c]=size(F);
u =3.99999; csp =0.400005674;

for i = 1:r
     for j = 1:c
            csp = u*csp*(1-csp); 
            n = thrldfun(csp); 
            Etxt(i,j)=bitxor(F(i,j),n); 
            
     end
end

set(handles.text8,'String','Input Text: ');
set(handles.text9,'String',char(F));

set(handles.text10,'String','Cipher Text: ');
set(handles.text11,'String',char(Etxt));


len=length(Etxt);
count=1;
totalbits=8*len;
a=128;
k=1;
[r c]=size(Y);
for i=1:8:r-7;
    for j=1:8:c-7;
        block3=Y(i:i+7,j:j+7);
        for ii=1:8
            for jj=1:8;
                if orig_key(ii,jj)==1;
                    coeff=abs(block3(ii,jj));
                    [ block3(ii,jj),a,k,count]=embed(coeff,a,k,Etxt,totalbits,count,len);
                    if count>totalbits;
                        break;
                    end
                end
                if count>totalbits;
                    break;
                end
            end
            if count>totalbits;
                break;
            end
        end
        Y1(i:i+7,j:j+7)=block3;
        Y1=abs(Y1);
        if count>totalbits;
            break;
        end
    end
    if count>totalbits;
        break;
    end
end
outpu_t=Y1;

embededimage= outpu_t;
handles.len =len;
handles.orig_key = orig_key;
handles.outpu_t=embededimage;
handles.totalbits=totalbits;
guidata(hObject, handles);
helpdlg('Process completed');


% --- Executes on button press in inversetran.
function inversetran_Callback(hObject, eventdata, handles)
% hObject    handle to inversetran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input = handles.input;
embededimage=handles.outpu_t;


[r c]=size(embededimage);
m=1;
n=1;
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_k11=embededimage(i:i+7,j:j+7);
        LL=bloc_k11(m:m+3,n:n+3);
        LH=bloc_k11(m:m+3,n+4:n+7);
        HL=bloc_k11(m+4:m+7,n:n+3);
        HH=bloc_k11(m+4:m+7,n+4:n+7);
        Z(i:i+7,j:j+7)=inversewt(LL,LH,HL,HH);
    end
end

Z1 = uint8(Z);
out(:,:,1) = input(:,:,1);
out(:,:,2) = input(:,:,2);
out(:,:,3) = Z1;
 x(1)=0.2350;
 y(1)=0.3500;
 z(1)=0.7350;
 a(1)=0.0125;
 b(1)=0.0157;
 l(1)=3.7700;
 %l(1) = 0.93;

 for i=1:1:2280000
     x(i+1)=l*x(i)*(1-x(i))+b*y(i)*y(i)*x(i)+a*z(i)*z(i)*z(i);
     y(i+1)=l*y(i)*(1-y(i))+b*z(i)*z(i)*y(i)+a*x(i)*x(i)*x(i);
     z(i+1)=l*z(i)*(1-z(i))+b*x(i)*x(i)*z(i)+a*y(i)*y(i)*y(i);
 end

 Sx=ceil(mod((x*1000000),256));
 Sy=ceil(mod((y*1000000),256));
 Sz=ceil(mod((z*1000000),256));
 [row,col,d]=size(input);
%col = ceil(col/3)

PR = reshape(input(:,:,1),1,[]);
PG = reshape(input(:,:,2),1,[]);
PB = reshape(input(:,:,3),1,[]);
for i = 1:1:row*col
    CDR(i)=x(i)*PR(i);
    CDG(i)=y(i)*PG(i);
    CDB(i)=z(i)*PB(i);
end

for i = 1:1:row*col
    CCR(i)=bitxor(uint8(Sx(i)),uint8(CDR(i)));
    CCG(i)=bitxor(uint8(Sy(i)),uint8(CDG(i)));
    CCB(i)=bitxor(uint8(Sz(i)),uint8(CDB(i)));
end
CCRN=reshape(CCR,row,col);
CCGN=reshape(CCG,row,col);
CCBN=reshape(CCB,row,col);

ci=cat(3,CCRN,CCGN,CCBN);

%%%%%%%%% encryption  %%%%%%%%%%%%%%%%%%%5
[eI, key] = encrypt(ci);
dI = decrypt( eI , key );
rcpass=passcode;
imwrite(eI,'enc.png');
axes(handles.axes7);
imshow(eI);
title('encrypted image');
axes(handles.axes1);
imshow(out,[]);
title('enc Image');
out = uint8(out);
imwrite(out,'Out.bmp')
handles.out = out;
handles.Z = Z;
handles.dI = dI;
guidata(hObject,handles)

% --- Executes on button press in tran2.
function tran2_Callback(hObject, eventdata, handles)
% hObject    handle to tran2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

extractinpu_t=handles.B1;

[r c]=size(extractinpu_t);
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_kextract=extractinpu_t(i:i+7,j:j+7);
        YY(i:i+7,j:j+7)=wdecomp(bloc_kextract);
    end
end
axes(handles.axes1);
imshow(YY,[]);
title('Decomposition');
handles.YY=YY;
guidata(hObject, handles);
helpdlg('Transformation completed');

% --- Executes on button press in extract.
function extract_Callback(hObject, eventdata, handles)
% hObject    handle to extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out=handles.out;
input = handles.input;
dI=handles.dI;
YY=handles.YY;
totalbits=handles.totalbits;
orig_key=handles.orig_key;
fil_e=YY;

a=128;
jjj=1;
count=1;
k=0;
[r c]=size(YY);
for i=1:8:r-7;
    for j=1:8:c-7;
        block9=fil_e(i:i+7,j:j+7);
        for ii=1:8
            for jj=1:8;
                if orig_key(ii,jj)==1;
                    coeff=abs(block9(ii,jj));
                    g=coeff;
                    if g>=64;
                        bits=6;

                        h=32;
                    elseif g<64 & g>=32;
                        bits=5;

                        h=16;
                    elseif g<32 & g>=16;
                        bits=4;

                        h=8;
                    elseif g<16
                        bits=3;
                        h=4;
                    end
                    l=bits;
                    for iii=1:l;
                        if bitand(g,h)==h;
                            k= bitor(k,a);
                        end
                        count=count+1;
                        a=a/2;
                        h=h/2;
                        if a<1;
                            etxt(jjj)=k;
                            jjj=jjj+1;
                            k=0;
                            a=128;
                        end
                        if count>totalbits;
                            break;
                        end
                    end
                    if count>totalbits;
                        break;
                    end
                end
                if count>totalbits;
                    break;
                end
            end
            if count>totalbits;
                break;
            end
        end
        if count>totalbits;
            break;
        end
    end
    if count>totalbits;
        break;
    end
end
 x(1)=0.2350;
 y(1)=0.3500;
 z(1)=0.7350;
 a(1)=0.0125;
 b(1)=0.0157;
 l(1)=3.7700;
 %l(1) = 0.93;

 for i=1:1:2280000
     x(i+1)=l*x(i)*(1-x(i))+b*y(i)*y(i)*x(i)+a*z(i)*z(i)*z(i);
     y(i+1)=l*y(i)*(1-y(i))+b*z(i)*z(i)*y(i)+a*x(i)*x(i)*x(i);
     z(i+1)=l*z(i)*(1-z(i))+b*x(i)*x(i)*z(i)+a*y(i)*y(i)*y(i);
 end

 Sx=ceil(mod((x*1000000),256));
 Sy=ceil(mod((y*1000000),256));
 Sz=ceil(mod((z*1000000),256));
[row,col,d]=size(input);
%%%%%%%%%% decryption%%%%%%%%%%%%%5555

dec = dI;
DR = reshape(dec(:,:,1),1,[]);
DG = reshape(dec(:,:,2),1,[]);
DB = reshape(dec(:,:,3),1,[]);

for i = 1:1:row*col
    DDR(i)=bitxor(uint8(Sx(i)),uint8(DR(i)));
    DDG(i)=bitxor(uint8(Sy(i)),uint8(DG(i)));
    DDB(i)=bitxor(uint8(Sz(i)),uint8(DB(i)));
end

xi = 1./x;
yi = 1./y;
zi = 1./z;

for i = 1:1:row*col
    DDDR(i)=xi(i)*DDR(i);
    DDDG(i)=yi(i)*DDG(i);
    DDDB(i)=zi(i)*DDB(i);
end
DDDR=reshape(DDDR,row,col);
DDDG=reshape(DDDG,row,col);
DDDB=reshape(DDDB,row,col);

di = cat(3,DDDR,DDDG,DDDB);
figure;
imshow(di);
imwrite(di,'dec.png');
axes(handles.axes7);
imshow(input);
title('Reconstructed image');
handles.etxt = etxt;
guidata(hObject,handles);

helpdlg('Process Completed');


% --- Executes on button press in validate.
function validate_Callback(hObject, eventdata, handles)
% hObject    handle to validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputimage=handles.a;
outputimage=handles.Z;
hd = handles.len; 
[M N]=size(outputimage);
inputimage=uint8(inputimage);
outputimage=uint8(outputimage);
%%%%%%%%%%%%%%%%%%%%MSE%%%%%%%%%%%
MSE=sum(sum((inputimage-outputimage).^2))/(M*N);
set(handles.edit1,'string',MSE);
%%%%%%%%%%%%%%%%%%PSNR%%%%%%%%%%%
PSNR = 10*log10(255*255/MSE);
set(handles.edit2,'string',PSNR);

rim = double(inputimage);  erim = double(outputimage);

rimd = rim - mean2(rim);
erimd = erim - mean2(erim);

cval = sum(sum(rimd.*erimd))./sqrt(sum(sum(rimd.*rimd))*sum(sum(erimd.*erimd)));

set(handles.edit4,'string',cval);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewout.
function viewout_Callback(hObject, eventdata, handles)
% hObject    handle to viewout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
etext = handles.etxt;
[r c]=size(etext);

u =3.99999; csp =0.400005674;  
for i = 1:r
    for j = 1:c
        csp = u*csp*(1-csp); 
        n = thrldfun(csp); 
        Dtext(i,j)=bitxor(etext(i,j),n); 
    end
end

%%%%%%%%Write the text data in Output File
fid1 = fopen('output.txt','wb');
fwrite(fid1,char(Dtext),'char');
fclose(fid1);

set(handles.text12,'String','Decryp Text:');
set(handles.text13,'String',char(Dtext));

% winopen('output.txt');


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete 'Out.bmp'
c = ones(256,256);
axes(handles.axes1);
imshow(c);
axes(handles.axes3);
imshow(c);
set(handles.edit1,'string','');
set(handles.edit2,'string','');
set(handles.text8,'String','');
set(handles.text9,'String','');
set(handles.text10,'String','');
set(handles.text11,'String','');
set(handles.text12,'String','');
set(handles.text13,'String','');
set(handles.edit4,'String','');


% --- Executes on button press in embedIm.
function embedIm_Callback(hObject, eventdata, handles)
% hObject    handle to embedIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = ones(256,256);
axes(handles.axes1);
imshow(c);
axes(handles.axes3);
imshow(c);

% To get an embedded image
[file,path] = uigetfile('*.bmp','Pick an Image File');
    a = imread(file);
    input =imresize(a,[256 256]);  
    [r c p] = size(a);
    B=input(:,:,3);
    axes(handles.axes1);
    imshow(input);
    title('Enc Image');
    
    handles.B1 = B;
    guidata(hObject, handles);


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
