function [cell_census_hist]=calculate_usage_rev1(app,temp_label,tf_ignore_usp,cell_census_freq_time,array_freq_bands,new_full_census_2010,cell_sub_band_data)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make this a generalize function with a table output
size(cell_census_freq_time)
[num_census,~]=size(cell_census_freq_time);
bin_edges=0.5:1:5.5
cell_census_hist=cell(num_census,6); %%%1)Geo Id, 2)Hist Count, 3)Pop 4)Count x Pop [This is the data for the heat map], 5) Effective Spectrum Usage 6)Effectice Free Spectrum Available
usage_array=horzcat(1,0.5,0.1,0.01,0)
step_array_freq=min(array_freq_bands):1:max(array_freq_bands);
total_freq_count=length(step_array_freq)
tic;
for i=1:1:num_census
    temp_freq_time_data=cell_census_freq_time{i,2};
    %%%%%%%Make a Hist/CDF for each census tract
    temp_count=histcounts(temp_freq_time_data(:,2),bin_edges);
    cell_census_hist{i,2}=temp_count;
    cell_census_hist{i,1}=cell_census_freq_time{i,1};
    cell_census_hist{i,3}=new_full_census_2010(i,5);
    cell_census_hist{i,4}=temp_count*new_full_census_2010(i,5);
    effective_usage=sum(temp_count.*usage_array);
    cell_census_hist{i,5}=effective_usage;
    cell_census_hist{i,6}=total_freq_count-effective_usage;
end
toc; %%%%%%%2.4 seconds

effective_federal_usage_2=ceil(sum(cell2mat(cell_sub_band_data(:,4))))
effective_federal_usage_2/540


array_hist_pop=vertcat(cell_census_hist{:,4});
size(array_hist_pop)

nation_hist_pop=sum(array_hist_pop);
size(step_array_freq)
total_pop=sum(new_full_census_2010(:,5));
freq_time_usage=nation_hist_pop/total_pop;
total_freq=sum(freq_time_usage); %%%Equals 541 MHz or 4400-4940MHz
effective_federal_usage=ceil(sum(usage_array.*freq_time_usage))
effective_federal_usage/(total_freq-1)
effective_available=(total_freq-1)-effective_federal_usage

%%%%%%%%%Check
if effective_federal_usage~=effective_federal_usage_2
    'Look back at the calculation'
    pause;
end

if tf_ignore_usp==1
    tabel_filename1=strcat('Effective_Federal_Usage_',temp_label,'.xlsx');
else
    tabel_filename1=strcat('Effective_Federal_Usage_',temp_label,'_USP.xlsx');
end

output_table=array2table(horzcat(effective_federal_usage,effective_available));
output_table.Properties.VariableNames={'Usage' 'Availablilty'}
writetable(output_table,tabel_filename1);


map_usage_census_rev1(app,cell_census_hist,array_freq_bands,tf_ignore_usp,temp_label,new_full_census_2010);

end