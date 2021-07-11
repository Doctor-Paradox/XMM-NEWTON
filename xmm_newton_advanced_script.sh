#V-2.2
##########################################################################################################
# Script for XMM-NEWTON Data reduction with maximum possible automation.                                 #
# Author: GURPREET SINGH                                                                                 #
# Designation: Junior Research Fellow, ARIES.                                                            #
# Date: 22-27, Aug, 2020                                                                                 #
# Last updated: 10, Dec, 2020                                                                            #
# E-Mail: gurpreet@aries.res.in                                                                          #
##########################################################################################################
#--------------------------------------------------------------------------------------------------------#
#         HERE WE ASSUME REDUCTION PROCEDURE STARTS FROM OBERVATION ID FILE e.g. 0979709709              #
#--------------------------------------------------------------------------------------------------------#
# NAMING CONVENTION:                                                                                     #
# RAW EVENT FILES: instrument_exposure.FITS                                                              #
# FILTERED FILES: instrument_exposure_stdFILT.FITS         ; std   = S for standard filter               #
#                                                                  = U for predefined filter             #
#                                                                  = User for user defined filter        #
#                                                                  = SOFT for 0.3-2.5 KeV filter         #
#                                                                  = HARD for 2.5-10 KeV filter          #
# BACKGROUND SOFT PROTON FLARE SET:           instrument_exposure_GE10KEV.FITS                           #
# NEW GTI FILE:                               instrument_exposure_gtiset_std.fits                        #
# GTI CORRECTED EVENT FILES:                  instrument_exposure_stdFILT_TIME.FITS                      #
# IMAGE FILES:                                (Filtered files/GTI corrected event file)_IM.FITS          #
# FILTERED SETS FOR BACKGROUND SPECTRA:       (Filtered files/GTI corrected event file)_BKG_SP_FILT.FITS #
# FILTERED SETS FOR SOURCE SPECTRA:           (Filtered files/GTI corrected event file)_SRC_SP_FILT.FITS #
# SOURCE SPECTRA:                             (Filtered files/GTI corrected event file)_SRC_SP.FITS      #
# BACKGROUND SPECTRA:                         (Filtered files/GTI corrected event file)_BKG_SP.FITS      #
# EPAT OUTPUT:                                (Filtered files/GTI corrected event file)_EPAT.ps          #
# SOURCE LIGHT CURVE:                         (Filtered files/GTI corrected event file)_SRC_LC.FITS      #
# BACKGROUND LIGHT CURVE:                     (Filtered files/GTI corrected event file)_BKG_LC.FITS      #
# BACKGROUND SUBTRACTED LIGHT CURVE:          (Filtered files/GTI corrected event file)_LC_CORR.FITS     #
# RMF:                                        (Filtered files/GTI corrected event file)_RMF.FITS         #
# ARF:                                        (Filtered files/GTI corrected event file)_ARF.FITS         #
# INTERMIDEATE TEXT FILES:                                                                               #
# user_filter.txt                         --> Shows current user filter expression                       #
# coord.txt                               --> Used for RA-DEC to physical coordinate conversion          #
# srcmatchi.txt                           --> To get source region ( circle ) in physical coordinates    #
#                                             using Ds9 (xpaget)                                         #
# matchi.txt                              --> To get background region ( circle ) in physical coord-     #
#                                             -inates using Ds9 (xpaget)                                 #
# *_pileup.txt                            --> Stores information of last used annular region of source   #
#                                             for pile-up correction.                                    #
# NOTE: INTEMIDEATE TEXT FILES kept on overwriting them. So information present in them after completion #
#       of script is just information of last processed file.                                            #
# PYTHON CODES:                                                                                          #
# coordX.py                            :- Gives X coordinate of source in physical coordinates.          #
# coordY.py                            :- Gives Y coordinate of source in physical coordinates.          #
# src_circle.py                        :- Gives circle parameters of source in physical coordinates      #
#                                         from Ds9 window (using xpaget).                                #
# bkg_circle.py                        :- Gives circle parameters of background in physical              #
#                                         coordinates from Ds9 window (using xpaget).                    #
# IMPORTANT NOTE: 1) Change the path of codes in your device otherwise results will be erroneous.        #
#                 2) Script uses "play" command frequently, so make sure this package is installed on    #
#                    device.                                                                             #  
#--------------------------------------------------------------------------------------------------------#
#*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_#
# Description:                                                                                           #
# This script reduces XMM-NEWTON data for EPIC-PN and EPIC-MOS. For succesful execution of script call   #
# it from obervation ID folder (folder with 10 digit number). User can make use of different filters for #
# same event file in one go.                                                                             #
# Script has four prdefined filters along with a user defined filter for both MOS and PN. For each filter#
# user can make soft and hard light curves sapparately along with usual full filter light curve.         #
# Source, background spectra can be selected either by RA-DEC information or directly by selecting       #
# region from image popped up as Ds9 window. Pile-up corrections are been taken care of. RMF and ARF     #
# files can be made only after successful removal of pile-up.                                            # 
#--------------------------------------------------------------------------------------------------------#
#*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_#
##########################################################################################################
echo "-----------------------------------------------------------------------------------------------------------------------------------------"
figlet -c XMM-NEWTON SCRIPT
echo "-----------------------------------------------------------------------------------------------------------------------------------------"

opted_method=$1
if [ -z "$1" ] 
then	echo "#*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_#"
	echo "# Description:                                                                                           #"
	echo "# This script reduces XMM-NEWTON data for EPIC-PN and EPIC-MOS. For succesful execution of script call   #"
	echo "# it from obervation ID folder (folder with 10 digit number).                                            #"
	echo "# Sript has two modes CLI and GUI. User can opt by passing argument -c (for CLI) -g(for GUI).            #"
	echo "# Options:                                                                                               #"
	echo "# 1) command line interface(CLI)                 ( pass argument -c at initialisation of script)         #"
	echo "# 2) Graphical user interface(GUI)               ( pass argument -g at initialisation of script)         #"
#	echo "# 3) Reduction on selected detectors:  PN only MOS only BOTH detector mode                               #"
#	echo "# NOTE:     Change the path of codes in your device otherwise results will be erroneous.                 # "
	echo "#--------------------------------------------------------------------------------------------------------#"
	echo "#*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_#"
	printf "########################################################################################################## \n

# Author: GURPREET SINGH                                                                                			   # \n
# Designation: Junior Research Fellow, ARIES.                                                           			   # \n
# Date: 07, Dec, 2020                                                                                 				   # \n
# Last updated: 10, jan, 2021                                                                           			   # \n
# E-Mail: gurpreet@aries.res.in                                                                          			   # \n
#################################################################################################################################### \n
#----------------------------------------------------------------------------------------------------------------------------------# \n
#         HERE WE ASSUME REDUCTION PROCEDURE STARTS FROM OBERVATION ID FILE e.g. 0979709709              			   # \n
#----------------------------------------------------------------------------------------------------------------------------------# \n 
# MAKING SENSE OF FILE NAMES:                                                                                                      # \n
#                                       BASIC FILE NAMES                                                 		           # \n
# RAW EVENT FILES:                            instrument_exposure.FITS                                                             # \n
# CLOSED FILTER EVENT FILE:                   instrument_exposure_closed.FITS                                                      # \n
# FILTERED FILES:                             instrument_exposure_stdFILT.FITS                           			   # \n
#                                                          ; std   = S for standard filter               			   # \n
#                                                                  = U for predefined filter             			   # \n
#                                                                  = User for user defined filter        			   # \n
#                                                                  = SOFT for 0.3-2.5 KeV filter         			   # \n
#                                                                  = HARD for 2.5-10 KeV filter          			   # \n
# BACKGROUND SOFT PROTON FLARE SET:           instrument_exposure_GE10KEV.FITS                           			   # \n
# IMAGESET FOR BACKGROUND FLARE CHECK         instrument_exposure_GE10KEV_image.FITS                   			           # \n
# NEW GTI FILE:                               instrument_exposure_gtiset.fits                           			   # \n
# GTI CORRECTED EVENT FILES:                  instrument_exposure_stdFILT_TIME.FITS                                                # \n
# SEVERLY DAMAGED BY BACKGROUND FLARE EVENT:  instrument_exposure_SEVERE.FITS                                                      # \n
# IMAGE FILES:                                (Filtered files/GTI corrected event file)_IM.FITS                                    # \n
# FILTERED SETS FOR BACKGROUND SPECTRA:       (Filtered files/GTI corrected event file)_BKG_SP_FILT.FITS                           # \n
# FILTERED SETS FOR SOURCE SPECTRA:           (Filtered files/GTI corrected event file)_SRC_SP_FILT.FITS                           # \n
# SOURCE SPECTRA:                             (Filtered files/GTI corrected event file)_SRC_SP.FITS                                # \n
# BACKGROUND SPECTRA:                         (Filtered files/GTI corrected event file)_BKG_SP.FITS                                # \n
# EPAT OUTPUT:                                (Filtered files/GTI corrected event file)_EPAT.ps                                    # \n
# SOURCE LIGHT CURVE:                         (Filtered files/GTI corrected event file)_SRC_LC.FITS                                # \n
# BACKGROUND LIGHT CURVE:                     (Filtered files/GTI corrected event file)_BKG_LC.FITS                                # \n
# BACKGROUND SUBTRACTED LIGHT CURVE:          (Filtered files/GTI corrected event file)_LC_CORR.FITS                               # \n
# SOFT SOURCE LIGHT CURVE:                    (Filtered files/GTI corrected event file)_SOFT_SRC_LC.FITS                           # \n
# SOFT BACKGROUND LIGHT CURVE:                (Filtered files/GTI corrected event file)_SOFT_BKG_LC.FITS                           # \n
# SOFT BACKGROUND SUBTRACTED LIGHT CURVE:     (Filtered files/GTI corrected event file)_SOFT_LC_CORR.FITS                          # \n
# HARD SOURCE LIGHT CURVE:                    (Filtered files/GTI corrected event file)_HARD_SRC_LC.FITS                           # \n
# HARD BACKGROUND LIGHT CURVE:                (Filtered files/GTI corrected event file)_HARD_BKG_LC.FITS                           # \n
# HARD BACKGROUND SUBTRACTED LIGHT CURVE:     (Filtered files/GTI corrected event file)_HARD_LC_CORR.FITS                          # \n
# RMF:                                        (Filtered files/GTI corrected event file)_RMF.FITS                                   # \n
# ARF:                                        (Filtered files/GTI corrected event file)_ARF.FITS                                   # \n
# GROUPED SPECTRA FILE:                       (Filtered files/GTI corrected event file)_GRP.FITS                                   # \n
# 100 BINNING LIGHT CURVES USED FOR ADVANCED FILTERING:                    *LC_CORR100.FITS                                        # \n
#																   # \n
#                                         QUIESCENT PHASE FILENAMES                                                                # \n
#																   # \n
# FILTERED SETS FOR BACKGROUND QUIET SPECTRA: (Filtered files/GTI corrected event file)_BKG_SP_FILT_QUITE.FITS                     # \n
# FILTERED SETS FOR SOURCE QUIET SPECTRA:     (Filtered files/GTI corrected event file)_SRC_SP_FILT_QUITE.FITS                     # \n
# QUIET SOURCE SPECTRA:                       (Filtered files/GTI corrected event file)_SRC_SP_QUITE.FITS                          # \n
# QUIET BACKGROUND SPECTRA:                   (Filtered files/GTI corrected event file)_BKG_SP_QUITE.FITS                          # \n
# QUIET RMF FILE:                             (Filtered files/GTI corrected event file)_RMF_QUITE.FITS                             # \n
# QUITE ARF FILE:                             (Filtered files/GTI corrected event file)_ARF_QUITE.FITS                             # \n          
# QUITE SOURCE LIGHT CURVE:                   (Filtered files/GTI corrected event file)_SRC_LC_QUITE.FITS                          # \n
# QUITE BACKGROUND LIGHT CURVE:               (Filtered files/GTI corrected event file)_BKG_LC_QUITE.FITS                          # \n
# QUITE BACKGROUND SUBTRACTED LIGHT CURVE:    (Filtered files/GTI corrected event file)_LC_CORR_QUITE.FITS                         # \n
# QUITE SOFT SOURCE LIGHT CURVE:              (Filtered files/GTI corrected event file)_SOFT_SRC_LC_QUITE.FITS                     # \n
# QUITE SOFT BACKGROUND LIGHT CURVE:          (Filtered files/GTI corrected event file)_SOFT_BKG_LC_QUITE.FITS                     # \n
# QUITE SOFT BACKGROUND SUBTRACTED LIGHTCURVE:(Filtered files/GTI corrected event file)_SOFT_LC_CORR_QUITE.FITS                    # \n
# QUITE HARD SOURCE LIGHT CURVE:              (Filtered files/GTI corrected event file)_HARD_SRC_LC_QUITE.FITS                     # \n
# QUITE HARD BACKGROUND LIGHT CURVE:          (Filtered files/GTI corrected event file)_HARD_BKG_LC_QUITE.FITS                     # \n
# QUITE HARD BACKGROUND SUBTRACTED LIGHTCURVE:(Filtered files/GTI corrected event file)_HARD_LC_CORR_QUITE.FITS                    # \n
#																   # \n
#                                           FLARE PHASE FILENAMES                                                                  #\n
#										          	           		           # \n
# *postfix if user given variable.                                                                                                 # \n
# *lowsoft and highsoft are lower and upper energy bounds for soft lightcurves                                                     # \n
# *lowhard and highhard are lower and upper energy bounds for hard lightcurves                                                     # \n
# FILTERED SETS FOR BACKGROUND FLARE SPECTRA: (Filtered files/GTI corrected event file)_BKG_SP_FILT_F_postfix.FITS                 # \n
# FILTERED SETS FOR SOURCE FLARE SPECTRA:     (Filtered files/GTI corrected event file)_SRC_SP_FILT_F_postfix.FITS                 # \n
# FLARE SOURCE SPECTRA:                       (Filtered files/GTI corrected event file)_SRC_SP_F_postfix.FITS                      # \n
# FLARE BACKGROUND SPECTRA:                   (Filtered files/GTI corrected event file)_BKG_SP_F_postfix.FITS                      # \n
# FLARE RMF FILE:                             (Filtered files/GTI corrected event file)_RMF_F_postfix.FITS                         # \n
# FLARE ARF FILE:                             (Filtered files/GTI corrected event file)_ARF_F_postfix.FITS                         # \n 
# FLARE SOURCE LIGHT CURVE:                   (Filtered files/GTI corrected event file)_SRC_LC_F_postfix.FITS                      # \n
# FLARE BACKGROUND LIGHT CURVE:               (Filtered files/GTI corrected event file)_BKG_LC_F_postfix.FITS                      # \n
# FLARE BACKGROUND SUBTRACTED LIGHT CURVE:    (Filtered files/GTI corrected event file)_LC_CORR_F_postfix.FITS                     # \n
# FLARE SOFT SOURCE LIGHT CURVE:              (Filtered files/GTI corrected event file)_${lowsoft}_${highsoft}_SOFT_SRC_LC_$postfix.FITS # \n
# FLARE SOFT BACKGROUND LIGHT CURVE:          (Filtered files/GTI corrected event file)_${lowsoft}_${highsoft}_SOFT_BKG_LC_$postfix.FITS # \n
# FLARE SOFT BACKGROUND SUBTRACTED LIGHTCURVE:(Filtered files/GTI corrected event file)_${lowsoft}_${highsoft}_SOFT_SRC_LC_$postfix.FITS # \n
# FLARE HARD SOURCE LIGHT CURVE:              (Filtered files/GTI corrected event file)_${lowhard}_${highhard}_SOFT_SRC_LC_$postfix.FITS # \n
# FLARE HARD BACKGROUND LIGHT CURVE:          (Filtered files/GTI corrected event file)_${lowhard}_${highhard}_SOFT_SRC_LC_$postfix.FITS # \n
# FLARE HARD BACKGROUND SUBTRACTED LIGHTCURVE:(Filtered files/GTI corrected event file)_${lowhard}_${highhard}_SOFT_SRC_LC_$postfix.FITS # \n
#																   # \n
#                                        RGS SPECIFIC FILENAMES                                                                    #\n
#																   # \n
# EVENT FILES:                                        detector_exposure_EVENT.FITS                                                 #\n
# SOURCE FILES:                                       detector_exposure_SRCLI.FITS                                                 #\n
# M_LAMBDA VS XDSP_CORR:                              name contains --> *spatial*                                                  #\n
# M_LAMBDA VS PI:                                     name contains -->  *pi*                                                      #\n
# BANANA PLOTS:                                       postscript file with *banana* in name                                        #\n
# BACKGROUND IMAGE:                                   name contains --> *background*                                               #\n
# BACKGROUND FLARE CHECK:                             name contains --> *BKG_FLARE_LC*                                             #\n
# FIRST ORDER SOURCE SPECTRA:                         detector_exposure_SRSPEC_O1.FITS                                             #\n
# FIRST ORDER BACKGROUND SPECTRA:                     detector_exposure_BGSPEC_O1.FITS                                             #\n
# SECOND ORDER SOURCE SPECTRA:                        detector_exposure_SRSPEC_O2.FITS                                             #\n
# SECOND ORDER BACKGROUND SPECTRA:                    detector_exposure_BGSPEC_O2.FITS                                             #\n
# FIRST ORDER RMF:                                    detector_exposure_RMF_O1.FITS                                                #\n
# SECOND ORDER RMF:                                   detector_exposure_RMF_O2.FITS                                                #\n
# COMBINED SPECTRA:                                   prefix for name : R12                                                        #\n
# BACKGROUND SUBTRACTED SOURCE LIGHT CURVE:           name contains: *SRC_LC_BKG_subtracted.lc                                     #\n
# *FLUXED SPECTRA CONTAINS *FLUXED* IN ITS NAME.                                                                                   #\n
# PILED-UP EVENT FILES:                               containes *piledup.FITS in name                                              #\n
#                                 PHASE RESOLVED SPECTRA                                                                           #\n
#  ** NAMES CONTAIN *PHASEstart-stop* PATTERN. start AND stop ARE START AND STOP OF PHASE INTERVAL.                                #\n
#  ** GROUPED SPECTRA FILES CONTAIN *GRP* IN NAME.                                                                                 #\n
#                                 ********************************                                                                 # \n
# TEXT FILES:                                                                                                                      # \n
# (RAW EVENT FILENAME)_filter.txt         --> Contains information on which filter was used for observa-                           # \n
#                                             -tion.                                                                               # \n
# user_filter.txt                         --> Shows current values for user defined filter on raw event                            # \n
#                                             file. ( Note: previous filter information is lost.)                                  # \n
# coord.txt                               --> Used for RA-DEC to physical coordinate conversion.                                   # \n
#                                             ( Note: previous information is lost.)                                               # \n
# srcmatchi.txt                           --> To get source region ( circle ) in physical coordinates                              # \n
#                                             using Ds9 (xpaget)                                                                   # \n
# bkg_matchi.txt/matchi.txt               --> To get background region ( circle ) in physical coord-                               # \n
#                                             -inates using Ds9 (xpaget)                                                           # \n
# (Filtered files/GTI corrected event									                           # \n
#  file)_pileup.txt                       --> Contains information about annulas region used while                                 # \n
#                                             correcting for pileup effects in EPIC.                                               # \n
# *_GE10KEV.reg                           --> Region file for background flare checking contains informa-                          # \n
#                                             -tion about each background circle in physical units.                                # \n
# (Filtered files/GTI corrected event									                           # \n
# file)_source.region                     --> Source region parameters in physical units for that event                            # \n
#                                             file.                                                                                # \n
# (Filtered files/GTI corrected event									                           # \n
# file)_background.region                 --> Background region parameters in physical units for that                              # \n
#                                             event file.                                                                          # \n
# *src.reg                                --> Source region file for RGS.                                                          # \n
# contaminator.reg                        --> Region file for bright X-ray contaminator, used for RGS.                             # \n
#                                 ********************************                                                                 # \n
# PYTHON CODES:                                                                                                                    # \n
# bkg_multicircle_xmm.py               :- Creates filter expression for background regions. N number of                            # \n
#                                         background circles can be selected. Modes: for bkg Flare check                           # \n
#                                         and for science products.				                                   # \n
# time_fil_expre_maker.py              :- Creates Time filter expression from lightcurve. Used for bkg                             # \n
#                                         flare removal and for extracting particular regions of time in                           # \n
#                                         science product files ( i.e. filtered event file).                                       # \n
# coordX.py                            :- Gives X coordinate of source in physical coordinates(used when                           # \n
#                                         RA DEC of source is given by user.                                                       # \n 
# coordY.py                            :- Gives Y coordinate of source in physical coordinates(used when                           # \n
#                                         RA DEC of source is given by user.                                                       # \n
# src_circle.py                        :- Gives circle parameters of source in physical coordinates                                # \n
#                                         from Ds9 window (using xpaget).                                                          # \n
# rgs_user_index_finder.py             :- Gives the value of USER index in RGS source list files.                                  # \n
# rgs_contaminator.py                  :- Used for removal of x-ray bright contaminating source in RGS.                            # \n
# rgs_pileup.py                        :- Plot First order and second order fluxed spectra alongwith                               # \n
#                                         there ratio.                                                                             # \n
#                                 ********************************                                                                 # \n
# IMPORTANT NOTE:                                                                                                                  # \n
#                 DO NOT FORGET TO SET CCFPATH BEFORE RUNNING THIS SCRIPT                                                          # \n 
#################################################################################################################################### \n"
	echo "Please enter valid option..."
	echo "For GUI:"
	echo "xmmadvanced -g 2>&1 | tee XMM-SCRIPT.log"
	echo "For CLI:"
	echo "xmmadvanced -c "
	exit
