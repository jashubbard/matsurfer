function fscolor=rgb2fscolor(rgb)
%takes an nx3 matrix of rgb values (0-255) and converts to freesurfer's
%integer format, according to the formula: r + g*2^8 + b*2^16
%returns an nx1 vector

r=rgb(:,1);
g=rgb(:,2);
b=rgb(:,3);

fscolor=r + g*2^8 + b*2^16; 


end