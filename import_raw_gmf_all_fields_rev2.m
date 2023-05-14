function [cell_gmf_data]=import_raw_gmf_all_fields_rev2(app,tf_read_gmf,gmf_filename,sim_label)

tic;
cell_gmf_filename=strcat('cell_gmf_data_',sim_label,'.mat');
[var_exist_input]=persistent_var_exist_with_corruption(app,cell_gmf_filename);
if tf_read_gmf==1
    var_exist_input=0;
end

if var_exist_input==2
    retry_load=1;
    while(retry_load==1)
        try
            load(cell_gmf_filename,'cell_gmf_data')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    pause(0.1)
else

    tic;
    [num,~,raw]=xlsread(gmf_filename);
    toc;
    %%%%%%%%%If the table gets new columns, find the header names assign them dynamically
    header_varname=raw(1,:)'

    %%%%%%%%
    idx_gmf_serial_number=find(contains(header_varname,'SER')); %1
    idx_assigned_freq=find(contains(header_varname,'FRQMHz')); %2
    idx_assigned_freq2=find(contains(header_varname,'FRUMHz'));%3
    idx_time=find(contains(header_varname,'TME')); %4
    idx_service=find(contains(header_varname,'Service')); %5
    idx_tx_city=find(contains(header_varname,'XAL')); %6
    idx_tx_state=find(contains(header_varname,'XSC'));%7
    idx_tx_ant_gain=find(contains(header_varname,'XAG')); %8
    idx_tx_ant_height=find(contains(header_varname,'XAH')); %9
    idx_station_class=find(contains(header_varname,'STC')); %10
    idx_tx_emission=find(contains(header_varname,'EMS')); %11
    idx_tx_power=find(contains(header_varname,'PWR')); %12
    idx_rx_ant_gain=find(contains(header_varname,'RAG')); %13
    idx_rx_ant_height=find(contains(header_varname,'RAH')); %14
    idx_rx_city=find(contains(header_varname,'RAL')); %15
    idx_rx_state=find(contains(header_varname,'RSC')); %16
    idx_tx_eut=find(contains(header_varname,'XEQ')); %17
    idx_rx_eut=find(contains(header_varname,'REQ')); %18
    idx_tx_lat=find(contains(header_varname,'XLA')); %19
    idx_tx_lon=find(contains(header_varname,'XLG')); %20
    idx_tx_lat_dd=find(contains(header_varname,'XLatDD')); %21
    idx_tx_lon_dd=find(contains(header_varname,'XLonDD')); %22
    idx_rx_lat=find(contains(header_varname,'RLA')); %23
    idx_rx_lon=find(contains(header_varname,'RLG')); %24
    idx_tx_radius=find(contains(header_varname,'TxRad')); %25
    idx_rx_radius=find(contains(header_varname,'RxRad')); %26
    idx_question_notes=find(contains(header_varname,'NOT')); %27
    idx_record_notes=find(contains(header_varname,'NTS')); %28
    idx_associated_gmf=find(contains(header_varname,'AGN')); %29
    idx_sup_notes=find(contains(header_varname,'SUP')); %30
    idx_agency=find(contains(header_varname,'Agency')); %31


    %%%%%%%%%%Keep Same Order as the GMF, just to make it easier
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    raw_gmf_num=raw(2:end,idx_gmf_serial_number); %1
    raw_freq=raw(2:end,idx_assigned_freq); %2
    raw_freq2=raw(2:end,idx_assigned_freq2); %3
    raw_time=raw(2:end,idx_time); %4
    raw_service=raw(2:end,idx_service); %5
    raw_tx_city=raw(2:end,idx_tx_city); %6
    raw_tx_state=raw(2:end,idx_tx_state); %7
    raw_tx_ant_gain=raw(2:end,idx_tx_ant_gain); %8
    raw_tx_ant_height=raw(2:end,idx_tx_ant_height); %9
    raw_station_class=raw(2:end,idx_station_class); %10
    raw_tx_ems=raw(2:end,idx_tx_emission); %11
    raw_tx_power=raw(2:end,idx_tx_power); %12
    raw_rx_ant_gain=raw(2:end,idx_rx_ant_gain); %13
    raw_rx_ant_height=raw(2:end,idx_rx_ant_height); %14
    raw_rx_city=raw(2:end,idx_rx_city); %15
    raw_rx_state=raw(2:end,idx_rx_state); %16
    raw_tx_eut=raw(2:end,idx_tx_eut); %17
    raw_rx_eut=raw(2:end,idx_rx_eut); %18
    raw_tx_lat=raw(2:end,idx_tx_lat); %19
    raw_tx_lon=raw(2:end,idx_tx_lon); %20
    raw_tx_lat_dd=raw(2:end,idx_tx_lat_dd); %21
    raw_tx_lon_dd=raw(2:end,idx_tx_lon_dd); %22
    raw_rx_lat=raw(2:end,idx_rx_lat); %23
    raw_rx_lon=raw(2:end,idx_rx_lon); %24
    raw_tx_radius=raw(2:end,idx_tx_radius); %25
    raw_rx_radius=raw(2:end,idx_rx_radius); %26
    raw_quest_notes=raw(2:end,idx_question_notes); %27
    raw_record_notes=raw(2:end,idx_record_notes); %28
    raw_asc_gmf=raw(2:end,idx_associated_gmf); %29
    raw_sup_notes=raw(2:end,idx_sup_notes); %30
    raw_agency=raw(2:end,idx_agency); %31

    %%%%%%%%%%%%%%%%Pull in all the Unique Equipment Names
    %%%%%%%%%%%%%%%%Then Unique all the Location names and lat/lon
    %%%%%%%%%%and Then find the radio parameters for each on.

    num_freq_assign=length(raw_gmf_num);
    cell_gmf_data=cell(num_freq_assign,31);

    %%%%%%%%%%Keep Same Order as the GMF, just to make it easier
    %%%1) GMF Assignment Number
    %%%2) Freq
    %%%3) Freq Max/Band
    %%%4) Time
    %%%5) Service (Radiolocation vs Research)
    %%%6) Tx City
    %%%7) Tx State
    %%%8) Tx Ant Gain
    %%%9) Tx Ant Height
    %%%10) Station Class
    %%%11) Tx Emission Bandwidth (MHz)
    %%%12) Tx Power (Watts)
    %%%13) Rx Ant Gain
    %%%14) Rx Ant Height
    %%%15) Rx City
    %%%16) Rx State
    %%%17) Tx EUT
    %%%18) Rx EUT
    %%%19) Tx Lat: DDMMSS
    %%%20) Tx Lon: DDMMSS
    %%%21) Tx Lat: DecDeg
    %%%22) Tx Lon: DecDeg
    %%%23) Rx Lat: DDMMSS
    %%%24) Rx Lon: DDMMSS
    %%%25) Tx Radius
    %%%26) Rx Radius
    %%%27) Other Notes [?]
    %%%28) Record Notes
    %%%29) Associated GMF Assignment
    %%%30) Supplementary Information
    %%%31) Agency


    tic;
    for i=1:1:num_freq_assign
        horzcat(i,i/num_freq_assign*100)
        cell_gmf_data{i,1}=raw_gmf_num{i};  %%%1) GMF Assignment Number
        cell_gmf_data{i,2}=raw_freq{i};     %%%2) Freq
        cell_gmf_data{i,3}=raw_freq2{i};    %%%3) Freq Max/Band

        if ischar(raw_time{i})
            cell_gmf_data{i,4}=str2num(raw_time{i});     %%%4) Time
        elseif isnan(raw_time{i})
            cell_gmf_data{i,4}=raw_time{i};     %%%4) Time
        else
            'Unknown time field'
            raw_time{i}
            pause;
        end

        %%%5) Service (Radiolocation vs Research)
        if ischar(raw_service{i})==1
            if contains(raw_service{i},',')==1
                temp_split=strsplit(raw_service{i},',');
                temp_service=unique(temp_split)';
                % % %             if length(temp_service)>1
                % % %                 clear temp_string;
                % % %                 for k=1:1:length(temp_service)
                % % %                     if k==1
                % % %                         temp_string=temp_service{k};
                % % %                     else
                % % %                         temp_string=strcat(temp_string,',',temp_service{k});
                % % %                     end
                % % %                 end
                % % %                 temp_string
                % % %                 'Make a string'
                % % %                 temp_service
                % % %                 pause;
                % % %             end
            else
                temp_service=raw_service(i);
            end
        else
            temp_service='None';
        end

        cell_gmf_data{i,5}=temp_service;    %%%5) Service (Radiolocation vs Research)
        cell_gmf_data{i,6}=raw_tx_city{i};  %%%6) Tx City
        cell_gmf_data{i,7}=raw_tx_state{i}; %%%7) Tx State


        %%%8) Tx Ant Gain
        temp_tx_ant_gain=raw_tx_ant_gain{i};
        if ischar(temp_tx_ant_gain)==1
            if contains(temp_tx_ant_gain,',')
                split_ant_height=strsplit(temp_tx_ant_gain,',');
                temp_tx_ant_gain=unique(split_ant_height);
                temp_tx_ant_gain=cellfun(@str2num,temp_tx_ant_gain);
                temp_tx_ant_gain=temp_tx_ant_gain(~isnan(temp_tx_ant_gain));
                if length(temp_tx_ant_gain)>1
                    temp_tx_ant_gain
                    temp_tx_ant_gain=max(temp_tx_ant_gain)
                    %pause;
                end
            end
            if ischar(temp_tx_ant_gain)==1
                temp_tx_ant_gain=str2num(temp_tx_ant_gain);
            end
        end
        cell_gmf_data{i,8}=temp_tx_ant_gain; %%%8) Tx Ant Gain


        %%%9) Tx Ant Height
        temp_tx_ant_height=raw_tx_ant_height{i};
        if ischar(temp_tx_ant_height)==1
            if contains(temp_tx_ant_height,',')
                split_ant_height=strsplit(temp_tx_ant_height,',');
                temp_tx_ant_height=unique(split_ant_height);
            end
            if iscell(temp_tx_ant_height)
                temp_tx_ant_height=cellfun(@str2num,temp_tx_ant_height,'UniformOutput',false);
            end
            if ischar(temp_tx_ant_height)==1
                temp_tx_ant_height=str2num(temp_tx_ant_height);
            end
            if iscell(temp_tx_ant_height)
                temp_tx_ant_height=cell2mat(temp_tx_ant_height);
            end
            temp_tx_ant_height=temp_tx_ant_height(~isnan(temp_tx_ant_height));
        end
        if isempty(temp_tx_ant_height)
            temp_tx_ant_height=NaN(1);
        end
        if length(temp_tx_ant_height)>1
            temp_tx_ant_height
            temp_tx_ant_height=max(temp_tx_ant_height)
            %pause;
        end
        cell_gmf_data{i,9}=temp_tx_ant_height; %%%9) Tx Ant Height


        %%%10) Station Class
        temp_station_class=raw_station_class{i};
        if isnan(temp_station_class)==1
            %%'NaN station class'
            clear split_station_class;
            temp_station_class=cell(1,1);
        elseif ~isempty(temp_station_class)==1
            split_station_class=strsplit(temp_station_class,',');
            temp_station_class=unique(split_station_class);
        else
            'Unknown'
            temp_station_class
            pause;
        end
        cell_gmf_data{i,10}=temp_station_class'; %%%10) Station Class

        %%%11) Tx Emission Bandwidth: We are not saving the Waveform Type
        temp_tx_ems=raw_tx_ems{i};
        array_ems_bw=NaN(1);
        if ischar(temp_tx_ems)==1
            if contains(temp_tx_ems,',')
                temp_split=strsplit(temp_tx_ems,',');
                temp_tx_ems=unique(temp_split);
            end

            %%%%%%%%%Convert to Cell to Make it Easier???
            if ischar(temp_tx_ems)
                temp_cell_tx_ems=cell(1,1);
                temp_cell_tx_ems{1}=temp_tx_ems;
                temp_tx_ems=temp_cell_tx_ems;
            end

            if iscell(temp_tx_ems)
                array_ems_bw=NaN(length(temp_tx_ems),1);
                for k=1:1:length(temp_tx_ems)
                    temp_ems=temp_tx_ems{k};
                    if length(temp_ems)==3
                        array_ems_bw(k)=NaN(1);%%%Empty
                    elseif contains(temp_ems,'M')
                        temp_strNum=regexp(temp_ems,'\d+','match');    % Extract numbers
                        temp_strNum=cellfun(@str2num,temp_strNum,'UniformOutput',false);
                        temp_ems_array=cell2mat(temp_strNum);
                        array_ems_bw(k)=temp_ems_array(1)+temp_ems_array(2)/100;
                    elseif contains(temp_ems,'K')
                        temp_strNum=regexp(temp_ems,'\d+','match');    % Extract numbers
                        temp_strNum=cellfun(@str2num,temp_strNum,'UniformOutput',false);
                        temp_ems_array=cell2mat(temp_strNum);
                        array_ems_bw(k)=temp_ems_array(1)/1000+temp_ems_array(2)/100000;
                    elseif contains(temp_ems,'G')
                        temp_strNum=regexp(temp_ems,'\d+','match');    % Extract numbers
                        temp_strNum=cellfun(@str2num,temp_strNum,'UniformOutput',false);
                        temp_ems_array=cell2mat(temp_strNum);
                        array_ems_bw(k)=temp_ems_array(1)*1000+temp_ems_array(2)*10;
                    elseif contains(temp_ems,'H')
                        temp_strNum=regexp(temp_ems,'\d+','match');    % Extract numbers
                        temp_strNum=cellfun(@str2num,temp_strNum,'UniformOutput',false);
                        temp_ems_array=cell2mat(temp_strNum);
                        array_ems_bw(k)=0;
                    end
                end
            end
        end
        cell_gmf_data{i,11}=array_ems_bw;   %%%11) Tx Emission Bandwidth

        %%%12) Tx Power
        temp_tx_pwr=raw_tx_power{i};
        array_tx_pwr=NaN(1);
        if ischar(temp_tx_pwr)==1
            if contains(temp_tx_pwr,',')
                temp_split=strsplit(temp_tx_pwr,',');
                temp_tx_pwr=unique(temp_split);
            end
            %%%%%%%%%Convert to Cell to Make it Easier???
            if ischar(temp_tx_pwr)
                temp_cell_tx_pwr=cell(1,1);
                temp_cell_tx_pwr{1}=temp_tx_pwr;
                temp_tx_pwr=temp_cell_tx_pwr;
            end

            if iscell(temp_tx_pwr)
                array_tx_pwr=NaN(length(temp_tx_pwr),1);
                for k=1:1:length(temp_tx_pwr)
                    temp_pwr=temp_tx_pwr{k};
                    if contains(temp_pwr,'W')
                        split_watts=strsplit(temp_pwr,'W');
                        array_tx_pwr(k)=str2num(split_watts{2});
                    elseif contains(temp_pwr,'K')
                        split_watts=strsplit(temp_pwr,'K');
                        array_tx_pwr(k)=str2num(split_watts{2})*1000;
                    elseif contains(temp_pwr,'M')
                        split_watts=strsplit(temp_pwr,'M');
                        array_tx_pwr(k)=str2num(split_watts{2})*1000000;
                    end
                end
            end
        end
        cell_gmf_data{i,12}=array_tx_pwr;  %%%12) Tx Power (Watts)

        %%%13) Rx Ant Gain
        temp_rx_ant_gain=raw_rx_ant_gain{i};
        if ischar(temp_rx_ant_gain)==1
            if contains(temp_rx_ant_gain,',')
                split_ant_height=strsplit(temp_rx_ant_gain,',');
                temp_rx_ant_gain=unique(split_ant_height);
                temp_rx_ant_gain=cellfun(@str2num,temp_rx_ant_gain);
                temp_rx_ant_gain=temp_rx_ant_gain(~isnan(temp_rx_ant_gain));
