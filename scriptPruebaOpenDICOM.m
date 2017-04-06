info = dicominfo('CT-MONO2-16-ankle.dcm');
Y = dicomread(info);
figure, imshow(Y);

%%

[filename,PathName] = uigetfile({'*','All DICOM Files';...
    '*.*','All Files' },'Abrir US Carotida');
dirImg= strcat(PathName,filename);
try
    info = dicominfo(dirImg);
    %Voy a seguir si es un archivo de imagen y no un directorio
    physicalDeltaX = info.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
catch
    physicalDeltaX = -1;
end

if physicalDeltaX > 0
    frames= dicomread(info);
    frames = double(frames)./255;
    'Lei la imagen DICOM'
    img = frames(:,:,1,1);
    size(img)
    figure, imshow(img);
    parteUtilDeLaImagen = [250 85 450 450];
    figure, imshow(imcrop(img,parteUtilDeLaImagen));
else
    'No es un archivo de imagen DICOM'
    
end