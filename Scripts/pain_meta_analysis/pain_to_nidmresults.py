# import glob
import os
from rdflib.graph import Graph
from subprocess import call
import shutil
# from nidmfsl.fsl_exporter.fsl_exporter import FSLtoNIDMExporter

fsl_pain_data_dir = "/Users/cmaumet/Projects/Meta-analysis/Data/" + \
    "FSL_pain_studies/tntmp"

# print [x[0] for x in os.walk(fsl_pain_data_dir)]
# import_files = glob.glob(os.path.join(NIDMPATH, "imports", '*.ttl'))
studies = next(os.walk(fsl_pain_data_dir))[1]

con_maps = dict()
sterr_maps = dict()

for study in studies:
    # print "\n\n"+study

    gfeat_dir = os.path.join(
        fsl_pain_data_dir, study, "gFeat", "flm_05mm.gfeat")
    assert os.path.isdir(gfeat_dir)

    # # Export as NIDM-Results
    # fslnidm = FSLtoNIDMExporter(feat_dir=gfeat_dir, version="1.0.0")
    # fslnidm.parse()
    # nidm_dir = fslnidm.export()
    # print 'NIDM export available at: '+str(nidm_dir)

    nidm_dir = os.path.join(gfeat_dir, "nidm")
    assert os.path.isdir(nidm_dir)

    nidm_doc = os.path.join(nidm_dir, "nidm.ttl")

    nidm_graph = Graph()
    nidm_graph.parse(nidm_doc, format='turtle')

    query = """
    prefix prov: <http://www.w3.org/ns/prov#>
    prefix nidm: <http://purl.org/nidash/nidm#>

    prefix contrast_estimation: <http://purl.org/nidash/nidm#NIDM_0000001>
    prefix contrast_map: <http://purl.org/nidash/nidm#NIDM_0000002>
    prefix stderr_map: <http://purl.org/nidash/nidm#NIDM_0000013>
    prefix contrast_name: <http://purl.org/nidash/nidm#NIDM_0000085>
    prefix statistic_map: <http://purl.org/nidash/nidm#NIDM_0000076>
    prefix mask_map: <http://purl.org/nidash/nidm#NIDM_0000054>

    SELECT ?contrastName ?con_file ?std_file ?mask_file WHERE {
     ?con_id a contrast_map: ;
          contrast_name: ?contrastName ;
          prov:atLocation ?con_file .
     ?std_id a stderr_map: ;
          prov:atLocation ?std_file .
     ?con_est a contrast_estimation: .
     ?con_id prov:wasGeneratedBy ?con_est .
     ?std_id prov:wasGeneratedBy ?con_est .
     ?con_est prov:used ?mask_id .
     ?mask_id a mask_map: ;
          prov:atLocation ?mask_file .
    }

    """
    sd = nidm_graph.query(query)

    if sd:
        for row in sd:
            con_name, con_file, std_file, mask_file = row

            if str(con_name) == "group mean ac" or \
               str(con_name) == "group mean":
                con_maps[study] = str(con_file).replace("file://.", nidm_dir)
                sterr_maps[study] = \
                    str(std_file).replace("file://.", nidm_dir)
                mask = str(mask_file).replace("file://.", nidm_dir)
            # # else:
            # #     print "con_name=--"+str(con_name)+"--"

            # print "\n\nrow:"
            # for el in row:
            #     print str(el)
    else:
        print "not found"

call(["fslmerge -t cope.nii.gz "+" ".join(con_maps.values())], shell=True)
call(["fslmerge -t varcope.nii.gz "+" ".join(sterr_maps.values())], shell=True)

# FIXME: should use a combined mask across all studies
shutil.copyfile(
    mask,
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "mask.nii.gz"))

call(["flameo --cope=cope --vc=varcope --ld=stats --dm=pain_meta_analysis.mat"
      " --cs=pain_meta_analysis.grp --tc=pain_meta_analysis.con "
      "--mask=mask.nii.gz --runmode=flame1"], shell=True)
