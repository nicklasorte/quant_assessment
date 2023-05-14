function [cell_census_freq_time,gmf_contours]=find_census_pop_freq_time_rev1(app,cell_gmf_data,cell_full_gmf_contours,tf_calc_pop_impact,temp_label,array_freq_bands,new_full_census_2010,tf_ignore_usp)

%%%%%%%%%%%%%%Need to extract the frequency and time usage. Need to convert the single frequency to an array of frequencies.

[num_asn,~]=size(cell_gmf_data)
[num_contours,~]=size(cell_full_gmf_contours)
gmf_contours=cell(num_asn,5);
% % % % % % 1)GMF Asn (Just in case),
% % % % % % 2)Contour,
% % % % % % 3)Time,
% % % % % % 4)Frequency Band Used (Convert Single to Band with TX Bandwidth)(array with 1Mhz spacing)
%%%%%%%%%%5) Contour TF: 0==April Contour 1==State, 2==USA/USP, 3==Nick Contour, 4==Request April Contour

tic;
for gmf_idx=1:1:num_asn
    if ~isempty(cell_full_gmf_contours{gmf_idx,2})  %%%%%%%%%If there is a contour, then bring together the data.
        gmf_contours{gmf_idx,1}=cell_gmf_data{gmf_idx,1};%%%%%%%%GMF Asn
        gmf_contours{gmf_idx,2}=cell_full_gmf_contours{gmf_idx,2}; %%%%%%%%%%%%Contour
        gmf_contours{gmf_idx,3}=cell_gmf_data{gmf_idx,4};  %%%%%%%%%%Time
        gmf_contours{gmf_idx,5}=cell_full_gmf_contours{gmf_idx,3}; %%%%%%%%%%%%Contour TF

        if isnan(gmf_contours{gmf_idx,5})
            gmf_contours{gmf_idx,5}=0;
        end

        %%%%%Frequency Array
        temp_freq1=cell_gmf_data{gmf_idx,2};
        temp_freq2=cell_gmf_data{gmf_idx,3};

        if temp_freq2==0 %%%Single
            temp_tx_bw=cell_gmf_data{gmf_idx,11};
            if isnan(temp_tx_bw)
                temp_tx_bw=1;
% % %                 'NAN Tx BW'
% % %                 cell_gmf_data(gmf_idx,:)
% % %                 pause;
            end

            freq_array=floor(temp_freq1-temp_tx_bw/2):1:ceil(temp_freq1+temp_tx_bw/2);
        else
            freq_array=temp_freq1:1:temp_freq2;
        end
        gmf_contours{gmf_idx,4}=freq_array;  %%%%%%%%Frequency
    end
end
toc;  


size(gmf_contours)
%%%%%%Remove the Empty Cells
non_empty_idx=find(~cellfun('isempty',gmf_contours(:,1)));
gmf_contours=gmf_contours(non_empty_idx,:);
[num_non_empty_contours,~]=size(gmf_contours)

time_bin_edges=0.5:1:5.5;
contour_gmf_time_hist=histcounts(vertcat(gmf_contours{:,3}),time_bin_edges)


tic;
if tf_ignore_usp==1
    cell_census_freq_time_filename=strcat('cell_census_freq_time_',temp_label,'_',num2str(num_non_empty_contours),'.mat');
else
    cell_census_freq_time_filename=strcat('cell_census_freq_time_',temp_label,'_',num2str(num_non_empty_contours),'_USP.mat');
end

[var_exist_input]=persistent_var_exist_with_corruption(app,cell_census_freq_time_filename);
if tf_calc_pop_impact==1
    var_exist_input=0;
end

if var_exist_input==2
    tic;
    retry_load=1;
    while(retry_load==1)
        try
            load(cell_census_freq_time_filename,'cell_census_freq_time')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    pause(0.1)
    toc;