% % %                 if length(temp_rx_ant_gain)>1
% % %                     temp_rx_ant_gain
% % %                     pause;
% % %                 end
            end
            if ischar(temp_rx_ant_gain)==1
                temp_rx_ant_gain=str2num(temp_rx_ant_gain);
            end
        end
        cell_gmf_data{i,13}=temp_rx_ant_gain; %%%13) Rx Ant Gain


        %%%14) Rx Ant Height
        temp_rx_ant_height=raw_rx_ant_height{i};
        if ischar(temp_rx_ant_height)==1
            if contains(temp_rx_ant_height,',')
                split_ant_height=strsplit(temp_rx_ant_height,',');
                temp_rx_ant_height=unique(split_ant_height);
            end
            if iscell(temp_rx_ant_height)
                temp_rx_ant_height=cellfun(@str2num,temp_rx_ant_height,'UniformOutput',false);
            end
            if ischar(temp_rx_ant_height)==1
                temp_rx_ant_height=str2num(temp_rx_ant_height);
            end
            if iscell(temp_rx_ant_height)
                temp_rx_ant_height=cell2mat(temp_rx_ant_height);
            end
            temp_rx_ant_height=temp_rx_ant_height(~isnan(temp_rx_ant_height));
        end
        if isempty(temp_rx_ant_height)
            temp_rx_ant_height=NaN(1);
        end
