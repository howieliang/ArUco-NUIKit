import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import cv2
import numpy as np
import sys

# Function to generate and export the page with ArUCo tags
def export():
    try:
        output = entries["output_entry"].get()
        tag_id = int(entries["id_entry"].get())
        # aruco_type = entries["type_entry"].get()
        aruco_type = marker_type_var.get()
        dpi = '72'
        size = int(entries["size_entry"].get())
        margin = int(entries["margin_entry"].get())
        x = int(entries["x_entry"].get())
        y = int(entries["y_entry"].get())
        pattern = entries["pattern_entry"].get()
        A4_width = int(entries["A4_width_entry"].get())
        A4_height = int(entries["A4_height_entry"].get())
        

        
        ARUCO_DICT = {
            "DICT_4X4_50": cv2.aruco.DICT_4X4_50,
            "DICT_4X4_100": cv2.aruco.DICT_4X4_100,
            "DICT_4X4_250": cv2.aruco.DICT_4X4_250,
            "DICT_4X4_1000": cv2.aruco.DICT_4X4_1000,
            "DICT_5X5_50": cv2.aruco.DICT_5X5_50,
            "DICT_5X5_100": cv2.aruco.DICT_5X5_100,
            "DICT_5X5_250": cv2.aruco.DICT_5X5_250,
            "DICT_5X5_1000": cv2.aruco.DICT_5X5_1000,
            "DICT_6X6_50": cv2.aruco.DICT_6X6_50,
            "DICT_6X6_100": cv2.aruco.DICT_6X6_100,
            "DICT_6X6_250": cv2.aruco.DICT_6X6_250,
            "DICT_6X6_1000": cv2.aruco.DICT_6X6_1000,
            "DICT_7X7_50": cv2.aruco.DICT_7X7_50,
            "DICT_7X7_100": cv2.aruco.DICT_7X7_100,
            "DICT_7X7_250": cv2.aruco.DICT_7X7_250,
            "DICT_7X7_1000": cv2.aruco.DICT_7X7_1000,
            "DICT_ARUCO_ORIGINAL": cv2.aruco.DICT_ARUCO_ORIGINAL,
            "DICT_APRILTAG_16h5": cv2.aruco.DICT_APRILTAG_16h5,
            "DICT_APRILTAG_25h9": cv2.aruco.DICT_APRILTAG_25h9,
            "DICT_APRILTAG_36h10": cv2.aruco.DICT_APRILTAG_36h10,
            "DICT_APRILTAG_36h11": cv2.aruco.DICT_APRILTAG_36h11
        }

        if ARUCO_DICT.get(aruco_type, None) is None:
            messagebox.showerror("Error", f"ArUCo tag of '{aruco_type}' is not supported")
            return

        arucoDict = cv2.aruco.Dictionary_get(ARUCO_DICT[aruco_type])

        if x < 1 or y < 1:
            messagebox.showerror("Error", "Please ensure that the grid contains at least one tag (x > 0 and y > 0).")
            return

        rest_x = A4_width - (x * size + (x - 1) * margin)
        rest_y = A4_height - (y * size + (y - 1) * margin)

        if rest_x < 0 or rest_y < 0:
            messagebox.showerror("Error", "Please ensure that the grid fits on the page.")
            return

        half_rest_x = int(np.floor(rest_x / 2))
        half_rest_y = int(np.floor(rest_y / 2))

        A4_DICT = {
            "72": (A4_width * 2.833, A4_height * 2.833)
        }

        PATTERN_DICT = {
            "ful": "FULL",
            "chk": "CHECKERS_2X2",
            "pt4": "PUPPY_TOOTH_4X4",
            "pt4x": "PUPPY_TOOTH_4X4_x",
            "pt4o": "PUPPY_TOOTH_4X4_o",
            "pdp8": "PIED_DE_POULES_8X8",
            "pdp8x": "PIED_DE_POULES_8X8_x",
            "pdp8o": "PIED_DE_POULES_8X8_o",
        }

        if A4_DICT.get(dpi, None) is None:
            messagebox.showerror("Error", f"A4 print of {dpi} DPI is not supported.")
            return

        dpi_value = A4_DICT[dpi]
        page = np.ones((int(dpi_value[1]), int(dpi_value[0]), 3), dtype="uint8") * 255
        multiplier = np.min([dpi_value[0] / A4_width, dpi_value[1] / A4_height])
        size_m = int(np.floor(size * multiplier))
        margin_m = int(np.floor(margin * multiplier))
        half_rest_x_m = int(np.floor(half_rest_x * multiplier))
        half_rest_y_m = int(np.floor(half_rest_y * multiplier))

        tag_id = int(tag_id)
        pattern_type = PATTERN_DICT[pattern]
        pn = 2
        dn = 1024/pn
        ni = 1024
        
        print(f"[INFO] creating {x * y} tags from the {aruco_type} dictionary. Starting with id:{tag_id}")

        for i in range(0, y):
          nj = 0
          for j in range(0, x):
            aninj =1
            img = np.ones((size_m,size_m,3), dtype="uint8")*255
            i_val = half_rest_y_m + i*size_m + i*margin_m
            j_val = half_rest_x_m + j*size_m + j*margin_m

            tag = np.zeros((size_m, size_m, 1), dtype="uint8")
            if(aninj>0):
              cv2.aruco.drawMarker(arucoDict, tag_id, size_m, tag, 1) //size
              page[i_val:i_val+size_m, j_val:j_val+size_m] = tag
              tag_id += 1
            nj += 1
          ni += 1

        for i in range(0, y):
          nj = 0
          for j in range(0, x):
            aninj = 0   
            nj += 1
          ni += 1
        cv2.imwrite(output, page)
        messagebox.showinfo("Success", f"Page saved to {output}")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {str(e)}")

