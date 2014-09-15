import os
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
def get_nodevalue(node,index=0):
    if node.firstChild == None:
        return "NULL"
    else:
        return node.childNodes[index].nodeValue

def prepare_parse_xml(source_xml):
    from xml.dom import minidom
    doc=minidom.parse(source_xml)
    root=doc.documentElement
    return root

def recursive_parse(node,target_file):
    if node.nodeType == node.TEXT_NODE or node.nodeType == node.COMMENT_NODE:
        pass
    else:
        if len(node.childNodes) > 1:
            node_child = node.childNodes
            for ele in node_child:
                if ele.nodeType == ele.TEXT_NODE or node.nodeType == node.COMMENT_NODE:
                    pass
                else:
                    recursive_parse(ele,target_file)
        else:
            param_name = node.nodeName
            param_value=get_nodevalue(node)
            if param_name == "project":
                f=open("%s/project.list" % target_file,"a")
                f.write("%s\n" % param_value)
                f.close()
            elif param_name == "job":
                f=open("%s/job.cfg" % target_file,"a")
                f.write("%s\n" % param_value)
                f.close()
            else:
                f=open("%s/config.cfg" % target_file,"a")
                f.write("%s=%s\n" % (param_name,param_value))
                f.close()

def parse_xml(source_xml,target_file):
    
    root=prepare_parse_xml(source_xml)
    recursive_parse(root,target_file)

argv_num=len(sys.argv)
source_xml=sys.argv[1]
target_file=sys.argv[2]

if argv_num != 3:
    exit_with_error("Input parameters wrong")
if os.path.exists(target_file) == True:
    os.system("rm -rf %s/config.cfg %s/project.list" % (target_file,target_file))
parse_xml(source_xml,target_file)
print "parse config xml success"
