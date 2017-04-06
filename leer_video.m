 vidObj = VideoReader('C:\Users\Usuario\Desktop\escritorio\cosas_diaz\img_diaz\MyLabExport\C-----------_20160606195700_1957140.avi');
 
        % Specify that reading should start at 0.5 seconds from the
        % beginning.
        vidObj.CurrentTime = 0;
 
        % Create an axes
        currAxes = axes;
        iter = 1;
        % Read video frames until available
        while hasFrame(vidObj)
            iter = iter + 1;
            vidFrame = readFrame(vidObj);
            image(vidFrame, 'Parent', currAxes);
            currAxes.Visible = 'off';
            pause(1/vidObj.FrameRate);
            imwrite(vidFrame,strcat(num2str(iter),'.png'));
        end