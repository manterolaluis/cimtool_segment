global language;
set(handles.textDetails,'FontSize',12);
set(handles.textDetails,'String','');

spanish.user = 'User';
spanish.stage = 'Stage';
spanish.segmentation = 'Segmentation';
spanish.ready = 'Ready';
spanish.redo = 'Redo';
spanish.export = 'Export';

spanish.openFile = 'Open DICOM file';
spanish.errorFile = 'File not supported';
spanish.checkLIAnterior = 'Anterior Lumen Intima';
spanish.checkLIPosterior = 'Posterior Lumen Intima';
spanish.checkDiameterLimits = 'Arterial Diameter';
spanish.checkIMTZoom = 'IMT zoom';
spanish.WarningMeditions = 'Insuficient Measurements';
spanish.checkLI = 'Lumen-intima';
spanish.checkMA = 'Media-Adventitia';
spanish.checkVisibleIntima = 'Visible Intima';
spanish.checkEdgeIntima = 'Intima';

spanish.explanationLIAnterior = 'Click points over near lumen-intima interface. Then, press enter';
spanish.explanationLIPosterior = 'Click points over far lumen-intima interface. Then, press enter';
spanish.explanationDiameterLimits = 'Click on start and end of the segment of interest for arterial diameter';
spanish.explanationZoomWall = 'Click and drag the mouse to zoom over posterior wall. Then, double click and enter';
spanish.explanationLI = 'Click over lumen-intima interface. Then, press enter';
spanish.explanationMA = 'Click over media-adventitia interface. Then, press enter';
spanish.explanationIntimaLimits = 'Click on start and end point of a visible intima segment';
spanish.explanationIntima = 'Click over intima-media interface. Then, press Enter';

language = spanish;

%Set descriptions

set(handles.text2, 'String', language.user);
set(handles.text1, 'String', language.segmentation);
set(handles.pushbuttonAbrir, 'String', language.openFile);
set(handles.text4, 'String', language.stage);
set(handles.checkboxLIAnterior, 'String', language.checkLIAnterior);
set(handles.checkboxLIPosterior, 'String', language.checkLIPosterior);
set(handles.checkboxDiamLimits, 'String', language.checkDiameterLimits);
set(handles.checkboxZoom, 'String', language.checkIMTZoom);
set(handles.checkboxLI, 'String', language.checkLI);
set(handles.checkboxMA, 'String', language.checkMA);
set(handles.checkboxLimitsIntima, 'String', language.checkVisibleIntima);
set(handles.checkboxEdgeIntima, 'String', language.checkEdgeIntima);
set(handles.pushbuttonRedo, 'String', language.redo);
set(handles.pushbuttonExport, 'String', language.export);