fi
if [ -z $SAS_CCFPATH ]
then	if [ "$opted_method" == "-c" ]
	then	echo "PLEASE SET CCFPATH"
		exit
	else 	zenity --title "XMM-SCRIPT" --width 500 --height 500 --error --text "CCFPATH Not set"
		exit
	fi
fi

if [ "$opted_method" == "-c" ]
then	imlooper=0
	while [ $imlooper = 0 ]
	do
		echo "PLEASE SELECT ON WHICH DETECTOR YOU WANt REDUCTION TO BE DONE."
		echo "1) PN ONLY."
		echo "2) MOS ONLY."
		echo "3) BOTH PN and MOS"
		echo "4) RGS ONLY"
		echo "5) Analysis folder maker"
		echo "6) Advanced options"
		read selc
		if [ $selc = 1 ]
		then	pnonly=1
			imlooper=1
		elif [ $selc = 2 ]
		then 	mosonly=1
			imlooper=1
		elif [ $selc = 3 ]
		then	mospn=1
			imlooper=1
		elif [ $selc = 5 ]
		then	analysismaker=1
			imlooper=1
		elif [ $selc = 6 ]
		then	advancedoption=1
			imlooper=1
		elif [ $selc = 4 ]
		then	rgsonly=1
			imlooper=1
		else echo "PLEASE SELECT VALID OPTION."
		fi
	done
else	det1="PN ONLY"
	det2="MOS ONLY"
	det3="BOTH PN and MOS"
	det4="RGS ONLY"
	det5="Analysis folder maker"
	det6="Advanced options"
	selc=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'PLEASE SELECT ON WHICH DETECTOR YOU WANt REDUCTION TO BE DONE.' --column 'Select...' --column '...' FALSE "$det1" FALSE "$det2" FALSE "$det3" FALSE "$det4" FALSE "$det5" FALSE "$det6"`
	
	if [ "$selc" == "$det1" ]
	then 	pnonly=1
		
	elif [ "$selc" == "$det2" ]
 	then	mosonly=1
	
	elif [ "$selc" == "$det3" ]
	then 	mospn=1
	elif [ "$selc" == "$det5" ]
	then 	analysismaker=1
	elif [ "$selc" == "$det6" ]
	then 	advancedoption=1
	elif [ "$selc" == "$det4" ]
	then 	rgsonly=1
	else exit
	fi
fi

cd ODF
echo "Now we are in:" $(pwd)
#export SAS_CCFPATH=/home/gurpreet/ccf
export SAS_CCF=$(pwd)/ccf.cif
export SAS_ODF=$(pwd)

a=$(ls *gz | wc -l)
if [ $a != 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "Unzipping files..."
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Unzipping files..."
		fi  
		gunzip *.gz
	else	if [ $opted_method == '-c' ]
		then	echo "Not unzipping any files either they don't exist or already been unzipped."
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Not unzipping any files either they don't exist or already been unzipped."
		fi 

fi

b=$(ls *M.SAS | wc -l)
if [ $b = 0 ] 
	then	if [ $opted_method == '-c' ]
		then	echo "Performing summary file and calibrated file list, as it seems this is first time of reduction." 
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Performing summary file and calibrated file list, as it seems this is first time of reduction."
		fi 
		set -e	
		cifbuild
		odfingest
		set +e
else	if [ $opted_method == '-c' ]
	then	echo "Seems like summary files anf CCF file has already been generated. Do you want to rerun it?"
		read cfd
		if [ $cfd = y ]
		then	rm *M.SAS
			set -e	
			cifbuild
			odfingest
			set +e
		fi
	else	cfd=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Seems like summary files anf CCF file has already been generated.Do you want to rerun it?"; echo $?)
		if [ $cfd = 0 ]
		then	rm *M.SAS
			set -e	
			cifbuild
			odfingest
			set +e
		fi
	fi
fi

c=$(ls *m.sas | wc -l)
if [ $c = 0 ]
	then	echo "Renaming summary file to somewhat handy."
		cp *SUM.SAS sum.sas 
else echo "Looks all good!"
fi

if [ $opted_method == '-c' ]
	then	echo "SETTING SAS PREFERENCES"
		set -e
		export SAS_ODF=$(pwd)/sum.sas
		echo "All set."
		echo "SAS_ODF= $SAS_ODF"
		echo "SAS_CCF= $SAS_CCF"
		set +e
	else 	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "SETTING SAS PREFERENCES"
		set -e
		export SAS_ODF=$(pwd)/sum.sas
		zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "printf SAS_ODF= $SAS_ODF \n SAS_CCF= $SAS_CCF \n SAS_CCFPTH= $SAS_CCFPATH"
		set +e
	fi

cd ..

d=$(ls -d pn | wc -l)
if [ $d = 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "Making sapparate folders for further data reduction."	
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Making sapparate folders for further data reduction."
		fi
		mkdir pn
		mkdir mos
		mkdir rgs
		mkdir analysis
	else	if [ $opted_method == '-c' ]
		then	echo "Sounds like sapparate folders have already been created. Do you wanna make folder again? (y/n)"
			read ans
			if [ $ans = 'y' ]
			then	mv  pn pn_old
				mv mos mos_old
				mv rgs rgs_old
				mv analysis analysis_old
				mkdir pn
				mkdir mos
				mkdir rgs
				mkdir analysis
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question  --text "sapparate folders have already been created. Do you wanna make folder again?"; echo $?)
			if [ $que = 0 ]
			then	mv  pn pn_old
				mv mos mos_old
				mv rgs rgs_old
				mv analysis analysis_old
				mkdir pn
				mkdir mos
				mkdir rgs
				mkdir analysis
			fi
		fi
			
fi



#============================================================================================================================================
#                                                         function declarations
#============================================================================================================================================
#                 pnproccer > runs epproc                                                                      working directory > pn
#============================================================================================================================================
function pnproccer(){
set +e
e=$(ls *AttHk* | wc -l)
if [ $e = 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "Running epproc"
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Running epproc"
		fi
		set -e
		epproc
		set +e
else	if [ $opted_method == '-c' ]
	then	echo "epproc has already been run.Do you want to rerun it?(y/n)"
		read ansp
		if [ $ansp = y ]
		then	set -e
			epproc
			set +e
		fi
	else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "epproc has already been run.Do you want to rerun it?"; echo $?)
		if [ $que = 0 ]
		then	set -e
			epproc
			set +e
		fi
	fi

fi
}
#============================================================================================================================================
#                 pnrenamer > renames PN imaging event files                                                    working directory > pn
#============================================================================================================================================
function pnrenamer(){
export tempnumb=1
set +e
ee=$(ls *PN*Im* | wc -l )
if [ $ee = 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "No imaging events were created by EPPROC. skipping all the procedures for PN."
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --warning --text "No imaging events were created by EPPROC. skipping all the procedures for PN."
		fi
		export pnflag=1
else	export pnflag=0
	jiraya=$(ls PN* | wc -l)
	if [ $jiraya = 0 ]	
	then	for filename in *PN*Im*; do  cp "$filename" "PN_$tempnumb.FITS"; tempnumb=$((tempnumb+1)); done
	fi
fi
}
#============================================================================================================================================
#                 mosproccer > runs emproc                                                                      working directory > mos
#============================================================================================================================================
function mosproccer(){
set +e
f=$(ls *AttHk* | wc -l)
if [ $f = 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "Running emproc"
		else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Running emproc"
		fi
		set -e
		emproc selectmodes=false
		set +e

else if [ $opted_method == '-c' ]
	then	echo "emproc has already been run.Do you want to rerun it?(y/n)"
		read ansp
		if [ $ansp = y ]
		then	set -e
			emproc selectmodes=false
			set +e
		fi
	else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "emproc has already been run.Do you want to rerun it?"; echo $?)
		if [ $que = 0 ]
		then	set -e
			emproc selectmodes=false
			set +e
		fi
	fi
fi
}
#============================================================================================================================================
#                 mosrenamer > renames mos imaging event files                                                    working directory > mos
#============================================================================================================================================
function mosrenamer(){
export tempnumb=1
set +e
ee=$(ls *MOS*Im* | wc -l )
if [ $ee = 0 ]
	then	if [ $opted_method == '-c' ]
		then	echo "No imaging events were created by EMPROC. skipping all the procedures for MOS."
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --warning --text "No imaging events were created by EMPROC. skipping all the procedures for MOS."
		fi
		export mosflag=1
else	export mosflag=0
	jiraya=$(ls MOS1* | wc -l )
	if [ $jiraya = 0 ]	
	then	for filename in *MOS1*Im*; do  cp "$filename" "MOS1_$tempnumb.FITS"; tempnumb=$((tempnumb+1)); done
	fi	
	export tempnumb=1	
	jiraya=$(ls MOS2* | wc -l )
	if [ $jiraya = 0 ]	
	then	for filename in *MOS2*Im*; do  cp "$filename" "MOS2_$tempnumb.FITS"; tempnumb=$((tempnumb+1)); done
	fi
fi
}
#============================================================================================================================================
#                mosfilterchecker  > checks filter for event file if closed will skip reduction for that file     working directory > Obs ID
#============================================================================================================================================
function mosfilterchecker(){
	set +e
	cd mos
	if [ $mosflag = 1 ]
	then	cd ..
	else	fil=$(ls *_closed* | wc -l)
		#set -e
		if [ $fil = 0 ] 
		then 	for filename in MOS1*; do echo $(fkeyprint $filename "FILTER")>${filename}_filter.txt; valu=$(grep -c  Closed ${filename}_filter.txt); if [ $valu != 0 ]; then echo "Filter is closed for $filename"; mv ${filename} ${filename//.FITS/_closed.FITS} ; else echo "Continue with $filename";fi; done

			for filename in MOS2*; do echo $(fkeyprint $filename "FILTER")>${filename}_filter.txt; valu=$(grep -c  Closed ${filename}_filter.txt); if [ $valu != 0 ]; then echo "Filter is closed for $filename";mv ${filename} ${filename//.FITS/_closed.FITS}; else echo "Continue with $filename";fi; done
		else if [ $opted_method == '-c' ]
		then echo "Filter is closed for this observation. "
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Filter is closed for this observation. "
		fi
		fi
	cd ..
	fi
	#set +e
	}
#============================================================================================================================================
#                pnfilterchecker  > checks filter for event file if closed will skip reduction for that file     working directory > Obs ID
#============================================================================================================================================
function pnfilterchecker(){
	set +e
	cd pn
	if [ $pnflag = 1 ] 
	then	cd ..
	else	fill=$(ls *_closed* | wc -l)
		#set -e
		if [ $fill = 0 ] 
		then	for filename in PN*; do echo $(fkeyprint $filename "FILTER")>${filename}_filter.txt; valu=$(grep -c  Closed ${filename}_filter.txt); if [ $valu != 0 ]; then echo "Filter is closed for $filename"; mv ${filename} ${filename//.FITS/_closed.FITS} ; else echo "Continue with $filename";fi; done
		else if [ $opted_method == '-c' ]
		then echo "Filter is closed for this observation. "
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Filter is closed for this observation. "
		fi
		fi
	cd ..
	fi
	#set +e 
	}
#============================================================================================================================================
#                USER  > set max pattern,energy bounds for user defined filter    arguments: 0 > pn 1 > mos     working directory > ---
#============================================================================================================================================
function USER() {
		set +e
		detector=$1
		if [ $opted_method == '-c' ]
		then	echo "Give max pattern."
			read maxPat
			echo "Give lower energy bound."
			read lowPI
			echo "Give upper energy bound."
			read upPI
			if [ $detector = 0 ]
			then
				defa="(PATTERN<=$maxPat)&&(PI in [$lowPI:$upPI])&&#XMMEA_EP"
				echo "Taking filter: $defa">user_filter.txt
				std=User
			else
				mdefa="(PATTERN<=$maxPat)&&(PI in [$lowPI:$upPI])&&#XMMEA_EM"
				echo "Taking filter: $mdefa">user_filter.txt
				mstd=User
			fi
			
		else	RETURNVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "User FILTER" --text  "USER DEFINED FILTER FOR EVENT FILE FILTERING" --add-entry="Max. Pattern" --add-entry="Lower energy bound" --add-entry="Upper energy bound"`
			maxPat=$(awk -F'|' '{print $1}' <<<$RETURNVALUE);    
			lowPI=$(awk -F'|' '{print $2}' <<<$RETURNVALUE);
			upPI=$(awk -F'|' '{print $3}' <<<$RETURNVALUE);
		fi
		echo "$maxPat"
		echo "$lowPI"
		echo "$upPI"
		if [ $detector = 0 ]
			then
				defa="(PATTERN<=$maxPat)&&(PI in [$lowPI:$upPI])&&#XMMEA_EP"	
				echo "Taking filter: $defa">user_filter.txt
			else
				mdefa="(PATTERN<=$maxPat)&&(PI in [$lowPI:$upPI])&&#XMMEA_EM"
				echo "Taking filter: $mdefa">user_filter.txt	
		fi
		
		}
