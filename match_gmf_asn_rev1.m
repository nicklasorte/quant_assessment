function [cell_full_gmf_contours]=match_gmf_asn_rev1(app,cell_contour_data,cell_gmf_data)

[num_contours,~]=size(cell_contour_data);
[num_gmf,num_cols]=size(cell_gmf_data);
cell_full_gmf_contours=cell(num_gmf,2); %%%%1)GMF ASN (in the GMF order), 2) Contours (Convexhull)
for gmf_idx=1:1:num_gmf
    temp_gmf_asn=cell_gmf_data{gmf_idx,1};
    cell_full_gmf_contours{gmf_idx,1}=temp_gmf_asn;
    match_idx=find(contains(cell_contour_data(:,1),temp_gmf_asn));
    if length(match_idx)>1
        'Possible Error: More than 1 match'
        temp_gmf_asn
        cell_contour_data(match_idx,1)
        pause;
    elseif length(match_idx)==1
        cell_full_gmf_contours{gmf_idx,2}=cell_contour_data{match_idx,3};
    end
end

