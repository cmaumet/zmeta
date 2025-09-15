#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import glob
# import nidmresults as nres
import nibabel as nib
import numpy as np
import sys


# ### Download data from NeuroVault

# In[2]:


import os
import glob
import logging
import zipfile
import urllib.request
from rdflib.graph import Graph
# from nidmresults import latest_owlfile as owl_file
# from nidmresults.objects.constants_rdflib import *
import json

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

data_dir = os.path.join('.', "data", "real_data")

if not os.path.isdir(data_dir):
    os.mkdir(data_dir)

# Check if the last study is available
locally = True
num_studies = 21

for i in range(1, num_studies+1):
    if not os.path.isdir(os.path.join(data_dir, "pain_{0:0>2}".format(i) + ".nidm")):
        locally = False

if not locally:
    sys.exit("Pain dataset should be downloaded from NeuroVault (see README)")

datasets = glob.glob(os.path.join(data_dir, '*.nidm'))
print(datasets)

print(locally)

# In[3]:
sys.exit("stopping here")


data_dir = os.path.join('.', "data", "real_data")

# Check that data directory exist and is not empty
assert os.path.isdir(data_dir)
assert os.listdir(data_dir)


# In[4]:


studies = glob.glob(os.path.join(data_dir, '*.nidm.zip'))
nidm_info = dict()
nidm_zip = dict()
for study in studies:
    study_name = (os.path.basename(study).split('.')[0])
    print('Loading ' + study_name)
    # Reading an existing NIDM-Results
    nidm = nres.load(study, workaround=True)
    nidm_info[study_name] = nidm.get_info()   
    nidm_zip[study_name] = study


# ## Retreive statistic and contrast files for all studies

# In[5]:


import zipfile
import scipy
from nilearn.image import new_img_like

pre_dir = os.path.join('.', 'pre')
if not os.path.exists(pre_dir):
    os.makedirs(pre_dir)

nidm_dir = os.path.join('.', 'pre', 'nidm')
if not os.path.exists(nidm_dir):
    os.makedirs(nidm_dir)


# Get the Z-statistic map, contrast map and contrast standard error map for contrast [1]  
for study_name, nidm in nidm_info.items():
    found = False
    print(study_name)
    for contrast in nidm['Contrasts']:
        if contrast['StatisticMap_contrastName'] == 'pain':
            found = True
            with zipfile.ZipFile(nidm_zip[study_name]) as z:
                if 'ZStatisticMap_atLocation' in contrast:
                    zstat_map = z.extract(contrast['ZStatisticMap_atLocation'], nidm_dir)
                    os.rename(zstat_map, os.path.join(nidm_dir, 'zstat_' + study_name + '.nii.gz'))
                else:
                    # If equivalent z-statistic is not directly available then compute it 
                    # from the T-stat and degrees of freedom                    
                    tstat_map = z.extract(contrast['StatisticMap_atLocation'], nidm_dir)
                    saved_tstat_map = os.path.join(nidm_dir, 'tstat_' + study_name + '.nii.gz')
                    os.rename(tstat_map, saved_tstat_map)
                    tstat_img = nib.load(saved_tstat_map)
            
                    dof = contrast['StatisticMap_errorDegreesOfFreedom']
                    zvalues = scipy.stats.norm.ppf(scipy.stats.t.cdf(tstat_img.get_data(), df=dof))
                    zstat_img = new_img_like(tstat_img, zvalues)
                    nib.save(zstat_img, os.path.join(nidm_dir, 'zstat_' + study_name + '.nii.gz'))
                    
                con_map = z.extract(contrast['ContrastMap_atLocation'], nidm_dir)
                os.rename(con_map, os.path.join(nidm_dir, 'con_' + study_name + '.nii.gz'))
                stderr_map = z.extract(contrast['ContrastStandardErrorMap_atLocation'], nidm_dir)
                os.rename(stderr_map, os.path.join(nidm_dir, 'stderr_' + study_name + '.nii.gz'))
           
    if not found:
        raise Exception('No group contrast found for study: ' + study)


# ## Rescale the data according to first-level contrast weights

# In[6]:


from shutil import copy

spm_studies = ['pain_01', 'pain_02', 'pain_03', 'pain_04', 'pain_05', 'pain_06', 
               'pain_07', 'pain_08', 'pain_09', 'pain_10']

sum_weights = [('pain_01', 1), ('pain_02', 1), ('pain_03', 1), ('pain_04', 1),
               ('pain_05', 1), ('pain_06', 1), ('pain_07', 1), ('pain_08', 2),
               ('pain_09', 2), ('pain_10', 2), ('pain_11', 2), ('pain_12', 1),
               ('pain_13', 2), ('pain_14', 4), ('pain_15', 4), ('pain_16', 4),
               ('pain_17', 2), ('pain_18', 2), ('pain_19', 1), ('pain_20', 2),
               ('pain_21', 1)]

export_dir = os.path.join('.', 'pre', 'scaled')

if not os.path.exists(export_dir):
    os.makedirs(export_dir)

def divide_by_factor_and_save(file, factor, scaled_filename=None):
    img = nib.load(file)
    scaled_img = nib.Nifti1Image(np.divide(img.get_data(), factor), img.get_qform())
    nib.save(scaled_img, scaled_filename)

def square_and_save(file, squared_filename=None):
    img = nib.load(file)
    squared_img = nib.Nifti1Image(np.square(img.get_data()), img.get_qform())
    nib.save(squared_img, squared_filename)
    
for study, factor in sum_weights:
    print(study)
    print(factor)
    if study in spm_studies:
        soft_factor = 2
    else:
        soft_factor = 100
            
#     else:
#         soft_factor = 100
    print(soft_factor)
    print('---')
    
    con_map = os.path.join(nidm_dir, 'con_' + study + '.nii.gz')
    divide_by_factor_and_save(con_map, factor*soft_factor, 
                              os.path.join(export_dir, 'con_' + study + '_scaled.nii'))
    stderr_map = os.path.join(nidm_dir, 'stderr_' + study + '.nii.gz')
    scl_stderr_map = os.path.join(export_dir, 'stderr_' + study + '_scaled.nii')
    divide_by_factor_and_save(stderr_map, factor*soft_factor, scl_stderr_map)
    # Square to get variance instead of standard deviation
    square_and_save(scl_stderr_map, os.path.join(export_dir, 'varcon_' + study + '_scaled.nii'))
    
    # Z-map is scale independent    
    z_map = os.path.join(nidm_dir, 'zstat_' + study + '.nii.gz')
    nib.save(nib.load(z_map), os.path.join(export_dir, 'zstat_' + study + '.nii'))


# ### Create mask (required for FSL analysis)

# In[7]:


mask = None
for study_name in nidm_info.keys():
    varcon = os.path.join(export_dir, 'varcon_' + study_name + '_scaled.nii')
    varcon_img = nib.load(varcon)
    zero_positions = np.nonzero(np.logical_or(
        varcon_img.get_data()==0,
        np.isnan(varcon_img.get_data())))
    
    if mask is None:
        mask = np.ones(varcon_img.shape)
        mask[zero_positions] = 0
    else:
        mask[zero_positions] = 0

any_img = nib.load(varcon)
mask_img = nib.Nifti1Image(mask, any_img.get_qform())
nib.save(mask_img, os.path.join(export_dir, 'mask.nii.gz'))


# In[8]:


results_dir = os.path.join('.', 'results')
if not os.path.exists(results_dir):
    os.makedirs(results_dir)


# In[ ]:




