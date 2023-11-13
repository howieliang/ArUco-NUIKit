########################################
# 3. Capture the ArUCo markers using the calibrated camera.
# Rong-Hao Liang: r.liang@tue.nl
# Tested with opencv-python ver. 4.6.0.66
########################################
# Press the q key to stop the program.

# Import necessary libraries
from pythonosc import udp_client  # Import UDP client for OSC communication
import cv2  # Import OpenCV library
import numpy as np  # Import numpy library for numerical operations
import json  # Import json library for reading camera calibration data from a JSON file
import time  # Import time library for measuring FPS

# Set the filename for the camera profiles here.
# camera_profiles = "camerafacetime.json"
# camera_profiles = "camera922pro.json"
# camera_profiles = "camera980stream.json"
camera_profiles = "camera_IR.json"
# camera_profiles = "camera_Tiny.json"
# camera_profiles = "camera_ft480p.json"

# Create a UDP client to send OSC messages
client = udp_client.SimpleUDPClient("127.0.0.1", 9000)  # Define the IP address and port of the receiver

# Initialize the camera capture
cap = cv2.VideoCapture(0)  # Initialize a video capture object with the default camera (0)
# cap.set(cv2.CAP_PROP_AUTOFOCUS, 0) # turn the autofocus off
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
# cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
# cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# Initialize variables for measuring FPS (Frames Per Second)
fps = 0
prev_time = time.time()  # Get the current time as the previous time

# Print the OpenCV library version
print(cv2.__version__)

# Define the marker size in meters (adjust according to your marker size)
aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_ARUCO_ORIGINAL)
# aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_APRILTAG_36h11)
parameters = cv2.aruco.DetectorParameters_create()
marker_size = 0.015  # Define the size of the ArUco marker in meters

# Load camera calibration data from a JSON file
with open(camera_profiles, 'r') as json_file:
    camera_data = json.load(json_file)
distCoeffs = np.array(camera_data["dist"])  # Distortion coefficients
cameraMatrix = np.array(camera_data["mtx"])  # Camera matrix (intrinsic parameters)

isCalibed = True

# Define a function to convert a rotation matrix to Euler angles (yaw, pitch, roll)
def rotation_matrix_to_euler_angles(rotation_matrix):
    # Extract the rotation components from the rotation matrix
    sy = np.sqrt(rotation_matrix[0, 0] * rotation_matrix[0, 0] + rotation_matrix[1, 0] * rotation_matrix[1, 0])
    singular = sy < 1e-6  # Check if the rotation matrix is singular (close to zero)

    if not singular:
        # Compute yaw, pitch, and roll from the rotation matrix
        roll = np.arctan2(rotation_matrix[2, 1], rotation_matrix[2, 2])
        pitch = np.arctan2(-rotation_matrix[2, 0], sy)
        yaw = np.arctan2(rotation_matrix[1, 0], rotation_matrix[0, 0])
    else:
        # Handle the case when the rotation matrix is singular
        roll = np.arctan2(-rotation_matrix[1, 2], rotation_matrix[1, 1])
        pitch = np.arctan2(-rotation_matrix[2, 0], sy)
        yaw = 0

    return roll, pitch, yaw

# Main loop for video capture and ArUco marker detection
while True:
    ret, frame = cap.read()  # Capture a frame from the camera

    if not ret:
        break  # Break the loop if no frame is captured (e.g., camera disconnected)

    # Calculate FPS (Frames Per Second)
    current_time = time.time()
    elapsed_time = current_time - prev_time
    if elapsed_time > 0:
        fps = 1 / elapsed_time
    prev_time = current_time
    
    # # Undistort the captured frame using camera_matrix and dist_coeffs
    frame = cv2.undistort(frame, cameraMatrix, distCoeffs)
    
    # Display FPS on the frame
    cv2.putText(frame, f'FPS: {int(fps)}', (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

    # Convert the frame to grayscale (optional)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Detect ArUco markers in the grayscale frame
    corners, ids, rejectedImgPoints = cv2.aruco.detectMarkers(gray, aruco_dict, parameters=parameters)

    if ids is not None:
        # Draw detected markers and their pose axes
        cv2.aruco.drawDetectedMarkers(frame, corners, ids)

        for i in range(len(ids)):
            rvec, tvec, markerPoints = cv2.aruco.estimatePoseSingleMarkers(corners[i], marker_size, cameraMatrix, distCoeffs)

            cv2.drawFrameAxes(frame, cameraMatrix, distCoeffs, rvec, tvec, marker_size * 0.5)

            # Convert the rotation matrix to Euler angles
            rotation_matrix, _ = cv2.Rodrigues(rvec)
            roll, pitch, yaw = rotation_matrix_to_euler_angles(rotation_matrix)

            # Flatten the translation vector to a 1D array
            translation_vector = tvec.flatten()
            tx, ty, tz = translation_vector
            # print(int(corners[i][0][0][0]),int(corners[i][0][0][1]),int(corners[i][0][1][0]),int(corners[i][0][1][1]),int(corners[i][0][2][0]),int(corners[i][0][2][1]),int(corners[i][0][3][0]),int(corners[i][0][3][1]))
            # Create an OSC message with marker ID and pose information
            message = [int(ids[i]), float(tx), float(ty), float(tz), float(roll), float(pitch), float(yaw), int(corners[i][0][0][0]),int(corners[i][0][0][1]),int(corners[i][0][1][0]),int(corners[i][0][1][1]),int(corners[i][0][2][0]),int(corners[i][0][2][1]),int(corners[i][0][3][0]),int(corners[i][0][3][1])] 
            # )

            # Send the OSC message to the specified address ("/message")
            client.send_message("/marker", message)

    # Display the frame with detected markers and axes
    cv2.imshow('ArUco Marker Detection', frame)

    # Print the current FPS to the console
    # print(fps)

    # if key == ord(' '):  # Press space key to toggle lens correction
    #     isCalibed = not isCalibed
    # Exit the program when the 'q' key is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the camera and close all OpenCV windows
cap.release()
cv2.destroyAllWindows()