% % %         if length(temp_rx_ant_height)>1
% % %             temp_rx_ant_height
% % %             pause;
% % %         end
        cell_gmf_data{i,14}=temp_rx_ant_height; %%%14) Rx Ant Height
        cell_gmf_data{i,15}=raw_rx_city{i};  %%%15) Rx City
        cell_gmf_data{i,16}=raw_rx_state{i}; %%%16) Rx State
        
        
        %%%17) Tx EUT
        temp_tx_eut=raw_tx_eut{i};
        temp_tx_eut_name=NaN(1);
        if ischar(temp_tx_eut)
            if contains(temp_tx_eut,'G,')==1
                temp_split=strsplit(temp_tx_eut,'G,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_tx_eut_name=temp_split2{1};
            elseif contains(temp_tx_eut,'C,')==1
                temp_split=strsplit(temp_tx_eut,'C,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_tx_eut_name=temp_split2{1};
            elseif contains(temp_tx_eut,'U,')==1
                temp_split=strsplit(temp_tx_eut,'U,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_tx_eut_name=temp_split2{1};
            end
            %%%%%%Remove the space to minimize the GMF EUT difference
            temp_tx_eut_name=temp_tx_eut_name(find(~isspace(temp_tx_eut_name)));
        end
        if isnan(temp_tx_eut_name)
            temp_tx_eut_name='N/A';
        end
        cell_gmf_data{i,17}=temp_tx_eut_name; %%%17) Tx EUT
        
        %%%18) Rx EUT
        temp_rx_eut=raw_rx_eut{i};
        temp_rx_eut_name=NaN(1);
        if ischar(temp_rx_eut)
            if contains(temp_rx_eut,'G,')==1
                temp_split=strsplit(temp_rx_eut,'G,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_rx_eut_name=temp_split2{1};
            elseif contains(temp_rx_eut,'C,')==1
                temp_split=strsplit(temp_rx_eut,'C,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_rx_eut_name=temp_split2{1};
            elseif contains(temp_rx_eut,'U,')==1
                temp_split=strsplit(temp_rx_eut,'U,');
                if contains(temp_split{2},',')
                    temp_split2=strsplit(temp_split{2},',');
                else
                    clear temp_split2;
                    temp_split2{1}=temp_split{2};
                end
                temp_rx_eut_name=temp_split2{1};
            end
            %%%%%%Remove the space to minimize the GMF EUT difference
            temp_rx_eut_name=temp_rx_eut_name(find(~isspace(temp_rx_eut_name)));
        end
        cell_gmf_data{i,18}=temp_rx_eut_name; %%%18) Rx EUT
        %%%%  cell_gmf_data(:,18)


        %%%19) Tx Lat: DDMMSS
        temp_tx_lat_ddmmss=raw_tx_lat{i};
        temp_tx_lat=NaN(1);
        if ischar(temp_tx_lat_ddmmss)
            if contains(temp_tx_lat_ddmmss,'N')==1
                temp_split=strsplit(temp_tx_lat_ddmmss,'N');
                temp_split_tx_lat=temp_split{1};
                if length(temp_split_tx_lat)==6
                    temp_tx_lat=str2num(temp_split_tx_lat(1:2))+str2num(temp_split_tx_lat(3:4))/60+str2num(temp_split_tx_lat(5:6))/360;
                else
                    'Unknown legnth'
                    temp_tx_lat_ddmmss
                    temp_split_tx_lat
                    pause;
                end
            elseif contains(temp_tx_lat_ddmmss,'S')==1
                temp_split=strsplit(temp_tx_lat_ddmmss,'S');
                temp_split_tx_lat=temp_split{1};
                if length(temp_split_tx_lat)==6
                    temp_tx_lat=-1*(str2num(temp_split_tx_lat(1:2))+str2num(temp_split_tx_lat(3:4))/60+str2num(temp_split_tx_lat(5:6))/360);
                else
                    'Unknown legnth'
                    temp_tx_lat_ddmmss
                    temp_split_tx_lat
                    pause;
                end
            end
        end
        cell_gmf_data{i,19}=temp_tx_lat; %%%19) Tx Lat: DDMMSS Converted to DecDeg

        %%%20) Tx Lon: DDMMSS
        temp_tx_lon_ddmmss=raw_tx_lon{i};
        temp_tx_lon=NaN(1);
        if ischar(temp_tx_lon_ddmmss)
            if contains(temp_tx_lon_ddmmss,'E')==1
                temp_split=strsplit(temp_tx_lon_ddmmss,'E');
                temp_split_tx_lon=temp_split{1};
                if length(temp_split_tx_lon)==6
                    temp_tx_lon=str2num(temp_split_tx_lon(1:2))+str2num(temp_split_tx_lon(3:4))/60+str2num(temp_split_tx_lon(5:6))/360;
                elseif length(temp_split_tx_lon)==7
                    temp_tx_lon=str2num(temp_split_tx_lon(1:3))+str2num(temp_split_tx_lon(4:5))/60+str2num(temp_split_tx_lon(6:7))/360;
                else
                    'Unknown legnth'
                    temp_tx_lon_ddmmss
                    temp_split_tx_lon
                    pause;
                end
            elseif contains(temp_tx_lon_ddmmss,'W')==1
                temp_split=strsplit(temp_tx_lon_ddmmss,'W');
                temp_split_tx_lon=temp_split{1};
                if length(temp_split_tx_lon)==6
                    temp_tx_lon=-1*(str2num(temp_split_tx_lon(1:2))+str2num(temp_split_tx_lon(3:4))/60+str2num(temp_split_tx_lon(5:6))/360);
                elseif length(temp_split_tx_lon)==7
                    temp_tx_lon=-1*(str2num(temp_split_tx_lon(1:3))+str2num(temp_split_tx_lon(4:5))/60+str2num(temp_split_tx_lon(6:7))/360);
                else
                    'Unknown legnth'
                    temp_tx_lon_ddmmss
                    temp_split_tx_lon
                    pause;
                end
            end
        end
        cell_gmf_data{i,20}=temp_tx_lon;        %%%20) Tx Lon: DDMMSS Converted to DecDeg
        cell_gmf_data{i,21}=raw_tx_lat_dd{i};   %%%21) Tx Lat: DecDeg
        cell_gmf_data{i,22}=raw_tx_lon_dd{i};   %%%22) Tx Lon: DecDeg


        
        %%%23) Rx Lat: DDMMSS
        temp_rx_lat_ddmmss=raw_rx_lat{i};
        temp_rx_lat=NaN(1);


        %%%%%We could have multiple rx points, split by comma
        if ischar(temp_rx_lat_ddmmss)
            if contains(temp_rx_lat_ddmmss,',')==1
                temp_split_multi_lat=strsplit(temp_rx_lat_ddmmss,',');
    
                temp_rx_lat=NaN(length(temp_split_multi_lat),1);
                for k=1:1:length(temp_split_multi_lat)
                    temp_rx_lat_ddmmss=temp_split_multi_lat{k};
                    %%%%%%%%Loop
                    if ischar(temp_rx_lat_ddmmss)
                        if contains(temp_rx_lat_ddmmss,'N/A')==1
                            %%%%Nothing
                        elseif contains(temp_rx_lat_ddmmss,'N')==1
                            temp_split=strsplit(temp_rx_lat_ddmmss,'N');
                            temp_split_rx_lat=temp_split{1};
                            if length(temp_split_rx_lat)==6
                                temp_rx_lat(k)=str2num(temp_split_rx_lat(1:2))+str2num(temp_split_rx_lat(3:4))/60+str2num(temp_split_rx_lat(5:6))/360;
                            else
                                'Unknown legnth'
                                temp_rx_lat_ddmmss
                                temp_split_rx_lat
                                pause;
                            end
                        elseif contains(temp_rx_lat_ddmmss,'S')==1
                            temp_split=strsplit(temp_rx_lat_ddmmss,'S');
                            temp_split_rx_lat=temp_split{1};
                            if length(temp_split_rx_lat)==6
                                temp_rx_lat(k)=-1*(str2num(temp_split_rx_lat(1:2))+str2num(temp_split_rx_lat(3:4))/60+str2num(temp_split_rx_lat(5:6))/360);
                            else
                                'Unknown legnth'
                                temp_rx_lat_ddmmss
                                temp_split_rx_lat
                                pause;
                            end
                        end
                    end
                end
            end
        end
