import gc
import time
import board
import displayio
import framebufferio
import terminalio
import rgbmatrix
import os
import adafruit_ntp
import rtc
import socketpool
import adafruit_imageload.png
import adafruit_requests as requests
import adafruit_connection_manager
import digitalio
from digitalio import DriveMode

from io import BytesIO
from adafruit_display_text.label import Label
from adafruit_bitmap_font import bitmap_font
from adafruit_matrixportal.network import Network
from adafruit_matrixportal.matrix import Matrix
from cedargrove_palettefader.palettefader import PaletteFader

DEBUG = False
# ENDPOINT = "http://192.168.1.70:5001/message"
ENDPOINT = "http://192.168.42.2:5001/message"
# Time in seconds before fetching a new message
IMAGE_PERIOD = 30
PIR_PERIOD = 0.1
AFTER_PIR_PERIOD = 20

# --- Display setup --- (chained panels)
bit_depth = 4
base_width = 64
base_height = 32
chain_across = 3
tile_down = 3
serpentine = True

width = base_width * chain_across
height = base_height * tile_down

addr_pins = [board.MTX_ADDRA, board.MTX_ADDRB, board.MTX_ADDRC, board.MTX_ADDRD]
rgb_pins = [
    board.MTX_R1,
    board.MTX_G1,
    board.MTX_B1,
    board.MTX_R2,
    board.MTX_G2,
    board.MTX_B2,
]
clock_pin = board.MTX_CLK
latch_pin = board.MTX_LAT
oe_pin = board.MTX_OE

# pins for the pir & power supply functions
pir_pin = digitalio.DigitalInOut(board.A0)
atx_pin = digitalio.DigitalInOut(board.A4)

# pir_pin.switchToInput()
#atx_pin.switchToInput()
atx_pin.switch_to_output(value=False, drive_mode=digitalio.DriveMode.OPEN_DRAIN)
pir_pin.switch_to_input(pull=digitalio.Pull.DOWN)


displayio.release_displays()
matrix = rgbmatrix.RGBMatrix(
    width=width,
    height=height,
    bit_depth=bit_depth,
    rgb_pins=rgb_pins,
    addr_pins=addr_pins,
    clock_pin=clock_pin,
    latch_pin=latch_pin,
    output_enable_pin=oe_pin,
    tile=tile_down,
    serpentine=serpentine
    )
display = framebufferio.FramebufferDisplay(matrix)
#display.brightness = BRIGHTNESS

network = Network(status_neopixel=board.NEOPIXEL, debug=True)
network.connect()
print("IP: ")
print(network._wifi.ip_address)
print("Time will be set for {}".format(os.getenv("TIMEZONE")))

ntp = adafruit_ntp.NTP(network._wifi.pool)
print(ntp.datetime)
r = rtc.RTC()
r.datetime = ntp.datetime

# --- Drawing setup ---
base_group = displayio.Group()  # Create a Group

color = displayio.Palette(5)  # Create a color palette
color[0] = 0x000000  # black background
color[1] = 0xFF0000  # red
color[2] = 0xCC4000  # amber
color[3] = 0x85FF00  # greenish
color[4] = 0xff4900  # logo "M" orange

#faded = PaletteFader(source_palette=color, brightness=BRIGHTNESS)

# logo:
color_converter = displayio.ColorConverter(dither=True)
bitmap = displayio.OnDiskBitmap('/makerlogo.bmp')
tile_grid = displayio.TileGrid(
    bitmap,
    pixel_shader=color_converter
)

base_group.append(tile_grid)

display.root_group = base_group
display.refresh()

motion_started = 0

while True:
    print("Requesting URL: {}".format(ENDPOINT))
    response = network.requests.get(ENDPOINT)
    bytes_img = BytesIO(response.content)
    bitmap, palette = adafruit_imageload.load(bytes_img)
    #socket = urllib.request.urlopen(url)

    # Load the image data into RAM (if you have enough!)
    #data = bytearray(1024 * 10)
    #socket.readinto(data)
    #socket.close()

    response.close()
    tile_grid = displayio.TileGrid(
        bitmap,
        #pixel_shader=color_converter
        pixel_shader=palette
    )
    base_group[0] = tile_grid
    display.refresh()

    gc.collect()

    image_done_time = time.monotonic()

    while (time.monotonic() < image_done_time + IMAGE_PERIOD):
        # print("motion_started_timeout: ", time.monotonic()-motion_started)
        if pir_pin.value:
            # atx_pin is inverted for some reason
            atx_pin.value = False
            motion_started = time.monotonic()
        else:
            if time.monotonic() > motion_started + AFTER_PIR_PERIOD:
                # atx_pin is inverted for some reason
                atx_pin.value = True

        time.sleep(PIR_PERIOD)
#    time.sleep(60)
