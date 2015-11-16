classdef matsurfer
    
    properties
        subject
        subjects_dir
        rootdir
        lh
        rh
        overlay
        stats
        labels
        figures
    end
    
    methods
        function obj=matsurfer(subj,varargin)
            
            if nargin>1
                sdir=varargin{1};
            else
                sdir=getenv('SUBJECTS_DIR');
            end
                
            if isempty(sdir)
                sdir='/Applications/freesurfer/subjects';
            end
            
            fprintf('Assuming subjects directory: %s...\n',sdir);
            
            if ~exist(fullfile(sdir,subj),'dir')
                error('Subject not found!');
            end
            
            
            obj.subjects_dir=sdir;
            obj.subject=subj;
            obj.figures=struct;
            
            obj.rootdir=fullfile(obj.subjects_dir,subj);
            
            obj.lh=struct;
            obj.rh=struct;
            
            obj=load_surf(obj);
            obj=load_annot(obj);
            obj=new_annot(obj,'lh','blank');
            obj=new_annot(obj,'rh','blank');
            
            
            obj=load_curv(obj);
            
            if ~strcmp(subj,'fsaverage');
            obj=load_avg(obj,'lh');
            obj=load_avg(obj,'rh');
            end
            
            obj.labels=obj.lh.annot.aparc.ct.struct_names;
            
            
        end
        
        
        function v=getlabel(obj,hemi,label,varargin)
           
           labelrow=find(strcmp(label,obj.labels));
           
           annotcolor=obj.(hemi).annot.aparc.ct.table(labelrow,5);
           
           v=obj.(hemi).annot.aparc.vertices(obj.(hemi).annot.aparc.label==annotcolor)+1;
            
            
        end
        
        
        function obj=new_annot(obj,hemi,annotname)
           
            obj.(hemi).annot.(annotname)=struct;
            obj.(hemi).annot.(annotname).vertices=obj.(hemi).annot.aparc.vertices;
%             obj.(hemi).annot.(annotname).label=zeros(length(obj.(hemi).annot.aparc.vertices),1);
            
            allgray=rgb2fscolor(repmat([128 128 128],length(obj.(hemi).annot.aparc.vertices),1));
            obj.(hemi).annot.(annotname).label=allgray;
            
            obj.(hemi).annot.(annotname).ct=obj.(hemi).annot.aparc.ct;
            obj.(hemi).annot.(annotname).ct.table= obj.(hemi).annot.(annotname).ct.table*.0;
            
        end
        
        
        function obj=update_annot(obj,hemi,annot,colortable)
            
            %initialize the color table for everything to be gray
            obj.(hemi).annot.(annot).ct.table(:,1)=128;
            obj.(hemi).annot.(annot).ct.table(:,2)=128;
            obj.(hemi).annot.(annot).ct.table(:,3)=128;
            
            
            if size(colortable.colors,1)==1 && length(colortable.names)>1
                colortable.colors=repmat(colortable.colors(1,:),length(colortable.names),1);
            end
            
            
            %loop through all the given name-color pairs and write them to
            %the new color table
            for i=1:length(colortable.names)
                
                ctrow=find(strcmp(colortable.names{i},obj.(hemi).annot.(annot).ct.struct_names));
                
                obj.(hemi).annot.(annot).ct.table(ctrow,1:3)=colortable.colors(i,:);
                              
            end
             
            %convert the rgb values to the integers
             obj.(hemi).annot.(annot).ct.table(:,5)=rgb2fscolor(obj.(hemi).annot.(annot).ct.table(:,1:3));
             
             
             %then loop through the color table and color all the regions
             for i=1:size(obj.(hemi).annot.aparc.ct.struct_names)
                    v=getlabel(obj,hemi,obj.(hemi).annot.aparc.ct.struct_names{i});
                    obj.(hemi).annot.(annot).label(v)=obj.(hemi).annot.(annot).ct.table(i,5);
                
             end
            
        end
        
        function obj=load_annot(obj,varargin)
            
            lhfile=fullfile(obj.rootdir,'label','lh.aparc.annot');
            rhfile=fullfile(obj.rootdir,'label','rh.aparc.annot');
            
            
            [lh_vertices,lh_label,lh_colortable]=read_annotation(lhfile);
            [rh_vertices,rh_label,rh_colortable]=read_annotation(rhfile);
            
            obj.lh.annot.aparc=struct;
            obj.rh.annot.aparc=struct;
            
            obj.lh.annot.aparc.vertices=lh_vertices;
            obj.lh.annot.aparc.label=lh_label;
            obj.lh.annot.aparc.ct=lh_colortable;
            
            obj.rh.annot.aparc.vertices=rh_vertices;
            obj.rh.annot.aparc.label=rh_label;
            obj.rh.annot.aparc.ct=rh_colortable;
        end
        
        
        function obj=load_surf(obj,varargin)
            
            lhfile=fullfile(obj.rootdir,'surf','lh.pial');
            rhfile=fullfile(obj.rootdir,'surf','rh.pial');
            
            obj.lh.surf=struct;
            obj.rh.surf=struct;
            obj.lh.surf.pial=struct;
            obj.lh.surf.inflated=struct;
            obj.lh.surf.white=struct;
            
            
            [obj.lh.surf.pial.vertices, obj.lh.surf.pial.faces] = read_surf(lhfile);
            [obj.rh.surf.pial.vertices, obj.rh.surf.pial.faces] = read_surf(rhfile);
            
            
            lhfile=fullfile(obj.rootdir,'surf','lh.inflated');
            rhfile=fullfile(obj.rootdir,'surf','rh.inflated');
            
            [obj.lh.surf.inflated.vertices, obj.lh.surf.inflated.faces] = read_surf(lhfile);
            [obj.rh.surf.inflated.vertices, obj.rh.surf.inflated.faces] = read_surf(rhfile);
            
            lhfile=fullfile(obj.rootdir,'surf','lh.white');
            rhfile=fullfile(obj.rootdir,'surf','rh.white');
            
            [obj.lh.surf.white.vertices, obj.lh.surf.white.faces] = read_surf(lhfile);
            [obj.rh.surf.white.vertices, obj.rh.surf.white.faces] = read_surf(rhfile);
            
        end
        
        function obj=load_stats(obj,varargin)
            
            
            
            
            
        end
        
        
        function obj=load_curv(obj,varargin)
            
            %load thickness data
            lhfile=fullfile(obj.rootdir,'surf','lh.thickness');
            rhfile=fullfile(obj.rootdir,'surf','rh.thickness');
            
            obj.lh.stats.thickness=struct;
            obj.rh.stats.thickness=struct;
            
            [lhthick,~] = read_curv(lhfile);
            [rhthick,~] = read_curv(rhfile);
            
            obj.lh.stats.thickness=lhthick;
            obj.rh.stats.thickness=rhthick;
            
            %load area data
            lhfile=fullfile(obj.rootdir,'surf','lh.area');
            rhfile=fullfile(obj.rootdir,'surf','rh.area');
            
            obj.lh.stats.area=struct;
            obj.rh.stats.area=struct;
            
            [lharea,~] = read_curv(lhfile);
            [rharea,~] = read_curv(rhfile);
            
            obj.lh.stats.area=lharea;
            obj.rh.stats.area=rharea;
            
            %load curvature data
            lhfile=fullfile(obj.rootdir,'surf','lh.curv');
            rhfile=fullfile(obj.rootdir,'surf','rh.curv');
            
            obj.lh.stats.curv=struct;
            obj.rh.stats.curv=struct;
            
            [lhcurv,~] = read_curv(lhfile);
            [rhcurv,~] = read_curv(rhfile);
            
            obj.lh.stats.curv=lhcurv;
            obj.rh.stats.curv=rhcurv;

            
             
            
        end
        
        function obj=setup_figure(obj,hemi,varargin)
            
            if isempty(varargin)
                surftype='pial';
            else
                surftype=varargin{1};
            end
            
            msh=struct;
            msh.vertices=obj.(hemi).surf.(surftype).vertices;
            msh.faces=obj.(hemi).surf.(surftype).faces;
            msh.faces=msh.faces+1;
            
            msh.FaceVertexCData=fscolor2rgb(obj.(hemi).annot.aparc.label);
