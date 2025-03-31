
% plot joint range in axis representation with interactive controls
function plot_axis_ranges(o)
    
    % layout grid for ui window
    col_name = 2; col_axis = 3; col_value = 4; col_slider = 5; col_ctrl = 6; col_rng = 7; col_pnt = 8;
    function pos = ui_get_pos(x,y, u,v)
        grid_x = [
            0.5, ...    % separator
            1,1,1, ...  % roll, pitch, yaw
            0.5, ...    % separator
            1,1,1, ...  % roll, pitch, yaw
            0.5, ...    % separator
            1,1,1, ...  % roll, pitch, yaw
            0.5         % separator
        ];
        grid_y = [
            0.5, ...    % separator
            1, ...      % name
            1, ...      % axis
            1, ...      % value
            14, ...     % slider
            3.5, ...    % control selection
            4.5, ...    % disp rng selection
            3.5, ...    % disp pnt selection
            0.5         % separator
        ];
        if nargin == 2, u = 1; v = 1; end
        grid_x = [0, cumsum(grid_x ./ sum(grid_x)) ];
        grid_y = [0, cumsum(grid_y ./ sum(grid_y)) ];
        pos = [grid_x(x), grid_y(y), grid_x(x+u)-grid_x(x), grid_y(y+v)-grid_y(y)];
        pos = [pos(1), 1-pos(2)-pos(4), pos(3), pos(4)];
    end
    
    % create ui control window
    ui.ctl = uifigure('Name', 'wing axis range plot controls', 'Position', [10 60 600 600], 'WindowStyle','alwaysontop');
    name  = {    'j3',    'j2',       'j1' };
    title = { 'wrist', 'elbow', 'shoulder' };
    row   = [       2,       6,         10 ];
    for j = 1:3
        % text labels
        o.ui_create_text(ui.ctl, title{j}, ui_get_pos(row(j), col_name,3,1));
        o.ui_create_text(ui.ctl, 'roll',   ui_get_pos(row(j)+0,col_axis));
        o.ui_create_text(ui.ctl, 'pitch',  ui_get_pos(row(j)+1,col_axis));
        o.ui_create_text(ui.ctl, 'yaw',    ui_get_pos(row(j)+2,col_axis));
        % values of sliders
        ui.(name{j}).value_x = o.ui_create_text(ui.ctl, '0°', ui_get_pos(row(j)+0,col_value));
        ui.(name{j}).value_y = o.ui_create_text(ui.ctl, '0°', ui_get_pos(row(j)+1,col_value));
        ui.(name{j}).value_z = o.ui_create_text(ui.ctl, '0°', ui_get_pos(row(j)+2,col_value));
        % sliders
        ui.(name{j}).slider_x = o.ui_create_slider(ui.ctl, 0, -pi/3, pi/3, ui_get_pos(row(j)+0,col_slider));
        ui.(name{j}).slider_y = o.ui_create_slider(ui.ctl, 0, -pi/3, pi/3, ui_get_pos(row(j)+1,col_slider));
        ui.(name{j}).slider_z = o.ui_create_slider(ui.ctl, 0, -pi/3, pi/3, ui_get_pos(row(j)+2,col_slider));
        % radio buttons for control selection
        ui.(name{j}).radio_ctrl = o.ui_create_radiogroup(ui.ctl, ui_get_pos(row(j),col_ctrl,3,1));
        ui.(name{j}).radio_ctrl_j = o.ui_create_radio(ui.(name{j}).radio_ctrl, 'control JOINT',   1);
        ui.(name{j}).radio_ctrl_a = o.ui_create_radio(ui.(name{j}).radio_ctrl, 'control ALIGNED', 0);
        if j==3, ui.(name{j}).radio_ctrl_a.Text = 'control PROTO'; end
        % radio buttons for range disply selection
        ui.(name{j}).radio_rng = o.ui_create_radiogroup(ui.ctl, ui_get_pos(row(j),col_rng,3,1));
        ui.(name{j}).radio_rng_j = o.ui_create_radio(ui.(name{j}).radio_rng, 'display JOINT',   3);
        ui.(name{j}).radio_rng_a = o.ui_create_radio(ui.(name{j}).radio_rng, 'display ALIGNED', 2);
        ui.(name{j}).radio_rng_p = o.ui_create_radio(ui.(name{j}).radio_rng, 'display PROTO',   1);
        ui.(name{j}).radio_rng_n = o.ui_create_radio(ui.(name{j}).radio_rng, 'display NONE',    0);
        % radio buttons for sample points display selection
        ui.(name{j}).radio_pnt = o.ui_create_radiogroup(ui.ctl, ui_get_pos(row(j),col_pnt,3,1));
        ui.(name{j}).radio_pnt_n = o.ui_create_radio(ui.(name{j}).radio_pnt, 'samples NONE', 0);
        ui.(name{j}).radio_pnt_a = o.ui_create_radio(ui.(name{j}).radio_pnt, 'samples ALL',  2);
        ui.(name{j}).radio_pnt_u = o.ui_create_radio(ui.(name{j}).radio_pnt, 'samples UNI',  1);
    
    end
    
    % create figure with joint ranges plot
    ui.fig = figure('Name','wing axis range plot'); hold on; ui.ax1 = gca;
    ui.fig.WindowState = 'maximized';
    fontsize(ui.ax1, o.const.textsize, "points");
    xlim([-80,40]); ylim([-140,40]); zlim([-60,60]); view(75,15);
    o.plot_finalize_scan(gca, zoom=1.4);
    ui.ax2 = gca;
    rotate3d(ui.ax2, 'on');
    ui_draw(ui, o);
    % register slider update loop
    ui.draw_timer = timer('ExecutionMode', 'fixedRate', 'Period', 0.2, 'TimerFcn', @(~,~) ui_loop(ui, o));
    start(ui.draw_timer);
    ui.ctl.DeleteFcn = @(o,~) ui_close(ui,o);
    ui.fig.DeleteFcn = @(o,~) ui_close(ui,o);
    % register radio button callbacks
    for name = {'j1', 'j2', 'j3'}
        ui.(name{:}).radio_ctrl.SelectionChangedFcn = @(src,evt) ui_callback(src,evt, ui,o);
        ui.(name{:}).radio_rng.SelectionChangedFcn  = @(src,evt) ui_callback(src,evt, ui,o);
        ui.(name{:}).radio_pnt.SelectionChangedFcn  = @(src,evt) ui_callback(src,evt, ui,o);
    end
    
    %% user defined initial settings

    ui.j3.slider_x.Value = deg2rad(3);
    ui.j3.slider_y.Value = deg2rad(-5);
    ui.j3.slider_z.Value = deg2rad(53);
    ui.j2.slider_x.Value = deg2rad(4);
    ui.j2.slider_y.Value = deg2rad(0);
    ui.j2.slider_z.Value = deg2rad(-48);
    ui.j1.slider_x.Value = deg2rad(0);
    ui.j1.slider_y.Value = deg2rad(0);
    ui.j1.slider_z.Value = deg2rad(0);
    ui.j1.radio_ctrl.SelectedObject = ui.j1.radio_ctrl_a;
    ui.j2.radio_ctrl.SelectedObject = ui.j2.radio_ctrl_a;
    ui.j3.radio_ctrl.SelectedObject = ui.j3.radio_ctrl_j;
    ui.j1.radio_rng.SelectedObject = ui.j1.radio_rng_p;
    ui.j2.radio_rng.SelectedObject = ui.j2.radio_rng_a;
    ui.j3.radio_rng.SelectedObject = ui.j3.radio_rng_j;
    view(ui.ax1, 115,30);

    %% functions

    % ui close window callback
    function ui_close(ui,o)
        if isvalid(ui.draw_timer), stop(ui.draw_timer); delete(ui.draw_timer); end
        if o == ui.fig && isvalid(ui.ctl), close(ui.ctl); end
        if o == ui.ctl && isvalid(ui.fig), close(ui.fig); end
    end
    
    % ui update loop listening for slider changes
    function ui_loop(ui, o)
        if ~ishandle(ui.ctl), close(ui.fig); end
        if ~ishandle(ui.fig), close(ui.ctl); end
        
        redraw = false;
        for i = {'j1', 'j2', 'j3'}

            if  ui.(i{:}).slider_x.Value ~= ui.(i{:}).value_x.Value || ...
                ui.(i{:}).slider_y.Value ~= ui.(i{:}).value_y.Value || ...
                ui.(i{:}).slider_z.Value ~= ui.(i{:}).value_z.Value
                redraw = true;
            end

            ui.(i{:}).value_x.Value = ui.(i{:}).slider_x.Value;
            ui.(i{:}).value_y.Value = ui.(i{:}).slider_y.Value;
            ui.(i{:}).value_z.Value = ui.(i{:}).slider_z.Value;

            ui.(i{:}).value_x.String = strcat(string(round(rad2deg( ui.(i{:}).value_x.Value ),0)), '°');
            ui.(i{:}).value_y.String = strcat(string(round(rad2deg( ui.(i{:}).value_y.Value ),0)), '°');
            ui.(i{:}).value_z.String = strcat(string(round(rad2deg( ui.(i{:}).value_z.Value ),0)), '°');

        end
        if redraw, ui_draw(ui, o); end

    end
    
    % callback for changes in ui radio buttons
    function ui_callback(src,evt, ui,o)
        switch src
            %case ui.j1.radio_ctrl, src = 'j1'; C_ja = o.T.j1a1(1:3,1:3); C_aj = o.T.a1j1(1:3,1:3); 
            case ui.j1.radio_ctrl, src = 'j1'; C_ja = [o.axs_rng.p1.x.axis,o.axs_rng.p1.y.axis,o.axs_rng.p1.z.axis]; C_aj = C_ja'; % replace control aligned of j1 with control I
            case ui.j2.radio_ctrl, src = 'j2'; C_ja = o.T.j2a2(1:3,1:3); C_aj = o.T.a2j2(1:3,1:3);
            case ui.j3.radio_ctrl, src = 'j3'; C_ja = o.T.j3a3(1:3,1:3); C_aj = o.T.a3j3(1:3,1:3);
            otherwise, ui_draw(ui, o); return;
        end

        if evt.NewValue == ui.(src).radio_ctrl_j && evt.OldValue == ui.(src).radio_ctrl_a
            C_a = eul2rotm( [ui.(src).value_z.Value, ui.(src).value_y.Value, ui.(src).value_x.Value] );
            C_j = C_ja * C_a * C_aj;
            eul = rotm2eul(C_j);
        end
        if evt.NewValue == ui.(src).radio_ctrl_a && evt.OldValue == ui.(src).radio_ctrl_j
            C_j = eul2rotm( [ui.(src).value_z.Value, ui.(src).value_y.Value, ui.(src).value_x.Value] );
            C_a = C_aj * C_j * C_ja;
            eul = rotm2eul(C_a);
        end

        ui.(src).slider_x.Value = eul(3);
        ui.(src).slider_y.Value = eul(2);
        ui.(src).slider_z.Value = eul(1);

    end
    
    % draw joint range plot
    function ui_draw(ui, o)

        T_j1j1_c = [ eul2rotm( [ui.j1.value_z.Value, ui.j1.value_y.Value, ui.j1.value_x.Value] ), [0;0;0]; [0,0,0], 1];
        T_j2j2_c = [ eul2rotm( [ui.j2.value_z.Value, ui.j2.value_y.Value, ui.j2.value_x.Value] ), [0;0;0]; [0,0,0], 1];
        T_j3j3_c = [ eul2rotm( [ui.j3.value_z.Value, ui.j3.value_y.Value, ui.j3.value_x.Value] ), [0;0;0]; [0,0,0], 1];

        %if ui.j1.radio_ctrl.SelectedObject == ui.j1.radio_ctrl_a,  T_j1j1_c = o.T.j1a1 * T_j1j1_c * o.T.a1j1;
        if ui.j1.radio_ctrl.SelectedObject == ui.j1.radio_ctrl_a  % replace control aligned of j1 with control proto (hack)
            temp = [[o.axs_rng.p1.x.axis,o.axs_rng.p1.y.axis,o.axs_rng.p1.z.axis,[0;0;0]];[0,0,0,1]];
            T_j1j1_c = temp * T_j1j1_c * temp'; 
        end
        if ui.j2.radio_ctrl.SelectedObject == ui.j2.radio_ctrl_a,  T_j2j2_c = o.T.j2a2 * T_j2j2_c * o.T.a2j2; end
        if ui.j3.radio_ctrl.SelectedObject == ui.j3.radio_ctrl_a,  T_j3j3_c = o.T.j3a3 * T_j3j3_c * o.T.a3j3; end

        T_j0j1_c = o.T.j0j1_0 * T_j1j1_c;
        T_j0j2_c = T_j0j1_c * o.T.j1j2_0 * T_j2j2_c;
        T_j0j3_c = T_j0j2_c * o.T.j2j3_0 * T_j3j3_c;

        T_j0j1_r = o.T.j0j1_0;
        T_j0j2_r = T_j0j1_c * o.T.j1j2_0;
        T_j0j3_r = T_j0j2_c * o.T.j2j3_0;
        
        cla(ui.ax1); hold(ui.ax1,'on');
        o.plot_scan(ui.ax1, o.scan.ind0, o.scan.vrt0_j0, eye(4));
        o.plot_scan(ui.ax1, o.scan.ind1, o.scan.vrt1_j1, T_j0j1_c);
        o.plot_scan(ui.ax1, o.scan.ind2, o.scan.vrt2_j2, T_j0j2_c);
        o.plot_scan(ui.ax1, o.scan.ind3, o.scan.vrt3_j3, T_j0j3_c);
        o.plot_finalize_scan(ui.ax1, axes=false, overlay=false);
        
        % stlwrite(triangulation(o.scan.ind1', (1.4*T_j0j1_c*o.scan.vrt1_j1)'), 'b1.stl');
        % stlwrite(triangulation(o.scan.ind2', (1.4*T_j0j2_c*o.scan.vrt2_j2)'), 'b2.stl');
        % stlwrite(triangulation(o.scan.ind3', (1.4*T_j0j3_c*o.scan.vrt3_j3)'), 'b3.stl');
        
        l = 18;
        cla(ui.ax2); hold(ui.ax2,'on');
        switch ui.j1.radio_pnt.SelectedObject
            case ui.j1.radio_pnt_a, draw_pnt = 'all';
            case ui.j1.radio_pnt_u, draw_pnt = 'uni';
            case ui.j1.radio_pnt_n, draw_pnt = 'none';
        end
        switch ui.j1.radio_rng.SelectedObject
            case ui.j1.radio_rng_j, plot_range2d(o, ui.ax2, o.axs_rng.j1, T_j0j1_r, T_j0j1_c, l, draw_pnt);
            case ui.j1.radio_rng_a, plot_range2d(o, ui.ax2, o.axs_rng.a1, o.T.a0j0*T_j0j1_r*o.T.j1a1, o.T.a0j0*T_j0j1_c*o.T.j1a1, l, draw_pnt);
            case ui.j1.radio_rng_p, plot_range2d(o, ui.ax2, o.axs_rng.p1, T_j0j1_r, T_j0j1_c, l, draw_pnt);
        end
        switch ui.j2.radio_pnt.SelectedObject
            case ui.j2.radio_pnt_a, draw_pnt = 'all';
            case ui.j2.radio_pnt_u, draw_pnt = 'uni';
            case ui.j2.radio_pnt_n, draw_pnt = 'none';
        end
        switch ui.j2.radio_rng.SelectedObject
            case ui.j2.radio_rng_j, plot_range2d(o, ui.ax2, o.axs_rng.j2, T_j0j2_r, T_j0j2_c, l, draw_pnt);
            case ui.j2.radio_rng_a, plot_range2d(o, ui.ax2, o.axs_rng.a2, o.T.a0j0*T_j0j2_r*o.T.j2a2, o.T.a0j0*T_j0j2_c*o.T.j2a2, l, draw_pnt);
            case ui.j2.radio_rng_p, plot_range2d(o, ui.ax2, o.axs_rng.p2, T_j0j2_r, T_j0j2_c, l, draw_pnt);
        end
        switch ui.j3.radio_pnt.SelectedObject
            case ui.j3.radio_pnt_a, draw_pnt = 'all';
            case ui.j3.radio_pnt_u, draw_pnt = 'uni';
            case ui.j3.radio_pnt_n, draw_pnt = 'none';
        end
        switch ui.j3.radio_rng.SelectedObject
            case ui.j3.radio_rng_j, plot_range2d(o, ui.ax2, o.axs_rng.j3, T_j0j3_r, T_j0j3_c, l, draw_pnt);
            case ui.j3.radio_rng_a, plot_range2d(o, ui.ax2, o.axs_rng.a3, o.T.a0j0*T_j0j3_r*o.T.j3a3, o.T.a0j0*T_j0j3_c*o.T.j3a3, l, draw_pnt);
            case ui.j3.radio_rng_p, plot_range2d(o, ui.ax2, o.axs_rng.p3, T_j0j3_r, T_j0j3_c, l ,draw_pnt);
        end
    
    end

    function plot_range2d(o, ax, joint, T, Tc, l,pnt)
    
        axes = ['x', 'y', 'z'];
        if isfield(joint,'w')
            axes = ['x', 'y', 'z', 'w'];
        end
        
        for axis = axes
            o.plot_points(ax, [Tc(1:3,4),l*Tc(1:3,1:3)*joint.(axis).axis+Tc(1:3,4)],'-',o.const.color.(axis));
            if isempty(joint.(axis).pnt_all), continue; end
            pnt_smth = l*T(1:3,1:3)*joint.(axis).pnt_smth + T(1:3,4);
            trisurf(joint.(axis).hull,pnt_smth(1,:),pnt_smth(2,:),pnt_smth(3,:), FaceColor=o.const.color.(axis), FaceAlpha=0.2, EdgeColor='none', Parent=ax);
            o.plot_points(ax, [pnt_smth(:,joint.(axis).loop),pnt_smth(:,joint.(axis).loop(1))],'-',o.const.color.(axis));
            if strcmp(pnt,'all'), o.plot_points(ax, l*T(1:3,1:3)*joint.(axis).pnt_all + T(1:3,4),'.',o.const.color.(axis)); end
            if strcmp(pnt,'uni'), o.plot_points(ax, l*T(1:3,1:3)*joint.(axis).pnt_uni + T(1:3,4),'.',o.const.color.(axis)); end
            l = 1.005*l;
        end
    
    end

end

