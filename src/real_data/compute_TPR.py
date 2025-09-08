#!/usr/bin/env python
# coding: utf-8

# In[1]:


import nibabel as nib
import os
from nibabel.processing import resample_from_to
import numpy as np
# out = resample_from_to(img, img)


# In[2]:


pain_GT_img = nib.load(os.path.join('.', 'GT', 'pain_pAgF_z_FDR_0.01.nii.gz'))


# ### Save true positive rate for each p-value threshold

# #### fishers

# In[3]:


import csv
from scipy import stats


# In[4]:


GT = np.zeros(pain_GT_img.shape)
GT[np.nonzero(pain_GT_img.get_data()>0)] = 1
# num_of_positives = np.sum(pain_GT_img.get_data()>0)


# In[5]:


def save_TPR_to_csv(meth, csv_file, GT, p_log10_file=None, z_file=None):
    if not p_log10_file:
        if not z_file:
            raise Exception('One of p_log10_file or z_file must be specified')
        else:
            z_img = nib.load(z_file)
            p_values = stats.norm.sf(z_img.get_data())
            minuslog10p_values = -np.log10(p_values)
    else:
        p_img = nib.load(p_log10_file)
        minuslog10p_values = p_img.get_data()

       
    # Mask out NaN values    
    in_mask = np.nonzero(np.logical_not(np.isnan(minuslog10p_values)))
    minuslog10p_values = minuslog10p_values[in_mask]
    GT = GT[in_mask]
    
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

csv_file=os.path.join('results', 'realdata_TPR.csv')

# Write csv file header
with open(csv_file,'w') as csvf:
    spamwriter = csv.writer(csvf)
    spamwriter.writerow(['Method', 'p', 'TPR'])   
    
save_TPR_to_csv('fishers', csv_file, GT, 
                p_log10_file=os.path.join('results', 'fishers', 'fishers_ffx_minus_log10_p.nii'))
save_TPR_to_csv('stouffers', csv_file, GT, 
                p_log10_file=os.path.join('results', 'stouffers', 'stouffers_ffx_minus_log10_p.nii'))
save_TPR_to_csv('weightedZ', csv_file, GT, 
                p_log10_file=os.path.join('results', 'WeightedZ', 'weightedz_ffx_minus_log10_p.nii'))
save_TPR_to_csv('stouffersMFX', csv_file, GT, 
                p_log10_file=os.path.join('results', 'StouffersMFX', 'stouffers_rfx_minus_log10_p.nii'))
save_TPR_to_csv('megaFFX_FSL', csv_file, GT, 
                z_file=os.path.join('results', 'megaFFX_FSL', 'stats', 'zstat1.nii.gz'))
save_TPR_to_csv('megaMFX', csv_file, GT, 
                z_file=os.path.join('results', 'megaMFX', 'stats', 'zstat1.nii.gz'))
save_TPR_to_csv('megaRFX', csv_file, GT, 
                p_log10_file=os.path.join('results', 'megaRFX', 'mega_rfx_minus_log10_p.nii'))
save_TPR_to_csv('permutCon', csv_file, GT, 
                p_log10_file=os.path.join('results', 'permutCon', 'lP+.img'))
save_TPR_to_csv('permutZ', csv_file, GT, 
                p_log10_file=os.path.join('results', 'permutZ', 'lP+.img'))


# In[ ]:




