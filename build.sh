#!/bin/bash
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is Text Trix code.
#
# The Initial Developer of the Original Code is
# Text Flex.
# Portions created by the Initial Developer are Copyright (C) 2012, 2015
# the Initial Developer. All Rights Reserved.
#
# Contributor(s): David Young <david@textflex.com>
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****

# Text Trix Builder

HELP="
Builds and packages the Text-Trix-modified Ostermiller Syntax Highlighter.

Syntax:
	build.sh [ --java java-compiler-binaries-path ] [ --plug ]
	[ --pkg ] [ --help ]
(\"sh \" might need to precede the command on the same line, in case
the file build.sh does not have executable permissions.)

Parameters:
	--clean: Cleans all .class files and exits.
	
	--jar: Builds a jar file.
	
	--java=java//binaries/path: Specifies the path to javac, 
	jar, and other Java tools necessary for compilation.  
	Alternatively, the JAVA variable can be hand-edited 
	to specify the path, which would override any command-line 
	specification.
	
	--help: Lends a hand by displaying yours truly.
	
Copyright:
	Copyright (c) 2012 Text Flex

Last updated:
	2012-11-03
"

#####################
# User-defined variables
# Check them!
####################

# compiler location
JAVA=""
JAVA_VER_SRC="1.5"

####################
# Setup variables
####################

PAR_JAVA="--java"
PAR_CLEAN="--clean"
CLEAN=0
PAR_JAR="--jar"
JAR=0

# Sets the base directory to the script location
if [ "x$BASE_DIR" = "x" ] # empty string
then
	BASE_DIR=`dirname $0`
fi
cd "$BASE_DIR"
BASE_DIR="$PWD"

# Platform and GUI detection
source "$BASE_DIR"/../texttrix/trunk/build-setup.sh

##############
# Respond to user arguments

if [ $# -gt 0 ]
then
	for arg in "$@"
	do
		# reads arguments
		if [ "x$arg" = "x--help" -o "x$arg" = "x-h" ] # help docs
		then
			if [ "`command -v more`" != '' ]
			then
				echo "$HELP" | more
			elif [ "`command -v less`" != "" ]
			then
				echo "$HELP" | less
			else
				echo "$HELP"
			fi
			exit 0
			
		# Java path
		elif [ ${arg:0:${#PAR_JAVA}} = "$PAR_JAVA" ]
		then
			JAVA="${arg#${PAR_JAVA}=}"
			echo "Set to use \"$JAVA\" as the Java compiler path"
			
		# clean
		elif [ ${arg:0:${#PAR_CLEAN}} = "$PAR_CLEAN" ]
		then
			CLEAN=1
			echo "Set to clean files and exit"
			
		# build SVN changelog
		elif [ ${arg:0:${#PAR_JAR}} = "$PAR_JAR" ]
		then
			JAR=1
			echo "Set to create a JAR file"
			
		fi
	done
fi

if [ x$JAVA = x"false" ]
then
	echo "Java software doesn't appear to be installed..."
	echo "Please download it (for free!) from http://java.com."
	echo "Or if it's already installed, please add it to your"
	echo "PATH or to the JAVA variable in this script."
	read -p "Press Enter to exit this script..."
	exit 1
fi

# Appends a file separator to end of Java compiler path if none there
if [ x$JAVA != "x" ]
then
	# appends the file separator after removing any separator already
	# present to prevent double separators
	JAVA=${JAVA%\/}/
fi

#####################
# Build operations
#####################

cd "$BASE_DIR" # change to work directory

#############
# Clean files and exit
if [ $CLEAN = 1 ]
then
	CLASS_FILES=`find -name *.class`
	if [ "$CLASS_FILES" != "" ]
	then
		rm $CLASS_FILES
		echo "Removed all .class files"
	else
		echo "No .class files to remove"
	fi
	exit 0
fi

#############
# Compile Text Trix classes
echo ""
echo "Compiling the Text-Trix-modified Ostermiller Syntax Highlighter library..."
echo "Using the Java binary directory at [defaults to PATH]:"
echo "$JAVA"
JAVA_FILES=`find -path ./com/Ostermiller/Syntax/doc -prune -o -name *.java -print`
if [ "$CYGWIN" = "true" ]
then
	JAVA_FILES=`cygpath -wp $JAVA_FILES`
fi
ERR=`"$JAVA"javac -source $JAVA_VER_SRC -target $JAVA_VER_SRC $JAVA_FILES`
echo $ERR

if [ $JAR -eq 1 ]
then
	# check for any occurrences of "error", which signals a 
	# compilation error
	if [ "${ERR/error/}" == "$ERR" ]
	then
		FILES_FOR_JAR=`find -name *.class`
		JAR_FILE=oster.jar
		if [ "$CYGWIN" = "true" ]
		then
			FILES_FOR_JAR=`cygpath -wp $FILES_FOR_JAR`
		fi
		jar cf $JAR_FILE $FILES_FOR_JAR
		echo "Created $JAR_FILE jar file"
	else
		echo "Jar file not created because there were errors during compilation"
	fi
fi

exit 0
