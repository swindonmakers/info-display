import WIFI_CONFIG
from network_manager import NetworkManager
import uasyncio
from urllib import urequest
from interstate75 import Interstate75, DISPLAY_INTERSTATE75_96X32
import jpegdec
import pngdec
import time

"""
Grab a message image from the makerspace display server, and display.

To run this example you'll need WIFI_CONFIG.py and network_manager.py from
the pimoroni-pico micropython/examples/common folder.
"""

i75 = Interstate75(display=DISPLAY_INTERSTATE75_96X32)
graphics = i75.display

WIDTH = i75.width
HEIGHT = i75.height
#FILENAME = "placekitten.jpg"
#ENDPOINT = "http://placekitten.com/{0}/{1}"
ENDPOINT = "http://192.168.42.2:5001/message"

# some colours to draw with
WHITE = graphics.create_pen(255, 255, 255)
BLACK = graphics.create_pen(0, 0, 0)


def status_handler(mode, status, ip):
    graphics.set_font("bitmap8")
    graphics.set_pen(BLACK)
    graphics.clear()
    graphics.set_pen(WHITE)
    graphics.text("Network: {}".format(WIFI_CONFIG.SSID), 2, 2, scale=1)
    status_text = "Connecting..."
    if status is not None:
        if status:
            status_text = "Connection successful!"
        else:
            status_text = "Connection failed!"

    graphics.text(status_text, 2, 12, scale=1)
    graphics.text("IP: {}".format(ip), 2, 22, scale=1)
    i75.update(graphics)


# connect to wifi
network_manager = NetworkManager(WIFI_CONFIG.COUNTRY, status_handler=status_handler)
uasyncio.get_event_loop().run_until_complete(network_manager.client(WIFI_CONFIG.SSID, WIFI_CONFIG.PSK))

url = ENDPOINT

while True:
    print("Requesting URL: {}".format(url))
    socket = urequest.urlopen(url)

    # Load the image data into RAM (if you have enough!)
    data = bytearray(1024 * 10)
    socket.readinto(data)
    socket.close()

    # draw the image
    png = pngdec.PNG(graphics)
    png.open_RAM(data)
    # https://github.com/pimoroni/pimoroni-pico/blob/main/micropython/modules/picographics/README.md#png-files
    png.decode(0,0, source=(0,0,96,32))

    # update the display
    i75.update(graphics)
    time.sleep(60)