%         
            p=plotbrain(msh);
            
            obj.figures.data=msh;
            obj.figures.hemi=hemi;
            obj.figures.handle=p;
            
        end
        
        
        function obj=change_surftype(obj,newtype)
           
            newtype=lower(newtype);
            if ~ismember(newtype,{'pial','inflated','white'})
                return
            else
                h=obj.figures.hanle;
                hemi=obj.figures.hemi;
                set(h,'Vertices')=obj.(hemi).surf.(newtype).vertices;
                set(h,'Faces')=obj.(hemi).surf.(newtype).faces;
            end
            
        end
        
        function display_fsaverage(obj,hemi,stat,varargin)
           
            
            temp=matsurfer('fsaverage');
            
            temp.(hemi).stats.(stat)=obj.(hemi).stats.(stat);
            
            temp=setup_figure(temp,hemi,'pial');
            
            add_overlay(temp,stat);
            
            
            
        end
        
        
        function obj=load_avg(obj,hemi,varargin)
            
             %load fsaverage standard-space thickness data 
            lhfile=fullfile(obj.rootdir,'surf','lh.thickness.fwhm10.fsaverage.mgh');
            rhfile=fullfile(obj.rootdir,'surf','rh.thickness.fwhm10.fsaverage.mgh');
            
            obj.lh.stats.thickfsaverage10=struct;
            obj.rh.stats.thickfsaverage10=struct;
            
            [lhcurv,~] = load_mgh(lhfile);
            [rhcurv,~] = load_mgh(rhfile);
            
            obj.lh.stats.thickfsaverage10=lhcurv;
            obj.rh.stats.thickfsaverage10=rhcurv;
            
        end
        
        function add_overlay(obj,val,varargin)
            
            h=obj.figures.handle;
            hemi=obj.figures.hemi;
            
            if isfield(obj.(hemi).stats,val)
                
                set(h,'FaceVertexCData',obj.(hemi).stats.(val));
                colorbar;
                set(h,'CDataMapping','scaled');
                caxis([min(obj.(hemi).stats.(val)),max(obj.(hemi).stats.(val))]);
            elseif isfield(obj.(hemi).annot,val)
                set(h,'FaceVertexCData',fscolor2rgb(obj.(hemi).annot.(val).label));
            end
            
            
            
           
            
            
        end
        
        function obj=label2stats(obj,hemi,valtable,name,varargin)
           
            obj.(hemi).stats.(name)=zeros(length(obj.(hemi).stats.thickness),1);
            
          for i=1:length(valtable.names)
             
              v=getlabel(obj,hemi,valtable.names{i});
              
              obj.(hemi).stats.(name)(v)=valtable.values(i);              
          end
            
            
            
        end
        
        
        
    end
    
    
    
end