import cv2
import numpy as np
import json  # JSON handling

camera_profiles = "camera.json"

# Load camera calibration data from a JSON file
with open(camera_profiles, 'r') as json_file:
    camera_data = json.load(json_file)
distCoeffs = np.array(camera_data["dist"])  # Distortion coefficients
cameraMatrix = np.array(camera_data["mtx"])  # Camera matrix (intrinsic parameters)

# Create a VideoCapture object
cap = cv2.VideoCapture(0)  # Use 0 for the default camera
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
isCalibed = True

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Undistort the captured frame using camera_matrix and dist_coeffs
    undistorted_frame = cv2.undistort(frame, cameraMatrix, distCoeffs)

    # Display the undistorted frame
    if isCalibed == True:
      cv2.imshow("Undistorted Camera View", undistorted_frame)
    else:
      cv2.imshow("Undistorted Camera View", frame)
    key = cv2.waitKey(1)

    if key == ord(' '):  # Press space key to capture and save
        isCalibed = not isCalibed
    if key == ord('q'):  # Press Esc to exit
        break

# Release the VideoCapture and close windows
cap.release()
cv2.destroyAllWindows()