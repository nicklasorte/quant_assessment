function [cell_pea_hist]=calculate_PEA_usage_rev1(app,temp_label,tf_calc_pea,tf_ignore_usp,array_freq_bands,cell_census_hist,cell_pea_census_data)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PEA
% % % 'This is where then take that data and apply it to a PEA'


 %%%1)Census Geo IDX, 2)Time/Freq Array
% % % % 'Calculate the PEA impact'
% % % % bin_edges=0.5:1:5.5
% % % % usage_array=horzcat(1,0.5,0.1,0.01,0)
total_freq_count=max(array_freq_bands)-min(array_freq_bands);


if tf_ignore_usp==1
    cell_pea_hist_filename=strcat('cell_pea_hist_',temp_label,'.mat');
else
    cell_pea_hist_filename=strcat('cell_pea_hist_',temp_label,'_USP.mat');
end

[var_exist_input]=persistent_var_exist_with_corruption(app,cell_pea_hist_filename);
if tf_calc_pea==1 
    var_exist_input=0;
end

if var_exist_input==2
    %%%%%%%%%%%%Load
     tic;
    retry_load=1;
    while(retry_load==1)
        try
             load(cell_pea_hist_filename,'cell_pea_hist')
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
    array_geo_idx=cell2mat(cell_census_hist(:,1));
    [num_peas,~]=size(cell_pea_census_data)
    %%%%cell_pea_census_data %%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid
    cell_pea_hist=cell(num_peas,6);%%%1)Geo Id, 2)Hist Count, 3)Pop 4)Count x Pop [This is the data for the heat map], 5) Effective Spectrum Usage 6)Effectice Free Spectrum Available
    tic;
    for pea_idx=1:1:num_peas
        clc;
        round(pea_idx/num_peas*100)
        pea_census_geo_idx=cell_pea_census_data{pea_idx,6};
        num_pea_census=length(pea_census_geo_idx);
        temp_match_idx=NaN(num_pea_census,1);
        
        %%%%%%cell_pea_hist 
        for j=1:1:num_pea_census
            temp_idx=find(pea_census_geo_idx(j)==array_geo_idx);
            if isempty(temp_idx)
                'Error: Empty IDX'
                pause;
            else
                temp_match_idx(j)=temp_idx;
            end
        end
        temp_match_idx=temp_match_idx(~isnan(temp_match_idx));

        %%%%%%%%%%%Find the Single Frequency Number for each PEA
        %%%%%%Compile all the census data and 

        temp_pea_hist_data=cell_census_hist(temp_match_idx,:);

        temp_array_geo_idx=cell2mat(temp_pea_hist_data(:,1));
        temp_array_count=cell2mat(temp_pea_hist_data(:,2));
        temp_array_pop=cell2mat(temp_pea_hist_data(:,3));
        temp_array_usage=cell2mat(temp_pea_hist_data(:,5));
        temp_array_count_pop=cell2mat(temp_pea_hist_data(:,4));

        %%%%%%%%%%Re-calibrate for population
        temp_pop_usage=temp_array_pop.*temp_array_usage;
        temp_total_pop=sum(temp_array_pop);
        
        cell_pea_hist{pea_idx,1}=temp_array_geo_idx;
        cell_pea_hist{pea_idx,2}=temp_array_count;
        cell_pea_hist{pea_idx,3}=temp_total_pop;
        cell_pea_hist{pea_idx,4}=sum(temp_array_count_pop);
        temp_usage=ceil(sum(temp_pop_usage)/temp_total_pop-1);

        if temp_usage>total_freq_count
            temp_usage=total_freq_count;
        end

        if temp_usage<0
            temp_usage=0;
        end

        cell_pea_hist{pea_idx,5}=temp_usage;
        cell_pea_hist{pea_idx,6}=(total_freq_count)-temp_usage;
    end
    toc; %%%%10 seconds
    retry_save=1;
    while(retry_save==1)
        try
            save(cell_pea_hist_filename,'cell_pea_hist')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
end

% % % min(cell2mat(cell_pea_hist(:,5)))
% % % max(cell2mat(cell_pea_hist(:,5)))
% % % min(cell2mat(cell_pea_hist(:,6)))
% % % min(cell2mat(cell_pea_hist(:,6)))

%%%%%%%%%%%'Make the Top 10 PEA Frequency Availability Table'

table_pea_freq_time=cell2table(horzcat(cell_pea_census_data(:,[1,2]),cell_pea_hist(:,[5,6])));
table_pea_freq_time.Properties.VariableNames={'PEA_Name' 'PEA_Number' 'Spectrum_Usage' 'Spectrum_Available'}


if tf_ignore_usp==1
    cell_pea_table_filename=strcat('PEA_Usage_',temp_label,'.xlsx');
else
    cell_pea_table_filename=strcat('PEA_Usage_',temp_label,'_USP.xlsx');
end
writetable(table_pea_freq_time,cell_pea_table_filename);


