import os
from rdflib.graph import Graph
from subprocess import call
import shutil
from nidmfsl.fsl_exporter.fsl_exporter import FSLtoNIDMExporter

fsl_pain_data_dir = "/Users/cmaumet/Projects/Meta-analysis/Data/" + \
    "FSL_pain_studies/tntmp"
export_dir = os.path.join(fsl_pain_data_dir, 'export')

if not os.path.exists(export_dir):
    os.makedirs(export_dir)

# print [x[0] for x in os.walk(fsl_pain_data_dir)]
# import_files = glob.glob(os.path.join(NIDMPATH, "imports", '*.ttl'))
# All studies but the 10 first (computed with SPM)
studies = next(os.walk(fsl_pain_data_dir))[1][0:1]
# [10:]

con_maps = dict()
sterr_maps = dict()

for study in studies:
    # print "\n\n"+study

    gfeat_dir = os.path.join(
        fsl_pain_data_dir, study, "gFeat", "flm_05mm.gfeat")
    assert os.path.isdir(gfeat_dir)

    # Export as NIDM-Results
    fslnidm = FSLtoNIDMExporter(feat_dir=gfeat_dir, version="1.0.0")
    fslnidm.parse()
    nidm_dir = fslnidm.export()
    print 'NIDM export available at: '+str(nidm_dir)
    shutil.copytree(nidm_dir, export_dir)

    # nidm_dir = os.path.join(gfeat_dir, "nidm")
    # assert os.path.isdir(nidm_dir)
