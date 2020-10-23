###################################################
## Add Cambridge Library and Qumranica iiif urls ##
###################################################

INSERT INTO image_urls (image_urls_id,url,suffix,proxy,license)
VALUES(3,"https://images.lib.cam.ac.uk/iiif/","native.jpg",NULL,"Provided by Cambridge University Library. Zooming image © Cambridge University Library, All rights reserved.  This image may be used in accord with fair use and fair dealing provisions, including teaching and research. If you wish to reproduce it within publications or on the public web, please contact <a href='mailto:genizah@lib.cam.ac.uk'>genizah@lib.cam.ac.uk</a>.");

INSERT INTO image_urls (image_urls_id,url,suffix,proxy,license)
VALUES(4,"https://qumranica.org/iiif?IIIF=","native.jpg",NULL,"Public Domain");

UPDATE image_urls
SET url = 'https://iaa.iiifhosting.com/iiif/',
    suffix = 'native.jpg',
    proxy = NULL,
    license = 'The images are licensed under a Creative Commons Attribution-Non Commercial 4.0 International (CC BY-NC 4.0).\nhttps://creativecommons.org/licenses/by-nc/4.0/\n\nYou are permitted to use images for non-commercial uses such as lectures, public presentations and other educational uses.  To license images for commercial uses such as reproduction, publications, displays, etc., please contact the Israel Antiquities Authority Visual Archive at VisualArchive@israntique.org.il.  \n\nFor more information on licensing please contact us at contact@deadseascrolls.org.il\n'
WHERE image_urls_id = 2;

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00001.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "1r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00001.jp2", 5302, 6569, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00002.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "1v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00002.jp2", 5489, 7099, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00003.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "2r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00003.jp2", 5047, 6765, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00004.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "2v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00004.jp2", 5145, 6883, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00005.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "3r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00005.jp2", 5351, 6824, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00006.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "3v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00006.jp2", 5066, 6696, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00007.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "4r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00007.jp2", 5420, 6736, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00008.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "4v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00008.jp2", 5086, 6608, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00009.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "5r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00009.jp2", 5096, 6716, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00010.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "5v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00010.jp2", 5253, 6873, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00011.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "6r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00011.jp2", 5017, 7069, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00012.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "6v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00012.jp2", 5007, 6755, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00013.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "7r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00013.jp2", 5223, 6971, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00014.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "7v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00014.jp2", 5322, 6834, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00015.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "8r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00015.jp2", 5047, 6726, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00016.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "8v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00016.jp2", 5007, 6902, 298, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00017.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a1r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00017.jp2", 4684, 5924, 588, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00018.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a2r_1v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00018.jp2", 6884, 4506, 433, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00019.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a3r_2v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00019.jp2", 6774, 4426, 431, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00020.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a4r_3v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00020.jp2", 6844, 4466, 431, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00021.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a4v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00021.jp2", 4564, 6139, 612, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00022.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a5r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00022.jp2", 4676, 5884, 583, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00023.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a6r_5v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00023.jp2", 6784, 4426, 432, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00024.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a6v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00024.jp2", 4526, 5904, 590, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00025.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a7r", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00025.jp2", 4536, 5814, 590, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00026.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a8r_7v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00026.jp2", 6672, 4404, 436, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00010-K-00006-000-00027.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 10K6", "a8v", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00010-K-00006-000-00027.jp2", 4496, 5824, 590, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00016-00311-000-00001.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 16.311", "1", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00016-00311-000-00001.jp2", 6348, 9564, 598, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://images.lib.cam.ac.uk/iiif/MS-TS-00016-00311-000-00002.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("CAM", "T-S 16.311", "1", 1)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "MS-TS-00016-00311-000-00002.jp2", 6180, 9564, 602, 0, 445, 704, 1,  LAST_INSERT_ID(), 0
FROM image_urls
WHERE url = "https://images.lib.cam.ac.uk/iiif/"
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);
            

# Insert https://qumranica.org/iiif?IIIF=1QIsaA-r.jp2}

INSERT INTO image_catalog (institution, catalog_number_1, catalog_number_2, catalog_side)
VALUES("SHR", "1QIsaA", "NULL", 0)
ON DUPLICATE KEY UPDATE image_catalog_id = LAST_INSERT_ID(image_catalog_id);
            

INSERT INTO SQE_image (image_urls_id, filename, native_width, native_height, dpi, type, wavelength_start, wavelength_end, is_master, image_catalog_id, is_recto)
SELECT image_urls_id, "1QIsaA-recto.tif", 127488, 5013, 1215, 0, 445, 704, 1,  LAST_INSERT_ID(), 1
FROM image_urls
WHERE url = "https://qumranica.org/iiif?IIIF="
ON DUPLICATE KEY UPDATE SQE_image_id = LAST_INSERT_ID(SQE_image_id);

