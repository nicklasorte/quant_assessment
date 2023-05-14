function [cell_sub_band_data]=find_sub_band_usage_rev1(app,temp_label,array_freq_bands,cell_census_freq_time,new_full_census_2010,tf_ignore_usp,tf_calc_pop_impact,tf_calc_sub_band)

    

tic;
if tf_ignore_usp==1
    cell_subband_filename=strcat('cell_sub_band_data_',temp_label,'.mat');
else
    cell_subband_filename=strcat('cell_sub_band_data_',temp_label,'_USP.mat');
end

[var_exist_input]=persistent_var_exist_with_corruption(app,cell_subband_filename);
if tf_calc_pop_impact==1 ||  tf_calc_sub_band==1
    var_exist_input=0;
end

if var_exist_input==2
    tic;
    retry_load=1;
    while(retry_load==1)
        try
            load(cell_subband_filename,'cell_sub_band_data')
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%Find the Sub-Band
    %%%%%%%%To not have memory issues, we'll need to do a double for loop
    step_array_freq=min(array_freq_bands):1:max(array_freq_bands);
    bin_edges=0.5:1:5.5
    usage_array=horzcat(1,0.5,0.1,0.01,0);
    array_time_value=1:1:5;
    num_time=length(array_time_value);
    num_freq_steps=length(step_array_freq);
    [num_census,~]=size(cell_census_freq_time);
    total_pop=sum(new_full_census_2010(:,5))
    tic;

    cell_sub_band_data=cell(num_freq_steps,5); %%%%%%%%1) Frequency, 2) All Census Data Array: Geo IDX, Time, Population, 3) Time, Hist Count, and Total Pop Per Count, 4)Effective Usage per 1MHz , 5) Temp Pop Count
    for freq_idx=1:1:num_freq_steps
        round(freq_idx/num_freq_steps*100)
        temp_census_data=NaN(num_census,3); %%%%1)Geo Idx, 2)Time (for that specific frequency), 3) Population
        for census_idx=1:1:num_census
            temp_freq_time_data=cell_census_freq_time{census_idx,2};
            temp_census_data(census_idx,1)=new_full_census_2010(census_idx,1); %%%%%%%Geo Id, Center Lat, Center Lon,  NLCD (1-4), Population
            temp_census_data(census_idx,2)=temp_freq_time_data(freq_idx,2); %%%%%Time
            temp_census_data(census_idx,3)=new_full_census_2010(census_idx,5);%%%%%%%%%Population
        end

        %%%%Histogram across the census tracts for a single frequency
        temp_count=histcounts(temp_census_data(:,3),bin_edges);
        temp_count_pop=NaN(num_time,1);
        for time_idx=1:1:num_time
            bin_idx=find(temp_census_data(:,2)==array_time_value(time_idx));
            temp_count_pop(time_idx)=sum(temp_census_data(bin_idx,3));
        end
        cell_sub_band_data{freq_idx,4}=(usage_array*temp_count_pop)/total_pop;   %%%%%%%%Find the effective factor of 1 mhz which can be share
        %%%%%%%%%%%This data isn't being used, so no use in saving it.
        cell_sub_band_data{freq_idx,1}=step_array_freq(freq_idx);
% % % %         cell_sub_band_data{freq_idx,2}=temp_census_data; %%%%%%%%This is the big data pushing us over 1GB
        cell_sub_band_data{freq_idx,3}=horzcat(array_time_value',temp_count',temp_count_pop);
        cell_sub_band_data{freq_idx,5}=temp_count_pop;
    end
    toc; %%%%%%%28 seconds
    retry_save=1;
    while(retry_save==1)
        try
            save(cell_subband_filename,'cell_sub_band_data')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    pause(0.1)


    tic;
    step_array_freq=min(array_freq_bands):1:max(array_freq_bands);
    array_nation_freq_time=horzcat(step_array_freq',vertcat(cell_sub_band_data{:,4}));  %%%1) Frequency, 2) Effective Federal Usage

    %%%%%%%%%%Now how do we find the nationwide for each frequency?
    close all;
    f = figure;
    hold on;
    bar(array_nation_freq_time(:,1),array_nation_freq_time(:,2)*100,'BarWidth',1)
    ylim([0 100])
    grid on;
    Ax = gca;
    Ax.YGrid = 'on';
    Ax.Layer = 'top';
    Ax.GridAlpha = 1;
    f.Position = [100 100 1000 400];
    xlabel('MHz')
    ylabel('Time Usage Percentage [%]')
    %%title({strcat('Effective Spectrum Usage [Frequency and Time]')})
    if tf_ignore_usp==1
        filename1=strcat('Subband_Usage_',temp_label,'.png');
    else
        filename1=strcat('Subband_Usage_',temp_label,'_USP.png');
    end
    pause(0.1)
    saveas(gcf,char(filename1))
    pause(0.1)
    %%%%%%%%%%%Save this figure, but make it wide
    toc;

end



end