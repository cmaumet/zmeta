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

for study in studies:
    gfeat_dir = os.path.join(
        fsl_pain_data_dir, study, "gFeat", "flm_05mm.gfeat")
    assert os.path.isdir(gfeat_dir)

    nidm_dir = os.path.join(gfeat_dir, "nidm")
    assert os.path.isdir(nidm_dir)

    nidm_doc = os.path.join(nidm_dir, "nidm.ttl")

    nidm_graph = Graph()
    nidm_graph.parse(nidm_doc, format='turtle')

    query = """
    prefix prov: <http://www.w3.org/ns/prov#>
    prefix nidm: <http://purl.org/nidash/nidm#>

    prefix coordinate_vector: <http://purl.org/nidash/nidm#NIDM_0000086>
    prefix peak: <http://purl.org/nidash/nidm#NIDM_0000062>
    prefix significant_cluster: <http://purl.org/nidash/nidm#NIDM_0000070>

    SELECT ?x WHERE {
      ?peak a peak: .
      ?cluster a significant_cluster: .
      ?peak prov:wasDerivedFrom ?cluster .
      ?peak prov:atLocation ?coordinate .
      ?coordinate coordinate_vector: ?x .
    }
    ORDER BY ?cluster ?peak

    """
    sd = nidm_graph.query(query)

    x_pos, y_pos, z_pos = [-58, -23, 20]
    tol = 30

    study_activated = False
    if sd:
        for row in sd:
            if study_activated:
                break

            for el in row:
                x, y, z = json.loads(str(el))

                if (x > (x_pos-tol/2)) and (x < (x_pos+tol/2)) and \
                   (y > (y_pos-tol/2)) and (y < (y_pos+tol/2)) and \
                   (z > (z_pos-tol/2)) and (z < (z_pos+tol/2)):
                    activated += 1
                    study_activated = True
                    break
    else:
        print "not found"

    print "%s activated? %d" % (study, study_activated)

print float(activated)/len(studies)*100
