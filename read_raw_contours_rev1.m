function [cell_contour_data]=read_raw_contours_rev1(app,temp_label,contour_excel_filename)


%%%1) GMF Serial Number
%%%2) Contour
%%%3) Convexhull Contour

tic;
cell_data_filename=strcat('cell_contour_data_',temp_label,'.mat');
[var_exist_input]=persistent_var_exist_with_corruption(app,cell_data_filename);
if var_exist_input==2
    retry_load=1;
    while(retry_load==1)
        try
            load(cell_data_filename,'cell_contour_data')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    pause(0.1)
else

    %%%%%%%%%%%%%%%%%%%%%%%%%Load in the Excel DCS location data
    tic;
    [num,~,raw]=xlsread(contour_excel_filename);
    toc;
    %%%%%%%%%If the table gets new columns, find the header names assign them dynamically
    header_varname=raw(1,:)'

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    idx_gmf_num=find(contains(header_varname,'SerialNumber')) %1
    idx_contour=find(contains(header_varname,'(No column name)')) %2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    raw_gmf=raw(2:end,idx_gmf_num); %1
    raw_contour=raw(2:end,idx_contour); %2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    num_locations=length(raw_gmf)
    cell_contour_data=cell(num_locations,3);

    %%%%%%%Need to have separate line for each type of data link
    %%%1) GMF Serial Number
    %%%2) Contour
    %%%3) Convexhull Contour


    for i=1:1:num_locations
        i/num_locations*100
        %%%%%%%%%%%%%1) GMF
        cell_contour_data{i,1}=raw_gmf{i};

        %%%%%%%%%%2) Contour
        temp_contour=raw_contour{i};
        par_start_idx=strfind(temp_contour,'(');
        par_end_idx=strfind(temp_contour,')');
        cut1_temp_contour=temp_contour([par_start_idx(end)+1:par_end_idx(1)-1]);
        temp_contour_split=strsplit(cut1_temp_contour,',')';
        temp_array_contour=cell2mat(cellfun(@str2num, temp_contour_split, 'UniformOutput', false));
        cell_contour_data{i,2}=temp_array_contour;

        %%%%%%%%%%%Convexhull (just because)
        con_idx=convhull(temp_array_contour);
        convex_contour=temp_array_contour(con_idx,:);
        cell_contour_data{i,3}=convex_contour;

        % % % %         figure;
        % % % %         hold on;
        % % % %         plot(temp_array_contour(:,2),temp_array_contour(:,1),'-')
        % % % %         plot(convex_contour(:,2),convex_contour(:,1),'-g')
        % % % %         axis square;
    end

    retry_save=1;
    while(retry_save==1)
        try
            save(cell_data_filename,'cell_contour_data')
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

end