else


    %%%%%%%%%%%%%%%Initialize the data structure
    mid_lat=new_full_census_2010(:,2);
    mid_lon=new_full_census_2010(:,3);
    step_array_freq=min(array_freq_bands):1:max(array_freq_bands);
    template_freq_time=horzcat(step_array_freq',5*ones(length(step_array_freq),1));
   
    %%%%%%1 --> 50-100% (GMF Defined)
    %%%%%%2 --> 10-50%
    %%%%%%3 --> 1-10%
    %%%%%%4 --> <1%
    %%%%%%%%%%5 means 0% usage


    [num_census,~]=size(new_full_census_2010);
    cell_census_freq_time=cell(num_census,2); %%%1)Census Geo IDX, 2)Time/Freq Array
    tic;
    for i=1:1:num_census
        cell_census_freq_time{i,1}=new_full_census_2010(i,1);
        cell_census_freq_time{i,2}=template_freq_time;
    end
    toc;

    [num_zones,~]=size(gmf_contours)
    tic;

    %%%%%%%This updates the cell_census_freq_time
    for i=1:1:num_zones
        %%%%clc;
        i/num_zones*100

        %%%%%%%%%First check for USP/USA
        if gmf_contours{i,5}==2
            %%%%%%%%%%%%USP
            %%%%Just skip at this point.
            %%%%We can easily just add do all the idx
            %%%%%%This might be the bottle neck
            if tf_ignore_usp==0
                %%%%'Need to add USP usage'
                %%pause;
                ind_idx=[1:1:size(mid_lon)]';
            else
                ind_idx=NaN(1,1);
                ind_idx=ind_idx(~isnan(ind_idx));
            end
        else
            %%%'Non-USP'
            temp_zone_bound=gmf_contours{i,2};

            % % %             gmf_contours(i,[1:3])
            % % %             close all;
            % % %             figure;
            % % %             hold on;
            % % %             plot(temp_zone_bound(:,1),temp_zone_bound(:,2),'-b')
            % % %             plot(us_cont(:,2),us_cont(:,1),'-k')
            % % %             pause(0.1)
            % % %
            % % %             %%%%%might Need to do the rough cut first to speed it up.
            % % %             min_lon=min(temp_zone_bound(:,1));
            % % %             max_lon=max(temp_zone_bound(:,1));
            % % %             min_lat=min(temp_zone_bound(:,2));
            % % %             max_lat=max(temp_zone_bound(:,2));
            % % %
            % % %             lon_idx1=find(min_lon<mid_lon);
            % % %             lon_idx2=find(max_lon>mid_lon);
            % % %             cut_lon_idx=intersect(lon_idx1,lon_idx2);
            % % %             %%%size(cut_lon_idx)


            %%%%%%%%Find the geo_id for each census tract, population, and NLCD value
            %tic;
            ind_idx=find(inpolygon(mid_lon,mid_lat,temp_zone_bound(:,1),temp_zone_bound(:,2))); %Check to see if the points are in the polygon
            %toc;

            % % %         if ~isnan(state_match_idx(i))
            % % %             'State match'
            % % %             'check ind_idx'
            % % %             length(ind_idx)
            % % %
            % % %             pause;
            % % %         end


            % % if ~isempty(ind_idx)
            % %     plot(temp_zone_bound(:,2),temp_zone_bound(:,1),'-')
            % %     plot(mid_lon(ind_idx),mid_lat(ind_idx),'o')
            % %     pause(0.1);
            % % end
        end
        
        if ~isempty(ind_idx)
            %tic;
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 %%%%%%%%%%%%%%%%%This for loop takes a lot longer than the
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 %%%%%%%%%%%%%%%%%inpolygon function, linearly as the number
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 %%%%%%%%%%%%%%%%%of ind_idx increases.
            %%%%%%%%%If there is overlap, adjust the cell_census_freq_time accordingly
            temp_gmf_time=gmf_contours{i,3};
            temp_gmf_freq=gmf_contours{i,4};
            for j=1:1:length(ind_idx)
                temp_census_idx=ind_idx(j);
                temp_freq_time_data=cell_census_freq_time{temp_census_idx,2};
                freq_match_idx=nearestpoint_app(app,temp_gmf_freq,temp_freq_time_data(:,1));
                %%%temp_freq_time_data(freq_match_idx,1)

                %%%%%%%%Update min time
                %%%temp_freq_time_data(freq_match_idx,2)
                temp_freq_time_data(freq_match_idx,2)=min(horzcat(temp_gmf_time*ones(length(freq_match_idx),1),temp_freq_time_data(freq_match_idx,2)),[],2);
                %%%temp_freq_time_data(freq_match_idx,2)
                %%%%pause;
                cell_census_freq_time{temp_census_idx,2}=temp_freq_time_data;
            end
            %toc;
        end
    end
    toc; %%%%%%+600 Seconds
    

    retry_save=1;
    while(retry_save==1)
        try
            save(cell_census_freq_time_filename,'cell_census_freq_time')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    pause(0.1)
end


end