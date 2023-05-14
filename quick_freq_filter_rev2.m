function [cell_gmf_data]=quick_freq_filter_rev2(app,cell_gmf_data,array_freq_bands)


%%%%%%%%%%%%%%%%Quick Filter, not into the specific bands.

%%Make this an array and check all.
min_freq_band=min(min(array_freq_bands));
max_freq_band=max(max(array_freq_bands));
[num_gmf,num_col]=size(cell_gmf_data);

tic;
temp_delete_asn_tf=zeros(num_gmf,1);
for gmf_idx=1:1:num_gmf
    %clc;
    temp_gmf_freq1=cell_gmf_data{gmf_idx,2};
    temp_gmf_freq2=cell_gmf_data{gmf_idx,3};

    if temp_gmf_freq2==0 %%% Single frequency
        %%%%if temp_gmf_freq1>=array_freq_bands(band_idx,1) && temp_gmf_freq1<=array_freq_bands(band_idx,2)
        %%%%For frequencies that were right on the band edge, we were double counting them. Can only sit on the bottom edge?
        %%%%%%%Might have to do this for the band assignments
        if temp_gmf_freq1>=min_freq_band && temp_gmf_freq1<max_freq_band
            temp_delete_asn_tf(gmf_idx)=0; %%%%%%Within Band
        else
            temp_delete_asn_tf(gmf_idx)=1; 
        end
    else %%%%Band Assingment
        %%%'Band Assignment'
        %%%%%Maybe check if the GMF Freq1==High Band Edge
        if temp_gmf_freq1==max_freq_band
            temp_delete_asn_tf(gmf_idx)=1;
            %%%'Logic 0: GMF Freq 1 == High Band Edge'
            %%%%Leave at Zero, no need to check anything else.
        elseif temp_gmf_freq1<=min_freq_band && temp_gmf_freq2<=max_freq_band && temp_gmf_freq2>min_freq_band %%%%%%Straddles Lower Band1
            %%%'Logic 1: Straddles Lower Band Bound'
            temp_delete_asn_tf(gmf_idx)=0;
        elseif temp_gmf_freq1<=max_freq_band && temp_gmf_freq2>=max_freq_band && temp_gmf_freq1>=min_freq_band %%%%%%Straddles High Band1
            %%%'Logic 2: Straddles High Band Bound'
            temp_delete_asn_tf(gmf_idx)=0;
        elseif temp_gmf_freq1>=min_freq_band && temp_gmf_freq2<=max_freq_band  %%%%%%Sits Within Band1
            %%%'Logic 3: Sits Within Band'
            temp_delete_asn_tf(gmf_idx)=0;
        elseif  temp_gmf_freq1<=min_freq_band && temp_gmf_freq2>=max_freq_band %%%%%%Overtop of entire band
            %%%'Logic 4: Overtop Entire Band'
            temp_delete_asn_tf(gmf_idx)=0;
        else
            temp_delete_asn_tf(gmf_idx)=1;
        end
    end
% % %     temp_delete_asn_tf(gmf_idx)
% % %     pause;

end

temp_del_idx=find(temp_delete_asn_tf==1);
size(cell_gmf_data)
cell_gmf_data(temp_del_idx,:)=[];
size(cell_gmf_data)


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