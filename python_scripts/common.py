try: 
    import queue
except ImportError:
    import Queue as queue

import sys

from matplotlib import pyplot

from mworks.conduit import IPCAccumClientConduit


class Conduit(IPCAccumClientConduit):

    def __init__(self, resource_name, event_handler, event_names):
        super(IPCAccumClientConduit, self).__init__(resource_name,
                                                    'start',
                                                    'stop',
                                                    event_names)
        self.event_handler = event_handler
        self._queue = queue.Queue()
        self._main_loop_running = False

    def _post_events(self, events):
        if events:
            if self._main_loop_running:
                self._stop_main_loop()
            self._queue.put(events)

    def run(self):
        self.initialize()
        try:
            self.register_bundle_callback(self._post_events)
            pyplot.cla()
            pyplot.draw()
            while True:
                self._main_loop_running = True
                try:
                    self._start_main_loop()
                finally:
                    self._main_loop_running = False
                self.event_handler(self, self._queue.get())
        finally:
            self.finalize()

    @classmethod
    def main(cls, event_handler, event_names):
        if len(sys.argv) > 1:
            # Client-side conduit: resource name is a script argument
            resource_name = sys.argv[1]
        else:
            # Server-side conduit: resource name is set in the experiment
            resource_name = 'server_conduit'

        cls(resource_name, event_handler, event_names).run()
