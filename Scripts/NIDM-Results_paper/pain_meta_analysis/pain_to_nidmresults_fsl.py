import os
import shutil
from nidmfsl.fsl_exporter.fsl_exporter import FSLtoNIDMExporter

fsl_pain_data_dir = "/Users/cmaumet/Projects/Meta-analysis/Data/" + \
    "FSL_pain_studies/tntmp"

# print [x[0] for x in os.walk(fsl_pain_data_dir)]
# import_files = glob.glob(os.path.join(NIDMPATH, "imports", '*.ttl'))
# All studies but the 10 first (computed with SPM)
studies = next(os.walk(fsl_pain_data_dir))[1][10:]
print studies

export_dir = os.path.join(fsl_pain_data_dir, '..', 'export_fsl')

if not os.path.exists(export_dir):
    os.makedirs(export_dir)

con_maps = dict()
sterr_maps = dict()

for study in studies:
    print "\n\n"+study

    gfeat_dir = os.path.join(
        fsl_pain_data_dir, study, "gFeat", "flm_05mm.gfeat")
    assert os.path.isdir(gfeat_dir)

    # Export as NIDM-Results
    fslnidm = FSLtoNIDMExporter(feat_dir=gfeat_dir, version="1.1.0")
    fslnidm.parse()
    nidm_dir = fslnidm.export()
    nidm_dirname = nidm_dir.split("/")[-1]

    nidm_export_dir = os.path.join(export_dir, study+"_"+nidm_dirname)
    shutil.move(nidm_dir, nidm_export_dir)

    assert os.path.isdir(nidm_export_dir)

    # Replace "group mean ac" and "group mean" by "pain: group mean"
    ttl = os.path.join(nidm_export_dir, "nidm.ttl")
    assert os.path.isfile(ttl)

    with open(ttl, "r") as fp:
        ttl_txt = fp.read()

    ttl_txt = ttl_txt.replace("group mean", "pain: group mean")
    fw = open(ttl, "w")
    fw.write(ttl_txt)
    fw.close()
