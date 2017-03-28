import numpy as np
import scipy
import matplotlib.pyplot as plt


from matplotlib import rc
# Set up latex settings
# rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
## for Palatino and other serif fonts use:
#rc('font',**{'family':'serif','serif':['Palatino']})


p_uppers = dict()
p_lowers = dict()

# Pre-computed confidence interval for QQplots for more effeciency
data_sizes = [27000, 38*30*30*30, 270000]
for d in data_sizes:
    x_log_spaced = np.logspace(np.log10(1), np.log10(d), num=500, endpoint=False)
    x_log_spaced = np.append(x_log_spaced,d) # Manually add endpoint to avoid rounding errors
    
    p_uppers[int(d)] = (
        [t/d for t in x_log_spaced],
        [scipy.stats.beta.ppf(0.025, t, d-t+1) for t in x_log_spaced]
    )
    p_lowers[int(d)] = (
        [t/d for t in x_log_spaced],
        [scipy.stats.beta.ppf(0.975, t, d-t+1) for t in x_log_spaced]
    )

def qqplot(data, dist, ax2, title, rightTail, *args, **kwargs):
    p_th = [t/data.size for t in range(1,data.size+1)]

    if rightTail:
        p_obs = dist.sf(data, *args)
        ptitle = 'Q-Q plot (right tail)'
    else:
        p_obs = dist.cdf(data, *args)
        ptitle = 'Q-Q plot (left tail)'
    
    line1, = ax2.loglog(p_th, sorted(p_obs), '.', linewidth=1, markersize=3)
    ax2.plot(p_th, p_th, '-')
    x, p_upper = p_uppers[int(data.size)]
    ax2.plot(x, p_upper, 'c-')
    x, p_lower = p_lowers[int(data.size)]
    ax2.plot(x, p_lower, 'c-')   
    ax2.set_title(ptitle)
    # ax2.legend(loc='lower right')
    ax2.invert_yaxis()
    ax2.invert_xaxis()
    
    
def distribution_plot(title, data, dist, *args, **kwargs):
    np.random.seed(0)
    num_bins = 100
    

    f, (ax1, ax2, ax3) = plt.subplots(1, 3, sharey=False, figsize=(10,5))

    # histogram plot
    n, bins, patches = ax1.hist(data, num_bins, normed=True)

#     # fit distribution and estimate parameters
#     param = dist.fit(data)
#     print(param)
#     y = dist.pdf(bins, *param[:-2], loc=param[-2], scale=param[-1])
    
    # known distribution
    y = dist.pdf(bins, *args)
    
    ax1.plot(bins, y, '-', label='Theoretical null distribution')
    # ax1.legend(loc='lower right')
    ax1.legend(bbox_to_anchor=(4, 1), loc='upper left', ncol=1)
    ax1.set_title('Histogram')
    
    rc('text', usetex=True)
    plt.suptitle(title, fontsize=20)
    rc('text', usetex=False)
    # plt.title(r"\TeX\ is Number ", fontsize=16, color='gray')
    # Make room for large title.
    plt.subplots_adjust(top=0.85)
    
    # qq-plot plot
    qqplot(data, dist, ax2, title, True, *args)
    qqplot(data, dist, ax3, title, False, *args)

    plt.show()
    
def chi2_distribution_plot(data, title, *args, **kwargs):   
    distribution_plot(title, data, scipy.stats.chi2, *args)
    
def t_distribution_plot(data, title, *args, **kwargs):   
    distribution_plot(title, data, scipy.stats.t, *args)

def z_distribution_plot(data, title, *args, **kwargs):    
    distribution_plot(title, data, scipy.stats.norm, *args)