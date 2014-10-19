'''
creates a nodes.json and links.json pages so it can be visualized in a forced graph in
d3.json
https://github.com/mbostock/d3/wiki/Force-Layout
http://nyquist212.wordpress.com/2014/03/11/simple-d3-js-force-layout-example-in-less-than-100-lines-of-code/


hero-network file can be found in http://exposedata.com/marvel/
'''

import csv
import json



with open('hero-network.csv','rt') as heroIn: #reads in the csv file skips the headers
    heroIn = csv.reader(heroIn)
    headers = next(heroIn)
    heroes = [row for row in heroIn]

uniqueHeroes = list(set([row[0] for row in heroes] + [row[1] for row in heroes])) #takes out redundancies in csv file

heroId = {name: i for i, name in enumerate(uniqueHeroes)} #maps each hero name with an id


links = [{'source': heroId[row[0]], 'target': heroId[row[1]]} for row in heroes] #creates a list of dictionaries to be put into jso format
nodes = [{"name":name} for name in uniqueHeroes] #creates a list of dictionaries for each superhero name to be put into a json file

with open('links.json', 'w') as f: #creates links json flie
     json.dump(links, f)
with open('nodes.json', 'w') as f:
     json.dump(nodes, f)


