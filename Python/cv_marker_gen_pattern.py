########################################
# CV marker pattern generator
# Adapted from Jes Fink-Jensen
# https://betterprogramming.pub/getting-started-with-aruco-markers-b4823a43973c
# and Loe Feijs' Houndstooth Generator
#	https://github.com/digital-craftsmanship/GOLDEN-RATIO/blob/master/DAY7-PIED-DE-POULE/pieddepouleFORMULE/pieddepouleFORMULE.pde
# Tested with opencv-python ver. 4.6.0.66
# Use-case Example: python cv_marker_gen_pattern.py -o "april_piedepole24x24.png" -i 0 -t "DICT_APRILTAG_36h11" -d 72 -s 6 -m 1 --no-write-id -x 24 -y 24 -p "pdp8"
########################################

# Import necessary libraries
import argparse     # For parsing command line arguments
import cv2          # OpenCV library for computer vision tasks
import sys          # Provides access to some variables used or maintained by the interpreter and to functions that interact with the interpreter
import numpy as np  # Library for numerical operations

# Create an ArgumentParser object to handle command line arguments
ap = argparse.ArgumentParser()

# Add various command line arguments and their descriptions
ap.add_argument("-o", "--output", required=True, help="path to output image containing ArUCo tag")
ap.add_argument("-i", "--id", type=int, required=True, help="ID of first ArUCo tag to generate")
ap.add_argument("-t", "--type", type=str, default="DICT_ARUCO_ORIGINAL", help="type of ArUCo tag to generate")
ap.add_argument("-d", "--dpi", type=str, default="72", help="the DPI of the output print")
ap.add_argument("-s", "--size", type=int, default=50, help="the size in mm of the ArUco tag")
ap.add_argument("-m", "--margin", type=int, default=5, help="the size in mm of the margins between the ArUco tags")
ap.add_argument("-x", "--x", type=int, default=3, help="number of ArUco tags in the X direction")
ap.add_argument("-y", "--y", type=int, default=4, help="number of ArUco tags in the Y direction")
ap.add_argument("--write-id", default=True, action=argparse.BooleanOptionalAction, help="write the id of the tag or not")
ap.add_argument("-p", "--pattern", type=str, default="ful", help="type of pattern")


# Parse the command line arguments and store them in a dictionary
args = vars(ap.parse_args())

# Dictionary mapping ArUCo types to their corresponding constant values in OpenCV
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

# Check if the specified ArUCo type is supported
if ARUCO_DICT.get(args["type"], None) is None:
	print("[INFO] ArUCo tag of '{}' is not supported".format(args["type"]))
	sys.exit(0)

# Get the ArUCo dictionary based on the specified type
arucoDict = cv2.aruco.Dictionary_get(ARUCO_DICT[args["type"]])
tag_type = args["type"]

# Define dimensions of an A4 paper in millimeters
A4_width = 210
A4_height = 297

# Get user-defined parameters
x = args["x"]
y = args["y"]
size = args["size"]
margin = args["margin"]
text_size = 8

# Adjust text size if writing IDs is disabled
write_id = args["write_id"]
if not(write_id):
	text_size = 0

# Check if the grid contains at least one tag
if x < 1 or y < 1:
	print(f"[INFO] Please make sure that the grid contains at least one tag - i.e. (x > 0) and (y > 0). Currently, x = {x} and y = {y}.")
	sys.exit(0)

# Calculate remaining space on the A4 paper after placing the tags
rest_x = A4_width - (x * size + (x - 1) * margin)
rest_y = A4_height - (y * size + y * text_size + (y - 1) * margin)

# Check if the grid fits on the page
stop = False
if rest_x < 0:
	print(f"[INFO] Please ensure that the grid fits on the page. Consider reducing the number of tags in the x-direction. Currently, x = {x}.")
	stop = True
if rest_y < 0:
	print(f"[INFO] Please ensure that the grid fits on the page. Consider reducing the number of tags in the y-direction. Currently, y = {y}.")
	stop = True
if stop:
	sys.exit(0)

# Calculate half of the remaining space on the x and y axes
half_rest_x = int(np.floor(rest_x/2))
half_rest_y = int(np.floor(rest_y/2))

# Define dimensions of A4 paper at different DPIs
A4_DICT = {
	"72": (595, 842),
	"96": (794, 1123)
}

PATTERN_DICT = {
	"ful": "FULL", # full pattern matrix
	"chk": "CHECKERS_2X2", # checker board pattern
	"chk2": "CHECKERS_2X2_REVERSED", # checker board pattern reversed
	"pt4": "PUPPY_TOOTH_4X4", # 4x4 puppy tooth pattern
	"pdp8": "PIED_DE_POULES_8X8", # 8x8 pied de poules pattern
	"hb4": "HERRING_BONE_4X4", # 4x4 herring bone pattern
	"bt4": "BROKEN_TWILL_4X4", # 4x4 broken twill pattern
	"ge": "GOOZE_EYE_6X8" # 6x8 gooze eye pattern
}

# Check if the specified DPI is supported
if A4_DICT.get(args["dpi"], None) is None:
	print("[INFO] A4 print of {} DPI is not supported. Please try one of the following: 72, 96.".format(args["dpi"]))
	sys.exit(0)

