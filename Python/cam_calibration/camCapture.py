########################################
# 1. Capture and Save Sample Images for Calibration
# Rong-Hao Liang: r.liang@tue.nl
# Tested with opencv-python ver. 4.6.0.66
########################################
# Press the SPACE key to save a snapshot from the camera.

import cv2  # Import the OpenCV library

# Initialize the camera capture
cap = cv2.VideoCapture(0)  # Create a VideoCapture object to access the default camera (usually the built-in webcam)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

id = 0  # Initialize a variable to keep track of the captured image IDs

while True:  # Start an infinite loop for continuously capturing frames from the camera

    # Capture a frame from the camera
    ret, frame = cap.read()  # Read a frame from the camera and store it in the 'frame' variable

    # Display the captured frame
    cv2.imshow("Camera Capture", frame)  # Show the captured frame in a window titled "Camera Capture"

    # Check if the space key is pressed
    key = cv2.waitKey(1) & 0xFF  # Wait for a key press event for 1 millisecond and store the key code in 'key'
    if key == ord(' '):  # If the space key is pressed
        # Generate a unique filename
        filename = str(id) + ".jpg"  # Create a filename by converting 'id' to a string and appending ".jpg"
        id = id + 1  # Increment the 'id' to ensure a unique filename for the next capture

        # Save the captured frame as a JPG image
        cv2.imwrite(filename, frame)  # Save the 'frame' as an image with the generated filename
        print(f"Saved {filename}")  # Print a message to indicate that the image has been saved

    # Exit the loop if the 'q' key is pressed
    elif key == ord('q'):  # If the 'q' key is pressed
        break  # Exit the while loop, terminating the program

# Release the camera and close all windows
cap.release()  # Release the camera resource
cv2.destroyAllWindows()  # Close all OpenCV windows (including the camera preview)
