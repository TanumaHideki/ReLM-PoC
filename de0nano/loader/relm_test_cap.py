from tkinter import ttk
import tkinter
from PIL import ImageGrab
import numpy as np
import cv2

root = tkinter.Tk()
root.title("Grab")
root.wm_attributes("-transparentcolor", "white")
ttk.Style().configure("TP.TFrame", background="white")
f = ttk.Frame(master=root, style="TP.TFrame", width=400, height=400)
f.pack(expand=True, fill=tkinter.BOTH)


def grab():
    image = cv2.cvtColor(
        np.array(
            ImageGrab.grab(
                bbox=(
                    root.winfo_rootx(),
                    root.winfo_rooty(),
                    root.winfo_rootx() + root.winfo_width(),
                    root.winfo_rooty() + root.winfo_height(),
                ),
                include_layered_windows=True,
                all_screens=True,
            ),
            dtype=np.uint8,
        ),
        cv2.COLOR_RGB2BGR,
    )
    cv2.imshow("Monitor", image)
    root.after(1, grab)


def onMouse(event, x, y, flag, params):
    if event == cv2.EVENT_LBUTTONDOWN:
        root.focus_force()


cv2.namedWindow("Monitor")
cv2.setMouseCallback("Monitor", onMouse)
root.after(0, grab)
root.mainloop()
