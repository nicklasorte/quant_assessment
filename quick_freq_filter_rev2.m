function [cell_gmf_data]=quick_freq_filter_rev2(app,cell_gmf_data,array_freq_bands)


%%%%%%%%%%%%%%%%Quick Filter, not into the specific bands.

%%Make this an array and check all.
min_freq_band=min(min(array_freq_bands));
max_freq_band=max(max(array_freq_bands));
[num_gmf,num_col]=size(cell_gmf_data);

tic;
temp_delete_asn_tf=zeros(num_gmf,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Removed for loop and four lines after
lf = cell2mat(cell_gmf_data(:,2) % matrix (num_gmf x 1) 
hf = cell2mat(cell_gmf_data(:,3) % matrix (num_gmf x 1) 
hf = max(lf,hf)% we need this to be max freq and not zero for next step
% Only two situations exist where the gmf freq is not within a band of interest
% if lf is larger than the max or if hf is lower than the min. 
% Using this, we avoid having to write if/then for several scenarios like 
% straddling lower and upper, sits within, overtop 
cell_gmf_data(lf > max_freq_band | hf < min_freq_band,:)=[] 
% very similar to how you did this with indexes
% it picks all the rows where lf > max or hf < min and sets it to []
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


temp_array_freq=cell2mat(cell_gmf_data(:,[2:3]));
temp_sort_freq_rows=sortrows(temp_array_freq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % % % % % uni_sort_freq_rows=unique(temp_sort_freq_rows,'rows');
% % % % % % % % cell_uni_freq_rows=num2cell(uni_sort_freq_rows);
% % % % % % % % %%%%%%%%%%%%%%%%%%%%%Service Occurance Table
% % % % % % % % table_record_count=cell2table(cell_uni_freq_rows);
% % % % % % % % table_record_count.Properties.VariableNames={'GMF_Freq1' 'GMF_Freq2'};
% % % % % % % % tic;
% % % % % % % % %%%writetable(table_record_count,strcat('Filtered_GMF_Rows_',sim_label,'_',num2str(min_freq_band),'_',num2str(max_freq_band),'MHz.xlsx'));
% % % % % % % % toc;

single_freq_idx=find(temp_sort_freq_rows(:,2)==0);
horzcat(min_freq_band,max_freq_band)
horzcat(min(temp_sort_freq_rows(single_freq_idx,1)),max(temp_sort_freq_rows(single_freq_idx,1)))

end
