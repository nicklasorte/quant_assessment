function [us_cont_bound]=load_us_bound_rev1(app)

tic;
load('us_cont.mat','us_cont')
k=convhull(us_cont(:,2),us_cont(:,1));
us_cont_bound=us_cont(k,:);
toc;

end