# Get the dimensions of the A4 paper based on the specified DPI
dpi = A4_DICT[args["dpi"]]

# Create a white canvas representing the A4 paper
page = np.ones((dpi[1],dpi[0],3), dtype="uint8")*255

# Calculate a multiplier for adjusting dimensions based on DPI
multiplier = np.min([dpi[0]/A4_width, dpi[1]/A4_height])

# Adjust dimensions and positions based on the multiplier
size_m = int(np.floor(size * multiplier))
text_size_m = int(np.floor(text_size * multiplier))
margin_m = int(np.floor(margin * multiplier))
half_rest_x_m = int(np.floor(half_rest_x * multiplier))
half_rest_y_m = int(np.floor(half_rest_y * multiplier))
edge_m = int(np.floor(1 * multiplier))

# Initialize the starting ID for the ArUCo tags
tag_id = args["id"]

# Initialize the pattern generation parameters
ni = 1000
pattern_type = PATTERN_DICT[args["pattern"]]

# Generate and place ArUCo tags on the page
print(f"[INFO] creating {x*y} tags from the {tag_type} dictionary. Starting with id:{tag_id}")
for i in range(0, y):
	nj = 0
	for j in range(0, x):
		if pattern_type == "CHECKERS_2X2": aninj = (ni - nj) % 2 < 1  # checkers
		elif pattern_type == "CHECKERS_2X2_REVERSED": aninj = ((ni - nj) % 2 == 1)  # checkers
		elif pattern_type == "PUPPY_TOOTH_4X4": aninj = (ni % 4 < 2) if (ni - nj) % 2 < 1 else (nj % 4 < 2)  # puppy tooth
		elif pattern_type == "PIED_DE_POULES_8X8": aninj = (ni % 8 < 4) if (ni - nj) % 4 < 2 else (nj % 8 < 4)  # pied de poules 8x8
		elif pattern_type == "HERRING_BONE_4X4": aninj = ((ni + nj) % 4 < 2) if (ni % 4 < 2) else ((10000 + nj - ni) % 4 < 2)  # herring bone
		elif pattern_type == "BROKEN_TWILL_4X4": aninj = ((ni + nj) % 4 < 2) if (ni % 4 < 2) else ((ni - nj) % 4 < 2)  # broken twill
		elif pattern_type == "GOOZE_EYE_6X8":
			gi = ni%6 if ni%6<3 else 6 - (ni%6) 
			gj = nj-1%8 if (nj-1)%8<4 else 8 - ((nj-1)%8) 
			aninj = 1 if ( gi + 1001 - gj)%4 < 2 else 0 #gooze-eye1
		else: aninj = 1

		i_val = half_rest_y_m + i*size_m + i*margin_m + 2*i*text_size_m
		j_val = half_rest_x_m + j*size_m + j*margin_m
		tag = np.zeros((size_m, size_m, 1), dtype="uint8")
		print(i_val,j_val)
		cv2.aruco.drawMarker(arucoDict, tag_id, size_m, tag, 1)
		if write_id:
			if "APRILTAG" in tag_type:
				text_string = f"A{tag_id}"
			else:
				text_string = f"a{tag_id}"
			cv2.putText(page, text_string, (j_val, i_val-margin_m), 
						fontFace=cv2.FONT_HERSHEY_TRIPLEX, fontScale=0.6, color=(0, 0, 0))
		tag_3_channel = cv2.cvtColor(tag, cv2.COLOR_GRAY2BGR)
		# Rotate the marker by 90 degrees
		if pattern_type == "CHECKERS_2X2_REVERSED":
			# angle = [0,90,270,180]
			if i%4 == 1 and j%4 == 1: 
				cy = int(half_rest_y_m + i*(size_m +margin_m) + size_m/2) # + (i*size_m)/2)
				cx = int(half_rest_x_m + j*(size_m +margin_m) + size_m/2) # + (j*size_m)/2)
				cr_in = size_m/2+margin_m - edge_m
				cr_out = size_m/2+margin_m+size_m/2 +int((size_m/2)*1.414)
				cv2.circle(page, center = (cx,cy), radius = int(cr_in), color = (0, 0, 0), thickness = 1)
				cv2.circle(page, center = (cx,cy), radius = int(cr_out), color = (0, 0, 0), thickness = 1)
			# if (aninj>0): 
				# index_angle = int((tag_id%9)/2)
				# rotated_tag = cv2.warpAffine(tag_3_channel, cv2.getRotationMatrix2D((size_m / 2, size_m / 2), angle[index_angle], 1), (size_m, size_m))
				# page[i_val:i_val+size_m, j_val:j_val+size_m] = rotated_tag
			if(aninj>0): page[i_val:i_val+size_m, j_val:j_val+size_m] = tag_3_channel
		else:
			if(aninj>0): page[i_val:i_val+size_m, j_val:j_val+size_m] = tag_3_channel
		tag_id += 1
		nj += 1
	ni += 1

# Save the generated page with ArUCo tags to the specified output path
cv2.imwrite(args["output"], page)

# Display the generated page with ArUCo tags
cv2.imshow("CV Marker Pattern Generator", page)

# Wait for a key press and then close the window
cv2.waitKey(0)