# Create the main window
root = tk.Tk()
root.title("ArUCo Marker Pattern Generator")

# Create and place the input fields and labels
fields = [
    # ("Marker Type", "type_entry"),
    ("Grid Size (mm)", "size_entry"),
    ("Grid Margin (mm)", "margin_entry"),
    ("Grid number in X-axis", "x_entry"),
    ("Grid number in Y-axis", "y_entry"),
    ("Pattern", "pattern_entry"),
    ("First ID", "id_entry"),
    ("Image Width (mm)", "A4_width_entry"),
    ("Image Height (mm)", "A4_height_entry"),
    ("Output Path", "output_entry"),
]

entries = {}
marker_type_var = tk.StringVar(value="DICT_ARUCO_ORIGINAL")  # Set default value
marker_type_frame = ttk.LabelFrame(root, text="Select Marker Type")
marker_type_frame.grid(row=len(fields), columnspan=2, padx=5, pady=5, sticky=tk.W)
marker_types = [
    "DICT_ARUCO_ORIGINAL"
]
for i, marker_type in enumerate(marker_types):
    radio_button = tk.Radiobutton(marker_type_frame, text=marker_type, variable=marker_type_var, value=marker_type)
    radio_button.grid(row=i//4, column=i%4, sticky=tk.W, padx=5, pady=5)

for i, (label_text, var_name) in enumerate(fields):
    label = ttk.Label(root, text=label_text)
    label.grid(row=i, column=0, padx=5, pady=5, sticky=tk.W)
    entry = ttk.Entry(root)
    entry.grid(row=i, column=1, padx=5, pady=5)
    entries[var_name] = entry

# Set default values

entries["output_entry"].insert(0, "output.png")
entries["id_entry"].insert(0, "1")
entries["size_entry"].insert(0, "8")
entries["margin_entry"].insert(0, "2")
entries["x_entry"].insert(0, "16")
entries["y_entry"].insert(0, "16")
entries["pattern_entry"].insert(0, "ful")
entries["A4_width_entry"].insert(0, "210")
entries["A4_height_entry"].insert(0, "297")

# Add the export button
export_button = ttk.Button(root, text="Export", command=export)
export_button.grid(row=len(fields) + 1, columnspan=2, padx=5, pady=5)

# Start the main event loop
root.mainloop()
