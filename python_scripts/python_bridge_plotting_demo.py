import sys
import numpy
sys.path.insert(0, '/Library/Application Support/MWorks/Scripting/Python')

from matplotlib import pyplot


values = []


def plot_values(conduit, events):
    rc = conduit.reverse_codec

    values.extend([e.value for e in events
                   # The "if" test is unnecesary in this example, which watches
                   # only one variable, but is needed in the general case
                   if e.code == rc['rand_var']])

    pyplot.cla()
    pyplot.hist(values)
    pyplot.title('Distribution of random values')
    pyplot.draw()


if __name__ == '__main__':
    from common import Conduit
    Conduit.main(plot_values, ['rand_var'])