% % %         if length(temp_rx_lat)>1
% % %             temp_rx_lat
% % %             pause;
% % %         end
        cell_gmf_data{i,23}=temp_rx_lat; %%%23) Rx Lat: DDMMSS Converted to DecDeg

        %%%24) Rx Lon: DDMMSS
        temp_rx_lon_ddmmss=raw_rx_lon{i};
        temp_rx_lon=NaN(1);
        %%%%%We could have multiple rx points, split by comma
        if ischar(temp_rx_lon_ddmmss)
            if contains(temp_rx_lon_ddmmss,',')==1
                temp_split_multi_lon=strsplit(temp_rx_lon_ddmmss,',');
    
                temp_rx_lon=NaN(length(temp_split_multi_lon),1);
                for k=1:1:length(temp_split_multi_lon)
                    temp_rx_lon_ddmmss=temp_split_multi_lon{k};
                    %%%%%%%%Loop
                    if ischar(temp_rx_lon_ddmmss)
                        if contains(temp_rx_lon_ddmmss,'N/A')==1
                            %%%%Nothing
                        elseif contains(temp_rx_lon_ddmmss,'E')==1
                            temp_split=strsplit(temp_rx_lon_ddmmss,'E');
                            temp_split_rx_lon=temp_split{1};
                            if length(temp_split_rx_lon)==6
                                temp_rx_lon(k)=str2num(temp_split_rx_lon(1:2))+str2num(temp_split_rx_lon(3:4))/60+str2num(temp_split_rx_lon(5:6))/360;
                            elseif length(temp_split_rx_lon)==7
                                temp_rx_lon(k)=str2num(temp_split_rx_lon(1:3))+str2num(temp_split_rx_lon(4:5))/60+str2num(temp_split_rx_lon(6:7))/360;
                            else
                                'Unknown legnth'
                                temp_rx_lon_ddmmss
                                temp_split_rx_lon
                                pause;
                            end
                        elseif contains(temp_rx_lon_ddmmss,'W')==1
                            temp_split=strsplit(temp_rx_lon_ddmmss,'W');
                            temp_split_rx_lon=temp_split{1};
                            if length(temp_split_rx_lon)==6
                                temp_rx_lon(k)=-1*(str2num(temp_split_rx_lon(1:2))+str2num(temp_split_rx_lon(3:4))/60+str2num(temp_split_rx_lon(5:6))/360);
                            elseif length(temp_split_rx_lon)==7
                                temp_rx_lon(k)=-1*(str2num(temp_split_rx_lon(1:3))+str2num(temp_split_rx_lon(4:5))/60+str2num(temp_split_rx_lon(6:7))/360);
                            else
                                'Unknown legnth'
                                temp_rx_lon_ddmmss
                                temp_split_rx_lon
                                pause;
                            end
                        end
                    end
                end
            end
        end
