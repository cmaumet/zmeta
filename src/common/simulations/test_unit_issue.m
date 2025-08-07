sigmsq=2;
k = 1/2;
prop_k = 1/2;

nbins = 100;

n_meta = 100000;
n_studies = 10;
n_subjects = 25;


sigmsq_subject=sigmsq*n_subjects;
x = normrnd(0, sqrt(sigmsq_subject), [n_meta, n_studies, n_subjects]);

mean_per_study = mean(x,3);
% std_per_study = std(x,0,3); useless for RFX

study_factor = ones(n_meta, n_studies);
study_factor(:, 1:ceil(n_studies*prop_k)) = k;

t_x = mean(mean_per_study,2)./(std(mean_per_study,0,2)./sqrt(n_studies));
t_y = mean(mean_per_study.*study_factor,2)./(std(mean_per_study.*study_factor,0,2)./sqrt(n_studies));
p_x = tcdf(t_x, n_studies-1, 'upper');
p_y = tcdf(t_y, n_studies-1, 'upper');
% figure(33);
% close()
figure(33);hold on;
% subplot(3,1,1);hist(x(:), nbins)
subplot(2,2,1);hist(t_x, nbins)
axis([-5 5 0 n_meta/20])
subplot(2,2,2);hist(t_y, nbins)
axis([-5 5 0 n_meta/20])
subplot(2,2,3);plot(norminv(1-((1:n_meta)/n_meta))', norminv(1-sort(p_x))-norminv(1-((1:n_meta)/n_meta))', '.-')
hold on;plot(norminv(1-((1:n_meta)/n_meta))', norminv(1-sort(p_y))-norminv(1-((1:n_meta)/n_meta))', '.r-')
xlim([0 5])

% hist(p, nbins)

