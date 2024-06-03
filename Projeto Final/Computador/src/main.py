import cv2
import numpy as np
from matplotlib import pyplot as plt

resolution = (800, 600)

print(f'Usando resolução: {resolution[0]}x{resolution[1]}')

cam = cv2.VideoCapture(0)

cam.set(cv2.CAP_PROP_FRAME_WIDTH, resolution[0])
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, resolution[1])

while True:
    ret, frame = cam.read()
    if not ret:
        print("failed to grab frame")
        break

    # print(type(frame))
    # print(frame.shape)

    blue_channel, green_channel, red_channel = cv2.split(frame)

    mask = 0b11110000
    # frame_4bits = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    # frame_4bits = cv2.bitwise_and(frame_4bits, mask)
    # frame = cv2.cvtColor(frame_4bits, cv2.COLOR_GRAY2BGR)

    blue = cv2.bitwise_and(blue_channel, mask)
    green = cv2.bitwise_and(green_channel, mask)
    red = cv2.bitwise_and(red_channel, mask)

    merged_image = cv2.merge([blue, green, red])
    cv2.imshow("merged_image", merged_image)

    # cv2.imshow("frame", frame)

    k = cv2.waitKey(1)
    if k%256 == 27:
        # ESC pressed
        print("Escape hit, closing...")
        break

cam.release()
cv2.destroyAllWindows()


 
