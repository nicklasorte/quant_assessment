function print_missing_contours_gmf_rev1(app,cell_full_gmf_contours,cell_gmf_data,temp_label)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Print out the Missing GMF Contours
[num_gmf,]=size(cell_full_gmf_contours);
for i=1:1:num_gmf
    if isempty(cell_full_gmf_contours{i,3})
        cell_full_gmf_contours{i,3}=0;
    end
end
array_index=cell2mat(cell_full_gmf_contours(:,3));

request_contour_idx=find(array_index==4);
request_gmf_data=cell_gmf_data(request_contour_idx,:);

tic;
%%%%%%%%%'If there is a cell array within a cell, create a string'
[num_rows,num_cols]=size(request_gmf_data);
for row_idx=1:1:num_rows
    for col_idx=1:1:num_cols
        if iscell(request_gmf_data{row_idx,col_idx})==1
            if length(request_gmf_data{row_idx,col_idx})==1
                request_gmf_data(row_idx,col_idx)=request_gmf_data{row_idx,col_idx};
            else
                temp_cell_data=sort(request_gmf_data{row_idx,col_idx});
                temp_cell_data=temp_cell_data(~cellfun('isempty', temp_cell_data));
                if length(temp_cell_data)>1
                    %%%%Build a string
                    for j=1:1:length(temp_cell_data)
                        if j==1
                            temp_str=temp_cell_data{j};
                        else
                            temp_str=strcat(temp_str,',',temp_cell_data{j});
                        end
                    end
                end
                request_gmf_data{row_idx,col_idx}=temp_str;
            end
        end
    end
end
toc;
table_missing_gmf=cell2table(request_gmf_data);
size(table_missing_gmf)
tic;
writetable(table_missing_gmf,strcat(temp_label,'_Missing_Contours_GMF.xlsx'));
toc;