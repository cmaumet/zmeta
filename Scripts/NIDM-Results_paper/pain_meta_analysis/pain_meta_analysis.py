import os
from rdflib.graph import Graph
from subprocess import check_call
import shutil

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
data_dir = os.path.join(SCRIPT_DIR, "data")

studies = next(os.walk(data_dir))[1]
print studies

con_maps = dict()
sterr_maps = dict()
mask_maps = dict()

ma_mask_name = "meta_analysis_mask"
ma_mask = None

SPM_SOFTWARE = "http://neurolex.org/wiki/nif-0000-00343"
FSL_SOFTWARE = "http://neurolex.org/wiki/birnlex_2067"

for study in studies:
    nidm_dir = os.path.join(data_dir, study)
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

    SELECT ?contrastName ?con_file ?std_file ?mask_file ?software WHERE {
     ?con_id a contrast_map: ;
          contrast_name: ?contrastName ;
          prov:atLocation ?con_file .
     ?std_id a stderr_map: ;
          prov:atLocation ?std_file .
     ?con_est a contrast_estimation: ;
              prov:wasAssociatedWith ?soft_id.
     ?con_id prov:wasGeneratedBy ?con_est .
     ?std_id prov:wasGeneratedBy ?con_est .
     ?con_est prov:used ?mask_id .
     ?mask_id a mask_map: ;
          prov:atLocation ?mask_file .
     ?soft_id a ?software .

      FILTER(?software NOT IN (prov:SoftwareAgent, prov:Agent))
    }

    """
    sd = nidm_graph.query(query)

    if sd:
        for row in sd:
            con_name, con_file, std_file, mask_file, software = row

            if str(con_name) == "pain: group mean ac" or \
               str(con_name) == "pain: group mean" or \
               str(con_name) == "Group: pain":

                if str(software) == SPM_SOFTWARE:
                    # If study was performed with SPM, reslice to FSL's
                    # template space
                    for to_reslice in [con_file, std_file, mask_file]:
                        file_name = os.path.basename(to_reslice).split(".")[0]
                        check_call(
                            ["cd " + nidm_dir + ";" +
                             " flirt -in " + file_name + " -ref " +
                             "$FSLDIR/data/standard/MNI152_T1_2mm -applyxfm " +
                             "-usesqform -out " + file_name + "_r"],
                            shell=True)
                    for to_rescale in [con_file, std_file]:
                        file_name = os.path.basename(to_rescale).split(".")[0]
                        check_call(
                            ["cd " + nidm_dir + ";" +
                             " fslmaths " + file_name + "_r -mul 40 " +
                             file_name + "_rs"],
                            shell=True)
                    con_file = con_file.replace(".nii", "_rs.nii")
                    std_file = std_file.replace(".nii", "_rs.nii")
                    mask_file = mask_file.replace(".nii", "_r.nii")

                mask_file = mask_file.replace("file://.", nidm_dir)

                if ma_mask is None:
                    ma_mask = mask_file
                else:
                    print [" fslmaths " + mask_file + " -min " +
                           ma_mask + " " + ma_mask_name]
                    check_call([" fslmaths " + mask_file + " -min " +
                           ma_mask + " " + ma_mask_name],
                               shell=True)
                    ma_mask = ma_mask_name


                # elif str(software == FSL_SOFTWARE):
                #     # If study was performed with FSL, rescale to a target
                #     # value of 100
                #     for to_relice in [con_file, std_file]:
                #         file_name = os.path.basename(to_relice).split(".")[0]
                #         check_call(
                #             ["cd " + nidm_dir + ";" +
                #              " fslmaths " + file_name + " -div 100 " +
                #              file_name + "_r"],
                #             shell=True)
                con_maps[study] = \
                    str(con_file).replace("file://.", nidm_dir)
                sterr_maps[study] = \
                    str(con_file).replace("file://.", nidm_dir)
                # mask_maps[study] = \
                #     str(mask_file).replace("file://.", nidm_dir)
            else:
                print study
                print "con_name=--"+str(con_name)+"--"
                print "********"

            # print "\n\nrow:"
            # for el in row:
            #     print str(el)
    else:
        print study
        print "not found"

# Binarize the mask
check_call(["fslmaths "+ ma_mask +" -thr 0.9 -bin "+ ma_mask], shell=True)

to_merge = {'copes': con_maps, 'varcopes': sterr_maps} #, 'masks': mask_maps}
for file_type, files in to_merge.items():
    check_call(
        ["fslmerge -t "+file_type+".nii.gz "+" ".join(files.values())],
        shell=True)
# check_call(
#     ["fslmerge -t varcope.nii.gz "+" ".join(sterr_maps.values())], shell=True)
# check_call(
#     ["fslmerge -t mask.nii.gz "+" ".join(mask_maps.values())], shell=True)

# FIXME: should use a combined mask across all studies
# print mask
# shutil.copyfile(
#     mask,
#     os.path.join(os.path.dirname(os.path.realpath(__file__)), "mask.nii.gz"))

check_call(["flameo --cope=cope --vc=varcope --ld=stats --dm=pain_meta_analysis.mat"
      " --cs=pain_meta_analysis.grp --tc=pain_meta_analysis.con "
      "--mask="+ma_mask_name+" --runmode=flame1"], shell=True)
