function brain=matsurfer_display(hemi,data,varargin)

if size(data,1)==1
    data=data';
end


if ~isempty(varargin)
    type=varargin{1};
else
    type='pial';
end



brain=matsurfer('fsaverage');

brain=setup_figure(brain,hemi,type);
brain.(hemi).stats.overlay=data;

add_overlay(brain,'overlay');


end