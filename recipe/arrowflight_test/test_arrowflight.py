import os
import signal
import subprocess
import sys
import time

import pyarrow as pa
import pyarrow.flight as flight

# start server (and wait a little)
print('Starting server...')
pid = subprocess.Popen([sys.executable, "server.py"]).pid
time.sleep(5)

print('Running client...')
location="grpc://arrowflight-server:8815"
client = flight.connect(location, disable_server_verification=True)
ticket_name="table_int"
response = client.do_get(flight.Ticket(ticket_name)).read_all()
print(response)

# tear down server
print('Terminating server...')
os.kill(pid, signal.SIGTERM)

print('Success!')
