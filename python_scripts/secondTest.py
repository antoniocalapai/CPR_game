import random
import signal
import sys

from mworks.conduit import IPCClientConduit


def main():
    conduit_resource_name = sys.argv[1]

    client = IPCClientConduit(conduit_resource_name)
    client.initialize()
    try:
        name = 'myvar'
        code = client.reverse_codec[name]
        data = random.randint(-100, 100)
        print 'Setting %r (code = %d) to %s' % (name, code, data)
        client.send_data(code, data)
    finally:
        client.finalize()


if __name__ == '__main__':
    main()