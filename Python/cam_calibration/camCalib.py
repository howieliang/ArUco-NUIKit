########################################
# 2. Load the camera-captured images and save the calibration data as a JSON file.
# Rong-Hao Liang: r.liang@tue.nl
# Tested with opencv-python ver. 4.6.0.66
########################################
# Press the SPACE key to browse the saved images

# Import required modules
import cv2  # OpenCV library for computer vision tasks
import numpy as np  # NumPy for numerical operations
import os  # Operating system operations
import glob  # File pattern matching
import json  # JSON handling
from datetime import datetime  # Date and time handling

camera_profiles = "camera.json"

# Define the dimensions of checkerboard
CHECKERBOARD = (6, 9)

# Stop the iteration when specified accuracy (epsilon) is reached or
# specified number of iterations are completed.
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

# Vector for 3D points
threedpoints = []

# Vector for 2D points
twodpoints = []

# 3D points representing real-world coordinates
objectp3d = np.zeros((1, CHECKERBOARD[0] * CHECKERBOARD[1], 3), np.float32)
objectp3d[0, :, :2] = np.mgrid[0:CHECKERBOARD[0], 0:CHECKERBOARD[1]].T.reshape(-1, 2)
prev_img_shape = None

# Extracting path of individual images stored in a given directory.
# Since no path is specified, it will take jpg files from the current directory.
images = glob.glob('*.jpg')

# Loop through each image
for filename in images:
    # Read the image
    image = cv2.imread(filename)
    grayColor = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Find the chessboard corners
    ret, corners = cv2.findChessboardCorners(
        grayColor, CHECKERBOARD,
        cv2.CALIB_CB_ADAPTIVE_THRESH + cv2.CALIB_CB_FAST_CHECK + cv2.CALIB_CB_NORMALIZE_IMAGE)

    # If the desired number of corners are found in the image, ret = True
    if ret == True:
        threedpoints.append(objectp3d)

        # Refine pixel coordinates for given 2D points
        corners2 = cv2.cornerSubPix(
            grayColor, corners, (11, 11), (-1, -1), criteria)

        twodpoints.append(corners2)

        # Draw and display the corners on the image
        image = cv2.drawChessboardCorners(image, CHECKERBOARD, corners2, ret)

    cv2.imshow('img', image)
    cv2.waitKey(0)

# Get the dimensions of the last image
w, h = image.shape[:2]
print(h, w)

# Perform camera calibration by passing the 3D points (threedpoints) and its
# corresponding pixel coordinates of the detected corners (twodpoints)
ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(
    threedpoints, twodpoints, grayColor.shape[::-1], None, None)

# Create a dictionary to store camera calibration data
camera = {}

# JSON encoder class to handle NumPy arrays
class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)

# Store the calibration data in the camera dictionary
for variable in ['ret', 'mtx', 'dist', 'rvecs', 'tvecs']:
    camera[variable] = eval(variable)

# Write the camera calibration data to a JSON file
with open(camera_profiles, 'w') as f:
    json.dump(camera, f, indent=4, cls=NumpyEncoder)

# Close all OpenCV windows
cv2.destroyAllWindows()
