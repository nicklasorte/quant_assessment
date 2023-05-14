clear;
clc;
close all;
app=NaN(1);
format shortG
%%%%format longG
top_start_clock=clock;


%%%%%%Import the GMF Contours 
folder1='C:\Local Matlab Data\SRA\QA_github'  %%%%%%%%Change this folder location to where you put the files.
cd(folder1)
addpath(folder1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Input Files 
temp_label_4GHz='4GHz';
contour_excel_filename_4GHz='QA_database_4_GHz.csv';
gmf_filename_4GHz='GMF4399_4941.xlsx';
freq_bands_4GHz=vertcat(horzcat(4.4,4.94))*1000;  %%%%%%%%%%%In MHz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load in Census/Map Data
tic;
load('Cascade_new_full_census_2010.mat','new_full_census_2010')%%%%%%%Geo Id, Center Lat, Center Lon,  NLCD (1-4), Population
[cell_state_data]=load_state_maps_rev1(app);
[us_cont_bound]=load_us_bound_rev1(app);
toc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load in the Contours from the QA 
[cell_contour_data_4GHz]=read_raw_contours_rev1(app,temp_label_4GHz,contour_excel_filename_4GHz);

%%%%%%%%%%%%cell_contour_data
%%%1) GMF Serial Number
%%%2) Contour
%%%3) Convexhull Contour

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load in the GMF
tf_read_gmf=0%1%0%1   %%%%%%%%%%%%%%%%Only do this is we are importing new data above. Else it will load that last pulled data.
[cell_gmf_data_4GHz]=import_raw_gmf_all_fields_rev2(app,tf_read_gmf,gmf_filename_4GHz,temp_label_4GHz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Filter GMF Data based on frequency
[cell_gmf_data_4GHz]=quick_freq_filter_rev2(app,cell_gmf_data_4GHz,freq_bands_4GHz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Cross Reference the Contours and the GMF
[cell_full_gmf_contours_4GHz]=match_gmf_asn_rev1(app,cell_contour_data_4GHz,cell_gmf_data_4GHz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Create STATE/USP Contours that are Missing
[cell_full_gmf_contours_4GHz]=fill_in_missing_contours_rev1(app,cell_full_gmf_contours_4GHz,cell_gmf_data_4GHz,cell_state_data,us_cont_bound);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Print out the GMF (in excel) that does not have contours.
print_missing_contours_gmf_rev1(app,cell_full_gmf_contours_4GHz,cell_gmf_data_4GHz,temp_label_4GHz)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Convert the Contours to a Geosphae and create a kml file
tf_create_kml=0%1  %%%%It takes some time to write all the contours to a kml file.
[geoshape_4GHz]=gmf_contours_to_kml_rev1(app,tf_create_kml,cell_full_gmf_contours_4GHz,temp_label_4GHz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Effective Spectrum Usage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Now Find the Pop Impact Freq and Time for All Contours
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%and Calculate the "Sub-band" Usage
tf_calc_pop_impact=0%0%1 %%%%%%%%%%%%%%%%Only do this is we are importing new data above. (Recalculate), Else it will load that last calculated.
tf_calc_sub_band=0%1%0%1  %%%%%%%%%%%%%%%%Only do this is we are importing new data above. (Recalculate), Else it will load that last calculated.


%%%%%%%%%%USP excluded
tf_ignore_usp=1;
[cell_census_freq_time_4GHz,gmf_contours_4GHz]=find_census_pop_freq_time_rev1(app,cell_gmf_data_4GHz,cell_full_gmf_contours_4GHz,tf_calc_pop_impact,temp_label_4GHz,freq_bands_4GHz,new_full_census_2010,tf_ignore_usp);
[cell_sub_band_data_4GHz]=find_sub_band_usage_rev1(app,temp_label_4GHz,freq_bands_4GHz,cell_census_freq_time_4GHz,new_full_census_2010,tf_ignore_usp,tf_calc_pop_impact,tf_calc_sub_band);

% %%%%%%%%%%%%USP included
% tf_ignore_usp=0;
% [cell_census_freq_time_4GHz_usp,gmf_contours_4GHz_usp]=find_census_pop_freq_time_rev1(app,cell_gmf_data_4GHz,cell_full_gmf_contours_4GHz,tf_calc_pop_impact,temp_label_4GHz,freq_bands_4GHz,new_full_census_2010,tf_ignore_usp);
% [cell_sub_band_data_4GHz_usp]=find_sub_band_usage_rev1(app,temp_label_4GHz,freq_bands_4GHz,cell_census_freq_time_4GHz_usp,new_full_census_2010,tf_ignore_usp,tf_calc_pop_impact,tf_calc_sub_band);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Census and PEA Impact
load('cell_pea_census_data.mat','cell_pea_census_data') %%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid
tf_calc_pea=0%1   %%%%%%%%%%%%%%%%Only do this is we are importing new data above. (Recalculate), Else it will load that last calculated.

%%%%%%%%%%USP excluded
tf_ignore_usp=1;
[cell_census_hist_4GHz]=calculate_usage_rev1(app,temp_label_4GHz,tf_ignore_usp,cell_census_freq_time_4GHz,freq_bands_4GHz,new_full_census_2010,cell_sub_band_data_4GHz);
[cell_pea_hist_4GHz]=calculate_PEA_usage_rev1(app,temp_label_4GHz,tf_calc_pea,tf_ignore_usp,freq_bands_4GHz,cell_census_hist_4GHz,cell_pea_census_data);

% %%%%%%%%%%%%USP included
% tf_ignore_usp=0;
% [cell_census_hist_4GHz_usp]=calculate_usage_rev1(app,temp_label_4GHz,tf_ignore_usp,cell_census_freq_time_4GHz_usp,freq_bands_4GHz,new_full_census_2010,cell_sub_band_data_4GHz_usp);
% [cell_pea_hist_4GHz_usp]=calculate_PEA_usage_rev1(app,temp_label_4GHz,tf_calc_pea,tf_ignore_usp,freq_bands_4GHz,cell_census_hist_4GHz_usp,cell_pea_census_data);


end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end
'Done'





