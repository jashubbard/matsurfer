%%

clear 
clc

%%
rootdir='~/Desktop/fs/0002053';

[code, name, rgbv] = read_fscolorlut; %reads in the Freesurfer default color lookup table, if helpful

%%

measure='thickness';
hemi='lh';

names=brain_subset.Properties.VarNames';
names=names(cell2mat(cellfun(@(x) ~isempty(regexp(x,hemi)),names,'UniformOutput',false)));
names=names(cell2mat(cellfun(@(x) ~isempty(regexp(x,measure)),names,'UniformOutput',false)));
names=strrep(names,measure,'');
names=strrep(names,hemi,'');
names=strrep(names,'_','');

loadings=(XL)/max(XL(:)).*255; %to rescale for coloring
plot(loadings)


%%

cbins=linspace(min(loadings(:)),max(loadings(:)),50);
colors=fix(jet(length(cbins)).*255)



%%
cd([rootdir filesep 'label']);
[lh_verticies,lh_label,lh_colortable]=read_annotation('lh.aparc.annot');
[rh_verticies,rh_label,rh_colortable]=read_annotation('rh.aparc.annot');

lh_newct=lh_colortable;
lh_newct.table=lh_newct.table.*0;

%%
%converts freesurfer integer value back in to r,g,b
b=idivide(int32(rh_label),2^16);
resid=rem(int32(rh_label),2^16);
g=idivide(int32(resid),2^8);
r=rem(int32(resid),2^8);


close all;
cd ~/Desktop/fs/0002053/surf
mesh='rh.pial'
[srf.vertices, srf.faces] = read_surf(mesh);
srf.faces=srf.faces+1;

srf.FaceVertexCData=double(horzcat(r,g,b))./255;

h=figure_wire(srf,'none',[.5 .5 .5]); 

% for i=1:72
%     camorbit(gca,10,0);
%     drawnow;
% end


%%

set(h,'CData',randsample(10,length(srf.faces),1))

%%


mesh='lh.pial'
[srf.vertices, srf.faces] = read_surf(mesh);
srf.faces=srf.faces+1;
h=figure_wire(srf,'blue','blue');
hold off;

%%

test.vertcies=[1 2 3 4 5 6];
test.faces=[1 2 3 4 5 6];
patch(test)


%%

f=1; %factor number (1-3)

for i=1:length(names)
   ctrow=strcmp(lh_newct.struct_names,names{i});
   
   colorbin=min(find(~(loadings(i,f)>cbins))); %first bin where the value is greater than the bin amount
   
   lh_newct.table(ctrow,1:3)=colors(colorbin,:); 
    
end
%%
%testing for now -- use factor loadings in the future
% r=randsample(1:255,36,1)';
% g=randsample(1:255,36,1)';
% b=randsample(1:255,36,1)';

r=lh_newct.table(:,1);
g=lh_newct.table(:,2);
b=lh_newct.table(:,3);
flag=lh_newct.table(:,4);

lh_newct.table(:,5)=r + g*2^8 + b*2^16 + flag*2^24;

for i=1:size(lh_colortable.table,1)
   
    lh_label(lh_label==lh_colortable.table(i,5))=lh_newct.table(i,5);
   
end




write_annotation('lh.test.annot',lh_verticies,lh_label,lh_newct)

% write_annotation(filename, vertices, label, ct)
%
% Only writes version 2...
%
% vertices expected to be simply from 0 to number of vertices - 1;
% label is the vector of annotation
%
% ct is a struct
% ct.numEntries = number of Entries
% ct.orig_tab = name of original ct
% ct.struct_names = list of structure names (e.g. central sulcus and so on)
% ct.table = n x 5 matrix. 1st column is r, 2nd column is g, 3rd column
% is b, 4th column is flag, 5th column is resultant integer values
% calculated from r + g*2^8 + b*2^16 + flag*2^24. flag expected to be all 0