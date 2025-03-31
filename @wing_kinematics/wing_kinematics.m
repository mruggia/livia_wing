classdef wing_kinematics < handle & matlab.mixin.Copyable

properties
    
    file     % file info of the loaded file
    const    % constants
    scan     % body 3d scan models
    T        % homogeneous transforms
    r        % location vectors
    mask     % mask for uniformly sampled transforms
    eul_rng  % joint movement ranges in euler coordinates
    axs_rng  % joint movement ranges as axis regions

end
methods

% plot joint range in axis representation with interactive controls
plot_axis_ranges(o)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% utility functions

function ret = ui_create_text(~, fig, name, pos)
    ret = uicontrol('parent',fig, 'style','text', 'string',name, 'Units','normalized', 'Position',pos, 'FontSize',11, 'BackgroundColor',[1,1,1]);
end
function ret = ui_create_slider(~, fig, val,min,max, pos)
    ret = uicontrol('parent',fig, 'style','slider', 'Value',val, 'min',min, 'max',max, 'Units','normalized', 'Position',pos, 'BackgroundColor',[1,1,1]);
end
function ret = ui_create_radiogroup(~, fig, pos)
    ret = uibuttongroup(fig, 'Units','normalized', 'BackgroundColor',[1 1 1],'BorderColor',[1 1 1], 'Position',pos);
end
function ret = ui_create_radio(~, parent, name, position)
    ret = uiradiobutton(parent,'Text',name,   'Position',[10 10+position*20 500 20], 'FontSize', 14);
end

function plot_points(o, ax, points, style, color)
    if ( size(points,1)==4 && size(points,2)==4 && size(points,3)>=1 )
        if ~exist('color','var')
            plot3( ax, squeeze(points(1,4,:)), squeeze(points(2,4,:)), squeeze(points(3,4,:)), style, LineWidth=o.const.linewidth)
        else
            plot3( ax, squeeze(points(1,4,:)), squeeze(points(2,4,:)), squeeze(points(3,4,:)), style, Color=color, LineWidth=o.const.linewidth)
        end
    elseif ( size(points,1)==3 && size(points,3)>1 )
        if ~exist('color','var')
            plot3( ax, squeeze(points(1,1,:)), squeeze(points(2,:,:)), squeeze(points(3,:,:)), style, LineWidth=o.const.linewidth)
        else
            plot3( ax, squeeze(points(1,1,:)), squeeze(points(2,:,:)), squeeze(points(3,:,:)), style, Color=color, LineWidth=o.const.linewidth)
        end
    elseif ( size(points,1)==3 && size(points,2)>=1 && size(points,3)==1 )
        if ~exist('color','var')
            plot3( ax, points(1,:), points(2,:), points(3,:), style, LineWidth=o.const.linewidth)
        else
            plot3( ax, points(1,:), points(2,:), points(3,:), style, Color=color, LineWidth=o.const.linewidth)
        end
    end
end

function plot_frame(o, ax, T, l)
    if ~exist('l','var')
        l = 8;
    end
    if size(T,2) == 4 
        w = T(1:3,4); 
    else
        w = [0;0;0];
    end
    x = l*T(1:3,1) + w;
    y = l*T(1:3,2) + w;
    z = l*T(1:3,3) + w;
    plot3(ax, [w(1),x(1)],[w(2),x(2)],[w(3),x(3)], Color=o.const.color.x, LineWidth=o.const.linewidth);
    plot3(ax, [w(1),y(1)],[w(2),y(2)],[w(3),y(3)], Color=o.const.color.y, LineWidth=o.const.linewidth);
    plot3(ax, [w(1),z(1)],[w(2),z(2)],[w(3),z(3)], Color=o.const.color.z, LineWidth=o.const.linewidth);
end

function plot_scan(~, ax, scan_t, scan_v, T)
    scan_v = T(1:3,1:3,1)*scan_v+T(1:3,4,1);
    ptch = patch(ax, 'Faces', scan_t', 'Vertices',scan_v', 'FaceColor',[0.9 0.9 0.9], 'EdgeColor','none');
    material(ptch, [0.65 0.4 0]);
end

function plot_finalize_scan(~, ax, NameValueArgs)
    arguments
        ~
        ax
        NameValueArgs.axes     double = true
        NameValueArgs.overlay  double = true
        NameValueArgs.zoom     double = 0.0
    end
    
    axis(ax, 'vis3d');
    daspect(ax, [1 1 1]);
    light(ax, Color=[1,1,1], Style='infinite', Position=[1,0,1]);
    lighting(ax, 'gouraud');

    if NameValueArgs.zoom ~= 0.0
        zoom = NameValueArgs.zoom;
        set(ax, "Position",[-(zoom-1)/2,-(zoom-1)/2,zoom,zoom]);
    end
    
    if NameValueArgs.axes
        ax.XRuler.FirstCrossoverValue = 0; ax.XRuler.SecondCrossoverValue = 0;
        ax.YRuler.FirstCrossoverValue = 0; ax.YRuler.SecondCrossoverValue = 0;
        ax.ZRuler.FirstCrossoverValue = 0; ax.ZRuler.SecondCrossoverValue = 0;
        ticks = min([ax.XTick(2)-ax.XTick(1), ax.XTick(2)-ax.XTick(1), ax.ZTick(2)-ax.ZTick(1)]);
        ax.XTick = (ax.XLim(1):ticks:ax.XLim(2)); ax.XTickLabel = {};
        ax.YTick = (ax.YLim(1):ticks:ax.YLim(2)); ax.YTickLabel = {};
        ax.ZTick = (ax.ZLim(1):ticks:ax.ZLim(2)); ax.ZTickLabel = {};
        set(ax, Clipping="off"); grid(ax,"off"); box(ax,"off");
    end
    
    if NameValueArgs.overlay
        ax2 = copyobj(ax,ax.Parent);
        linkaxes([ax,ax2]);
        links = getappdata(gcf, 'StoreTheLink');
        links = {links, linkprop([ax, ax2],{'CameraUpVector', 'CameraPosition', 'CameraTarget'})};
        setappdata(gcf, 'StoreTheLink', links);
        set(ax2, Visible='off');  set(ax2, Clipping="off");
        cla(ax2); axes(ax2);
    end

end

end
end