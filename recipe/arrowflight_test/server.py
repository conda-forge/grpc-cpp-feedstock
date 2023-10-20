import pyarrow.flight as flight
import pyarrow as pa

def create_table_int():
    data = [
        pa.array([1, 2, 3]),
        pa.array([4, 5, 6])
    ]
    return pa.Table.from_arrays(data, names=['column1', 'column2'])


class FlightServer(flight.FlightServerBase):
    def __init__(self, location, **kwargs):
        super(FlightServer, self).__init__(location, **kwargs)
        self.data = pa.array([1, 2, 3, 4, 5])
        self.tables = {
            b'table_int': create_table_int()
        }

    def do_get(self, context, ticket):
        table = self.tables[ticket.ticket]
        # return fl.RecordBatchStream(table)
        return flight.GeneratorStream(table.schema, table.to_batches(max_chunksize=1024))

if __name__ == "__main__":
    location = "grpc://0.0.0.0:8815"
    server = FlightServer(location)
    print(f"Flight server listening on {location}")
    server.serve()
