import plotly

from neuron import h, gui
from neuron.units import mV, ms

# download session file
# from modeldb.yale.edu/87284
h.load_file('c91662.ses')
for sec in h.allsec():
    sec.nseg = int(1 + 2 * (sec.L / 40 ))
    sec.insert(h.hh)
ic = h.IClamp(h.soma(0.5))
ic.delay = 1
ic.dur = 1
ic.amp = 10

v = h.Vector()
t = h.Vector()
v.record(h.soma(0.5)._ref_v, sec=h.soma)
t.record(h._ref_t, sec=h.soma)

pc = h.ParallelContext()
pc.set_maxstep(10)
h.cvode.cache_efficient(1)

# run using classic neuron
h.continuerun(h.t + 0.5)
pc.psolve(h.t + 0.5)

from neuron import coreneuron
coreneuron.enable = True
coreneuron.gpu = True
coreneuron.filemode = False

pc.psolve(h.tstop)

from matplotlib import cm
ps = h.PlotShape(False)
ps.variable("v")
ps.plot(plotly, cmap=cm.cool).show()
