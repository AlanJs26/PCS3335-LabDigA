from WF_SDK import device, supplies, static, error, warning     # import instruments
from WF_SDK.protocol import uart                                # import protocol instrument


class CameraSender:
    def __init__(self, tx=0, rx=1, baud_rate=9600):

        try:
            # connect to the device
            self.device_data = device.open()

            # initialize the uart interface on DIO0 and DIO1
            uart.open(self.device_data, tx=tx, rx=rx, baud_rate=baud_rate)

        except error as e:
            print(e)
            # close the connection
            device.close(device.data)

    def read(self, timeout=1000):
        message = ""
        try:
            # read raw data
            for _ in range(timeout):
                message, error = uart.read(self.device_data)
                if message != "":
                    break
        except warning as w:
            print(w)
        except error as e:
            print(e)

        return message

    def write(self, message: str):
        uart.write(self.device_data, message)

    def close(self):
        # reset the interface
        uart.close(self.device_data)

        # close the connection
        device.close(self.device_data)