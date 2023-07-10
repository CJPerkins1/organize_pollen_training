# Introduction ------------------------------------------------------------
# This script will randomly select images from the second camera dataset (
# after 2022-05-27) then create bash code to copy them to a new directory for 
# uploading.

library(dplyr)
library(googlesheets4)

# Makes the random selections reproducible
set.seed(13)

# Adding my Google service account credentials
# This is to avoid logging in every time you run this
# gs4_auth(path = "~/.credentials/google_sheets_api/service_account.json")


# Getting all the image paths ---------------------------------------------
# None of the images are named after their accession, just the wells. The
# required information to link well to accession can be found in this sheet:
# wells_to_accessions <- read_sheet("193VJf4eJNUMQZGTL2FtOpLGVIceUZKzQJheDtrPrWjg")

# Only keeping the columns we need
# wells_to_accessions <- wells_to_accessions[ , c("date", "run", "well", "temp_target", "accession")]

# Also I need to pull in which wells are a good density
# wells_with_good_density <- read_sheet("10_lG9N0wGvgOmxDGuX5PXILB7QwC7m6CuYXzi78Qe3Q")

# Read pollen density sheet
file_names <- read_sheet("193VJf4eJNUMQZGTL2FtOpLGVIceUZKzQJheDtrPrWjg")

# Only keeping the good ones
file_names <- file_names[complete.cases(file_names), ]
file_names <- file_names[file_names$density == "g", ]

# Only keeping ones newer than 2022-05-27 for the new camera
# file_names <- file_names[file_names$date > "2022-05-27", ]

file_names <- file_names[ , 1:5]

# There were 66 frames in each sequence for the second camera.
file_names <- file_names[rep(seq_len(nrow(file_names)), each = 66), ]

file_names$frame_num <- rep(seq(0, 65), times = nrow(file_names) / 66)

file_names$frame_num <- sprintf("%03d", file_names$frame_num) 

# This is the path of the base directory that the jpgs are in
base_dir_path <- "/xdisk/rpalaniv/cjperkins1/chronic_hs/images/normalized_stabilized"

file_names$string <- paste0(base_dir_path,
                            file_names$date,
                            "_run",
                            file_names$run,
                            "_",
                            file_names$temp_target,
                            "C_normalized_stabilized/well_",
                            file_names$well,
                            "/",
                            file_names$date,
                            "_run",
                            file_names$run,
                            "_",
                            file_names$temp_target,
                            "C_",
                            file_names$well,
                            "_t",
                            file_names$frame_num,
                            "_stab.jpg")


# Subsetting and saving, with data leakage fix ----------------------------
# Sampling 1 row from each group
sampled_file_names <- file_names %>%
  group_by(date, run, well) %>%
  slice_sample(n = 1)

# Checking to see if there are any well duplicates 
all(duplicated(sampled_file_names[ , 1:5])) # FALSE

# Removing one it chose that didn't exist for whatever reason
sampled_file_names <- sampled_file_names %>%
  filter(string != "/xdisk/rpalaniv/cjperkins1/chronic_hs/images/normalized_stabilized/2023-06-20_run1_26C_normalized_stabilized/well_A1/2023-06-20_run1_26C_A1_t000_stab.jpg")


# Randomizing
random_vec <- sample(nrow(sampled_file_names))

# Pulling the first 500 to make up upload_3 (the first two uploads were from camera 1)
upload_1 <- sampled_file_names[random_vec[1:500], ]

# Triple checking that there are no well duplicates and no overlap with upload 1
upload_1[duplicated(upload_1[ , 1:5]) | duplicated(upload_1[ , 1:5], fromLast = TRUE), ] # No dupe wells

# Looks good, writing out the second list
write.table(upload_1[ , c("string")],
            file = file.path(getwd(), "data", "upload_1.txt"),
            row.names = F,
            col.names = F,
            quote = F)

# Reminder: the bash command to copy them is:
# cat ~/scratch/upload_3.txt | xargs -I % cp % ~/scratch/upload_3

