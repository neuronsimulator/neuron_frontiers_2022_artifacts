from neuron import h
import pandas as pd
import matplotlib as mpl
import sqlite3
import numpy as np
from matplotlib import pyplot
pyplot.ion()
h.load_file('import3d.hoc')
h.load_file('stdrun.hoc')
class Cell:
    def __init__(self,filename):
        """Read geometry from a given SWC file and create a cell"""
        cell = h.Import3d_Neurolucida3()
        cell.input(filename)
        h.Import3d_GUI(cell, 0)
        i3d = h.Import3d_GUI(cell, 0)
        i3d.instantiate(self)
        for sec in self.all:
            sec.nseg = 1 + 10 * int(sec.L / 11)
mycell = Cell('070314F_11.ASC') 
h.distance(sec=mycell.soma[0])
secs3d = [mycell.soma[0], mycell.apic[0], mycell.apic[1]]  + [dend for dend in h.allsec() if (h.distance(0.5, sec=dend) < 70 + h.distance(0.5, sec=mycell.soma[0])) and (dend in mycell.apic)]
ps = h.PlotShape(h.SectionList(secs3d))


DB_FILENAME = 'diffusion3d_full_times.db'
 
with sqlite3.connect(DB_FILENAME) as conn:
    data = pd.read_sql("""
        SELECT version, nthread, dx, run, MIN(initialize), MIN(setup), MIN(runtime)
        FROM data
        GROUP BY version, nthread, dx, run
    """, conn)



barlabels = ['Circadian Rhythm\nmodel',
             'Voxelization',
             '3D intracellular\ndiffusion (1-thread)',
             '3D intracellular\ndiffusion (16-thread)']

old3d = data.loc[3]
new3d = data.loc[11]
new3d16 = data.loc[43]
circadian7 = np.load('circadian7.npy')
circadian8 = np.load('circadian8.npy')

bardata = [circadian7.mean()/circadian8.mean(),
           old3d['MIN(initialize)']/new3d['MIN(initialize)'],
           old3d['MIN(runtime)']/new3d['MIN(runtime)'],
           old3d['MIN(runtime)']/new3d16['MIN(runtime)']]
pyplot.figure()
pyplot.bar(range(4),bardata, color="#80b1d3", edgecolor='k', linewidth=0.5)
pyplot.gca().set_xticks(range(4))
pyplot.gca().set_xticklabels(barlabels,fontsize=8)
for i,v in zip(range(4),bardata):
    pyplot.text(i-0.11,v+0.25,"%1.1f"%v)
pyplot.ylabel("Speedup [$\\times$ NEURON 7.6]")
pyplot.savefig('rxd_perfomance_bar.svg')

ps.plot(pyplot,cmap=mpl.cm.hot)
ax = pyplot.gca()
ax.view_init(90,270)
pyplot.plot([-85,-85],[20,70],'-k',linewidth=2)
ax.text(-86,40,0,'50$\mu$m',rotation=90)
ax.set_axis_off()
pyplot.savefig('rxd_perfomance_shape.svg')

