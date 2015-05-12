# import glob
import os
from rdflib.graph import Graph

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
data_dir = os.path.join(SCRIPT_DIR, "data_spm_fsl")

studies = next(os.walk(data_dir))[1]

con_maps = dict()
sterr_maps = dict()

study = studies[0]

owl_file = "https://raw.githubusercontent.com/incf-nidash/nidm/master/nidm/\
nidm-results/terms/releases/nidm-results_100.owl"

nidm_dir = os.path.join(data_dir, study)
assert os.path.isdir(nidm_dir)

nidm_doc = os.path.join(nidm_dir, "nidm.ttl")
print nidm_doc
nidm_graph = Graph()
nidm_graph.parse(nidm_doc, format='turtle')

query = """
prefix prov: <http://www.w3.org/ns/prov#>
prefix nidm: <http://purl.org/nidash/nidm#>

prefix ModelParamEstimation: <http://purl.org/nidash/nidm#NIDM_0000056>
prefix withEstimationMethod: <http://purl.org/nidash/nidm#NIDM_0000134>
prefix errorVarianceHomogeneous: <http://purl.org/nidash/nidm#NIDM_0000094>
prefix SearchSpaceMaskMap: <http://purl.org/nidash/nidm#NIDM_0000068>
prefix contrastName: <http://purl.org/nidash/nidm#NIDM_0000085>
prefix StatisticMap: <http://purl.org/nidash/nidm#NIDM_0000076>
prefix searchVolumeInVoxels: <http://purl.org/nidash/nidm#NIDM_0000121>
prefix HeightThreshold: <http://purl.org/nidash/nidm#NIDM_0000034>
prefix userSpecifiedThresholdType: <http://purl.org/nidash/\
nidm#NIDM_0000125>
prefix ExtentThreshold: <http://purl.org/nidash/nidm#NIDM_0000026>

SELECT DISTINCT ?est_method ?homoscedasticity ?contrast_name
        ?search_region_nifti  ?search_vol_vox ?extent_thresh
        ?user_extent_thresh ?height_thresh ?user_height_thresh WHERE {
    ?mpe a ModelParamEstimation: .
    ?mpe withEstimationMethod: ?est_method .
    ?mpe prov:used ?error_model .
    ?error_model errorVarianceHomogeneous: ?homoscedasticity .
    ?stat_map prov:wasGeneratedBy/prov:used/prov:wasGeneratedBy ?mpe ;
              a StatisticMap: ;
              contrastName: ?contrast_name .
    ?search_region prov:wasGeneratedBy/prov:used ?stat_map ;
                   a SearchSpaceMaskMap: ;
                   prov:atLocation ?search_region_nifti ;
                   searchVolumeInVoxels: ?search_vol_vox .
    ?inference prov:used ?stat_map ;
               prov:used ?extent_thresh ;
               prov:used ?height_thresh .
    ?extent_thresh a ExtentThreshold: ;
                   userSpecifiedThresholdType: ?user_extent_thresh .
    ?height_thresh a HeightThreshold: ;
                   userSpecifiedThresholdType: ?user_height_thresh .

}

"""
sd = nidm_graph.query(query)

Z_STATISTIC = 'Z-Statistic'
P_VALUE_FWER = 'p-value FWE'
P_VALUE_FDR = 'p-value FDR'
P_VALUE_UNCORRECTED = 'p-value uncorrected'

    # ?inference prov:used ?height_thresh .
    # ?height_thresh a HeightThreshold: ;
    #                userSpecifiedThresholdType: ?height_thresh_type ;
    #                prov:value ?height_thresh_value .

owl_graph = Graph()
owl_graph.parse(owl_file, format='turtle')

if sd:
    for row in sd:

        est_method, homoscedasticity, contrast_name, search_region_nifti, \
            search_vol_vox, extent_thresh, user_extent_thresh, \
            height_thresh, user_height_thresh = row

        user_extent_thresh = str(user_extent_thresh)
        user_height_thresh = str(user_height_thresh)

        if str(contrast_name) == "group mean ac" or \
           str(contrast_name) == "group mean":

            thresh = {
                Z_STATISTIC: 'prov:value',
                P_VALUE_FWER: 'pValueFWER:',
                P_VALUE_FDR: 'pValueFDR:',
                P_VALUE_UNCORRECTED: 'pValueUncorrected:'}

# FIXME: add pvalueFDR
            query = """
    prefix prov: <http://www.w3.org/ns/prov#>
    prefix nidm: <http://purl.org/nidash/nidm#>

    prefix pValueFWER: <http://purl.org/nidash/nidm#NIDM_0000115>
    prefix pValueUncorrected: <http://purl.org/nidash/nidm#NIDM_0000116>

    SELECT DISTINCT ?extent_value ?height_value WHERE {
        <"""+str(extent_thresh)+"> " + \
                thresh[user_extent_thresh] + """ ?extent_value .
        <"""+str(height_thresh)+"> " + \
                thresh[user_height_thresh]+""" ?height_value .
    }
            """

            thresholds = nidm_graph.query(query)
            if thresholds:
                assert len(thresholds) == 1
                for th_row in thresholds:
                    extent_thresh, height_thresh = th_row

            # Convert all info to text
            thresh = ""
            multiple_compa = ""
            if str(user_extent_thresh) in [P_VALUE_FDR, P_VALUE_FWER]:
                inference_type = "Cluster-wise"
                multiple_compa = "with correction for multiple \
comparisons "
                thresh = "P < %0.2f" % float(extent_thresh)
                if user_extent_thresh == P_VALUE_FDR:
                    thresh += " FDR-corrected"
                else:
                    thresh += " FWER-corrected"

                thresh += " (cluster defining threshold "
                if user_height_thresh == P_VALUE_UNCORRECTED:
                    thresh += "P < %0.2f)" % float(height_thresh)
                if user_height_thresh == Z_STATISTIC:
                    thresh += "Z > %0.2f)" % float(height_thresh)
            else:
                inference_type = "Voxel-wise"
                if user_height_thresh in [P_VALUE_FDR, P_VALUE_FWER]:
                    multiple_compa = "with correction for multiple \
comparisons "
                    thresh = "P < %0.2f" % float(height_thresh)
                    if user_height_thresh == P_VALUE_FDR:
                        thresh += " FDR-corrected"
                    else:
                        thresh += " FWER-corrected"
                elif user_height_thresh == P_VALUE_UNCORRECTED:
                    thresh = "P < %0.2f uncorrected" % float(height_thresh)
                elif user_height_thresh == Z_STATISTIC:
                    thresh = "Z > %0.2f uncorrected" % float(height_thresh)

            if homoscedasticity:
                variance = 'equal'
            else:
                variance = 'unequal'

            print "-------------------"
            print "%s was performed assuming %s variances. %s inference\
was performed %susing a threshold %s. The search volume was made of %d voxels\
(cf. %s)" % (
                owl_graph.label(est_method), variance, inference_type,
                multiple_compa, thresh, int(search_vol_vox),
                search_region_nifti.replace("file://./", ""))

            print "-------------------"
            # print "row:"
            # for el in row:
            #     print str(el)
            # print "\n"

else:
    print "not found"

# print "%s activated? %d" % (study, study_activated)
