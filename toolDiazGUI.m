
%Apertura del archivo
clear all; close all; clc;
currentFolder = pwd;
%Archivo donde guardo la ultima direccion
inicFolderFile = strcat(currentFolder,'\lastUsedFolder.txt');
contentConfigFile = fileread(inicFolderFile);
contentConfigFile = strsplit(contentConfigFile,'\n')
inicFolder = contentConfigFile{1};
oldUser = contentConfigFile{2};

%Ingresar nombre de usuario
activeUser = functionChangeUser( oldUser );

segmentarStudies = true;

while segmentarStudies
    clearvars -except currentFolder inicFolderFile contentConfigFile contentConfigFile inicFolder oldUser segmentarStudies activeUser;

    close all; clc;
    nroFrameSelected = -1;
    
    [filename,PathName] = uigetfile({'*.avi;*.jpg;*.tif;*.png;*.bmp;*.gif','All Image Files';...
        '*.*','All Files' },'Abrir US Carotida',inicFolder);
    dirImg= strcat(PathName,filename);
    k = strfind(filename,'.avi');
    isImage = isempty(k)
    
    if isImage
        imgRGB = imread(dirImg);
        originalUS = double(imgRGB(:,:,1))/255;
        dirImg = strcat(dirImg,'_user_',activeUser);
    else
        [ frameSelected, nroFrameSelected ] = functionVideoBrowser( dirImg );
        
        originalUS = frameSelected(:,:,1);
        dirImg = strcat(dirImg,'_frame_',num2str(nroFrameSelected),'_user_',activeUser);
    end
    
    %Guardar en lastUsedFolder asi lo vuelve a abrir
    fid=fopen(inicFolderFile,'w');
    fprintf(fid,'%s\n%s',PathName,activeUser);
    fclose(fid);
    
    %dejar solo la parte util de la imagen
    parteUtilDeLaImagen = [246 125 460 485];
    originalUSCrop = imcrop(originalUS, parteUtilDeLaImagen);
    
    panelTool(originalUSCrop);
end

clear all; close all; clc;