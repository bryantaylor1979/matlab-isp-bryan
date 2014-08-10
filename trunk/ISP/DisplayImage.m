function [h] = DisplayImage(image,Name)
h.figure = figure;
h.image = imshow(image);      %display image
h.axis = gca;
h.scrollpanel = imscrollpanel(h.figure,h.image);

set(h.figure,'Name',Name);
Lum = 0.3;
set(h.figure,'Color',[Lum,Lum,Lum])
set(h.figure,'NumberTitle','off');
end