% % %         if length(temp_rx_lon)>1
% % %             temp_rx_lon
% % %             pause;
% % %         end
        cell_gmf_data{i,24}=temp_rx_lon;        %%%24) Rx Lon: DDMMSS Converted to DecDeg


        
        %%%25) Tx Radius
        %%%26) Rx Radius
        temp_tx_radius=raw_tx_radius{i};
        temp_rx_radius=raw_rx_radius{i};
        if ischar(temp_rx_radius)==1
            temp_rx_radius=str2num(temp_rx_radius);
        end
        cell_gmf_data{i,25}=NaN(1);
        cell_gmf_data{i,26}=NaN(1);
        if ischar(temp_tx_radius)==1
            if contains(temp_tx_radius,'T')
                split_radius=strsplit(temp_tx_radius,'T');
                tx_radius=str2num(split_radius{1});
                cell_gmf_data{i,25}=tx_radius;
            end
            if contains(temp_tx_radius,'B')
                split_radius=strsplit(temp_tx_radius,'B');
                tx_radius=str2num(split_radius{1});
                cell_gmf_data{i,25}=tx_radius;
                cell_gmf_data{i,26}=tx_radius;
            else
                cell_gmf_data{i,26}=temp_rx_radius;
            end
        else
            cell_gmf_data{i,25}=temp_tx_radius;
            cell_gmf_data{i,26}=temp_rx_radius; %%%Check Rx Radius
        end

        
        if ischar(raw_quest_notes{i})
            cell_gmf_data{i,27}=raw_quest_notes{i};  %%%27) Other Notes [?]
        elseif isnan(raw_quest_notes{i})
            cell_gmf_data{i,27}='N/A'; %%%27) Other Notes [?]
        else
            'Unknown Quest Notes'
            raw_quest_notes{i}
            pause;
        end

        %%%28) Record Notes
        temp_record_notes=raw_record_notes{i};
        if isnan(temp_record_notes)==1
            %%'NaN Record Notes'
            clear split_record;
            split_record='N/A';%%%cell(1,1);
        elseif ~isempty(temp_record_notes)==1
            split_record=strsplit(temp_record_notes,',');
        else
            'Unknown'
            temp_record_notes
            pause;
        end
        cell_gmf_data{i,28}=split_record;

        if ischar(raw_asc_gmf{i})
            cell_gmf_data{i,29}=raw_asc_gmf{i}; %%%29) Associated GMF Assignment
        elseif isnan(raw_asc_gmf{i})
            cell_gmf_data{i,29}='N/A'; %%%29) Associated GMF Assignment
        else
            'Unknown Asc GMF'
            raw_asc_gmf{i}
            pause;
        end

        if ischar(raw_sup_notes{i})
            cell_gmf_data{i,30}=raw_sup_notes{i}; %%%30) Supplementary Information
        elseif isnan(raw_sup_notes{i})
            cell_gmf_data{i,30}='N/A'; %%%30) Supplementary Information
        else
            'Unknown Supplementary'
            raw_sup_notes{i}
            pause;
        end

        cell_gmf_data{i,31}=raw_agency{i}; %%%31) Agency
    end
    toc;

    retry_save=1;
    while(retry_save==1)
        try
            save(cell_gmf_filename,'cell_gmf_data')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    pause(0.1)
