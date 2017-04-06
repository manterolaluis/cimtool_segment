%Apertura del archivo
clear all; close all; clc;
currentFolder = pwd
%Archivo donde guardo la ultima direccion
inicFolderFile = strcat(currentFolder,'\lastUsedFolder.txt');
inicFolder = fileread(inicFolderFile);
[filename,PathName] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Abrir US Carotida',inicFolder)
dirImg= strcat(PathName,filename);
imgRGB = imread(dirImg);
imgGray1 = double(imgRGB(:,:,1))/255;
%Guardar en lastUsedFolder asi lo vuelve a abrir
fid=fopen(inicFolderFile,'w');
fprintf(fid,'%s',PathName);
fclose(fid);
%%
%Seleccionar region a ampliar
figure('Name','Seleccionar region a ampliar y doble click'); imshow(imgGray1);
title('Seleccionar region a ampliar y doble click');
rect = imrect;
position = wait(rect);
%%
zoomPared = imcrop(imgGray1,position);
%Agrando la imagen proporcionalmente a sus dimensiones, que no la reescale
[hRegion, wRegion] = size(zoomPared);
%Seleccionar placa
hFig = figure('Name','Seleccionar puntos de LI y presionar enter', 'Position',...
    [500, 500, wRegion*5, hRegion*5]);
imshow(zoomPared,'InitialMagnification','fit');
title('Seleccionar puntos de LI y presionar enter');
[xLIManual, yLIManual] = getpts(hFig);

dibujar = false;
[xLI,yLI,GsmoothAbs] = functionSegmentEdgeCarotid( xLIManual, yLIManual, zoomPared, dibujar );

hFig = figure('Name','Seleccionar puntos de MA y presionar enter', 'Position',...
    [500, 500, wRegion*5, hRegion*5]);
imshow(zoomPared,'InitialMagnification','fit');
title('Seleccionar puntos de MA y presionar enter');
[xMAManual, yMAManual] = getpts(hFig);

[xMA,yMA,GsmoothAbs] = functionSegmentEdgeCarotid( xMAManual, yMAManual, zoomPared, dibujar );

scriptDrawSegmentation;

%%
interfacePolarLI = functionInterfaceToImg( [xLI',yLI'] , hRegion, wRegion);
maskLI = functionLabelizarPixelPolar( interfacePolarLI );

interfacePolarMA = functionInterfaceToImg( [xMA',yMA'] , hRegion, wRegion);
maskMA = functionLabelizarPixelPolar( interfacePolarMA );

paredMask = xor(maskLI,maskMA);
figure, imshow(paredMask);

hFig = figure('Name','Features Placa', 'Position', [100, 100, 1500, 700]);
subplot(3,5,1),imshow(zoomPared);title('Placa');
hold on;
plot(xLI,yLI,'r');
plot(xMA,yMA,'r');
hold off;

[iLI,iMACorrespondants,imtLIPxMean,imtLIPxStd,imtLIPxMin,imtLIPxMax] =...
    functionIMT( xLI,yLI,xMA,yMA );
[iMA,iLICorrespondants,imtMAPxMean,imtMAPxStd,imtMAPxMin,imtMAPxMax] =...
    functionIMT( xMA,yMA,xLI,yLI );

%Normalizacion como en Sztajzel2005 Loizou2012
grayLumen = 0/255;
grayAdventitia = 190/255;
zoomParedNormalized = functionUSNormalization(zoomPared, maskLI, not(maskMA),...
    grayLumen, grayAdventitia);

placa = zoomParedNormalized(paredMask);
[hPlaca,wPlaca]=size(maskMA);

     %Histograma
[ histogramaGray,histNormGray,rangosGray,marcasDeClaseGray ] = functionHistogramaGray( placa );
functionDrawHistogram( histNormGray, marcasDeClaseGray, hFig, 2, 'Grises' );

%GLCM
window = 7;
[haralickSquare] = functionHaralickTextureFeatures( zoomParedNormalized, window, wPlaca, hPlaca );

[ histogramaEntropy,histNormEntropy,rangosEntropy,marcasDeClaseEntropy ] =...
    functionHistogramaEntropy( haralickSquare.entropia(paredMask) );
functionDrawHistogram( histNormEntropy, marcasDeClaseEntropy, hFig, 4, 'Entropia' );

[ histogramaContrast,histNormContrast,rangosContrast,marcasDeClaseContrast ] =...
    functionHistogramaContrast( haralickSquare.contrast(paredMask));
functionDrawHistogram( histNormContrast, marcasDeClaseContrast, hFig, 6, 'Contraste' );

[haralickRadial] = functionHaralickTextureFeaturesRadial( zoomParedNormalized, window, wPlaca, hPlaca );

[ histogramaEntropyRadial,histNormEntropyRadial,rangosEntropyRadial,marcasDeClaseEntropyRadial ]...
    = functionHistogramaEntropy( haralickRadial.entropiaRadial(paredMask));
