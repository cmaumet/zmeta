#!/usr/bin/env python
# coding: utf-8

# In[1]:


import nibabel as nib
import os
from nibabel.processing import resample_from_to
import numpy as np
from sklearn.metrics import roc_auc_score
# out = resample_from_to(img, img)


# In[2]:

scriptDir = os.path.dirname(os.path.abspath(__file__))
rootDir = os.path.abspath(os.path.join(scriptDir, os.pardir, os.pardir))


pain_GT_img = nib.load(os.path.join(rootDir, 'data', 'raw', 'real_data', 'GT', 'pain_uniformity-test_z_FDR_0.01.nii'))


# ### Save true positive rate for each p-value threshold

# #### fishers

# In[3]:


import csv
from scipy import stats


# In[4]:


GT = np.zeros(pain_GT_img.shape)
GT[np.nonzero(pain_GT_img.get_fdata()>0)] = 1
# num_of_positives = np.sum(pain_GT_img.get_fdata()>0)


# In[5]:


def save_TPR_to_csv(meth, csv_file, GT, p_log10_file=None, z_file=None, mask_file=None):
    if not p_log10_file:
        if not z_file:
            raise Exception('One of p_log10_file or z_file must be specified')
        else:
            z_img = nib.load(z_file)
            p_values = stats.norm.sf(z_img.get_fdata())
            minuslog10p_values = -np.log10(p_values)
    else:
        p_img = nib.load(p_log10_file)
        minuslog10p_values = p_img.get_fdata()

    # Mask using mask
    mask_img = nib.load(mask_file)
    in_mask = np.nonzero(mask_img.get_fdata()) #np.nonzero(np.logical_not(np.isnan(minuslog10p_values)))
    minuslog10p_values = minuslog10p_values[in_mask]
    GT = GT[in_mask]

    # Remove Nan values
    is_nan = np.isnan(minuslog10p_values);
    minuslog10p_values = minuslog10p_values[~is_nan]
    GT = GT[~is_nan]

    Positives = np.sum(GT)
    
    with open(csv_file,'a') as csvfile:
        spamwriter = csv.writer(csvfile)
        # Traverse p-values in log-space from 10-8 to 1
        for p in np.append([0], np.logspace(-15, 0, num=100)):
            if not p == 0:
                TruePositives = np.sum(np.logical_and(minuslog10p_values > -np.log10(p), GT>0))
            else:
                TruePositives = 0
            if p<=1:
                spamwriter.writerow([meth, p, TruePositives/Positives])

    # auc_file = csv_file.replace("_TPR", "_AUC");
    # auc = roc_auc_score(GT, minuslog10p_values);

    # with open(auc_file,'a') as aucfile:
    #     aucwriter = csv.writer(aucfile)
    #     aucwriter.writerow([meth, auc])
    

real_data_resdir = os.path.join(rootDir, 'data', 'derived', 'real_data')

csv_file=os.path.join(rootDir, 'results', 'realdata_TPR.csv')

# Write csv file header
with open(csv_file,'w') as csvf:
    spamwriter = csv.writer(csvf)
    spamwriter.writerow(['Method', 'p', 'TPR'])   

# auc_file = csv_file.replace("_TPR", "_AUC");
# with open(auc_file,'w') as aucfile:
#     aucwriter = csv.writer(aucfile)
#     aucwriter.writerow(['Method', 'AUC'])
    
mask_file = os.path.join(real_data_resdir, 'mask.nii');

save_TPR_to_csv('fishers', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'fishers', 'fishers_ffx_minus_log10_p.nii'),
                mask_file=mask_file)

save_TPR_to_csv('stouffers', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'stouffers', 'stouffers_ffx_minus_log10_p.nii'),
                mask_file=mask_file)
save_TPR_to_csv('weightedZ', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'WeightedZ', 'weightedz_ffx_minus_log10_p.nii'),
                mask_file=mask_file)
save_TPR_to_csv('stouffersMFX', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'StouffersMFX', 'stouffers_rfx_minus_log10_p.nii'),
                mask_file=mask_file)
save_TPR_to_csv('megaFFX', csv_file, GT, 
                z_file=os.path.join(real_data_resdir, 'megaFFX', 'stats', 'zstat1.nii.gz'),
                mask_file=mask_file)
save_TPR_to_csv('megaMFX', csv_file, GT, 
                z_file=os.path.join(real_data_resdir, 'megaMFX', 'stats', 'zstat1.nii.gz'),
                mask_file=mask_file)
save_TPR_to_csv('megaRFX', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'megaRFX', 'mega_rfx_minus_log10_p.nii'),
                mask_file=mask_file)
save_TPR_to_csv('permutCon', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'permutCon', 'lP+.img'),
                mask_file=mask_file)
save_TPR_to_csv('permutZ', csv_file, GT, 
                p_log10_file=os.path.join(real_data_resdir, 'permutZ', 'lP+.img'),
                mask_file=mask_file)


# In[ ]:




