#! /usr/bin/python

# BENCHMARKING PROJECT
# ANNOTATION CREATION SCRIPT

'''
This script is used to create the LTR-RT annotations to use
within the insvar benchmarking project.
'''

###################################################

# SETTINGS

species = 'mh63'
raw_annotation = 'MH63.corrected.harvestraw.gff'
id2proteins_file = 'mh63_id2protein.tab'

###################################################

import os

## STEP 0: Classes and functions
##
##  0.1 Class gffline(). Manages the importation of gff lines and their modifications

class gffline():

    def __init__(self):

        self.id = ''
        self.type = ''
        self.age = ''

        self.seqname = ''
        self.source = ''
        self.feature = ''
        self.start = ''
        self.end = ''
        self.score = ''
        self.strand = ''
        self.frame = '.'
        self.attribute = ''
    
    def importline(self, line):
        c = line.split('\t')
        self.seqname = c[0]
        self.source = c[1]
        self.feature = c[2]
        self.start = c[3]
        self.end = c[4]
        self.score = c[5]
        self.strand = c[6]
        self.frame = c[7]
        self.attribute = c[8]

    def join(self):

        a = '\t'.join([
            self.seqname,
            self.source,
            self.feature,
            self.start,
            self.end,
            self.score,
            self.strand,
            self.frame,
            self.attribute
        ])

        return a

##  0.2 Function makedict(). Imports a dictionary from a tabbed file.

def makedict(infile_path, key = 0, value = 1):

    with open(infile_path, 'rU') as infile:
        inlist = infile.read().split('\n')
    
    outdict = {}

    for l in inlist:
        try:
            c = l.split('\t')
            ckey = c[key]
            cvalue = c[value]
            outdict[ckey] = cvalue
        except:
            pass
    
    return outdict

##  0.3 Function rread(). It opens a file into a list. Te "uniq" mode will exclude repetitions
def rread(infile_path, mode='multi'):
    with open(infile_path, 'rU') as infile:
        inlist = infile.read().split('\n')

    if mode.lower() == 'uniq':

        outlist = []

        for l in inlist:
            if l not in outlist:
                outlist.append(l)
        return outlist
    else:
        return inlist

##  0.4 Function scan_attribute(). Scans into the attributes to find a specific feature.

def scan_attribute(tag, attribute_string):
    output = 'not_found'
    l = attribute_string.split(';')

    for element in l:
        if tag.lower() in element.lower():
            output = element.split('=')[1]
    
    return output

##
##
## STEP 1: Load the dictionaries
##
##  1.1 id 2 strand dictionary
id2strand = makedict(id2proteins_file, 0, 2)

##  1.1 id 2 type dictionary
id2type= makedict(id2proteins_file, 0, 3)

##
##
## STEP 2: Select the annotation
##

accepted_lines = []

for line in rread(raw_annotation):
    try:
        z = gffline()
        z.importline(line)

        if z.feature == 'LTR_retrotransposon':
            z.id = scan_attribute('ID', z.attribute)
            z.feature = z.id

            # Here the filtering happens (not found in dictionary are not Set A and thus discarded)
            z.strand = id2strand[z.id]
            z.type = id2type[z.id]

            z.age = scan_attribute('ltr_similarity', z.attribute)
            z.attribute = z.attribute + ';Type=' + z.type
            accepted_lines.append(z)
    except:
        pass

##
##
## STEP 3: Print the tab and gff output
##

gff_output = open(species+'.setA.gff', 'w')
tab_output = open(species+'setA.tab', 'w')

for z in accepted_lines:

    print>> gff_output, z.join()
    print>> tab_output, '\t'.join([z.id, z.type, z.age, species]) 

gff_output.close()
tab_output.close()