from smboolmanager import SMBoolManagerPlando as SMBoolManager
from helpers import Pickup
from solver.conf import Conf
from graph_access import getAccessPoint
from solver.comeback import ComeBack
from solver.standardSolver import StandardSolver
from parameters import easy
from solver.out import Out
import log

class RandoSolver(StandardSolver):
    def __init__(self, majorsSplit, startAP, areaGraph, locations):
        self.interactive = False
        self.checkDuplicateMajor = False
        self.vcr = None
        # for compatibility with some common methods of the interactive solver
        self.mode = 'standard'

        self.log = log.get('Solver')

        # default conf
        self.setConf(easy, 'all', [], False)

        self.firstLogFile = None

        self.extStatsFilename = None
        self.extStatsStep = None
        self.plot = None

        self.type = 'rando'
        self.output = Out.factory(self.type, self)
        self.outputFileName = None

        self.locations = locations

        self.smbm = SMBoolManager()

        # preset already loaded by rando
        self.presetFileName = None

        self.pickup = Pickup(Conf.itemsPickup)

        self.comeBack = ComeBack(self)

        # load ROM info, patches are already loaded by the rando. get the graph from the rando too
        self.majorsSplit = majorsSplit
        self.startAP = startAP
        self.startArea = getAccessPoint(startAP).Start['solveArea']
        self.areaGraph = areaGraph

        # store at each step how many locations are available
        self.nbAvailLocs = []
