import os
from nidmfsl.fsl_exporter.fsl_exporter import FSLtoNIDMExporter

fsl_pain_data_dir = \
    "/Users/cmaumet/Projects/Meta-analysis/Data/FSL_pain_studies/tntmp"

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
    fslnidm = FSLtoNIDMExporter(feat_dir=gfeat_dir, version="1.2.0")
    fslnidm.parse()
    zipped_dir = fslnidm.export()

    print zipped_dir
    if study[0:4] == "mlee":
        abv = "l"
    else:
        abv = study[0]
    abv = abv + study[-3:]
    os.rename(zipped_dir, os.path.join(export_dir, abv + ".nidm.zip"))

    # nidm_dirname = zipped_dir.split("/")[-1].replace(".nidm.zip", "")
    # print nidm_dirname


    # if not os.path.exists(nidm_export_dir):
    #     os.makedirs(nidm_export_dir)

    # with zipfile.ZipFile(zipped_dir) as z:
    #     z.extract('nidm.ttl', nidm_export_dir)
    #     z.extract('nidm.provn', nidm_export_dir)

    # # Replace "group mean ac" and "group mean" by "pain: group mean"
    # ttl = os.path.join(nidm_export_dir, "nidm.ttl")
    # assert os.path.isfile(ttl)

    # with open(ttl, "r") as fp:
    #     ttl_txt = fp.read()

    # ttl_txt = ttl_txt.replace("group mean", "pain: group mean")
    # fw = open(ttl, "w")
    # fw.write(ttl_txt)
    # fw.close()
