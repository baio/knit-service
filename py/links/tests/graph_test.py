from dom.graph.get_shortest_path import get_shortest_path_neo
from dom.graph.get_linked_nodes import get_linked_nodes_neo



def start():
    get_linked_nodes_neo(u"http://dbpedia.org/resource/Barack_Obama")
    #get_shortest_path_neo("mitt romney", "george bush")