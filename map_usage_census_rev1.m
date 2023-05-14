function map_usage_census_rev1(app,cell_census_hist,array_freq_bands,tf_ignore_usp,temp_label,new_full_census_2010)


census_usage=vertcat(cell_census_hist{:,5});
usage_range=max(array_freq_bands)-min(array_freq_bands);
color_set=flipud(plasma(usage_range));
over_idx=find(census_usage>usage_range);
census_usage(over_idx)=usage_range;

close all;
f1=figure;
AxesH = axes;
hold on;
mid_lat=new_full_census_2010(:,2);
mid_lon=new_full_census_2010(:,3);
%%%%%%%%%Need to plot a min and max
scatter(0,0,1,0,'filled');
scatter(0,0,1,usage_range,'filled');
[~,sort_usage_idx]=sort(census_usage,'ascend');
scatter(mid_lon(sort_usage_idx),mid_lat(sort_usage_idx),10,census_usage(sort_usage_idx),'filled');
h = colorbar('southoutside');
ylabel(h, 'Federal Spectrum Usage [megahertz]')
colormap(f1,color_set)
grid on;
xlabel('Longitude')
ylabel('Latitude')
max_lon=-65;
min_lon=-127;
max_lat=49;
min_lat=25;
xlim([min_lon,max_lon])
ylim([min_lat,max_lat])
%%title({strcat('Effective Spectrum Usage [Frequency and Time]')})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
pause(0.1)
    if tf_ignore_usp==1
        filename1=strcat('Effective_Federal_Usage_',temp_label,'.png');
    else
        filename1=strcat('Effective_Federal_Usage_',temp_label,'_USP.png');
    end
retry_save=1;
while(retry_save==1)
    try
        saveas(gcf,char(filename1))
        pause(0.1)
        retry_save=0;
    catch
        retry_save=1;
        pause(1)
    end
end
pause(0.1)




census_availability=vertcat(cell_census_hist{:,6});
available_range=max(array_freq_bands)-min(array_freq_bands);
color_set2=plasma(available_range);
over_idx=find(census_availability>usage_range);
census_availability(over_idx)=usage_range;


close all;
f1=figure;
AxesH = axes;
hold on;
%%%%%%%%%Need to plot a min and max
scatter(0,0,1,0,'filled');
scatter(0,0,1,available_range,'filled');
[~,sort_avail_idx]=sort(census_availability,'ascend');
scatter(mid_lon(sort_avail_idx),mid_lat(sort_avail_idx),10,census_availability(sort_avail_idx),'filled');
h = colorbar('southoutside');
ylabel(h, 'Effective Available Spectrum [megahertz]')
colormap(f1,color_set2)
grid on;
xlabel('Longitude')
ylabel('Latitude')
max_lon=-65;
min_lon=-127;
max_lat=49;
min_lat=25;
xlim([min_lon,max_lon])
ylim([min_lat,max_lat])
%%%%%%title({strcat('Effective Available Spectrum [Frequency and Time]')})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
pause(0.1)
    if tf_ignore_usp==1
        filename1=strcat('Effective_Available_Spectrum_',temp_label,'.png');
    else
        filename1=strcat('Effective_Available_Spectrum_',temp_label,'_USP.png');
    end
retry_save=1;
while(retry_save==1)
    try
        saveas(gcf,char(filename1))
        pause(0.1)
        retry_save=0;
    catch
        retry_save=1;
        pause(1)
    end
end


end