####################################
## Add some of the new IAA images ##
####################################

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "df945ab4d9d3b4c84b49a6f64fa183e43214d3ee7a02a3dd33fc10cea0d894d0", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "dc8f471e54731035261d4c042013ee190eab8283a3c92fcd1e863b217f022e40", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d4fc607d4cb4f0b0966a18f34400ea4a0c1cfb52d792e287027ea9650aa3256c", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "339f5bb479be72d8058e0ad3254e9e2f530ae133ef2c4715b8d84b09afd58380", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3e708c9b72c94c6f5a84d3e059a368a5595f811358c497007096c8b11f0fd3c9", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d9d5237200fe6fb7e41e737693dacf94e617375dde3dcd95d894c13f40e3ebd6", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "235d7283489b51c5bbc58c9ec374a46160213dbb8b907c59c60fb82d25f0d5b2", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a06a5718ae19de13ff22c1136a57a91410effbf7260d71b42a2fba745301552a", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "1"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "1100de9f7d53079e987349fac2dd00affad80920d73d3e6fdb2d0274e4f214c6", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a392b991b6cde212f11f0942eaec737c64a91032ad3e6fc1e68ac1e1de7a0ce6", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3893b5ca951c4f4fd71b003cedf0c09b781c9bbf2db3c56cb2c9260470816bc5", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d08fedeea4082d4436e248f2fa95838655af038071b9105f4f9777d1b0dc8976", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "48254d833200fe1d3aa3f274387c1655e937b0c025b3f22ffb63c87eac68333f", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "b6b40fdd1e9c3952bb9646e5056e48b2ec309b7ffb6245ec803b1f765087748", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "e8fb89275280790baa93c86234609d5aad60a28c780894dc7b464c8dbfe8e08f", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "cef35578b92dee3eb71540cc85cbc6bce25f4da678b5b8f2ed78479d8ac1f895", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "2"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "4f8eeafd048e03180a38d734e13e2511a8b99bd4dcec274ec1bc8fa2ec0b6f2e", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "b407474bfc20433c604a33771a1eaf3a4e9f29d3f2e6f89b13c11da5522b8b97", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c990c00d39aba21820e971f1160a134f254515ae06795f2d624886a08e17b02b", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "b356ff382a7c63a846c01c0e3d4b02ba040ce61dbabefa7acb4d232d923e9d84", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "2a940ce6c2dd7937c76cb92100511231846662e5d95f5021d6147618366208e0", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d0e36466ffad5a088751b033f5d8478093fa94e6b60da6898c28f5fecf1d46b3", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c11826c3b1212a2f21d3f5836d1a96ebc273f11a23919feb5033f576f7433464", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3e7056f347848d2b7cef29ad64f22029ead46bb898407abd2565fcaab85d59e0", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "3"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "ff739240db70fa165b00dcd3e48481d95ecd8160e6f93cba053c02c195d9e27a", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "432421d37cd9583555266f3208546ad2cc4e38ccf10ab13cb3a1341d284e6d6f", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "7812b0dd33e99e20975d796ff4a91a1393efb4fec2ee696b50f680a4248023e4", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "5522325f8a311102556c9343baf603667e113b3cf6a33013822d1e09d5870128", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "adb1f85aa50c302187e30080c25d3a4ce219f34e604f627dc0bcc5ff2fa5f2af", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "defa0cc29b9b0fa13eaaa5c553813c849904d4231cce6349b40c58bceebb62c0", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "401f94b1991ae88072f4ea94f4bd30e0b95f3293187ede8a0ca0e31e4edd9b21", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a8fc9861cdc63a8a1961f051ee4606606e7e2fbddc13cf4886677ab0b3f92d03", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "4"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "cf903d5f6c6239be6de9848e991dcea437a2f5ed7692cafd6b0055004ab2985c", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c3f5828b464b48216a90f8ad072973134e9387851aa95ed847bf181b01a4bb3e", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3e83776c784e29c0a550018fd424a70c0371cbd194c164e5a4902816f60207f5", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "8d1bf3cb2d2e12857b260374403ff8fd526819b06df4651767fed6163806bb0b", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a35b2bad649a6820d582d9ea3ed4bdfa011acf4808ca593e6c35598502c24db4", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a33260ae81d8456aa88020977769d278efb851519ef194fbb25016c7f4666215", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3268001b51b196b62d4cb60960c78c26e2c8859640c559caabd776a30b7b4a01", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "e34dbd2359afa5775e3040d85c6881da2bc15569a6a1ff108d85140ce7cefb2d", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "5"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c50d031285378251501cb265b00299bf64a4b3e02c6c9df6490dcf842d7627dc", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "887a242a7a09517a602894014c92a8086bc856ba976c76485fbcd506d4c8f8cd", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "43a57dfc627e49938709e7ac76996781cef13c96f8bdfe7d9e186ce4635cdbc3", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "fb9b00c208b0ad17d974cd3925ccfc24d0c39a736ddc953964b778eaba8be2ff", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d6fb235ac47a3c83a1646f22ea3c19f16225eb9bda2df14e5adcd0b11c540d14", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "547506b0a2472de816e490843d396c2f1d5be5526faca3abb889e948fa44f1ce", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a24e30015c5fa86417db88abe10102688f375493205317c062bb253935e05fb9", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "7f36eee7bcffd22484496a999833c7ab68ab43efabe12c317205e087deac7fea", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "6"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "308c0b5d3b3e4eefecb733e4e4bb4dd9082897a28b77ba534b4ef29ca60f2230", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "2c4582bdf67bf1d0b99dd5a31c1dc44cc2980a4872a29635ded59c328ebf89bc", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "6c52798d86b7b08364844ee9d36fbb726c2025e82d49afa35bacb59b4af15af5", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "688cdfa4a9af3189fe8f5cb1402a428a386983923adffadf024a229fecc1d939", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a15d80526190091212d24444c0c95e1bafcfe7bb7c321b41195e8800bbc4ea08", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c111e9e06ddd1614ec2fc2309029c030da3b0277d6b7b6dd369c9a4284e1ca2", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "993a71f13887e0a9cca7d8a0e270314f4f079f92464cde5b2a1d278b8a42d8b0", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "dff8bee7e6d06176fe44312963d57cf3e6b126af46764ce5f7a6f944b1e7d204", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "7"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "7f009bbcc1dba25e43429b48efe56738d45768b9bbb4dba3a1d36ef95a7b82de", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "8a037beee3f35ba10aa20bd29bd9da916035b3a6017ad1bfce0d28b7266379ba", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "fdecf30a84ca354b2475108ba510760635f46873dcc695b19e373313434dbd2e", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "dd1d9f504d2bee8792a07d8b442632f042221f2f1c6b4df1ff5d64622a4f4320", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "9a7ca25e33606dd74c861410457ec7a5d31019a54953f2f5c9fbb9118b42df92", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c61e0c22a4fd012d395c3b1da0469c9d2994d5668e95a6eab653a61a9214d8ce", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "3cede78ccd5ae424e57edf5caa22e3889a28092d335e3b62e7a187e98b742d6e", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "a36a1590c069ff67e9587ba575e51e181eafbf3b5d957a5eb3466bd2b00ea01e", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "8"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "8db0558a86f72aa8d19126e316c0e17f3fcac568db1e97ea0728959e3b4f5993", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "bdd81921471a3ad547aa6dc62875dcd32f4dca05a442d908e02aec0d38ac27a4", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c982359d09d6d323e13ba66dca3eb34f34777df78c59d21b502ff04d5171cd96", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "689aa96b16e76b977867755536c1fc86216d19d1b1b10940d7e05c807ece8189", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c9055d4d9bebe179ed36850fe8a4d7d9765a9c74fa7faae9877ade9393257a98", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "e2db7d25028d513a5bba152af2f9382099ac0aa834b49950670d7098aefd1019", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d5cb9a24a989099676528ce44ef5d833eb904d7c12dfe3d20d0c1c81454cc847", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "127b7e6260c0585902630bd637a82eb551a73b24d21c18badb327857cec25405", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "9"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "c96ef63521272f0d8ce4d786bf8b911f70f5213ba8aa82035f37aaa8e715bf13", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "24613995b26f32fb3db1c5efe738b76276b41e38ae19d8225a846737336c38d", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "9489fd14c7837bf3627f0880633c0387c4ae90d3c8d886d13562c95f9145d89f", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "e122b5430bc9d7bbe7bf0cfc27b3dbc2a2f694b2dc74ef53c1c63753d2995c1b", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 1
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 0
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "ff4bd88367f5f9d78ba4f047c35e4819770074142818ced730ceda742e8cec02", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 0
    AND SQE_image.is_master = 1;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "d1bc50b9b09d2e872998e39b97a7837533c898934fdce7ef138da4eeacd550b", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 1
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "28c1281071e46071003d48a01eb6a2866e009acf10ec14306288736c1bc0f928", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 2
    AND SQE_image.is_master = 0;
                

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
SET SQE_image.filename = "cb5557feb434e092237e1663763cdd83d9f2d772b428320e20067770f57554d5", 
    SQE_image.image_urls_id = (SELECT image_urls_id FROM image_urls WHERE url = "https://iaa.iiifhosting.com/iiif/"),
    SQE_image.native_width = 7216,
    SQE_image.native_height = 5412,
    SQE_image.is_recto = 0
WHERE image_catalog.catalog_number_1 = "289"
    AND image_catalog.catalog_number_2 = "10"
    AND image_catalog.institution = "IAA"
    AND image_catalog.catalog_side = 1
    AND SQE_image.type = 3
    AND SQE_image.is_master = 0;