functionDrawHistogram( histNormEntropyRadial, marcasDeClaseEntropyRadial, hFig, 8, 'Ent Radial' );

[ histogramaContrastRadial,histNormContrastRadial,rangosContrastRadial,marcasDeClaseContrastRadial ] =...
    functionHistogramaContrast( haralickRadial.contrastRadial(paredMask) );
functionDrawHistogram( histNormContrastRadial, marcasDeClaseContrastRadial, hFig, 10, 'Const Radial' );

[ MNGs, MNGxLonja ] = functionCraiem2009PlacaIrregular( zoomParedNormalized, paredMask );
subplot(3,5,11),imshow(MNGs);title('Mediana por lonja - Craiem 2009');
Craiem2009 = MNGxLonja;
subplot(3,5,12),plot(MNGxLonja);
axis([0 length(MNGxLonja)+1 0/255 145/255]); %Ejes de la Fig 3 de Craiem 2009
title('Curva de profundidad - Craiem 2009');

%Sztajzel 2005
[ canalR,canalG,canalB, isHomogenea, isHeterogenea ] = functionSztajzel2005( zoomParedNormalized, paredMask );
subplot(3,5,13),imshow(cat(3,canalR,canalG,canalB));title('Sztajzel 2005');

export_fig(strcat(dirImg,'_features.png'));

%exportar bien


%%
%Estadisticas

cnames = {'Gray','Entropy','Contrast','Ent Rad','Con Rad','Sztajzel - Homogenea','Sztajzel - Heterogenea'};
rnames = {'Mean','Std','Median'};

meanPlaca = mean(placa(:)); stdPlaca = std(placa(:)); medianPlaca = median(placa(:));

meanEntropia = mean(haralickSquare.entropia(:));
stdEntropia = std(haralickSquare.entropia(:)); medianEntropia = median(haralickSquare.entropia(:));

meanContraste = mean(haralickSquare.contrast(:));
stdContraste = std(haralickSquare.contrast(:)); medianContraste = median(haralickSquare.contrast(:));

meanEntropiaRadial = mean(haralickRadial.entropiaRadial(:));
stdEntropiaRadial = std(haralickRadial.entropiaRadial(:));
medianEntropiaRadial = median(haralickRadial.entropiaRadial(:));

meanContrasteRadial = mean(haralickRadial.contrastRadial(:));
stdContrasteRadial = std(haralickRadial.contrastRadial(:));
medianContrasteRadial = median(haralickRadial.contrastRadial(:));

matrizEstadisticas = [meanPlaca, stdPlaca, medianPlaca;
    meanEntropia,stdEntropia,medianEntropia;...
meanContraste,stdContraste,medianContraste;...
meanEntropiaRadial, stdEntropiaRadial, medianEntropiaRadial;...
meanContrasteRadial,stdContrasteRadial,medianContrasteRadial;
double(isHomogenea), double(isHomogenea), double(isHomogenea);
double(isHeterogenea),double(isHeterogenea),double(isHeterogenea)]';

hFigureEstadisticas = figure('Name','Estadisticas','Position', [100 100 1052 500]);

t = uitable(hFigureEstadisticas, 'Data',matrizEstadisticas,...
            'ColumnName',cnames,... 
            'RowName',rnames,'ColumnWidth',{80},'Position',[20 20 1000 400]);

export_fig(strcat(dirImg,'_estadisticas.png'));

%Agregar los input de el

%guardar variables workspace
save(strcat(dirImg,'_features.mat'),'zoomPared','zoomParedNormalized','placa',...
    'meanPlaca', 'stdPlaca', 'medianPlaca', 'meanEntropia','stdEntropia',...
'medianEntropia','meanContraste','stdContraste','medianContraste', 'meanEntropiaRadial', 'stdEntropiaRadial',...
 'medianEntropiaRadial', 'meanContrasteRadial','stdContrasteRadial','medianContrasteRadial',...
 'isHomogenea','isHeterogenea', 'Craiem2009',...
 'histogramaGray','histNormGray','rangosGray','marcasDeClaseGray',...
 'histogramaEntropy','histNormEntropy','rangosEntropy','marcasDeClaseEntropy',...
 'histogramaContrast','histNormContrast','rangosContrast','marcasDeClaseContrast',...
 'histogramaEntropyRadial','histNormEntropyRadial','rangosEntropyRadial','marcasDeClaseEntropyRadial',...
 'histogramaContrastRadial','histNormContrastRadial','rangosContrastRadial','marcasDeClaseContrastRadial',...
 'xLI','yLI','xMA','yMA','paredMask','imtLIPxMean','imtLIPxStd','imtLIPxMin','imtLIPxMax','imtMAPxMean','imtMAPxStd',...
 'imtMAPxMin','imtMAPxMax');
