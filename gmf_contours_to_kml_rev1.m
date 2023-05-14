function [geos]=gmf_contours_to_kml_rev1(app,tf_create_kml,cell_full_gmf_contours,temp_label)



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Save the Contours as kml files
    non_empty_idx=find(~cellfun('isempty',cell_full_gmf_contours(:,2)));
    non_empty_contours=cell_full_gmf_contours(non_empty_idx,:);
    [num_contours,~]=size(non_empty_contours)
    temp_cell_lat=cell(num_contours,1);
    temp_cell_lon=cell(num_contours,1);
    temp_cell_name=non_empty_contours([1:num_contours],1);
    tic;
    for i=1:1:num_contours
        temp_bound=non_empty_contours{i,2};
        [temp_lon,temp_lat]=poly2cw(temp_bound(:,1),temp_bound(:,2));
        temp_cell_lat{i}=temp_lat;
        temp_cell_lon{i}=temp_lon;
    end
    toc;

    tic;
    geos=geoshape(temp_cell_lat,temp_cell_lon);
    geos.Name=temp_cell_name;
    geos.Geometry='polygon';
    if tf_create_kml==1
        kmlwrite(strcat(temp_label,'.kml'), geos, 'Name', geos.Name, 'Description',{},'EdgeColor','w','FaceColor','b','FaceAlpha',0.5,'LineWidth',3);
        toc;
    end

