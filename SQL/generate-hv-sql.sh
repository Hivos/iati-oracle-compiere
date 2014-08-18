#!/bin/bash

# This file is part of the IATI, partnerdump AFFM/Compiere project.
# Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.


echo 'This script creates an SQL script that can be used to create install script, iati-partnerdump-affm-compiere/SQL/output/hv_all_views.sql

'
directory=.

scan_directory()
{
    echo 'Found files:'
    for file in "$1"/*.sql
    do
        if [ -f "$file" ]
        then
            process_file "$file"
        fi

        if [ -d "$file" ]
        then
            scan_directory "$file"
        fi
    done
}
process_file()
{
echo $file
cat $file >> $directory/output/hv_all_views.sql
echo '
' >> $directory/output/hv_all_views.sql

}

mkdir $directory/output
rm $directory/output/hv_all_views.sql
scan_directory $directory

echo 'done'

