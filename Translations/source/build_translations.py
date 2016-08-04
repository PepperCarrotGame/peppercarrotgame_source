# ==== Pepper & Carrot Game ====
#
# Purpose: Get all the translations from the csv files and put them together in one
#
# ==============================
import os
import sys
import csv

BUILD_FOLDER = os.path.dirname(os.path.realpath(sys.argv[0]))

files = os.listdir(BUILD_FOLDER)

# Extract the languages
needs_languages = True

csv_file_w = open("translation.csv", "w", newline="")
csv_writer = csv.writer(csv_file_w)

for file_name in files:
    if file_name.endswith(".csv") and file_name != "translation.csv":
        f = open(file_name)
        csv_file = csv.reader(f)
        csv_list = list(csv_file)
        if needs_languages:
            csv_writer.writerow(csv_list[0])
            needs_languages = False
        for row in csv_list[1:]:
            csv_writer.writerow(row)
        f.close()
csv_file_w.close()
