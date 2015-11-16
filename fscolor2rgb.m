function rgb=fscolor2rgb(colorvector)
%takes integer values used in freesurfer annotation/label files and
%converts them to rgb values (0-255,0-255,0-255)
%according to the calculation: r + g*2^8 + b*2^16

%converts freesurfer integer value back in to r,g,b
b=idivide(int32(colorvector),2^16);
resid=rem(int32(colorvector),2^16);
g=idivide(int32(resid),2^8);
r=rem(int32(resid),2^8);

rgb=double(horzcat(r,g,b))./255;




end