import cv2
import numpy as np
from matplotlib import pyplot as plt
from sdk import CameraSender
from time import time

resolution = (200, 200)

print(f'Usando resolução: {resolution[0]}x{resolution[1]}')

cam = cv2.VideoCapture(0)

# cam.set(cv2.CAP_PROP_FRAME_WIDTH, resolution[0])
# cam.set(cv2.CAP_PROP_FRAME_HEIGHT, resolution[1])


camera_sender = CameraSender(tx=0, rx=1, baud_rate=115200*2)

def to_bytearray(x):
   return np.array(x.astype('half')/16, dtype='b')

while True:
    ret, frame = cam.read()
    if not ret:
        print("failed to grab frame")
        break

    frame = cv2.resize(frame, resolution) 

    print(frame.shape)

    # blue_channel, green_channel, red_channel = cv2.split(frame)

    # mask = 0b11110000
    # frame_4bits = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    # frame_4bits = cv2.bitwise_and(frame_4bits, mask)
    # frame = cv2.cvtColor(frame_4bits, cv2.COLOR_GRAY2BGR)

    # blue = cv2.bitwise_and(blue_channel, mask)
    # green = cv2.bitwise_and(green_channel, mask)
    # red = cv2.bitwise_and(red_channel, mask)

    # merged_image = cv2.merge([blue, green, red])

    # cv2.imshow("frame", frame)

    # rows, columns, _ = merged_image.shape

    # merged_image = to_bytearray(frame)
    cv2.imshow("frame", frame)

    start_time = time()

    # Start Transmission
    camera_sender.write(b'\xaa')

    # Send Frame
    byte_string = to_bytearray(frame).reshape(np.prod(frame.shape)).tobytes()
    camera_sender.write(byte_string)
    end_time = time()

    print(f'tempo de envio: {end_time-start_time} segundos')


    # print(byte_string)

    # for x in range(columns):
    #     for y in range(rows):
    #         byte_string = np.array(merged_image[y,x], dtype='b').tobytes().decode(errors='ignore')
    #         # if x*y == 0:
    #         #     print(byte_string, x, y)
    #         camera_sender.write(byte_string)
    #         print(x,y)
    


    k = cv2.waitKey(1)
    if k%256 == 27:
        print("Escape hit, closing...")
        break

camera_sender.close()

cam.release()
cv2.destroyAllWindows()


 
