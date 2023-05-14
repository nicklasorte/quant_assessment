function [cell_full_gmf_contours]=fill_in_missing_contours_rev1(app,cell_full_gmf_contours,cell_gmf_data,cell_state_data,us_cont_bound)

%%%%%%%%%%%%Adding Column #3 Nick Contour) 1==State, 2==USA/USP, 3==Nick Contour, 4==Request April Contour
%%%%%%%%%%Cut those outside the USA
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STATE/USP/USA Assignments
empty_idx=find(cellfun('isempty',cell_full_gmf_contours(:,2))); 
if ~isempty(empty_idx)
    num_empty=length(empty_idx);
    for emt_idx=1:1:num_empty
        %%%%%%%Check for City/State Match then make that the bound
        %%%%%%%Check for City/State Match then make that the bound
        temp_empty_idx=empty_idx(emt_idx);
        temp_city=cell_gmf_data{temp_empty_idx,6};
        temp_state=cell_gmf_data{temp_empty_idx,7};

         if strcmp(temp_city,temp_state)==1 %%%%%%City and State Match
            state_match_idx=find(strcmp(temp_state,cell_state_data(:,6)));
            if ~isempty(state_match_idx)
                cell_full_gmf_contours{temp_empty_idx,2}=fliplr(cell_state_data{state_match_idx,7});
                cell_full_gmf_contours{temp_empty_idx,3}=1;
            elseif strcmp(temp_city,'USP') && strcmp(temp_state,'USP') %%%%%%%Check for USP
                cell_full_gmf_contours{temp_empty_idx,2}=fliplr(us_cont_bound);
                cell_full_gmf_contours{temp_empty_idx,3}=2;
            elseif strcmp(temp_city,'USA') && strcmp(temp_state,'USA') %%%%%%%Check for USA
                cell_full_gmf_contours{temp_empty_idx,2}=fliplr(us_cont_bound);
                cell_full_gmf_contours{temp_empty_idx,3}=2;
            end
         else   %%%%%%%%%%Check for Lat/Lon and then create a Nick Contour
             %%%21) Tx Lat: DecDeg
             %%%22) Tx Lon: DecDeg
             %%%25) Tx Radius
             %%%26) Rx Radius

             temp_lat_dd=cell_gmf_data{temp_empty_idx,21};
             temp_lon_dd=cell_gmf_data{temp_empty_idx,22};

             if ~isnan(temp_lat_dd) && ~isnan(temp_lon_dd)

                 %%%%%%%First check if it's outside the USA
                tf_in=inpolygon(temp_lon_dd,temp_lat_dd,us_cont_bound(:,2),us_cont_bound(:,1));

                if tf_in==0
% %                     'Outside USA'
% %                     cell_gmf_data(temp_empty_idx,:)'
% %                     pause;
                else
                    %%%'Inside USA: Create a Contour '
                    cell_full_gmf_contours{temp_empty_idx,3}=4; %%%%%%%%Ask April to make the contour 

                end
% %                  temp_radius=max(cell2mat(cell_gmf_data(temp_empty_idx,[25,26])));
% %                  temp_radius
% %                  cell_gmf_data(temp_empty_idx,:)'
% %                  pause;
% %                  if ~isnan(temp_radius)
% %                      ''
% %                  else
% %                     'NaN Radius'
% %                  end

             end
         end
    end
end
toc;
end