end
toc;


temp_non_ng_idx=find(~contains(cell_gmf_data(:,1),'NG'));  %%%%%%Non-Government
cell_gmf_data=cell_gmf_data(temp_non_ng_idx,:); %%%%%%%%%%%%%%%Cut NG Assignments.
temp_non_can_idx=find(~contains(cell_gmf_data(:,1),'CAN'));  %%%% Cut Cananda
cell_gmf_data=cell_gmf_data(temp_non_can_idx,:);


%%%%%%%%%%%%%%%Cut 'GUM'
temp_non_gum_idx=find(~contains(cell_gmf_data(:,7),'GUM'));  %%%% Cut Guam
cell_gmf_data=cell_gmf_data(temp_non_gum_idx,:);

%%%%%%%%%%%%%%%Cut 'MHL'
temp_non_mhl_idx=find(~contains(cell_gmf_data(:,7),'MHL'));  %%%% Cut MHL
cell_gmf_data=cell_gmf_data(temp_non_mhl_idx,:);


%%%%%%%%%%%%%%%Cut 'PLW'
temp_non_PLW_idx=find(~contains(cell_gmf_data(:,7),'PLW'));  %%%% Cut PLW
cell_gmf_data=cell_gmf_data(temp_non_PLW_idx,:);


%%%%%%%%%%%%%%%Cut 'VI'
temp_non_VI_idx=find(~contains(cell_gmf_data(:,7),'VI'));  %%%% Cut VI
cell_gmf_data=cell_gmf_data(temp_non_VI_idx,:);


%%%%%%%%%%%%%%%Cut 'SPCE'
temp_non_SPCE_idx=find(~contains(cell_gmf_data(:,7),'SPCE'));  %%%% Cut SPCE
cell_gmf_data=cell_gmf_data(temp_non_SPCE_idx,:);


temp_non_ak_idx=find(~contains(cell_gmf_data(:,7),'AK'));  %%%% Cut Alaska
cell_gmf_data=cell_gmf_data(temp_non_ak_idx,:);
temp_non_hi_idx=find(~contains(cell_gmf_data(:,7),'HI'));  %%%% Cut Hawaii
cell_gmf_data=cell_gmf_data(temp_non_hi_idx,:);
temp_non_pr_idx=find(~contains(cell_gmf_data(:,7),'PR'));  %%%% Cut PR
cell_gmf_data=cell_gmf_data(temp_non_pr_idx,:);




end