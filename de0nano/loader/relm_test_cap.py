import tkinter as tk
from PIL import ImageGrab
import numpy as np
import cv2

root = tk.Tk()
root.config(width=400, height=400, bg="gray")
root.wm_attributes("-toolwindow", True)
root.title("Grab")
root.wm_attributes("-alpha", 0.75)
frame = tk.Frame(root, width=380, height=380, bg="blue")
frame.place(x=10, y=10)
root.wm_attributes("-transparentcolor", "blue")
root.wm_attributes("-topmost", True)


def on_configure(_):
    frame.place(width=root.winfo_width() - 20, height=root.winfo_height() - 20)


root.bind("<Configure>", on_configure)


def grab():
    image = cv2.cvtColor(
        np.array(
            ImageGrab.grab(
                bbox=(
                    frame.winfo_rootx(),
                    frame.winfo_rooty(),
                    frame.winfo_rootx() + frame.winfo_width(),
                    frame.winfo_rooty() + frame.winfo_height(),
                ),
                all_screens=True,
            ),
            dtype=np.uint8,
        ),
        cv2.COLOR_RGB2BGR,
    )
    cv2.imshow("Monitor", image)
    root.after(1, grab)


cv2.namedWindow("Monitor")
root.after(0, grab)
root.mainloop()
