# import glob
import os
from rdflib.graph import Graph
import json

fsl_pain_data_dir = "/Users/cmaumet/Projects/Meta-analysis/Data/" + \
    "FSL_pain_studies/tntmp"
studies = next(os.walk(fsl_pain_data_dir))[1]

con_maps = dict()
sterr_maps = dict()

activated = 0

studies = [studies[0]]



for study in studies:
    gfeat_dir = os.path.join(
        fsl_pain_data_dir, study, "gFeat", "flm_05mm.gfeat")
    assert os.path.isdir(gfeat_dir)

    nidm_dir = os.path.join(gfeat_dir, "nidm")
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
    prefix userSpecifiedThresholdType: <http://purl.org/nidash/nidm#NIDM_0000125>
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

        # ?inference prov:used ?height_thresh .
        # ?height_thresh a HeightThreshold: ;
        #                userSpecifiedThresholdType: ?height_thresh_type ;
        #                prov:value ?height_thresh_value .
    if sd:
        for row in sd:

            est_method, homoscedasticity, contrast_name, search_region_nifti, \
            search_vol_vox, extent_thresh, user_extent_thresh, height_thresh, \
            user_height_thresh = row
            if str(contrast_name) == "group mean ac" or \
               str(contrast_name) == "group mean":

                thresh = {
                    'Z-Statistic': 'prov:value',
                    'p-value FWE': 'pValueFWER:',
                    'p-value FDR': 'pValueFDR:',
                    'p-value uncorrected': 'pValueUncorrected:'}

    # FIXME: add pvalueFDR
                query = """
        prefix prov: <http://www.w3.org/ns/prov#>
        prefix nidm: <http://purl.org/nidash/nidm#>

        prefix pValueFWER: <http://purl.org/nidash/nidm#NIDM_0000115>
        prefix pValueUncorrected: <http://purl.org/nidash/nidm#NIDM_0000116>

        SELECT DISTINCT ?extent_value ?height_value WHERE {
            <"""+str(extent_thresh)+"> "+thresh[str(user_extent_thresh)]+""" ?extent_value .
            <"""+str(height_thresh)+"> "+thresh[str(user_height_thresh)]+""" ?height_value .
        }
                """

                thresholds = nidm_graph.query(query)
                if thresholds:
                    assert len(thresholds) == 1
                    for th_row in thresholds:
                        extent_thresh, height_thresh = th_row

                if homoscedasticity:
                    variance = 'equal'
                else:
                    variance = 'unequal'                

                print "Estimation was performed using %s and assuming %s \
variances. Inference was performed using " % (est_method, variance)

                print "row:"
                for el in row:
                    print str(el)
                print "\n"

               
    else:
        print "not found"

    # print "%s activated? %d" % (study, study_activated)

print float(activated)/len(studies)*100