#============================================================================================================================================
#                FILTERING  > creates filtered event files with gti correction     working directory > pn
#============================================================================================================================================
function FILTERING() {
	set +e
	if [ $opted_method == '-c' ]
	then	echo "STARTING STANDARD REDUCTION PROCEDURE FROM HERE"
		echo "Applying standard filters. Defaults are:"
		echo "(PATTERN<=12)&& (PI in [300:15000]) && #XMMEA_EP"
		echo "If change is needed press y else n"
		read choice
		if [ $choice = y ]
		then	echo "Choose between following."
			echo "1) (PATTERN<=12)&& (PI in [300:10000]) && #XMMEA_EP"
			echo "2) User defined"
			echo "3) (PATTERN<=12)&& (PI in [300:2500]) && #XMMEA_EP : SOFT BAND FILTER"
			echo "4) (PATTERN<=12)&& (PI in [2500:10000]) && #XMMEA_EP : HARD BAND FILTER"
			read choi
		else	echo "Taking default filters"
			defa="(PATTERN <= 12)&&(PI in [300:15000])&&#XMMEA_EP"
			choi=0
			std=S	
			echo $defa
		fi

		if [ $choi = 1 ]
		then	defa="(PATTERN<=12)&&(PI in [300:10000])&&#XMMEA_EP"
			echo "Taking filter:$defa "
			std=U
		elif [ $choi = 2 ]
		then	std=User
			check=$(ls *User* | wc -l)
			if [ $check = 0 ]
			then	USER 0;
			else	echo "This filter was already been used. Do you want to continue? It may lead to loss of previous filter data."
				read qw
				if [ $qw = y ]
				then	USER;
				else	echo "Skipping ."
				fi
			fi
		elif [ $choi = 3 ]
		then	defa="(PATTERN<=12)&&(PI in [300:2500])&&#XMMEA_EP"
			echo "Taking filter:$defa "
			std=SOFT
		elif [ $choi = 4 ]
		then	defa="(PATTERN<=12)&&(PI in [2500:10000])&&#XMMEA_EP"
			echo "Taking filter:$defa "
			std=HARD
		fi
	else	opt1="(PATTERN <= 12)&&(PI in [300:15000])&&#XMMEA_EP"
		opt2="(PATTERN<=12)&&(PI in [300:10000])&&#XMMEA_EP"
		opt3="(PATTERN<=12)&&(PI in [300:2500])&&#XMMEA_EP"
		opt4="(PATTERN<=12)&&(PI in [2500:10000])&&#XMMEA_EP"
		opt5="USER"
		defa=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'Select the filter expression to be used:' --column 'Select...' --column 'Filter expression' FALSE "$opt1" TRUE "$opt2" FALSE "$opt3" FALSE "$opt4" FALSE "$opt5"`
		
		if [ "$defa" == "$opt1" ]
		then std=S
		elif [ "$defa" == "$opt2" ]
		then std=U
		elif [ "$defa" == "$opt3" ]
		then std=SOFT
		elif [ "$defa" == "$opt4" ]
		then std=HARD
		else 	std=User
			check=$(ls *User* | wc -l)
			if [ $check = 0 ]
			then	USER 0;
				else userque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "This filter was already been used. Do you want to continue? It may lead to loss of previous filter data."; echo $?)
				
				#play -q -n synth 0.1 sin 880
				if [ $userque = 0 ]
				then USER 0;
				else echo "Skipping ."
				fi
			fi
		fi
		echo "Chosen option: "$defa
		echo "std set:"$std
		
	fi	
		
		
		
		
		
		
#----------------------------------------------------------------------------------------------------
#                                      Applying filters                                     
#----------------------------------------------------------------------------------------------------
		for files in PN*.FITS
		do	[[ $files == *FILT* ]] && continue
			[[ $files == *GE10* ]] && continue
			if [ $opted_method == '-c' ]
			then	[[ $files == *closed* ]] && echo "$files have closed filter so skipping it." && continue
			else	[[ $files == *closed* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "$files have closed filter so skipping it." && continue
			fi
			kakashi=$(ls *Im* | wc -l )
			clcheck=$(ls *closed* | wc -l)			
			if [ $clcheck = $kakashi ]
			then	if [ $opted_method == '-c' ]
				then	echo "all the imaging exposures have closed filters so skipping them."
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "all the imaging exposures have closed filters so skipping them."
				fi
				break
			fi
			#[[ $files = ${files//_closed.FITS/.FITS} ]] && echo "skipping ${files//_closed.FITS/.FITS} file as it has closed filter." && continue
			#[[ $files == *SEVERE* ]] && echo "File has serious proton flaring which can't be corrected, skipping it." && continue	
			if [ $opted_method == '-c' ]
			then	[[ $files == *SEVERE* ]] && echo "File has serious proton flaring which can't be corrected, so skipping it." && continue
			else	[[ $files == *SEVERE* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "File has serious proton flaring which can't be corrected, so skipping it." && continue
			fi
			
			var=${files//.FITS/_${std}FILT.FITS}	
			echo "evselect table=$files withfilteredset=yes expression='$defa' filteredset=$var filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes"
			set -e
			evselect table=$files withfilteredset=yes expression="$defa" filteredset=$var filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes
			set +e
			gticheck=$(ls ${files//.FITS/_gtiset.fits} | wc -l)
			if [ $gticheck = 0 ]
			then	if [ $opted_method == '-c' ]
				then	echo "Seems no gti correction was needed for this set. Skipping Filtering with gti."
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Seems no gti correction was needed for this set. Skipping Filtering with gti."
				fi
			else	if [ $opted_method == '-c' ]
				then	echo "Creating filtered file with new gti correction"
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Creating filtered file with new gti correction"
				fi
				echo "evselect table=$var withfilteredset=yes expression="'GTI(gtiset_${std}.fits,TIME)'" filteredset=${var//.FITS/_TIME.FITS} filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes"
				set -e
				evselect table=$var withfilteredset=yes expression="GTI(${files//.FITS/_gtiset.fits},TIME)" filteredset=${var//.FITS/_TIME.FITS} filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes
				set +e
			fi
	

		done

	}
#============================================================================================================================================
#                bkg_flare_pn  > creates GTI if needed so this must be run before FILTERING always     working directory > pn
#============================================================================================================================================
function bkg_flare_pn(){
	set +e
	for files in PN*.FITS
	do	[[ $files == *FILT* ]] && continue
		[[ $files == *GE10* ]] && continue
		if [ $opted_method == '-c' ]
		then	[[ $files == *closed* ]] && echo "$files have closed filter so skipping it." && continue
		else	[[ $files == *closed* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "$files have closed filter so skipping it." && continue
		fi
		clcheck=$(ls *closed* | wc -l)
		kakashi=$(ls *Im* | wc -l )
		if [ $clcheck = $kakashi ]
		then	if [ $opted_method == '-c' ]
			then	echo "all the imaging exposures have closed filters so skipping them."
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "all the imaging exposures have closed filters so skipping them."
			fi
			break
		fi
		if [ $opted_method == '-c' ]
		then	[[ $files == *SEVERE* ]] && echo "File has serious proton flaring which can't be corrected, so skipping it." && continue
			echo "Checking for soft proton flares"
		else	[[ $files == *SEVERE* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "File has serious proton flaring which can't be corrected, so skipping it." && continue
			zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Checking for soft proton flares"
		fi
			
		varr=${files//.FITS/_GE10KEV.FITS}	
		#defab="(PI>10000&&PI<12000)&&(PATTERN==0)&&#XMMEA_EP"
		set -e
		evselect table=$files xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100 withimageset=true imageset=${files//.FITS/_GE10KEV_image.FITS}
		set +e
		ds9 ${files//.FITS/_GE10KEV_image.FITS} &
		if [ $opted_method == '-c' ]
		then	echo "Select background region/s from image shown and press y"
			read me
			if [ $me == 'y' ]
			then	(xpaget ds9 regions -system physical -sky fk5)>${files//.FITS/_GE10KEV.reg}
				pkill -9 ds9
			else pkill -9 ds9
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Background region selected?"; echo $?)
			if [ $que = 0 ]
			then	(xpaget ds9 regions -system physical -sky fk5)>${files//.FITS/_GE10KEV.reg}
				pkill -9 ds9
			else pkill -9 ds9
			fi
		fi
		set -e
		bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
		defab=$(python $bkgcode ${files//.FITS/_GE10KEV.reg} 'pn' 'yes')
		echo "$defab"
		
		
		echo "evselect table=$files withrateset=Y rateset=$varr maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression=$defab"
		evselect table=$files withrateset=Y rateset=$varr maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="$defab"
		echo "dsplot table=$varr x=TIME y=RATE"
		
		dsplot table=$varr x=TIME y=RATE &
		#set +e
		if [ $opted_method == '-c' ]
		then	echo "Need to correct for bckground flare? (y/n)"
		
			read ans
			echo "Can new gti be created for this file or data is contaminated for whole time?"
				
			read sokka
			if [ $ans = n ]
			then	echo "Skipping gti build tasks."
			elif [[ ( $sokka = y ) && ( $ans = y ) ]]
			then	echo "Creating a new gti. Is GTI filtering expression on RATE (R) or TIME (T)?"
			
				read ans
				echo "You choose filtering on $ans."
				if [ $ans = R ]
				then	echo "Give max acceptable rate for this set."
				#	play -q -n synth 0.1 sin 880
					read maxr
					echo "tabgtigen table=$varr expression='RATE<=$maxr' gtiset=${files//.FITS/_}gtiset.fits"
					tabgtigen table=$varr expression="RATE<=$maxr" gtiset=${files//.FITS/_gtiset.fits} 
				elif [ $ans = T ]
				then	#echo "Give exact expression for time filtering."
				#play -q -n synth 0.1 sin 880
					#read Timefil
					echo "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
					timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
					Timefil=$(python $timecode $varr)
					echo "Time filter used here is: $Timefil"
					echo "tabgtigen table=$varr expression='$Timefil' gtiset=gtiset_${std}.fits"
					tabgtigen table=$varr expression="$Timefil" gtiset=${files//.FITS/_gtiset.fits}	
				fi
			else	echo "Seems data is severely damaged by soft proton flares. Will skip reduction for this set for rest and all."
				mv ${files} ${files//.FITS/_SEVERE.FITS}
	
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Need to correct for bckground flare?"; echo $?)
			severity=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Can new gti be created for this file or data is contaminated for whole time?"; echo $?)
			if [ $severity != 0 ]
			then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Skipping gti build tasks"
				mv ${files} ${files//.FITS/_SEVERE.FITS}
			elif [[ ( $severity = 0 ) && ( $que = 0 ) ]]
			then	op1="RATE"
				op2="TIME"
				answer=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'filter expression to be used on what:' --column 'Select...' --column 'Filter expression' TRUE "$op1" FALSE "$op2"`
				if [ "$answer" == "$op1" ]
				then	maxr=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Max. allowed rate:"`
					tabgtigen table=$varr expression="RATE<=$maxr" gtiset=${files//.FITS/_gtiset.fits}
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
					timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
					Timefil=$(python $timecode $varr)
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "printf Time filter expression used is: $Timefil"
					#Timefil=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Enter exact time filtering expression:"`
					tabgtigen table=$varr expression="$Timefil" gtiset=${files//.FITS/_gtiset.fits}
				fi
			fi
		fi
	set +e
	done
}
#============================================================================================================================================
#                FILTERING  > for pn does filtering and bkg flare correction for n number of filters     working directory > Obs ID
#============================================================================================================================================
function pnfilter(){
	set +e
	cd pn
	if [ $pnflag = 1 ]
	then 	cd ..
	else	#FILTERING;
	



	fite=$(ls *FILT* | wc -l)
	if [ $fite = 0 ]
	then	bkg_flare_pn;
		FILTERING;
	else	if [ $opted_method == '-c' ]
		then	echo "FILTER FILE ALREADY EXIST. Do you want to try other filters?"
			read what
			if [ $what = n ]
			then	echo "Alright skipping and going to next part."
			else	FILTERING;
			fi
		else	quee=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "FILTER FILE ALREADY EXIST. Do you want to try other filters?"; echo $?)
			if [ $quee = 0 ]
			then	FILTERING;
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright skipping and going to next part."
			fi
		fi

	fi
	zz="y"
	while [ $zz = y ]
	do
		if [ $opted_method == '-c' ]
		then	echo "DO YOU WANNA TRY OTHER FILTERS TOO?"
			read zz
			if [ $zz = y ]
			then	FILTERING;
			fi
		else	queee=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "DO YOU WANNA TRY OTHER FILTERS TOO?"; echo $?)
			if [ $queee = 0 ]
			then	zz="y"
				FILTERING;
			else	zz="n"
			fi
		fi

	done

	cd ..
fi

}
#============================================================================================================================================
#                MFILTERING  > creates filtered event files with gti correction     working directory > mos
#============================================================================================================================================
#################################################################
# DONE TILL THIS POINT AT 2:33 AM 9DEC2020
#################################################################
function MFILTERING() {
	set +e
	if [ $opted_method == '-c' ]
	then
		echo "STARTING STANDARD REDUCTION PROCEDURE FOR MOS FROM HERE"
		echo "Applying standard filters. Defaults are:"
		echo "(PATTERN<=12)&& (PI in [300:15000]) && #XMMEA_EM"
		echo "If change is needed press y else n"
		#play -q -n synth 0.1 sin 880
		read mchoice
		if [ $mchoice = y ]
		then	echo "Choose between following."
			echo "1) (PATTERN<=12)&& (PI in [300:10000]) && #XMMEA_EM"
			echo "2) User defined"
			echo "3) (PATTERN<=12)&& (PI in [300:2500]) && #XMMEA_EM : SOFT BAND FILTER"
			echo "4) (PATTERN<=12)&& (PI in [2500:10000]) && #XMMEA_EM : HARD BAND FILTER"
			#play -q -n synth 0.1 sin 880
			read mchoi
		else	echo "Taking default filters"
			mdefa="(PATTERN<=12)&& (PI in [300:15000]) && #XMMEA_EM"
			mchoi=0
			mstd=S	
			echo $mdefa
		fi


		if [ $mchoi = 1 ]
		then	mdefa="(PATTERN<=12)&& (PI in [300:10000]) && #XMMEA_EM"
			echo "Taking filter:$mdefa "
			mstd=U
		elif [ $mchoi = 2 ]
		then	mstd=User
			mcheck=$(ls *User* | wc -l)
			if [ $mcheck = 0 ]
			then	USER 1;
				else echo "This filter was already been used. Do you want to continue? It may lead to loss of previous filter data."
				#play -q -n synth 0.1 sin 880
				read mqw
				if [ $mqw = y ]
				then USER 1;
				else echo "Skipping ."
				fi
			fi
		elif [ $mchoi = 3 ]
		then	mdefa="(PATTERN<=12)&&(PI in [300:2500])&&#XMMEA_EM"
		echo "Taking filter:$mdefa "
		mstd=SOFT
		elif [ $mchoi = 4 ]
		then	mdefa="(PATTERN<=12)&&(PI in [2500:10000])&&#XMMEA_EM"
		echo "Taking filter:$mdefa "
		mstd=HARD
		fi
		
	else	mopt1="(PATTERN <= 12)&&(PI in [300:15000])&&#XMMEA_EM"
		mopt2="(PATTERN<=12)&&(PI in [300:10000])&&#XMMEA_EM"
		mopt3="(PATTERN<=12)&&(PI in [300:2500])&&#XMMEA_EM"
		mopt4="(PATTERN<=12)&&(PI in [2500:10000])&&#XMMEA_EM"
		mopt5="USER"
		mdefa=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --width=400 --list --radiolist --text 'Select the filter expression to be used:' --column 'Select...' --column 'Filter expression' TRUE "$mopt1" FALSE "$mopt2" FALSE "$mopt3" FALSE "$mopt4" FALSE "$mopt5"`
		
		if [ "$mdefa" == "$mopt1" ]
		then mstd=S
		elif [ "$mdefa" == "$mopt2" ]
		then mstd=U
		elif [ "$mdefa" == "$mopt3" ]
		then mstd=SOFT
		elif [ "$mdefa" == "$mopt4" ]
		then mstd=HARD
		else 
			mstd=User
			mcheck=$(ls *User* | wc -l)
			if [ $mcheck = 0 ]
			then	USER 1;
				else userque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "This filter was already been used. Do you want to continue? It may lead to loss of previous filter data."; echo $?)
				
				#play -q -n synth 0.1 sin 880
				if [ $userque = 0 ]
				then USER 1;
				else echo "Skipping ."
				fi
			fi
		
		fi
		echo "Chosen option: "$mdefa
		echo "std set:"$mstd
		
	fi	
		
		
		
		
		
		
#---------------------------------------------------------------------------------------------------------
#                                         Applying filters 
#---------------------------------------------------------------------------------------------------------   
		for mfiles in MOS*.FITS
		do	[[ $mfiles == *FILT* ]] && continue
			[[ $mfiles == *GE10* ]] && continue
			if [ $opted_method == '-c' ]
			then	[[ $mfiles == *closed* ]] && echo "$mfiles have closed filter so skipping it." && continue
			else	[[ $mfiles == *closed* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "$mfiles have closed filter so skipping it." && continue
			fi
			clcheck=$(ls *closed* | wc -l)
			kakashi=$(ls *Im* | wc -l )
			if [ $clcheck = $kakashi ]
			then	if [ $opted_method == '-c' ]
				then	echo "all the imaging exposures have closed filters so skipping them."
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "all the imaging exposures have closed filters so skipping them."
				fi
				break
			fi
			if [ $opted_method == '-c' ]
			then	[[ $mfiles == *SEVERE* ]] && echo "File has serious proton flaring which can't be corrected, so skipping it." && continue
			else	[[ $mfiles == *SEVERE* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "File has serious proton flaring which can't be corrected, so skipping it." && continue
			fi
			mvar=${mfiles//.FITS/_${mstd}FILT.FITS}	
			echo "evselect table=$mfiles withfilteredset=yes expression='$mdefa' filteredset=$mvar filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes"
			set -e
			evselect table=$mfiles withfilteredset=yes expression="$mdefa" filteredset=$mvar filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes
			set +e
			gticheck=$(ls ${mfiles//.FITS/_gtiset.fits} | wc -l)
			if [ $gticheck = 0 ]
			then if [ $opted_method == '-c' ]
				then	echo "Seems no gti correction was needed for this set. Skipping Filtering with gti."
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Seems no gti correction was needed for this set. Skipping Filtering with gti."
				fi
			else	if [ $opted_method == '-c' ]
				then	echo "Creating filtered file with new gti correction."
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Creating filtered file with new gti correction"
				fi
				echo "evselect table=$mvar withfilteredset=yes expression='GTI(${mfiles//.FITS/_gtiset.fits},TIME)' filteredset=${mvar//.FITS/_TIME.FITS} filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes"
				set -e
				evselect table=$mvar withfilteredset=yes expression="GTI(${mfiles//.FITS/_gtiset.fits},TIME)" filteredset=${mvar//.FITS/_TIME.FITS}	filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes
				set +e
			fi


		done

	}
#============================================================================================================================================
#                bkg_flare_mos  > creates GTI if needed so must run before MFILTERING always     working directory > mos
#============================================================================================================================================

function bkg_flare_mos(){
	set +e
	for mfiles in MOS*.FITS
	do	[[ $mfiles == *FILT* ]] && continue
		[[ $mfiles == *GE10* ]] && continue
		if [ $opted_method == '-c' ]
		then	[[ $mfiles == *closed* ]] && echo "$files have closed filter so skipping it." && continue
		else	[[ $mfiles == *closed* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "$files have closed filter so skipping it." && continue
		fi
		clcheck=$(ls *closed* | wc -l)
		kakashi=$(ls *Im* | wc -l )
		if [ $clcheck = $kakashi ]
		then	if [ $opted_method == '-c' ]
			then	echo "all the imaging exposures have closed filters so skipping them."
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "all the imaging exposures have closed filters so skipping them."
			fi
			break
		fi
		if [ $opted_method == '-c' ]
		then	[[ $mfiles == *SEVERE* ]] && echo "File has serious proton flaring which can't be corrected, so skipping it." && continue
			echo "Checking for soft proton flares"
		else	[[ $mfiles == *SEVERE* ]] && zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "File has serious proton flaring which can't be corrected, so skipping it." && continue
			zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Checking for soft proton flares"
		fi
			
		mvarr=${mfiles//.FITS/_GE10KEV.FITS}	
		#defab="(PI>10000&&PI<12000)&&(PATTERN==0)&&#XMMEA_EP"
		set -e
		evselect table=$mfiles xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100 withimageset=true imageset=${mfiles//.FITS/_GE10KEV_image.FITS}
		set +e
		ds9 ${mfiles//.FITS/_GE10KEV_image.FITS} &
		if [ $opted_method == '-c' ]
		then	echo "Select background region/s from image shown and press y"
			read me
			if [ $me == 'y' ]
			then	(xpaget ds9 regions -system physical -sky fk5)>${mfiles//.FITS/_GE10KEV.reg}
				pkill -9 ds9
			else pkill -9 ds9
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Background region selected?"; echo $?)
			if [ $que = 0 ]
			then	(xpaget ds9 regions -system physical -sky fk5)>${mfiles//.FITS/_GE10KEV.reg}
				pkill -9 ds9
			else pkill -9 ds9
			fi
		fi
		set -e
		bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
		mdefab=$(python $bkgcode ${mfiles//.FITS/_GE10KEV.reg} 'mos' 'yes')
		echo "$mdefab"
		
		
		echo "evselect table=$mfiles withrateset=Y rateset=$mvarr maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression=$mdefab"
		evselect table=$mfiles withrateset=Y rateset=$mvarr maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="$mdefab"
		echo "dsplot table=$mvarr x=TIME y=RATE"
		
		dsplot table=$mvarr x=TIME y=RATE &
		#set +e
		if [ $opted_method == '-c' ]
		then	echo "Need to correct for bckground flare? (y/n)"
		
			read ans
			echo "Can new gti be created for this file or data is contaminated for whole time?"
				
			read sokka
			if [ $ans = n ]
			then	echo "Skipping gti build tasks."
			elif [[ ( $sokka = y ) && ( $ans = y ) ]]
			then	echo "Creating a new gti. Is GTI filtering expression on RATE (R) or TIME (T)?"
			
				read ans
				echo "You choose filtering on $ans."
				if [ $ans = R ]
				then	echo "Give max acceptable rate for this set."
				#	play -q -n synth 0.1 sin 880
					read maxr
					echo "tabgtigen table=$mvarr expression='RATE<=$maxr' gtiset=${mfiles//.FITS/_}gtiset.fits"
					tabgtigen table=$mvarr expression="RATE<=$maxr" gtiset=${mfiles//.FITS/_gtiset.fits} 
				elif [ $ans = T ]
				then	#echo "Give exact expression for time filtering."
				#play -q -n synth 0.1 sin 880
					#read Timefil
					echo "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
					timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
					Timefil=$(python $timecode $mvarr)
					echo "tabgtigen table=$varr expression='$Timefil' gtiset=gtiset_${std}.fits"
					tabgtigen table=$mvarr expression="$Timefil" gtiset=${mfiles//.FITS/_gtiset.fits}	
				fi
			else	echo "Seems data is severely damaged by soft proton flares. Will skip reduction for this set for rest and all."
				mv ${mfiles} ${mfiles//.FITS/_SEVERE.FITS}
	
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Need to correct for bckground flare?"; echo $?)
			severity=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Can new gti be created for this file or data is contaminated for whole time?"; echo $?)
			if [ $severity != 0 ]
			then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Skipping gti build tasks"
				mv ${mfiles} ${mfiles//.FITS/_SEVERE.FITS}
			elif [[ ( $severity = 0 ) && ( $que = 0 ) ]]
			then	op1="RATE"
				op2="TIME"
				answer=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'filter expression to be used on what:' --column 'Select...' --column 'Filter expression' TRUE "$op1" FALSE "$op2"`
				if [ "$answer" == "$op1" ]
				then	maxr=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Max. allowed rate:"`
					tabgtigen table=$mvarr expression="RATE<=$maxr" gtiset=${mfiles//.FITS/_gtiset.fits}
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
					timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
					Timefil=$(python $timecode $mvarr)
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text  "Time filter expression used is: $Timefil"
					#Timefil=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Enter exact time filtering expression:"`
					tabgtigen table=$mvarr expression="$Timefil" gtiset=${mfiles//.FITS/_gtiset.fits}
				fi
			fi
		fi
	set +e
	done
}
#============================================================================================================================================
#                mosfilter  > filters mos event files for n number of filers     working directory > ObsID
#============================================================================================================================================
function mosfilter(){
	set +e
	cd mos
	if [ $mosflag = 1 ]
	then 	cd ..
	else	#FILTERING;
	



	fite=$(ls *FILT* | wc -l)
	if [ $fite = 0 ]
	then	bkg_flare_mos;
		MFILTERING;
	else	if [ $opted_method == '-c' ]
		then	echo "FILTER FILE ALREADY EXIST. Do you want to try other filters?"
			read what
			if [ $what = n ]
			then	echo "Alright skipping and going to next part."
			else	MFILTERING;
			fi
		else	quee=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "FILTER FILE ALREADY EXIST. Do you want to try other filters?"; echo $?)
			if [ $quee = 0 ]
			then	MFILTERING;
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright skipping and going to next part."
			fi
		fi

	fi
	zz="y"
	while [ $zz = y ]
	do
		if [ $opted_method == '-c' ]
		then	echo "DO YOU WANNA TRY OTHER FILTERS TOO?"
			read zz
			if [ $zz = y ]
			then	MFILTERING;
			fi
		else	queee=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "DO YOU WANNA TRY OTHER FILTERS TOO?"; echo $?)
			if [ $queee = 0 ]
			then	zz="y"
				MFILTERING;
			else	zz="n"
			fi
		fi

	done

	cd ..
fi

}
#============================================================================================================================================
#                IMAGER  > look for FILT or FILT_TIME files and make images from them     working directory > ---
#============================================================================================================================================
function IMAGER(){
	set +e
	for files in *FILT.FITS
	do	tenma=$(ls ${files//.FITS/_TIME.FITS} | wc -l)
		if [ $tenma = 0 ] 
		then	if [ $opted_method == '-c' ]
			then	echo "Creating images for filtered files."
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Creating images for filtered files."
			fi
			set -e
			evselect table=$files xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100 withimageset=true imageset=${files//.FITS/_IM.FITS}
			set +e
		else continue
		fi
	done

	for files in *TIME.FITS
	do 
		te=$(ls *TIME.FITS | wc -l)
		if [ $te = 0 ]
		then	if [ $opted_method == '-c' ]
			then	echo "Looks like no Gti correction was made. Skipping image generation process for this."
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Looks like no Gti correction was made. Skipping image generation process for this."
			fi
			break
		else	if [ $opted_method == '-c' ]
			then	echo "Creating images for time filtered files."
			else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Creating images for time filtered files."
			fi
			set -e
			evselect table=$files xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100 withimageset=true imageset=${files//.FITS/_IM.FITS}
			set +e
		fi
	done
	}
#============================================================================================================================================
#                pn_images  > creates images for pn filtered event files  using IMAGEr function   working directory > ObsID
#============================================================================================================================================
function pn_images(){
set +e
cd pn
if [ $pnflag = 1 ]
then	cd ..
else	echo "FOR PN"
	
	kenzo=$(ls *IM.FITS | wc -l )
	if [ $kenzo = 0 ]		
	then	IMAGER;
	else	if [ $opted_method == '-c' ]
		then	echo "Image files have already been generated. Do you want to regenerate these? Previous Images will be overwritten."
			read ana
			if [ $ana = y ] 
			then	IMAGER;
			else echo "Alright! skipping Imaging part."
			fi
		else	qpn=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Image files have already been generated. Do you want to regenerate these? Previous Images will be overwritten."; echo $?)
			if [ $qpn = 0 ]
			then	IMAGER;
			else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping Imaging part."
			fi
		fi
			
	fi
	cd ..
fi

}
#============================================================================================================================================
#                mos_images  > creates images for pn filtered event files using IMAGER function    working directory > ObsID
#============================================================================================================================================
function mos_images(){
set +e
cd mos
if [ $mosflag = 1 ]
then	cd ..
else	echo "FOR MOS"
	
	kenzo=$(ls *IM.FITS | wc -l )
	if [ $kenzo = 0 ]		
	then	IMAGER;
	else	if [ $opted_method == '-c' ]
		then	echo "Image files have already been generated. Do you want to regenerate these? Previous Images will be overwritten."
			read ana
			if [ $ana = y ] 
			then	IMAGER;
			else echo "Alright! skipping Imaging part."
			fi
		else	qpn=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Image files have already been generated. Do you want to regenerate these? Previous Images will be overwritten."; echo $?)
			if [ $qpn = 0 ]
			then	IMAGER;
			else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping Imaging part."
			fi
		fi
			
	fi
	cd ..
fi

}
#============================================================================================================================================
#                pn_spectra  > creates source, background spectra check for pileup and make ARF and RMF     working directory > ObsID
#============================================================================================================================================
function pn_spectra(){
set +e
cd pn
if [ $pnflag = 1 ]
then 	cd ..

else	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	echo "Looks like no images were formed.skipping all pn procedure."
		cd ..
	else	for files in *IM.FITS
		do	sho=$(ls ${files//_IM.FITS/_EPAT.ps} | wc -l)
			if [ $sho = 0 ] 	
			then	echo "For source spectra generation."
				echo "Choose between:"
				echo "1) RA-DEC and Source radius."
				echo "2) choose from IMAGE"	
				#play -q -n synth 0.1 sin 880
				read srcchoice
				if [ $srcchoice = 1 ]
				then	echo "GIVE THE RA (enter) DEC (enter)OF SOURCE."
			#		play -q -n synth 0.1 sin 880	
						read RA
						read DEC

					
					echo "RA selected is: $RA"
					echo "DEC selected is: $DEC"
					echo "Enter source region to be selected in ArcSec, DEFAULT is 55 ArcSec"
				#	play -q -n synth 0.1 sin 880
					read area
					area=${area:- 55}
					areaPix=`echo "$area/0.05" | bc`
					echo $(ecoordconv imageset=$files x=$RA y=$DEC coordtype=eqpos) > coord.txt
#---------------------------------------------------------------------------------------------------------------------
#                                   python code implementation
#---------------------------------------------------------------------------------------------------------------------	
					Xcode=$(readlink -f ~/bin/coordX.py)
					Ycode=$(readlink -f ~/bin/coordY.py)			
					Xcord=`python $Xcode`
					Ycord=`python $Ycode`
					
					#Xcord=`python /home/aries/bin/coordX.py`
					#Ycord=`python /home/aries/bin/coordY.py`
					echo "PARAMETERS IN PHYSICAL UNITS ARE:"
					echo "X: $Xcord"
					echo "Y: $Ycord"
					echo "Radius: $areaPix"
				elif [ $srcchoice = 2 ]
				then 	echo "Select the source region from image shown by ds9 here."
					ds9  -scale log $files &
					echo "Selected region?"
						#play -q -n synth 0.1 sin 880
					read sa
					if [ $sa = y ]
					then	echo $(xpaget  ds9 region -system physical -sky fk5)>srcmatchi.txt
#---------------------------------------------------------------------------------------------------------------------
#                                     python code implementation
#---------------------------------------------------------------------------------------------------------------------
						srccode=$(readlink -f ~/bin/src_circle.py)				
						while read line ; do   array=($line); done < <(python $srccode)
						Xcord=${array[0]}
						Ycord=${array[1]}
						areaPix=${array[2]}
						echo "PARAMETERS IN PHYSICAL UNITS ARE:"
						echo "X: $Xcord"
						echo "Y: $Ycord"
						echo "Radius: $areaPix"
						area=`echo "$areaPix*0.05" | bc`
					else	continue
					fi
				fi
				pkill -9 ds9
	

				echo "Source region for spectra extraction has been calculated. Working on Background region."
				echo "Choose between:"
				echo "1) Standard annulas region around source"
				echo "2) User defined region."
				#play -q -n synth 0.1 sin 880
				read bkgchoice
				if [ $bkgchoice = 1 ]
				then	echo "Choosing annulas region around the source. Give upper bound to annulas region ( in ArcSec)."
						#play -q -n synth 0.1 sin 880	
					read upanu
					if [ $upanu < $area ]
					then	echo "WARNING: upper bound is lower than lower bound this may lead to wrong results."
					fi
					upanuPix=`echo "$upanu/0.05" | bc`
					echo "CREATING BACKGROUND SPECTRA..."
					set -e
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN annulus($Xcord,$Ycord,$areaPix,$upanuPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
					set +e
				else	echo "Select the background region from image shown by ds9 here.export the expression."
					ds9 -scale log $files &
					echo "Selected region?"
						#play -q -n synth 0.1 sin 880
					read ba
					if [ $ba = y ]
					then	echo "okay..."
						(xpaget  ds9 region -system physical -sky fk5)>matchi.txt
						echo "okay"
#---------------------------------------------------------------------------------------------------------------------
#                                     python code implementation
#---------------------------------------------------------------------------------------------------------------------	
						bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
						#set -e
						expre=$(python $bkgcode matchi.txt 'pn' 'no')			
						#expre=`python /home/aries/bin/bkg_circle.py`	
						pkill -9 ds9 
						echo "CREATING BACKGROUND SPECTRA..."
						set -e
						evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="$expre" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
						
					else echo ""
					fi

				fi		
				echo "GENERATING SOURCE SPECTRA"
				evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN circle($Xcord,$Ycord,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

				echo "Making backscale corrections"
				echo "ON SOURCE "
				backscale spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				echo "ON BACKGROUND"
				backscale spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				echo "CHECKING FOR PILE-UP"
				epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
				gv ${files//_IM.FITS/_EPAT.ps}
				
				
				
				
				
				
				export inner=2                  #this is radius in arcsec
				function pileupcorr() {
					innera=`echo "$inner/0.05" | bc`
					echo "Excising the innermost part of PSF."
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN annulus($Xcord,$Ycord,$innera,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
					echo "xcord: $Xcord (in detecter cor) , xcord: $Ycord (in detecter cor), outer radius:$area , inner radius: $inner , in arcsec ">${files//_IM.FITS/_pileup.txt}
					echo "CHECKING FOR PILE-UP"
					epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
					gv ${files//_IM.FITS/_EPAT.ps}
					echo "NEED FOR PILE_UP CORRECTION?"
					#play -q -n synth 0.1 sin 880
					read pilechoice
					if [ $pilechoice = n ]
					then	echo "Alright! going for next steps."
					else	inner=$((inner+2))	
						pileupcorr; 
					fi

				}
				echo "NEED FOR PILE_UP CORRECTION?"
				#play -q -n synth 0.1 sin 880
				read pilechoice
				if [ $pilechoice = n ]
				then	echo "Alright! going for next steps."
				else	pileupcorr; 
				fi
		
				
				echo "Was pile-up removed successfully?"
				#play -q -n synth 0.1 sin 880
				read pileans
				if [ $pileans = y ]
				then	echo "Generating ARF and RMF files"
					rmfgen rmfset="${files//_IM.FITS/_RMF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}"
					arfgen arfset="${files//_IM.FITS/_ARF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" withrmfset=yes rmfset="${files//_IM.FITS/_RMF.FITS}" withbadpixcorr=yes badpixlocation="${files//_IM.FITS/.FITS}" setbackscale=yes
				else echo "Not generating any arf and rmf files as pile-up was not removed effectively."
				fi


			else echo "looks like pile-up was checked for this file. skipping this file"
			fi
		done
	fi	
	cd ..
fi
set +e
}
#============================================================================================================================================
#                lightcurves  > creates source, background, bkg corrected lightcurves also               working directory > ObsID
#                               create soft and hard band (set by user) lightcurves 
#============================================================================================================================================
function lightcurves(){
	set +e
	echo "Creating light curves"
	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	echo "Looks like no images were formed.skipping all pn procedure."
		
	else	for files in *IM.FITS
		do	set -e
			if [ $(ls ${files//_IM.FITS/_SRC_SP_FILT.FITS}) = 0 ]
			then echo "skipping" 
			else	evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_SRC_LC.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
				evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_BKG_LC.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
				epiclccorr srctslist="${files//_IM.FITS/_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_IM.FITS/_LC_CORR.FITS}" x=TIME y=RATE &
				sleep 5
				pkill -9 xmgrace
				echo "Do you want soft and hard light curves sapparately?"
				read lcanss
				if [ $lcanss = y ]
				then	echo "Enter the lower bound for soft light curve"
					read lowsoft
					echo "Enter higher bound for soft light curve"
					read highsoft
					echo "Enter lower bound for hard light curve"
					read lowhard
					echo "Enter upper bound for hard light curve"
					read highhard
					echo "Generating soft and  hard light curves sapparately..."
					evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_SOFT_SRC_LC.FITS}" maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="(PI in [$lowsoft:$highsoft])"
					evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_SOFT_BKG_LC.FITS}" maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="(PI in [$lowsoft:$highsoft])"	
					epiclccorr srctslist="${files//_IM.FITS/_SOFT_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_SOFT_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_SOFT_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
					evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_HARD_SRC_LC.FITS}" maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="(PI in [$lowhard:$highhard])"
					evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_HARD_BKG_LC.FITS}" maketimecolumn=Y timebinsize=100 makeratecolumn=Y expression="(PI in [$lowhard:$highhard])"	
					epiclccorr srctslist="${files//_IM.FITS/_HARD_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_HARD_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_HARD_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes	
					dsplot table="${files//_IM.FITS/_SOFT_LC_CORR.FITS}" x=TIME y=RATE &
					sleep 5
					pkill -9 xmgrace
					dsplot table="${files//_IM.FITS/_HARD_LC_CORR.FITS}" x=TIME y=RATE &
					sleep 5
					pkill -9 xmgrace
				else	echo "Alright! skipping this step."
				fi
			fi
		done
	fi
}
#============================================================================================================================================
#                pn_spectra_gui  > creates source, background spectra check for pileup and make ARF and RMF     working directory > ObsID
#                                  GUI  version of pn_spectra   
#============================================================================================================================================
function pn_spectra_gui(){
set +e
cd pn
if [ $pnflag = 1 ]
then 	cd ..

else	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Looks like no images were formed.skipping all pn procedure."
		cd ..
	else	for files in *IM.FITS
		do	sho=$(ls ${files//_IM.FITS/_EPAT.ps} | wc -l)
			if [ $sho = 0 ] 	
			then	pt1="RA-DEC and Source radius."
				pt2="choose from IMAGE"
				srcchoice=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'For source spectra generation.' --column 'Select...' --column '...' TRUE "$pt1" FALSE "$pt2"`
		
				if [ "$srcchoice" == "$pt1" ]
				then	RVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Source R.A. Dec. " --add-entry="R.A." --add-entry="Dec." --add-entry="Radius for source circle(in Arc Sec)"`
					RA=$(awk -F'|' '{print $1}' <<<$RVALUE);    
					DEC=$(awk -F'|' '{print $2}' <<<$RVALUE);
					area=$(awk -F'|' '{print $3}' <<<$RVALUE);
					areaPix=`echo "$area/0.05" | bc`
					echo $(ecoordconv imageset=$files x=$RA y=$DEC coordtype=eqpos) > coord.txt
					Xcode=$(readlink -f ~/bin/coordX.py)
					Ycode=$(readlink -f ~/bin/coordY.py)			
					Xcord=`python $Xcode`
					Ycord=`python $Ycode`
					#Xcord=`python /home/aries/bin/coordX.py`
					#Ycord=`python /home/aries/bin/coordY.py`
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "$(printf "PARAMETERS in PHYSICAL COORDINATES ARE: \n X: $Xcord \n Y: $Ycord \n Area: $area")"
				
				elif [ "$srcchoice" == "$pt2" ]
				then	ds9  -scale log $files &	
					srcque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Select the source region from image shown by ds9 here.Click yes when selected."; echo $?)
					if [ $srcque = 0 ]
					then	echo $(xpaget  ds9 region -system physical -sky fk5)>srcmatchi.txt
						cp srcmatchi.txt ${files//IM.FITS/source.region}
						srccode=$(readlink -f ~/bin/src_circle.py)
						while read line ; do   array=($line); done < <(python $srccode)
						Xcord=${array[0]}
						Ycord=${array[1]}
						areaPix=${array[2]}
						area=`echo "$areaPix*0.05" | bc`
						zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "$(printf "PARAMETERS in PHYSICAL COORDINATES ARE: \n X: $Xcord \n Y: $Ycord \n Area: $area")"					
					else	continue
					fi
				fi
				pkill -9 ds9
				ptt1="Annulas region around source."
				ptt2="choose from IMAGE"
				bkgchoice=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'For Background spectra generation.' --column 'Select...' --column '...' TRUE "$ptt1" FALSE "$ptt2"`
				if [ "$bkgchoice" == "$ptt1" ]
				then	upanu=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --entry --text "Give upper bound to annulas region:(in Arc Sec)" --entry-text " ")
					
					while [  $upanu -lt $area ]
					do	zenity --title "XMM-SCRIPT" --width 500 --height 500 --warning --text "upper bound to anulas region is smaller than source radius.Please select valid region."
 						upanu=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --entry --text "Give upper bound to annulas region:(in Arc Sec)" --entry-text " ")
 						
 					done
 					upanuPix=`echo "$upanu/0.05" | bc`
 					
 					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CREATING BACKGROUND SPECTRA..."
					set -e
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN annulus($Xcord,$Ycord,$areaPix,$upanuPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
					set +e		
 				else 	ds9  -scale log $files &	
					bkgque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Select the background region from image shown by ds9 here.Click yes when selected."; echo $?)
					if [ $bkgque = 0 ]
					then	(xpaget ds9 regions -system physical -sky fk5)>bkg_matchi.txt
						cp bkg_matchi.txt ${files//IM.FITS/background.region}
						pkill -9 ds9
					else pkill -9 ds9
					fi
			
					set -e
					bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
					bkgexpre=$(python $bkgcode bkg_matchi.txt 'pn' 'no')		
 							
 					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CREATING BACKGROUND SPECTRA..."
 					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="$bkgexpre" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
						
					
				fi			
 				evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN circle($Xcord,$Ycord,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

				zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Making backscale corrections"
				#echo "ON SOURCE "
				backscale spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				#echo "ON BACKGROUND"
				backscale spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CHECKING FOR PILE-UP"
				epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
				gv ${files//_IM.FITS/_EPAT.ps}
					#set +e
				export inner=2                  #this is radius in arcsec
				function pileupcorr() {
					innera=`echo "$inner/0.05" | bc`
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Excising the innermost part of PSF."
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN annulus($Xcord,$Ycord,$innera,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
					echo "xcord: $Xcord (in detecter cor) , xcord: $Ycord (in detecter cor), outer radius:$area , inner radius: $inner , in arcsec ">${files//_IM.FITS/_pileup.txt}
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CHECKING FOR PILE-UP"
					epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
					gv ${files//_IM.FITS/_EPAT.ps}
					pileque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "NEED FOR PILE_UP CORRECTION?"; echo $?)
					
					if [ $pileque = 0 ]
					then	inner=$((inner+2))	
						pileupcorr;
					else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping pileup corrections..." 
					fi

				}
				pileque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "NEED FOR PILE_UP CORRECTION?"; echo $?)
					
				if [ $pileque = 0 ]
				then	inner=$((inner+2))	
					pileupcorr;
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping pileup corrections..." 
				fi

				pileans=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Was pile-up removed successfully?"; echo $?)
				#play -q -n synth 0.1 sin 880
				
				if [ $pileans = 0 ]
				then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Generating ARF and RMF files"
					rmfgen rmfset="${files//_IM.FITS/_RMF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}"
					arfgen arfset="${files//_IM.FITS/_ARF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" withrmfset=yes rmfset="${files//_IM.FITS/_RMF.FITS}" withbadpixcorr=yes badpixlocation="${files//_IM.FITS/.FITS}" setbackscale=yes
				else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Not generating any arf and rmf files as pile-up was not removed effectively."
				fi


			else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "looks like pile-up was checked for this file. skipping this file"
			fi
		done
	fi	
	cd ..
fi
set +e
}
#============================================================================================================================================
#                lightcurves_gui  >  creates source, background, bkg corrected lightcurves also               working directory > ObsID
#                               create soft and hard band (set by user) lightcurves 
#                                  GUI  version of lightcurves   
#============================================================================================================================================
function lightcurves_gui(){
	set +e
	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Looks like no images were formed.skipping all pn procedure."
		
	else	for files in *IM.FITS
		do	set -e
			if [ $(ls ${files//_IM.FITS/_SRC_SP_FILT.FITS}) = 0 ]
			then echo "skipping" 
			else	evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_SRC_LC.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes
				evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_BKG_LC.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes
				epiclccorr srctslist="${files//_IM.FITS/_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
				#just for quite and flaring light curve extraction 
				evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_SRC_LC100.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
				evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_IM.FITS/_BKG_LC100.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
				epiclccorr srctslist="${files//_IM.FITS/_SRC_LC100.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_LC_CORR100.FITS}" bkgtslist="${files//_IM.FITS/_BKG_LC100.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_IM.FITS/_LC_CORR.FITS}" x=TIME y=RATE &
				sleep 5
				pkill -9 xmgrace
				lcanss=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want soft and hard light curves sapparately?"; echo $?)
				if [ $lcanss = 0 ]
				then	RRVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Parameters for soft hard lightcurves" --add-entry="Lower bound for soft LC" --add-entry="Upper bound for soft LC" --add-entry="Lower bound for hard LC" --add-entry="Upper bound for hard LC"`
					lowsoft=$(awk -F'|' '{print $1}' <<<$RRVALUE);    
					highsoft=$(awk -F'|' '{print $2}' <<<$RRVALUE);
					lowhard=$(awk -F'|' '{print $3}' <<<$RRVALUE);
					highhard=$(awk -F'|' '{print $4}' <<<$RRVALUE);
					evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_SOFT_SRC_LC.FITS}" maketimecolumn=Y timebinsize=10 makeratecolumn=Y expression="(PI in [$lowsoft:$highsoft])"
					evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_SOFT_BKG_LC.FITS}" maketimecolumn=Y timebinsize=10 makeratecolumn=Y expression="(PI in [$lowsoft:$highsoft])"	
					epiclccorr srctslist="${files//_IM.FITS/_SOFT_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_SOFT_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_SOFT_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
					evselect table="${files//_IM.FITS/_SRC_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_HARD_SRC_LC.FITS}" maketimecolumn=Y timebinsize=10 makeratecolumn=Y expression="(PI in [$lowhard:$highhard])"
					evselect table="${files//_IM.FITS/_BKG_SP_FILT.FITS}" withrateset=Y rateset="${files//_IM.FITS/_HARD_BKG_LC.FITS}" maketimecolumn=Y timebinsize=10 makeratecolumn=Y expression="(PI in [$lowhard:$highhard])"	
					epiclccorr srctslist="${files//_IM.FITS/_HARD_SRC_LC.FITS}" eventlist="${files//_IM.FITS/.FITS}" outset="${files//_IM.FITS/_HARD_LC_CORR.FITS}" bkgtslist="${files//_IM.FITS/_HARD_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes	
					
					
					
					dsplot table="${files//_IM.FITS/_SOFT_LC_CORR.FITS}" x=TIME y=RATE &
					sleep 5
					pkill -9 xmgrace
					dsplot table="${files//_IM.FITS/_HARD_LC_CORR.FITS}" x=TIME y=RATE &
					sleep 5
					pkill -9 xmgrace
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping this step."
				fi
			fi
		done
	fi

}
####################################################################################################
#                        TILL THIS ON 9 DEC 20:02
####################################################################################################
#============================================================================================================================================
#                mos_spectra  > creates source, background spectra check for pileup and make ARF and RMF     working directory > ObsID
#============================================================================================================================================
function mos_spectra(){
set +e
echo "GENERATING SPECTRA AND LIGHT CURVES FOR MOS."
cd mos
if [ $mosflag = 1 ]
then 	cd ..

else	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then echo "Looks like no images were formed.skipping all pn procedure."

	else	for files in *IM.FITS
		do	sho=$(ls ${files//_IM.FITS/_EPAT.ps} | wc -l)
			if [ $sho = 0 ]
			then	echo "For source spectra generation."
				echo "Choose between:"
				echo "1) RA-DEC and Source radius."
				echo "2) choose from IMAGE"
				read srcchoice
				if [ $srcchoice = 1 ]
				then	echo "GIVE THE RA DEC OF SOURCE."
						
						read RA
						read DEC

					echo "RA selected is: $RA"
					echo "DEC selected is: $DEC"
					echo "Enter source region to be selected in ArcSec, DEFAULT is 55 ArcSec"
					#play -q -n synth 0.1 sin 880
					read area
					area=${area:- 55}
					areaPix=`echo "$area/0.05" | bc`	
					echo $(ecoordconv imageset=$files x=$RA y=$DEC coordtype=eqpos) > coord.txt
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------
					Xcode=$(readlink -f ~/bin/coordX.py)
					Ycode=$(readlink -f ~/bin/coordY.py)			
					Xcord=`python $Xcode`
					Ycord=`python $Ycode`				
					#Xcord=`python /home/aries/bin/coordX.py`
					#Ycord=`python /home/aries/bin/coordY.py`
					echo "PARAMETERS IN PHYSICAL UNITS ARE:"
					echo "X: $Xcord"
					echo "Y: $Ycord"
					echo "Radius: $areaPix"
#done
				elif [ $srcchoice = 2 ]
				then 	echo "Select the source region from image shown by ds9 here."
					ds9 -scale log $files &
					echo "Selected region?"
					#play -q -n synth 0.1 sin 880
					read sa
					if [ $sa = y ]
					then	echo $(xpaget  ds9 region -system physical -sky fk5)>srcmatchi.txt
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------	
						srccode=$(readlink -f ~/bin/src_circle.py)			
						while read line ; do   array=($line); done < <(python $srccode)
						Xcord=${array[0]}
						Ycord=${array[1]}
						areaPix=${array[2]}
						echo "PARAMETERS IN PHYSICAL UNITS ARE:"
						echo "X: $Xcord"
						echo "Y: $Ycord"
						echo "Radius: $areaPix"
						area=`echo "$areaPix*0.05" | bc`
					else continue
					fi
				fi
				pkill -9 ds9
				echo "Source region for spectra extraction has been calculated. Working on Background region."
				echo "Choose between:"
				echo "1) Standard annulas region around source"
				echo "2) User defined region."
				#play -q -n synth 0.1 sin 880
				read bkgchoice
				if [ $bkgchoice = 1 ]
				then	echo "Choosing annulas region around the source. Give upper bound to annulas region ( in ArcSec)."
					#play -q -n synth 0.1 sin 880	
					read upanu
					if [ $upanu < $area ]
					then	echo "WARNING: upper bound is lower than lower bound this may lead to wrong results."
					fi
					upanuPix=`echo "$upanu/0.05" | bc`
					echo "CREATING BACKGROUND SPECTRA..."
					set -e
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN annulus($Xcord,$Ycord,$areaPix,$upanuPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
					seet +e
				else	echo "Select the background region from image shown by ds9 here.export the expression."
					ds9 -scale log $files &
					echo "Selected region?"
					#play -q -n synth 0.1 sin 880
					read ba
					if [ $ba = y ]
					then	(xpaget  ds9 region -system physical -sky fk5)>matchi.txt
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------				
						bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
						expre=$(python $bkgcode matchi.txt 'mos' 'no')
						#expre=`python /home/aries/bin/bkg_circle.py`
						pkill -9 ds9 
						echo "CREATING BACKGROUND SPECTRA..."
						evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="$expre" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
					else echo ""
					fi

				fi		
				echo "GENERATING SOURCE SPECTRA"
				evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN circle($Xcord,$Ycord,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

				echo "Making backscale corrections"
				echo "ON SOURCE "
				backscale spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				echo "ON BACKGROUND"
				backscale spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				echo "CHECKING FOR PILE-UP"
				epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
				gv ${files//_IM.FITS/_EPAT.ps}

				export inner=2                  #this is radius in arcsec
				function pileupcorr() {
					innera=`echo "$inner/0.05" | bc`
					echo "Excising the innermost part of PSF."
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN annulus($Xcord,$Ycord,$innera,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
	#				echo "outer radius:$area , inner radius: $inner , in arcsec">pileup.txt
					echo "xcord: $Xcord (in detecter cor) , ycord: $Ycord (in detecter cor), outer radius:$area , inner radius: $inner , in arcsec ">${files//_IM.FITS/_pileup.txt}
					echo "CHECKING FOR PILE-UP"
					epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
					gv ${files//_IM.FITS/_EPAT.ps}
					echo "NEED FOR PILE_UP CORRECTION?"
					#play -q -n synth 0.1 sin 880
					read pilechoice
					if [ $pilechoice = n ]
					then	echo "Alright! going for next steps."
					else	inner=$((inner+2))	
						pileupcorr; 
					fi

				}
				echo "NEED FOR PILE_UP CORRECTION?"
				#play -q -n synth 0.1 sin 880
				read pilechoice
				if [ $pilechoice = n ]
				then	echo "Alright! going for next steps."
					else	pileupcorr; 
				fi


				echo "Was pile-up removed successfully?"
				#play -q -n synth 0.1 sin 880
				read pileans
				if [ $pileans = y ]
				then	echo "Generating ARF and RMF files"
					rmfgen rmfset="${files//_IM.FITS/_RMF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}"
					arfgen arfset="${files//_IM.FITS/_ARF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" withrmfset=yes rmfset="${files//_IM.FITS/_RMF.FITS}" withbadpixcorr=yes badpixlocation="${files//_IM.FITS/.FITS}" setbackscale=yes
				else echo "Not generating any arf and rmf files as pile-up was not removed effectively."
				fi

			else echo "looks like pile-up was checked for this file. skipping this file"
			fi
		done
	fi
	cd ..
fi
set +e 
}
#============================================================================================================================================
#                mos_spectra_gui  > creates source, background spectra check for pileup and make ARF and RMF     working directory > ObsID
#                                  GUI  version of mos_spectra   
#============================================================================================================================================
function mos_spectra_gui(){
set +e
cd mos
if [ $mosflag = 1 ]
then 	cd ..

else	imcheck=$(ls *IM.FITS | wc -l)
	if [ $imcheck = 0 ]
	then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text  "Looks like no images were formed.skipping all pn procedure."
		cd ..

	else	for files in *IM.FITS
		do	set +e
			sho=$(ls ${files//_IM.FITS/_EPAT.ps} | wc -l)
			if [ $sho = 0 ]
			then	pt1="RA-DEC and Source radius."
				pt2="choose from IMAGE"
				srcchoice=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'For source spectra generation.' --column 'Select...' --column '...' TRUE "$pt1" FALSE "$pt2"`
		
				if [ "$srcchoice" == "$pt1" ]
				then	RVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Source R.A. Dec. " --add-entry="R.A." --add-entry="Dec." --add-entry="Radius for source circle(in Arc Sec)"`
					RA=$(awk -F'|' '{print $1}' <<<$RVALUE);    
					DEC=$(awk -F'|' '{print $2}' <<<$RVALUE);
					area=$(awk -F'|' '{print $3}' <<<$RVALUE);
					areaPix=`echo "$area/0.05" | bc`
					echo $(ecoordconv imageset=$files x=$RA y=$DEC coordtype=eqpos) > coord.txt
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------
					Xcode=$(readlink -f ~/bin/coordX.py)
					Ycode=$(readlink -f ~/bin/coordY.py)			
					Xcord=`python $Xcode`
					Ycord=`python $Ycode`				
					#Xcord=`python /home/aries/bin/coordX.py`
					#Ycord=`python /home/aries/bin/coordY.py`
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "$(printf "PARAMETERS in PHYSICAL COORDINATES ARE: \n X: $Xcord \n Y: $Ycord \n Area: $area")"
#done
				elif [ "$srcchoice" == "$pt2" ]
				then	ds9  -scale log $files &	
					srcque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Select the source region from image shown by ds9 here.Click yes when selected."; echo $?)
					if [ $srcque = 0 ]
					then	echo $(xpaget  ds9 region -system physical -sky fk5)>srcmatchi.txt
						cp srcmatchi.txt ${files//IM.FITS/source.region}
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------	
						srccode=$(readlink -f ~/bin/src_circle.py)			
						while read line ; do   array=($line); done < <(python $srccode)
						Xcord=${array[0]}
						Ycord=${array[1]}
						areaPix=${array[2]}
						area=`echo "$areaPix*0.05" | bc`
						zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "$(printf "PARAMETERS in PHYSICAL COORDINATES ARE: \n X: $Xcord \n Y: $Ycord \n Area: $area")"
					else continue
					fi
				fi
				pkill -9 ds9
				ptt1="Annulas region around source."
				ptt2="choose from IMAGE"
				bkgchoice=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'For Background spectra generation.' --column 'Select...' --column '...' TRUE "$ptt1" FALSE "$ptt2"`
				if [ "$bkgchoice" == "$ptt1" ]
				then	upanu=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --entry --text "Give upper bound to annulas region:(in Arc Sec)" --entry-text " ")
					
					while [  $upanu -lt $area ]
					do	zenity --title "XMM-SCRIPT" --width 500 --height 500 --warning --text "upper bound to anulas region is smaller than source radius.Please select valid region."
 						upanu=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --entry --text "Give upper bound to annulas region:(in Arc Sec)" --entry-text " ")
 						
 					done
 					upanuPix=`echo "$upanu/0.05" | bc`
 					
 					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CREATING BACKGROUND SPECTRA..."
					set -e
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN annulus($Xcord,$Ycord,$areaPix,$upanuPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
					set +e
				else	ds9 -scale log $files &
					
					
					bkgque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --width 600 --text "Select the background region from image shown by ds9 here.Click yes when selected."; echo $?)
					if [ $bkgque = 0 ]
					then	(xpaget  ds9 region -system physical -sky fk5)>bkg_matchi.txt
						cp bkg_matchi.txt ${files//IM.FITS/background.region}
						pkill -9 ds9
					else	pkill -9 ds9
						continue
					fi
#---------------------------------------------------------------------------------------------------------------------
#                                     CHANGE THE CODE PATH POINTING ITS RECENT LOCATION
#---------------------------------------------------------------------------------------------------------------------				
					set -e
						bkgcode=$(readlink -f ~/bin/bkg_multicircle_xmm.py)
						expre=$(python $bkgcode bkg_matchi.txt 'mos' 'no')
						#expre=`python /home/aries/bin/bkg_circle.py`
						
						zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CREATING BACKGROUND SPECTRA..."
						evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_BKG_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="$expre" withspectrumset=yes spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
					

				fi		
				
				evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN circle($Xcord,$Ycord,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

				zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Making backscale corrections"
				#echo "ON SOURCE "
				backscale spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				#echo "ON BACKGROUND"
				backscale spectrumset="${files//_IM.FITS/_BKG_SP.FITS}" badpixlocation=${files//_IM.FITS/.FITS}
				zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CHECKING FOR PILE-UP"
				epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
				gv ${files//_IM.FITS/_EPAT.ps}

				export inner=2                  #this is radius in arcsec
				function pileupcorr() {
					innera=`echo "$inner/0.05" | bc`
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Excising the innermost part of PSF."
					evselect table="${files//_IM.FITS/.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_IM.FITS/_SRC_SP_FILT.FITS}" keepfilteroutput=yes filtertype="expression" expression="#XMMEA_EM && (PATTERN<=12)&&((X,Y) IN annulus($Xcord,$Ycord,$innera,$areaPix))" withspectrumset=yes spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
	#				echo "outer radius:$area , inner radius: $inner , in arcsec">pileup.txt
					echo "xcord: $Xcord (in detecter cor) , ycord: $Ycord (in detecter cor), outer radius:$area , inner radius: $inner , in arcsec ">${files//_IM.FITS/_pileup.txt}
					zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "CHECKING FOR PILE-UP"
					epatplot set="${files//_IM.FITS/_SRC_SP_FILT.FITS}" plotfile="${files//_IM.FITS/_EPAT.ps}"  useplotfile=yes withbackgroundset=yes backgroundset="${files//_IM.FITS/_BKG_SP_FILT.FITS}"
					gv ${files//_IM.FITS/_EPAT.ps}
					pileque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "NEED FOR PILE_UP CORRECTION?"; echo $?)
					
					if [ $pileque = 0 ]
					then	inner=$((inner+2))	
						pileupcorr;
					else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping pileup corrections..." 
					fi

				}
				pileque=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "NEED FOR PILE_UP CORRECTION?"; echo $?)
					
				if [ $pileque = 0 ]
				then	inner=$((inner+2))	
					pileupcorr;
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Alright! skipping pileup corrections..." 
				fi


				pileans=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Was pile-up removed successfully?"; echo $?)
				#play -q -n synth 0.1 sin 880
				
				if [ $pileans = 0 ]
				then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Generating ARF and RMF files"
					rmfgen rmfset="${files//_IM.FITS/_RMF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}"
					arfgen arfset="${files//_IM.FITS/_ARF.FITS}" spectrumset="${files//_IM.FITS/_SRC_SP.FITS}" withrmfset=yes rmfset="${files//_IM.FITS/_RMF.FITS}" withbadpixcorr=yes badpixlocation="${files//_IM.FITS/.FITS}" setbackscale=yes
				else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Not generating any arf and rmf files as pile-up was not removed effectively."
				fi


			else zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "looks like pile-up was checked for this file. skipping this file"
			fi
		done
	fi
	cd ..
fi
set +e 

}




#============================================================================================================================================
#                only_pn_reduction  > manipulates above all functions run them in order required for pn data      working directory > ObsID
#                                     reduction
#============================================================================================================================================

function only_pn_reduction(){
	set +e
	echo "STARTING PN REDUCTION PROCEDURES"
	cd pn 
	echo "we are in: "$(pwd)
	touch PN	
	rm PN*
	pnproccer;
	echo "pnproccer------------------------------done---------------------------------------"
	pnrenamer;
	echo "pnrenamer------------------------------done---------------------------------------"
	cd ..
	pnfilterchecker;
	echo "pnfilterchecker------------------------------done---------------------------------------"
	cd pn	
	closedpnss=$(ls *closed* | wc -l)
	allim=$(ls *Im* | wc -l)
	cd ..	
	if [ $closedpnss = $allim ]
	then	if [ $opted_method = "-c" ]
		then	echo "skipping all processes as all event files have closed exposures..."
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "skipping all processes as all event files have closed exposures..."
		fi
	else	pnfilter;
		echo "pnfilter------------------------------done---------------------------------------"
		pn_images;
		echo "pnimages------------------------------done---------------------------------------"
		if [ $opted_method = "-c" ]
		then	pn_spectra;
		echo "pnspectra------------------------------done---------------------------------------"
		else	pn_spectra_gui;
			echo "pnspectra------------------------------done---------------------------------------"
		fi
		cd pn
		if [ $opted_method = "-c" ]
		then	echo "Do you want lightcurves?"
			read nah
			if [ $nah = y ]
			then	lightcurves;
			fi
			echo "lightcurves------------------------------done---------------------------------------"
		else	nah=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want lightcurves?"; echo $?)
			if [ $nah = 0 ]
			then	lightcurves_gui;
			fi
			echo "lightcurves------------------------------done---------------------------------------"
		fi
	fi
	cd ..
	[ -d analysis ] || mkdir analysis
	pdir=$(pwd)
	cd pn 
	copier;
	cd ..
}

#============================================================================================================================================
#                grouper  > groups spectrum files, ARF and RMF      working directory > analysis
#============================================================================================================================================
function grouper(){
	set +e
	for files in *SRC_SP.FITS
		do	grppha ${files} !${files//SRC_SP.FITS/GRP.FITS} comm="chkey BACKFILE ${files//SRC_SP.FITS/BKG_SP.FITS} & chkey RESPFILE ${files//SRC_SP.FITS/RMF.FITS} & chkey ANCRFILE ${files//SRC_SP.FITS/ARF.FITS} & group min 20 & exit"
		done
	for files in *SRC_SP_QUITE.FITS
		do	grppha ${files} !${files//SRC_SP_QUITE.FITS/GRP_QUITE.FITS} comm="chkey BACKFILE ${files//SRC_SP_QUITE.FITS/BKG_SP_QUITE.FITS} & chkey RESPFILE ${files//SRC_SP_QUITE.FITS/RMF_QUITE.FITS} & chkey ANCRFILE ${files//SRC_SP_QUITE.FITS/ARF_QUITE.FITS} & group min 20 & exit"
		done
	for files in *SRC_SP_PHASE*
	do	#grppha $files !${files//SRC_SP/GRP} comm="chkey BACKFILE ${files//SRC_SP/BKG_SP} & chkey RESPFILE ${files//SRC_SP/SRC_RMF} & chkey ANCRFILE ${files//SRC_SP/SRC_ARF} & group min 20 & exit !${files//SRC_SP/GRP}"
		#${files%_SRC_SP*}.FITS
		grppha $files !${files//SRC_SP/GRP} comm="chkey BACKFILE ${files//SRC_SP/BKG_SP} & chkey RESPFILE ${files%_SRC_SP*}_RMF.FITS & chkey ANCRFILE ${files%_SRC_SP*}_ARF.FITS & group min 20 & exit !${files//SRC_SP/GRP}"
	done
	for files in *SRC_SP_F_*
	 do	grppha $files !${files//SRC_SP/GRP} comm="chkey BACKFILE ${files//SRC/BKG} & chkey RESPFILE ${files/SRC_SP_F/RMF_F} & chkey ANCRFILE ${files/SRC_SP_F/ARF_F} & group min 20 & exit !${files//SRC_SP/GRP}"
	 done
}

#============================================================================================================================================
#                copier  > copies spectrum files, ARF and RMF from current directory to analysis dirPN_1_UFILT_SRC_SP_PHASE.7-.9.FITSectory     working directory > ---
#============================================================================================================================================
function copier(){
	set +e
	for files in *SRC_SP.FITS
	do	cp $files $pdir/analysis/$files
		cp ${files//SRC_SP.FITS/BKG_SP.FITS} $pdir/analysis/${files//SRC_SP.FITS/BKG_SP.FITS}
		cp ${files//SRC_SP.FITS/RMF.FITS} $pdir/analysis/${files//SRC_SP.FITS/RMF.FITS}
		cp ${files//SRC_SP.FITS/ARF.FITS} $pdir/analysis/${files//SRC_SP.FITS/ARF.FITS}
	#src=$(ls *SRC_SP.FITS )
	#cp $src $pdir/analysis/$src
	#bkg=$(ls *BKG_SP.FITS )
	#cp $bkg $pdir/analysis/$bkg
	#rmf=$(ls *RMF.FITS )
	#cp $rmf $pdir/analysis/$rmf	
	#arf=$(ls *ARF.FITS )
	#cp $arf $pdir/analysis/$arf	
	done
	for files in *SRC_SP_QUITE.FITS
	do	cp $files $pdir/analysis/$files
		cp ${files//SRC_SP_QUITE.FITS/BKG_SP_QUITE.FITS} $pdir/analysis/${files//SRC_SP_QUITE.FITS/BKG_SP_QUITE.FITS}
		cp ${files//SRC_SP_QUITE.FITS/RMF_QUITE.FITS} $pdir/analysis/${files//SRC_SP_QUITE.FITS/RMF_QUITE.FITS}
		cp ${files//SRC_SP_QUITE.FITS/ARF_QUITE.FITS} $pdir/analysis/${files//SRC_SP_QUITE.FITS/ARF_QUITE.FITS}
	done
	for files in *SRC_SP_PHASE*
	do	cp $files $pdir/analysis/$files
		cp ${files//SRC_SP/BKG_SP} $pdir/analysis/${files//SRC_SP/BKG_SP}
		cp ${files//SRC_SP/SRC_RMF} $pdir/analysis/${files//SRC_SP/SRC_RMF}
		cp ${files//SRC_SP/SRC_ARF} $pdir/analysis/${files//SRC_SP/SRC_ARF}
	
	done
	 for files in *SRC_SP_F_*
	 do	cp $files $pdir/analysis/$files
		cp ${files//SRC/BKG} $pdir/analysis/${files//SRC/BKG}
		cp ${files/SRC_SP_F/RMF_F} $pdir/analysis/${files/SRC_SP_F/RMF_F}
		cp ${files/SRC_SP_F/ARF_F} $pdir/analysis/${files/SRC_SP_F/ARF_F}
	 done
	
}

#============================================================================================================================================
#                analysis_maker  > creates analysis folder containing grouped spectra files     working directory > ObsID
#============================================================================================================================================
function analysis_maker(){
	set +e
	[ -d analysis ] || mkdir analysis
	pdir=$(pwd)
	cd pn 
	copier;
	cd ..
	cd mos
	copier;
	cd ..
	cd analysis
	grouper;
	cd ..
}
#============================================================================================================================================
#                only_mos_reduction  > manipulates above all functions run them in order required for mos data      working directory > ObsID
#                                     reduction
#============================================================================================================================================
function only_mos_reduction(){
	set +e
	echo "STARTING MOS REDUCTION PROCEDURES"
	cd mos
	echo "we are in: "$(pwd)
	touch MOS
	rm MOS*
	mosproccer;
	echo "mosproccer------------------------------done---------------------------------------"
	mosrenamer;
	echo "mosrenamer------------------------------done---------------------------------------"
	cd ..
	mosfilterchecker;
	echo "mosfilterchecker------------------------------done---------------------------------------"
	cd mos 
	closedmoses=$(ls *closed* | wc -l)
	allimageevents=$(ls *Im* | wc -l)
	cd ..
	if [ $closedmoses = $allimageevents ]
	then	if [ "$opted_method" == "-c" ]
		then	echo "skipping all processes as all event files have closed exposures..."
		else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "skipping all processes as all event files have closed exposures..."
fi
	else	mosfilter;
		echo "mosfilter------------------------------done---------------------------------------"
		mos_images;
		echo "mosimages------------------------------done---------------------------------------"
		if [ $opted_method = "-c" ]
		then	mos_spectra;
			echo "mosspectra------------------------------done---------------------------------------"
		else	mos_spectra_gui;
			echo "mosspectra------------------------------done---------------------------------------"
		fi
		cd mos
		if [ "$opted_method" == "-c" ]
		then	echo "Do you want lightcurves?"
			read nah
			if [ $nah = y ]
			then	lightcurves;
			fi
			echo "lightcurves------------------------------done---------------------------------------"
		else	nah=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want lightcurves?"; echo $?)
			if [ $nah = 0 ]
			then	lightcurves_gui;
			fi
			echo "lightcurves------------------------------done---------------------------------------"
		fi
	fi
	cd ..
	cd mos
	copier;
	cd ..
}

#============================================================================================================================================
#                quite_lightcurve  > creates quiscent phase lightcurve                       working directory > ---
#       0 means for mos 
#============================================================================================================================================
function quite_lightcurve_spectra(){
	imcheck=$(ls *LC_CORR.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	echo "No lightcurves to edit..."
	else	for files in *LC_CORR.FITS
		do	[[ $files == *HARD* ]] && continue
			[[ $files == *SOFT* ]] && continue
			dsplot table=$files x=TIME y=RATE.ERROR 
			echo "Do you want to deflare lightcurve?"
			read qwer
			if [ $qwer = y ]
			then	timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
				Timefil=$(python $timecode $files)
				tabgtigen table=$files gtiset=gti.ds expression="$Timefil"
				if [ $1 = 0 ]
			
				then	evselect table="${files//_LC_CORR.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR.FITS/_SRC_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR.FITS/_SRC_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				evselect table="${files//_LC_CORR.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR.FITS/_BKG_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR.FITS/_BKG_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				else	evselect table="${files//_LC_CORR.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR.FITS/_SRC_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR.FITS/_SRC_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				evselect table="${files//_LC_CORR.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR.FITS/_BKG_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR.FITS/_BKG_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				fi
				rmfgen rmfset="${files//_LC_CORR.FITS/_RMF_QUITE.FITS}" spectrumset="${files//_LC_CORR.FITS/_SRC_SP_QUITE.FITS}"
				arfgen arfset="${files//_LC_CORR.FITS/_ARF_QUITE.FITS}" spectrumset="${files//_LC_CORR.FITS/_SRC_SP_QUITE.FITS}" withrmfset=yes rmfset="${files//_IM.FITS/_RMF.FITS}" withbadpixcorr=yes badpixlocation="${files//_IM.FITS/.FITS}" setbackscale=yes
				evselect table="${files//_LC_CORR.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				evselect table="${files//_LC_CORR.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				epiclccorr srctslist="${files//_LC_CORR.FITS/_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR.FITS/.FITS}" outset="${files//_LC_CORR.FITS/_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR.FITS/_BKG_LC_QUITE.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_LC_CORR.FITS/_LC_CORR_QUITE.FITS}" x=TIME y=RATE &
				echo "Do you want soft and hard light curves sapparately?"
				read lcanss
				if [ $lcanss = y ]
				then	echo "Enter the lower bound for soft light curve"
					read lowsoft
					echo "Enter higher bound for soft light curve"
					read highsoft
					echo "Enter lower bound for hard light curve"
					read lowhard
					echo "Enter upper bound for hard light curve"
					read highhard
					echo "Generating soft and  hard light curves sapparately..."
					evselect table="${files//_LC_CORR.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_SOFT_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="(PI in [$lowsoft:$highsoft])&&gti(gti.ds,TIME)"
				evselect table="${files//_LC_CORR.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_SOFT_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="(PI in [$lowsoft:$highsoft])&&gti(gti.ds,TIME)"
				epiclccorr srctslist="${files//_LC_CORR.FITS/_SOFT_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR.FITS/.FITS}" outset="${files//_LC_CORR.FITS/_SOFT_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR.FITS/_SOFT_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_LC_CORR.FITS/_SOFT_LC_CORR_QUITE.FITS}" x=TIME y=RATE &	
				evselect table="${files//_LC_CORR.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_HARD_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="(PI in [$lowhard:$highhard])&&gti(gti.ds,TIME)"
				evselect table="${files//_LC_CORR.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR.FITS/_HARD_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes expression="(PI in [$lowhard:$highhard])&&gti(gti.ds,TIME)"
				epiclccorr srctslist="${files//_LC_CORR.FITS/_HARD_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR.FITS/.FITS}" outset="${files//_LC_CORR.FITS/_HARD_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR.FITS/_HARD_BKG_LC.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_LC_CORR.FITS/_HARD_LC_CORR_QUITE.FITS}" x=TIME y=RATE &	
				fi
			else continue
			fi
		
		done
	
			
			
	fi
}

function quite_lightcurve_spectra_gui(){
	imcheck=$(ls *LC_CORR100.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	zenity --title "XMM-SCRIPT" --notification --text "No lightcurves to edit..."
	else	for files in *LC_CORR100.FITS
		do	[[ $files == *HARD* ]] && continue
			[[ $files == *SOFT* ]] && continue
			dsplot table=$files x=TIME y=RATE.ERROR
			qwer=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want to deflare lightcurve?"; echo $?)
			if [ $qwer = 0 ]
			then	timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
				Timefil=$(python $timecode $files)
				tabgtigen table=$files gtiset=gti.ds expression="$Timefil"
				zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text  "Time filter expression used is: $Timefil"
				if [ $1 = 0 ]
			
				then	set -e
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_SRC_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_BKG_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				else	evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_SRC_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_BKG_SP_FILT_QUITE.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_QUITE.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				fi
				backscale spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_QUITE.FITS}" badpixlocation=${files//_LC_CORR100.FITS/.FITS}
				backscale spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_QUITE.FITS}" badpixlocation=${files//_LC_CORR100.FITS/.FITS}
				
				rmfgen rmfset="${files//_LC_CORR100.FITS/_RMF_QUITE.FITS}" spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_QUITE.FITS}"
				arfgen arfset="${files//_LC_CORR100.FITS/_ARF_QUITE.FITS}" spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_QUITE.FITS}" withrmfset=yes rmfset="${files//_LC_CORR100.FITS/_RMF_QUITE.FITS}" withbadpixcorr=yes badpixlocation="${files//_LC_CORR100.FITS/.FITS}"
				evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				epiclccorr srctslist="${files//_LC_CORR100.FITS/_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_BKG_LC_QUITE.FITS}" withbkgset=yes applyabsolutecorrections=yes
				dsplot table="${files//_LC_CORR100.FITS/_LC_CORR_QUITE.FITS}" x=TIME y=RATE &
				lcanss=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want soft and hard light curves sapparately?"; echo $?)
				if [ $lcanss = 0 ]
				then	RRVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Parameters for soft hard lightcurves" --add-entry="Lower bound for soft LC" --add-entry="Upper bound for soft LC" --add-entry="Lower bound for hard LC" --add-entry="Upper bound for hard LC"`
					lowsoft=$(awk -F'|' '{print $1}' <<<$RRVALUE);    
					highsoft=$(awk -F'|' '{print $2}' <<<$RRVALUE);
					lowhard=$(awk -F'|' '{print $3}' <<<$RRVALUE);
					highhard=$(awk -F'|' '{print $4}' <<<$RRVALUE);
					set -e
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_SOFT_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)&&(PI in [$lowsoft:$highsoft])"
					evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_SOFT_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)&&(PI in [$lowsoft:$highsoft])"
					epiclccorr srctslist="${files//_LC_CORR100.FITS/_SOFT_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_SOFT_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_SOFT_BKG_LC_QUITE.FITS}" withbkgset=yes applyabsolutecorrections=yes
					dsplot table="${files//_LC_CORR100.FITS/_SOFT_LC_CORR_QUITE.FITS}" x=TIME y=RATE &	
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_HARD_SRC_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)&&(PI in [$lowhard:$highhard])"
					evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_HARD_BKG_LC_QUITE.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)&&(PI in [$lowhard:$highhard])"
					epiclccorr srctslist="${files//_LC_CORR100.FITS/_HARD_SRC_LC_QUITE.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_HARD_LC_CORR_QUITE.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_HARD_BKG_LC_QUITE.FITS}" withbkgset=yes applyabsolutecorrections=yes
					dsplot table="${files//_LC_CORR100.FITS/_HARD_LC_CORR_QUITE.FITS}" x=TIME y=RATE &	
				fi
			else continue
			fi
		done	
	fi
set +e
}

function flare_lightcurve_spectra_gui(){
	imcheck=$(ls *LC_CORR100.FITS | wc -l)
	if [ $imcheck = 0 ]
	then 	zenity --title "XMM-SCRIPT" --notification --text "No lightcurves to edit..."
	else	for files in *LC_CORR100.FITS
		do	[[ $files == *HARD* ]] && continue
			[[ $files == *SOFT* ]] && continue
			dsplot table=$files x=TIME y=RATE.ERROR
			qwer=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want to extract flare from lightcurve?"; echo $?)
			if [ $qwer = 0 ]
			then	postfix=$(zenity --title "XMM-SCRIPT" --entry --text "Postfix for filename")
				timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
				Timefil=$(python $timecode $files)
				tabgtigen table=$files gtiset=gti.ds expression="$Timefil"
				zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text  "Time filter expression used is: $Timefil"
				if [ $1 = 0 ]
			
				then	set -e
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_SRC_SP_FILT_F_$postfix.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_F_$postfix.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_BKG_SP_FILT_F_$postfix.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_F_$postfix.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999
				else	evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_SRC_SP_FILT_F_$postfix.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_F_$postfix.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" energycolumn="PI" withfilteredset=yes filteredset="${files//_LC_CORR100.FITS/_BKG_SP_FILT_F_$postfix.FITS}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_F_$postfix.FITS}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479
				fi
				backscale spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_F_$postfix.FITS}" badpixlocation=${files//_LC_CORR100.FITS/.FITS}
				backscale spectrumset="${files//_LC_CORR100.FITS/_BKG_SP_F_$postfix.FITS}" badpixlocation=${files//_LC_CORR100.FITS/.FITS}
				
				rmfgen rmfset="${files//_LC_CORR100.FITS/_RMF_F_$postfix.FITS}" spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_F_$postfix.FITS}"
				arfgen arfset="${files//_LC_CORR100.FITS/_ARF_F_$postfix.FITS}" spectrumset="${files//_LC_CORR100.FITS/_SRC_SP_F_$postfix.FITS}" withrmfset=yes rmfset="${files//_LC_CORR100.FITS/_RMF_F_$postfix.FITS}" withbadpixcorr=yes badpixlocation="${files//_LC_CORR100.FITS/.FITS}"
				evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_SRC_LC_F_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_BKG_LC_F_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="gti(gti.ds,TIME)"
				epiclccorr srctslist="${files//_LC_CORR100.FITS/_SRC_LC_F_$postfix.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_LC_CORR_F_$postfix.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_BKG_LC_F_$postfix.FITS}" withbkgset=yes applyabsolutecorrections=yes
				set -e
				dsplot table="${files//_LC_CORR100.FITS/_LC_CORR_F_$postfix.FITS}" x=TIME y=RATE &
				lcanss=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want soft and hard light curves sapparately?"; echo $?)
				if [ $lcanss = 0 ]
				then	RRVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Parameters for soft hard lightcurves" --add-entry="Lower bound for soft LC" --add-entry="Upper bound for soft LC" --add-entry="Lower bound for hard LC" --add-entry="Upper bound for hard LC"`
					lowsoft=$(awk -F'|' '{print $1}' <<<$RRVALUE);    
					highsoft=$(awk -F'|' '{print $2}' <<<$RRVALUE);
					lowhard=$(awk -F'|' '{print $3}' <<<$RRVALUE);
					highhard=$(awk -F'|' '{print $4}' <<<$RRVALUE);
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_SRC_LC_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="(PI in [$lowsoft:$highsoft])&&gti(gti.ds,TIME)"
					evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_BKG_LC_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="(PI in [$lowsoft:$highsoft])&&gti(gti.ds,TIME)"
					epiclccorr srctslist="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_SRC_LC_$postfix.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_LC_CORR_$postfix.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_BKG_LC_$postfix.FITS}" withbkgset=yes applyabsolutecorrections=yes
					dsplot table="${files//_LC_CORR100.FITS/_${lowsoft}_${highsoft}_SOFT_LC_CORR_$postfix.FITS}" x=TIME y=RATE &	
					evselect table="${files//_LC_CORR100.FITS/_SRC_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_SRC_LC_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="(PI in [$lowhard:$highhard])&&gti(gti.ds,TIME)"
					evselect table="${files//_LC_CORR100.FITS/_BKG_SP_FILT.FITS}" withrateset=yes rateset="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_BKG_LC_$postfix.FITS}" maketimecolumn=yes timecolumn=TIME timebinsize=10 makeratecolumn=yes expression="(PI in [$lowhard:$highhard])&&gti(gti.ds,TIME)"
					epiclccorr srctslist="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_SRC_LC_$postfix.FITS}" eventlist="${files//_LC_CORR100.FITS/.FITS}" outset="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_LC_CORR_$postfix.FITS}" bkgtslist="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_BKG_LC_$postfix.FITS}" withbkgset=yes applyabsolutecorrections=yes
					dsplot table="${files//_LC_CORR100.FITS/_${lowhard}_${highhard}_HARD_LC_CORR_$postfix.FITS}" x=TIME y=RATE &	
				fi
			else continue
			fi
		done	
	fi
set +e
}

#function phase_stamp_to_lightcurves(){
#	RRVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Parameters for phase resoolved spectra" --add-entry="Reference epoch(UTC)(e.g. ccyy-mm-ddThh:mm:ss)" --add-entry="Phase at epoch" --add-entry="frequency (i.e. 1/Period(in sec)) (Hz)" --add-entry="Frequency dot"`
#	epoch=$(awk -F'|' '{print $1}' <<<$RRVALUE);    
#	phaseepoch=$(awk -F'|' '{print $2}' <<<$RRVALUE);
#	frequency=$(awk -F'|' '{print $3}' <<<$RRVALUE);
#	frequencydot=$(awk -F'|' '{print $4}' <<<$RRVALUE);
#	for files in *LC_CORR*
#	do	phasecalc --tables="$files:RATE" frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4
#	done
#}
#-----------------------------------------------------------------------------------------------------------------------------------------------
#                                                                   FUNCTION DECLARATIONS FOR RGS
#-----------------------------------------------------------------------------------------------------------------------------------------------
function rgsproccer(){
	if [ "$opted_method" == "-c" ]
	then	echo "------------------------------------------------------------------------------------------RGSPROCCER------------------------------------------------------------------------------------------------------"
		echo "Running rgsproc"
		echo "Give R.A. of source"
		read ra
		echo "GIve Dec of source"
		read dec
		#echo $ra $dec
		echo "rgsproc withsrc=yes srclabel='USER' srcstyle=radec srcra=$ra srcdec=$dec"
		set -e		
		rgsproc withsrc=yes srclabel='USER' srcstyle=radec srcra=$ra srcdec=$dec
		set +e
	else	op1="R.A."
		op2="Dec."
		RET=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --add-entry="R.A." --add-entry="Dec."`
		ra=$(awk -F'|' '{print $1}' <<<$RET);    
		dec=$(awk -F'|' '{print $2}' <<<$RET);
		set -e		
		rgsproc withsrc=yes srclabel='USER' srcstyle=radec srcra=$ra srcdec=$dec
		set +e
	fi
	}
function rgsproc_runner(){
	g=$(ls *ATT* | wc -l)
	if [ $g = 0 ]
		then	rgsproccer;
		#rgsproc orders="1 2" bkgcorrect=no withmlambdacolumn=yes spectrumbinning=lambda
	else	if [ "$opted_method" == "-c" ]
		then	echo "rgsproc has already been run. do you want to run it again?"
			read ans
			ans=${ans:=no}
			if [ $ans = 'yes' ]
			then	rgsproccer;
			else echo "Alright!!! going to further steps..."
			fi
		else	q=$(zenity --question --text "rgs proc has already been run. Do you want to run it again?"; echo $?)
			if [ $q = 0 ]
			then	rgsproccer;
			else	zenity --notification --text "Alright!!! going to further steps..."
			fi
		fi
	fi
	}
function rgs_renamer() {
	echo "----------------------------------------------------------------------------------------RENAMER-----------------------------------------------------------------------------------------------------------"
	if [ $(ls *EVENT* | wc -l) = 0 ] 
	then	export tempnumb=1
		for file in *R1*EVEN* 
		do	cp $file R1_${tempnumb}_EVENT.FITS				
			tempnumb=$((tempnumb+1))
		done
		export tempnumb=1
		for file in *R2*EVEN* 
		do	cp $file R2_${tempnumb}_EVENT.FITS				
			tempnumb=$((tempnumb+1))
		done
	else	if [ "$opted_method" == "-c" ]
		then	echo "files have been renamed already..."
		else	zenity --notification --text "files have been renamed already..."
		fi
	fi
	if [ $(ls *SRCLI.FITS | wc -l) = 0 ] 
	then	export tempnumb=1
		for file in *R1*SRCLI* 
		do	cp $file R1_${tempnumb}_SRCLI.FITS				
			tempnumb=$((tempnumb+1))
		done
		export tempnumb=1
		for file in *R2*SRCLI* 
		do	cp $file R2_${tempnumb}_SRCLI.FITS				
			tempnumb=$((tempnumb+1))
		done
	
	else	if [ "$opted_method" == "-c" ]
		then	echo "files have been renamed already..."
		else	zenity --notification --text "files have been renamed already..."
		fi
	fi
}

function rgs_plotter(){
	echo "-----------------------------------------------------------------------------------------------PLOTTER----------------------------------------------------------------------------------------------------"
	for files in R1*EVENT.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR1=`python $usrindexcode ${files//EVENT/SRCLI}`
		echo "evselect table=\"$files:EVENTS\" imageset="${files//EVENT/spatial}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'"
  		echo "evselect table='$files:EVENTS' imageset="${files//EVENT/pi}" xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression=REGION(${files//EVENT/SRCLI}:RGS1_SRC${indexR1}_SPATIAL,M_LAMBDA,XDSP_CORR)"
		echo "rgsimplot endispset="${files//EVENT/pi}" spatialset="${files//EVENT/spatial}" srcidlist='${indexR1}' srclistset='${files//EVENT/SRCLI}' device=/xs"
		set -e
		evselect table="$files:EVENTS" imageset="${files//EVENT/spatial}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'
		evselect table="$files:EVENTS" imageset="${files//EVENT/pi}" xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression="REGION(${files//EVENT/SRCLI}:RGS1_SRC${indexR1}_SPATIAL,M_LAMBDA,XDSP_CORR)"
		
		rgsimplot endispset="${files//EVENT/pi}" spatialset="${files//EVENT/spatial}" srcidlist="${indexR1}" srclistset="${files//EVENT/SRCLI}" device=/CPS plotfile="${files//EVENT/banana}"
		gv ${files//EVENT/banana}	
	done
	for files in R2*EVENT.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR2=`python $usrindexcode ${files//EVENT/SRCLI}`
		echo "evselect table=\"$files:EVENTS\" imageset="${files//EVENT/spatial}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'"
  		echo "evselect table='$files:EVENTS' imageset="${files//EVENT/pi}" xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression=REGION(${files//EVENT/SRCLI}:RGS2_SRC${indexR2}_SPATIAL,M_LAMBDA,XDSP_CORR)"
		echo "rgsimplot endispset="${files//EVENT/pi}" spatialset="${files//EVENT/spatial}" srcidlist='3' srclistset='${files//EVENT/SRCLI}' device=/xs"
		evselect table="$files:EVENTS" imageset="${files//EVENT/spatial}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'
		evselect table="$files:EVENTS" imageset="${files//EVENT/pi}" xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression="REGION(${files//EVENT/SRCLI}:RGS2_SRC${indexR2}_SPATIAL,M_LAMBDA,XDSP_CORR)"
		rgsimplot endispset="${files//EVENT/pi}" spatialset="${files//EVENT/spatial}" srcidlist="${indexR2}" srclistset="${files//EVENT/SRCLI}" device=/CPS plotfile="${files//EVENT/banana}"
		gv ${files//EVENT/banana}	
 
	done
	set +e
	for files in *banana*
		do	mv $files ${files//.FITS/.ps}
		done
	set +e
	}

function rgs_bkg_plotter(){
	for files in R1*EVENT.FITS
	do	set -e
		evselect table="$files:EVENTS" imageset="${files//EVENT/background}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR' expression="REGION(${files//EVENT/SRCLI}:RGS1_BACKGROUND,M_LAMBDA,XDSP_CORR)"	
		ds9 ${files//EVENT/background} &
	done

	for files in R2*EVENT.FITS
	do	evselect table="$files:EVENTS" imageset="${files//EVENT/background}" xcolumn='M_LAMBDA' ycolumn='XDSP_CORR' expression="REGION(${files//EVENT/SRCLI}:RGS2_BACKGROUND,M_LAMBDA,XDSP_CORR)"	
		ds9 ${files//EVENT/background} &
	done
}



function rgs_bkg_flare_corrector(){
	echo "--------------------------------------------------------------------BACKGROUND FLARE CHECKING ------------------------------------------------------------------------------------------------------------"
	set -e
	for files in R1*EVENT.FITS
	do	evselect table=$files withrateset=yes rateset=${files//EVENT/BKG_FLARE_LC} maketimecolumn=yes timebinsize=100 makeratecolumn=yes expression="(CCDNR==9)&&(REGION(${files//EVENT/SRCLI}:RGS1_BACKGROUND,M_LAMBDA,XDSP_CORR))"
		dsplot table=${files//EVENT/BKG_FLARE_LC} x=TIME y=RATE &
		bkglcvar=${files//EVENT/BKG_FLARE_LC}
		set +e
		if [ $opted_method == '-c' ]
		then	echo "Need to correct for bckground flare? (y/n)"
			read ans
			echo "Can new gti be created for this file or data is contaminated for whole time?"			
			read sokka
			if [ $ans = n ]
			then	echo "Skipping gti build tasks."
			elif [[ ( $sokka = y ) && ( $ans = y ) ]]
			then	echo "Creating a new gti. Is GTI filtering expression on RATE (R) or TIME (T)?"			
				read ans
				echo "You choose filtering on $ans."
				if [ $ans = R ]
				then	echo "Give max acceptable rate for this set."
					#	play -q -n synth 0.1 sin 880
					read maxr
					#tabgtigen table=R1_LC.FITS expression="RATE<=$maxr" gtiset=gtiset_R1.fits
					tabgtigen table=${files//EVENT/BKG_FLARE_LC} expression="RATE<=$maxr" gtiset=${files//EVENT.FITS/_gtiset.fits} 
				elif [ $ans = T ]
				then	#echo "Give exact expression for time filtering."
					#play -q -n synth 0.1 sin 880
					#read Timefil
					echo "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
					timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
					Timefil=$(python $timecode ${files//EVENT/BKG_FLARE_LC})
					echo "Time filter used here is: $Timefil"
					tabgtigen table=${files//EVENT/BKG_FLARE_LC} expression="$Timefil" gtiset=${files//EVENT.FITS/_gtiset.fits}	
				fi
			else	echo "Seems data is severely damaged by soft proton flares. Will skip reduction for this set for rest and all."
				mv ${files} ${files//.FITS/_SEVERE.FITS}
	
			fi
		else	que=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Need to correct for bckground flare?"; echo $?)
			severity=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Can new gti be created for this file or data is contaminated for whole time?"; echo $?)
			if [ $severity != 0 ]
			then	zenity --title "XMM-SCRIPT" --width 500 --height 500 --notification --text "Skipping gti build tasks"
				mv ${files} ${files//.FITS/_SEVERE.FITS}
			elif [[ ( $severity = 0 ) && ( $que = 0 ) ]]
			then	op1="RATE"
				op2="TIME"
				answer=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'filter expression to be used on what:' --column 'Select...' --column 'Filter expression' TRUE "$op1" FALSE "$op2"`
				if [ "$answer" == "$op1" ]
				then	maxr=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Max. allowed rate:"`
					tabgtigen table=${files//EVENT/BKG_FLARE_LC} expression="RATE<=$maxr" gtiset=${files//EVENT.FITS/gtiset.fits}
				else	zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "Select the pairs of good time intervals in ratecurve shown by clicking on time-axis"
				timecode=$(readlink -f ~/bin/time_fil_expre_maker.py)
				Timefil=$(python $timecode ${files//EVENT/BKG_FLARE_LC})
				zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --text "printf Time filter expression used is: $Timefil"
				#Timefil=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms --title "GTI BUILDER EXPRESSION SELECTOR" --add-entry="Enter exact time filtering expression:"`
				tabgtigen table=${files//EVENT/BKG_FLARE_LC} expression="$Timefil" gtiset=${files//EVENT.FITS/gtiset.fits}
				fi
			fi
		fi
		echo "rgsproc entrystage=3:filter auxgtitables=gtiset_R1.fits"
		#rgsproc withsrc=yes srclabel='USER' srcstyle=radec srcra=$ra srcdec=$dec entrystage=3:filter auxgtitables=gtiset_R1.fits
		set +e
		if [ $(ls ${files//EVENT.FITS/gtiset.fits} | wc -l) = 0 ]
		then	echo "..."
		else	rgsproc entrystage=3:filter auxgtitables=${files//EVENT.FITS/gtiset.fits}		
			echo "removing previous files..."
			rm R*EVENT.FITS
			rm R*SRCLI.FITS
			echo "renaming new event files..."
			rgs_renamer;
		fi	
		
	done
}


function rgs_extraction_mask_corrector(){
echo "----------------------------------------------------------------------EXTRACTION MASK CORRECTION----------------------------------------------------------------------------------------------------------"
	set -e
	for files in R1*SRCLI.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR1=`python $usrindexcode $files`
		cxctods9 table="$files:RGS1_SRC${indexR1}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
		ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
		if [ "$opted_method" == "-c" ]
		then	echo "Do we need to increase extraction mask size?"
			read ans
			if [ $ans = y ]
			then	echo "Alright! changing mask size to 98% of PSF..."
				rgsregions srclist=$files evlist=${files//SRCLI/EVENT} xpsfbelow=98 xpsfabove=98 xpsfexcl=99
				cxctods9 table="$files:RGS1_SRC${indexR1}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
				ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
			else	echo "Keeping this Mask."
			fi
		else	qw=$(zenity --question --text "Do we need to increase extraction mask size?"; echo $?)
			if [ $qw = 0 ]
			then	zenity --notification --text "Alright! changing mask size to 98% of PSF..."
				rgsregions srclist=$files evlist=${files//SRCLI/EVENT} xpsfbelow=98 xpsfabove=98 xpsfexcl=99
				cxctods9 table="$files:RGS1_SRC${indexR1}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
				ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
			else	zenity --notification --text "Keeping this mask"
			fi
		fi
	done
	for files in R2*SRCLI.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR2=`python $usrindexcode $files`
		cxctods9 table="$files:RGS2_SRC${indexR2}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
		ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
		if [ "$opted_method" == "-c" ]
		then	echo "Do we need to increase extraction mask size?"
			read ans
			if [ $ans = y ]
			then	echo "Alright! changing mask size to 98% of PSF..."
				rgsregions srclist=$files evlist=${files//SRCLI/EVENT} xpsfbelow=98 xpsfabove=98 xpsfexcl=99
				cxctods9 table="$files:RGS2_SRC${indexR2}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
				ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
			else	echo "Keeping this Mask."
			fi
		else	qw=$(zenity --question --text "Do we need to increase extraction mask size?"; echo $?)
			if [ $qw = 0 ]
			then	zenity --notification --text "Alright! changing mask size to 98% of PSF..."
				rgsregions srclist=$files evlist=${files//SRCLI/EVENT} xpsfbelow=98 xpsfabove=98 xpsfexcl=99
				cxctods9 table="$files:RGS2_SRC${indexR2}_SPATIAL" regtype=linear -V 0 >${files//SRCLI.FITS/src.reg}
				ds9  ${files//SRCLI/spatial} -regions ${files//SRCLI.FITS/src.reg} &
			else	zenity --notification --text "Keeping this mask"
			fi
		fi
	done
	set +e	
}

function rgs_other_source_corrector(){
	set +e
	directroy=$(pwd)	
	echo "---------------------------------------------------------NEARBY BRIGHT X-RAY SOURCE CORRECTION------------------------------------------------------------------------------------------------------------"
	cd ..
	echo "we are in $(pwd) we was in $directroy"
	cd pn
	echo "we are in $(pwd)"
	if [ $(ls *IM.FITS | wc -l ) = 0 ]
	then	cd ..
		echo "we are in $(pwd)"
		cd mos
		echo "we are in $(pwd)"
		if [ $(ls *IM.FITS | wc -l ) = 0 ]
		then	if [ "$opted_method" == "-c" ]
			then	echo "no images found to compare in mos and pn directories..."
			else	zenity --warning --text "no images found to compare in mos and pn directories..."
				return 1
			fi
			cd ..
			echo "we are in $(pwd)"
		else	cp *IM.FITS $directroy/EPIC_IMAGE.FITS
		fi
	else	cp *IM.FITS $directroy/EPIC_IMAGE.FITS
	fi
	#cd ..
	echo "we are in $(pwd)"
	cd $directroy
	for files in R1*EVENT.FITS
	do	ds9 EPIC_IMAGE.FITS ${files//EVENT/spatial} &
		if [ "$opted_method" == "-c" ]
		then	echo "check R.A. DEC of contaminator from image shown..."
			echo " If needed, MAKE A CICLE AROUND CONTAMINATOR WITH IT AS A CENTER THEN ENTER..."
			read waa
			waa=${waa:=n}
			if [ $waa = y ]
			then	set -e
				xpaget  ds9 region -system wcs -sky fk5 -coordformat degrees>contaminator.reg		
				conatminatorcode=$(readlink -f ~/bin/rgs_contaminator.py)				
				while read line ; do   array=($line); done < <(python $conatminatorcode)
					Xcord=${array[0]}
					Ycord=${array[1]}
					areaPix=${array[2]}
				usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
				indexR1=`python $usrindexcode ${files//EVENT/SRCLI}`	
				rgssources srclist=${files//EVENT/SRCLI} addusersource=yes label='CONTAMINATOR' ra=$Xcord dec=$Ycord bkgexclude=yes
				rgsregions srclist=${files//EVENT/SRCLI} evlist=$files procsrcsexpr="INDEX==${indexR1}"
			else	echo "Okay... Not doing correction for contaminating sources in FOV"
			fi
		else	han=$(zenity --question --text "printf check R.A. Dec. of cotaminator from image shown... \n If needed, Make a circle around contaminator with it as a center and then press yes"; echo $?)
			if [ $han = 0 ]
			then	set -e
				xpaget  ds9 region -system wcs -sky fk5 -coordformat degrees>contaminator.reg		
				conatminatorcode=$(readlink -f ~/bin/rgs_contaminator.py)
				while read line ; do   array=($line); done < <(python $conatminatorcode)
					Xcord=${array[0]}
					Ycord=${array[1]}
					areaPix=${array[2]}	
				usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
				indexR1=`python $usrindexcode ${files//EVENT/SRCLI}`	
				rgssources srclist=${files//EVENT/SRCLI} addusersource=yes label='CONTAMINATOR' ra=$Xcord dec=$Ycord bkgexclude=yes
				rgsregions srclist=${files//EVENT/SRCLI} evlist=$files procsrcsexpr="INDEX==${indexR1}"
			else	zenity --notification --text "Okay... Not doing correction for contaminating sources in FOV"
			fi	
		fi
	done
	for files in R2*EVENT.FITS
	do	ds9 EPIC_IMAGE.FITS ${files//EVENT/spatial} &
		if [ "$opted_method" == "-c" ]
		then	echo "check R.A. DEC of contaminator from image shown..."
			echo " If needed, MAKE A CICLE AROUND CONTAMINATOR WITH IT AS A CENTER THEN ENTER..."
			read waa
			waa=${waa:=n}
			if [ $waa = y ]
			then	set -e
				xpaget  ds9 region -system wcs -sky fk5 -coordformat degrees>contaminator.reg		
				conatminatorcode=$(readlink -f ~/bin/rgs_contaminator.py)				
				while read line ; do   array=($line); done < <(python $conatminatorcode)
					Xcord=${array[0]}
					Ycord=${array[1]}
					areaPix=${array[2]}
				usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
				indexR2=`python $usrindexcode ${files//EVENT/SRCLI}`	
				rgssources srclist=${files//EVENT/SRCLI} addusersource=yes label='CONTAMINATOR' ra=$Xcord dec=$Ycord bkgexclude=yes
				rgsregions srclist=${files//EVENT/SRCLI} evlist=$files procsrcsexpr="INDEX==${indexR2}"
			else	echo "Okay... Not doing correction for contaminating sources in FOV"
			fi
		else	han=$(zenity --question --text "printf check R.A. Dec. of cotaminator from image shown... \n If needed, Make a circle around contaminator with it as a center and then press yes"; echo $?)
			if [ $han = 0 ]
			then	set -e
				xpaget  ds9 region -system wcs -sky fk5 -coordformat degrees>contaminator.reg		
				conatminatorcode=$(readlink -f ~/bin/rgs_contaminator.py)
				while read line ; do   array=($line); done < <(python $conatminatorcode)
					Xcord=${array[0]}
					Ycord=${array[1]}
					areaPix=${array[2]}	
				usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
				indexR2=`python $usrindexcode ${files//EVENT/SRCLI}`	
				rgssources srclist=${files//EVENT/SRCLI} addusersource=yes label='CONTAMINATOR' ra=$Xcord dec=$Ycord bkgexclude=yes
				rgsregions srclist=${files//EVENT/SRCLI} evlist=$files procsrcsexpr="INDEX==${indexR2}"
			else	zenity --notification --text "Okay... Not doing correction for contaminating sources in FOV"
			fi	
		fi
	done
	set +e
}


function rgs_spectra_and_response_generator(){
	echo "---------------------------------------------SPECTRA AND RESPONSE MATRICES GENERATION --------------------------------------------------------------------------------------------------------------------"
	set -e
	echo "generating spectra and RMFs..."
	for files in R1*EVENT.FITS
	do	rgsspectrum evlist=$files srclist=${files//EVENT/SRCLI} order=1 spectrumset=${files//EVENT.FITS/SRSPEC_O1.FITS} bkgset=${files//EVENT.FITS/BGSPEC_O1.FITS} #source="${indexR1}"
		rgsspectrum evlist=$files srclist=${files//EVENT/SRCLI} order=2 spectrumset=${files//EVENT.FITS/SRSPEC_O2.FITS} bkgset=${files//EVENT.FITS/BGSPEC_O2.FITS} #source="${indexR1}"
		rgsrmfgen spectrumset=${files//EVENT.FITS/SRSPEC_O1.FITS} srclist=${files//EVENT/SRCLI} rmfset=${files//EVENT.FITS/RMF_O1.FITS} evlist=$files emin=0.4 emax=2.5 rows=4000 order=1 #source="${indexR1}"
		rgsrmfgen spectrumset=${files//EVENT.FITS/SRSPEC_O2.FITS} srclist=${files//EVENT/SRCLI} rmfset=${files//EVENT.FITS/RMF_O2.FITS} evlist=$files emin=0.4 emax=2.5 rows=4000 order=2 #source="${indexR1}"
	done
	for files in R2*EVENT.FITS
	do	rgsspectrum evlist=$files srclist=${files//EVENT/SRCLI} order=1 spectrumset=${files//EVENT.FITS/SRSPEC_O1.FITS} bkgset=${files//EVENT.FITS/BGSPEC_O1.FITS} #source="${indexR1}"
		rgsspectrum evlist=$files srclist=${files//EVENT/SRCLI} order=2 spectrumset=${files//EVENT.FITS/SRSPEC_O2.FITS} bkgset=${files//EVENT.FITS/BGSPEC_O2.FITS} #source="${indexR1}"
		rgsrmfgen spectrumset=${files//EVENT.FITS/SRSPEC_O1.FITS} srclist=${files//EVENT/SRCLI} rmfset=${files//EVENT.FITS/RMF_O1.FITS} evlist=$files emin=0.4 emax=2.5 rows=4000 order=1 #source="${indexR1}"
		rgsrmfgen spectrumset=${files//EVENT.FITS/SRSPEC_O2.FITS} srclist=${files//EVENT/SRCLI} rmfset=${files//EVENT.FITS/RMF_O2.FITS} evlist=$files emin=0.4 emax=2.5 rows=4000 order=2 #source="${indexR1}"
	done
	echo "combining R1 and R2 spectra..."
	for files in R1*SRSPEC_O1.FITS
	do	o1rmf=${files//SRSPEC_O1.FITS/RMF_O1.FITS}
		o1bgspec=${files//SRSPEC_O1.FITS/BGSPEC_O1.FITS}
		rgscombine pha="$files ${files//R1/R2}" rmf="$o1rmf ${o1rmf//R1/R2}" bkg="$o1bgspec ${o1bgspec//R1/R2}" filepha=${files//R1/R12} filermf=${o1rmf//R1/R12} filebkg=${o1bgspec//R1/R12} rmfgrid=4000
	done
	for files in R1*SRSPEC_O2.FITS
	do	o2rmf=${files//SRSPEC_O2.FITS/RMF_O2.FITS}
		o2bgspec=${files//SRSPEC_O2.FITS/BGSPEC_O2.FITS}
		rgscombine pha="$files ${files//R1/R2}" rmf="$o2rmf ${o2rmf//R1/R2}" bkg="$o2bgspec ${o2bgspec//R1/R2}" filepha=${files//R1/R12} filermf=${o2rmf//R1/R12} filebkg=${o2bgspec//R1/R12} rmfgrid=4000
	done
	for files in R12*SRSPEC_O1.FITS
	do	if [ $(ls ${files//SRSPEC/GRP} | wc -l) = 0 ]
		then	grppha $files ${files//SRSPEC/GRP} comm="chkey BACKFILE ${files//SRSPEC/BGSPEC} & chkey RESPFILE ${files//SRSPEC/RMF} & group min 20 & exit"
		fi
	done
	for files in R12*SRSPEC_O2.FITS
	do	if [ $(ls ${files//SRSPEC/GRP} | wc -l) = 0 ]
		then	grppha $files ${files//SRSPEC/GRP} comm="chkey BACKFILE ${files//SRSPEC/BGSPEC} & chkey RESPFILE ${files//SRSPEC/RMF} & group min 20 & exit"
		fi
	done
	set +e
}

function rgs_lightcurve_generator(){
	echo "----------------------------------------------------------------------------LIGHTCURVE GENERATION---------------------------------------------------------------------------------------------------------"
	set -e
	for files in R1*EVENT.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR1=`python $usrindexcode ${files//EVENT/SRCLI}`
		rgslccorr evlist=$files srclist=${files//EVENT/SRCLI} outputsrcfilename=${files//EVENT.FITS/SRC_LC_BKG_subtracted.lc} withbkgsubtraction=yes outputbkgfilename=${files//EVENT.FITS/BKG_LC.lc} withfiltering=yes filtering="energy" energymin='300' energymax='2500' sourceid="${indexR1}" timebinsize=1
		dsplot table=${files//EVENT.FITS/SRC_LC_BKG_subtracted.lc} x=TIME y=COUNTS &
	done
	for files in R2*EVENT.FITS
	do	usrindexcode=$(readlink -f ~/bin/rgs_user_index_finder.py)	
		indexR2=`python $usrindexcode ${files//EVENT/SRCLI}`
		rgslccorr evlist=$files srclist=${files//EVENT/SRCLI} outputsrcfilename=${files//EVENT.FITS/SRC_LC_BKG_subtracted.lc} withbkgsubtraction=yes outputbkgfilename=${files//EVENT.FITS/BKG_LC.lc} withfiltering=yes filtering="energy" energymin='300' energymax='2500' sourceid="${indexR2}" timebinsize=1
		dsplot table=${files//EVENT.FITS/SRC_LC_BKG_subtracted.lc} x=TIME y=COUNTS &
	done
set +e
}

function rgs_pileup_checker(){
	for files in R1*SRSPEC_O1.FITS
	do	rgsfluxer pha=$files rmf=${files//SRSPEC/RMF} file=${files//.FITS/FLUXED.FITS}
		secondorderpha=${files//O1/O2}
		rgsfluxer pha=$secondorderpha rmf=${secondorderpha//SRSPEC/RMF} file=${secondorderpha//.FITS/FLUXED.FITS}
		pileupcode=$(readlink -f ~/bin/rgs_pileup.py)
		python $pileupcode ${files//.FITS/FLUXED.FITS} ${secondorderpha//.FITS/FLUXED.FITS}
		if [ "$opted_method" == "-c" ]
		then	echo "Pileup present?"
			read pil
			if [ $pil = y ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		else	qwe=$(zenity --question --text "Pileup present?"; echo $?)
			if [ $qwe = 0 ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		fi
	done
	for files in R2*SRSPEC_O1.FITS
	do	rgsfluxer pha=$files rmf=${files//SRSPEC/RMF} file=${files//.FITS/FLUXED.FITS}
		secondorderpha=${files//O1/O2}
		rgsfluxer pha=$secondorderpha rmf=${secondorderpha//SRSPEC/RMF} file=${secondorderpha//.FITS/FLUXED.FITS}
		pileupcode=$(readlink -f ~/bin/rgs_pileup.py)
		python $pileupcode ${files//.FITS/FLUXED.FITS} ${secondorderpha//.FITS/FLUXED.FITS}
		if [ "$opted_method" == "-c" ]
		then	echo "Pileup present?"
			read pil
			if [ $pil = y ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		else	qwe=$(zenity --question --text "Pileup present?"; echo $?)
			if [ $qwe = 0 ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		fi
	done
	for files in R12*SRSPEC_O1.FITS
	do	rgsfluxer pha=$files rmf=${files//SRSPEC/RMF} file=${files//.FITS/FLUXED.FITS}
		secondorderpha=${files//O1/O2}
		rgsfluxer pha=$secondorderpha rmf=${secondorderpha//SRSPEC/RMF} file=${secondorderpha//.FITS/FLUXED.FITS}
		pileupcode=$(readlink -f ~/bin/rgs_pileup.py)
		python $pileupcode ${files//.FITS/FLUXED.FITS} ${secondorderpha//.FITS/FLUXED.FITS}
		if [ "$opted_method" == "-c" ]
		then	echo "Pileup present?"
			read pil
			if [ $pil = y ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		else	qwe=$(zenity --question --text "Pileup present?"; echo $?)
			if [ $qwe = 0 ]
			then	mv $files ${files//.FITS/piledup.FITS}
			fi
		fi
	done
#rgsfluxer pha='R1_SRSPEC_O1.FITS' rmf='R1_O1_RMF.FITS' file=R1_flux_1storder.fits
}


#---------------------------------------------------------------------------
#-------------------------for phase resolved spectra------------------------ 0 means mos
#---------------------------------------------------------------------------
function phase_resolved_spectra(){
	rm *PHASE*
	echo "we are in phase function and in directory $(pwd)"
	RRVALUE=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --forms  --text  "Parameters for phase resoolved spectra" --add-entry="Reference epoch(UTC)(e.g. ccyy-mm-ddThh:mm:ss)" --add-entry="Phase at epoch" --add-entry="frequency (i.e. 1/Period(in sec)) (Hz)" --add-entry="Frequency dot" --add-entry="Phase interval in which you want spectra" --add-entry="Phase to start with in spectral analysis"`
	epoch=$(awk -F'|' '{print $1}' <<<$RRVALUE);    
	phaseepoch=$(awk -F'|' '{print $2}' <<<$RRVALUE);
	frequency=$(awk -F'|' '{print $3}' <<<$RRVALUE);
	frequencydot=$(awk -F'|' '{print $4}' <<<$RRVALUE);
	phaseinterval=$(awk -F'|' '{print $5}' <<<$RRVALUE);
	currentphase=$(awk -F'|' '{print $6}' <<<$RRVALUE);
	#phasecalc --tables=PN_1_UFILT_SRC_SP_FILT.FITS:EVENTS --frequency=3.7512888933467406e-05 --epoch=2006-10-17T15:18:22  --frequencydot=0 phase=0 -V 4
	for files in *FILT.FITS
	do	set -e
		echo "phasecalc --tables=$files:EVENTS --frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4"
		phasecalc --tables=$files:EVENTS --frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4
		expos=($(python ~/bin/for_phasecalc.py $files | tr -d '[],'))
		for (( i=0; i<=`expr ${#expos[@]} - 1`; i++))
		do	echo "phasecalc --tables=$files:${expos[$i]} frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4"
			phasecalc --tables=$files:${expos[$i]} frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4
		done
			set +e
	done
	for files in *FILT_QUITE.FITS
	do	set -e
		echo "phasecalc --tables=$files:EVENTS --frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4"
		phasecalc --tables=$files:EVENTS --frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4
		expos=($(python ~/bin/for_phasecalc.py $files | tr -d '[],'))
		for (( i=0; i<=`expr ${#expos[@]} - 1`; i++))
		do	echo "phasecalc --tables=$files:${expos[$i]} frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4"
			phasecalc --tables=$files:${expos[$i]} frequency=$frequency --epoch=$epoch  --frequencydot=$frequencydot phase=$phaseepoch -V 4
		done
			set +e
	done
	zenity --title "XMM-SCRIPT" --notification --text "generating GTI for relavant phases"
	#currentphase="0.0"
	phaselimit="1.0"
	#increment="$phaseinterval"
	veryfirstcurrentphase=$(bc <<< "1.0 + $currentphase - 1.0")
	while [ "$(bc <<< "$currentphase < $phaselimit")" == "1"  ]
	do	phasup=$(bc <<< "$currentphase+$phaseinterval")
		if [ "$(bc <<< "$phasup > $phaselimit")" == "1" ]
		then	phasup=$(bc <<< "$phasup - 1.0")
		fi
		if [ $(ls *QUITE.FITS | wc -l) = 0 ]
		then	for files in *SRC_SP_FILT.FITS
			do	echo "tabgtigen table=$files gtiset=gti.ds expression=\"(PHASE>=$currentphase||PHASE<$phasup)\" "
				if [ "$(bc <<< "$phasup < $currentphase")" == "1" ]
				then	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase||PHASE<$phasup)"
				else	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)"
				fi
				if [ $1 = 0 ]
				then	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_SRC_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
				else	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_SRC_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
				fi
			done
			for files in *BKG_SP_FILT.FITS
			do	echo "tabgtigen table=$files gtiset=gti.ds expression=\"(PHASE>=$currentphase||PHASE<$phasup)\" "
				if [ "$(bc <<< "$phasup < $currentphase")" == "1" ]
				then	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase||PHASE<$phasup)"
				else	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)"
				fi
				#tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)" 
				if [ $1 = 0 ]
				then	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_BKG_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
				else	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_BKG_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
				fi
			done
		
		else	for files in *SRC_SP_FILT_QUITE.FITS
			do	echo "tabgtigen table=$files gtiset=gti.ds expression=\"(PHASE>=$currentphase||PHASE<$phasup)\" "
				if [ "$(bc <<< "$phasup < $currentphase")" == "1" ]
				then	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase||PHASE<$phasup)"
				else	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)"
				fi
				if [ $1 = 0 ]
				then	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_SRC_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
				else	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_SRC_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
				fi
			done
			for files in *BKG_SP_FILT_QUITE.FITS
			do	echo "tabgtigen table=$files gtiset=gti.ds expression=\"(PHASE>=$currentphase||PHASE<$phasup)\" "
				if [ "$(bc <<< "$phasup < $currentphase")" == "1" ]
				then	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase||PHASE<$phasup)"
				else	tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)"
				fi
				#tabgtigen table=$files gtiset=gti.ds expression="(PHASE>=$currentphase&&PHASE<$phasup)" 
				if [ $1 = 0 ]
				then	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_BKG_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="11999"
				else	echo "evselect table="$files" energycolumn=\"PI\" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype=\"expression\" expression=\"gti(gti.ds,TIME)\" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479"
					evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="gti(gti.ds,TIME)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
					backscale spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" badpixlocation=${files%_BKG_SP*}.FITS
					#evselect table="$files" energycolumn="PI" withfilteredset=yes filteredset="${files//SP_FILT/SP_FILT_PHASE$currentphase-$phasup}" keepfilteroutput=yes filtertype="expression" expression="(PHASE>=$currentphase&&PHASE<$phasup)" withspectrumset=yes spectrumset="${files//SP_FILT/SP_PHASE$currentphase-$phasup}" spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax="20479"
				fi
			done
		fi
		
		
	    	currentphase=$(bc <<< "$currentphase+$phaseinterval")
	    	if [ "$(bc <<< "$currentphase > $phaselimit")" == "1" ]
		then	currentphase=$(bc <<< "$currentphase - 1.0")
		fi
		if [ "$currentphase" == "$veryfirstcurrentphase" ]
		then	break
		fi
	done
	set -e
	#for files in *SRC_SP_PHASE*
	#	do	echo "rmfgen rmfset="${files//SRC_SP/SRC_RMF}" spectrumset="$files""
	#		echo "arfgen arfset="${files//SRC_SP/SRC_ARF}" spectrumset="$files" withrmfset=yes rmfset="${files//SRC_SP/SRC_RMF}" withbadpixcorr=yes badpixlocation="${files%_SRC_SP*}.FITS" setbackscale=yes"
	#		rmfgen rmfset="${files//SRC_SP/SRC_RMF}" spectrumset="$files"
	#		arfgen arfset="${files//SRC_SP/SRC_ARF}" spectrumset="$files" withrmfset=yes rmfset="${files//SRC_SP/SRC_RMF}" withbadpixcorr=yes badpixlocation="${files%_SRC_SP*}.FITS" setbackscale=yes
	#	done
	set +e
	
}

#                                                                                       -----------------------------------
#                                                                                   RUNNING MAIN PROCEDURES BY CALLING FUNCTIONS
#                                                                                       ------------------------------------

if [[ $pnonly = 1 ]]
then	only_pn_reduction;
fi

if [[ $mosonly = 1 ]]
then	only_mos_reduction;
fi


if [[ $mospn = 1 ]]
then	only_pn_reduction;
	only_mos_reduction;
fi

if [[ $analysismaker = 1 ]]
then	analysis_maker;
else	cd analysis
	grouper;
	cd ..
fi

if [[ $advancedoption = 1 ]]
then	if [ "$opted_method" == "-c" ]
	then	imlooper=0
		while [ $imlooper = 0 ]
		do	echo "Please select from following:"
			echo "1) Lighcurves generation (spectra files are mandatory)"
			echo "2) Quiescent lightcurves and spectra maker"
			
			read advan
			if [ $advan = 1 ]
			then	imlooper=1
				cd pn
				lightcurves;
				cd ..
				cd mos
				lightcurves;
				cd ..
			elif [ $advan = 2 ]
			then	imlooper=1
				cd pn
				quite_lightcurve_spectra 1;
				cd ..
				cd mos
				quite_lightcurve_spectra 0;
				cd ..
			else	echo "Please enter valid option."
			fi
		done
	else	deti1="Lighcurves generation (spectra files are mandatory)"
		deti2="Quiescent lightcurves and spectra maker"
		deti3="Phase resolved spectra"
		deti4="Flare lightcurve + spectra extraction"
		#deti5="Add PHASE stamp to lightcurves"
		selc=`zenity --title "XMM-SCRIPT" --width 500 --height 500 --height=275 --list --radiolist --text 'PLEASE SELECT:' --column 'Select...' --column '...' FALSE "$deti1" FALSE "$deti2" FALSE "$deti3" FALSE "$deti4"` # FALSE "$deti5"`
	
		if [ "$selc" == "$deti1" ]
		then 	cd pn
			lightcurves_gui;
			cd ..
			cd mos
			lightcurves_gui;
			cd ..
		elif [ "$selc" == "$deti2" ]
		then	cd pn
			quite_lightcurve_spectra_gui 1;
			cd ..
			cd mos
			quite_lightcurve_spectra_gui 0;
			cd ..
		elif [ "$selc" == "$deti3" ]
		then	cd pn
			phase_resolved_spectra 1;
			cd ..
			cd mos
			phase_resolved_spectra 0;
			cd ..
			analysis_maker;
		elif [ "$selc" == "$deti4" ]
		then	cd pn
			flare_lightcurve_spectra_gui 1;
			cd ..
			cd mos
			flare_lightcurve_spectra_gui 0;
			cd ..
#		elif [ "$selc" == "$deti5" ]
#		then	cd pn
#			phase_stamp_to_lightcurves;
#			cd ..
#			cd mos
#			phase_stamp_to_lightcurves
#			cd ..
		else	exit
		fi
	fi
fi

if [[ $rgsonly = 1 ]]
then	cd rgs
	rgsproc_runner;
	rgs_renamer;
	rgs_plotter;
	rgs_bkg_flare_corrector;
	rgs_extraction_mask_corrector;
	rgs_bkg_plotter;
	echo "before calling im in $(pwd)"
	rgs_other_source_corrector;	
	rgs_spectra_and_response_generator;
	rgs_pileup_checker;
	if [ "$opted_method" == "-c" ]
		then	echo "Do you want lightcurves?"
			read nah
			if [ $nah = y ]
			then	rgs_lightcurve_generator;
			fi
			echo "lightcurves------------------------------done---------------------------------------"
		else	nah=$(zenity --title "XMM-SCRIPT" --width 500 --height 500 --question --text "Do you want lightcurves?"; echo $?)
			if [ $nah = 0 ]
			then	rgs_lightcurve_generator;
			fi
	fi
	
	cd ..

fi




echo "ALL DATA HAVE BEEN REDUCED SUCCESSFULLY AND NOW CAN BE USED FOR ANALYSIS PART."
zenity --title "XMM-SCRIPT" --width 500 --height 500 --info --width=600 --text "ALL DATA HAVE BEEN REDUCED SUCCESSFULLY AND NOW CAN BE USED FOR ANALYSIS PART."


#--------------------------------------------------------------------------------------------------------
#                                                Script ENDs
#--------------------------------------------------------------------------------------------------------
