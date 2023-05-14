function [cell_state_data]=load_state_maps_rev1(app)

tic;
load('cell_state_data2.mat','cell_state_data')
%%%Make each state convex polygon to simplify
[num_state,num_col]=size(cell_state_data);
tic;
for state_idx=1:1:num_state
    temp_lat=cell2mat(cell_state_data(state_idx,2));
    temp_lon=cell2mat(cell_state_data(state_idx,3));

    temp_zone_bound=horzcat(temp_lat',temp_lon');
    temp_zone_bound=temp_zone_bound(~isnan(temp_zone_bound(:,1)),:);

    k=convhull(temp_zone_bound(:,2),temp_zone_bound(:,1));
    zone_bound=temp_zone_bound(k,:);
    cell_state_data{state_idx,num_col+1}=zone_bound;
end
toc;


end