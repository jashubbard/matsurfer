 function p=plotbrain(msh,varargin)

            h=figure;

            p=patch(msh);
            
            if nargin>2 && strcmp(varargin{1},'scaled')
                set(p,'CDataMapping','scaled');
                caxis([min(varargin{2}), max(varargin{2})]);
            else
                set(p,'CDataMapping','direct');
            end
            
            
            
            %set up coloring and basic lighting properties
            set(p,'FaceColor','flat','EdgeColor','none');
            set(p,'BackFaceLighting','lit');
            set(p,'AmbientStrength',0.3);
            lighting gouraud; 
            
            if isempty(varargin)
            
            %setting viewing angle, etc
            daspect([1 1 1]);
            view(90,20);
            axis vis3d
            
            %add some lights
            light('Position',[20 0 20],'Style','infinite'); %OFC area
            light('Position',[0 0 20],'Style','infinite'); %occipital area
            light('Position',[0 0 -20],'Style','infinite'); %top/parietal
            light('Position',[-20 0 -10],'Style','infinite'); %medial
            
            
            
            
            background='black';
            whitebg(gcf,background);
            set(gcf,'Color',background,'InvertHardcopy','off');
   
            %show axes
            % xlabel('X'); ylabel('Y'); zlabel('Z');
            %or not..
            axis off;
            end
            
            rotate3d on; %for rotating with mouse
          
        end
        