iati-partnerdump-affm-compiere
==============================

PL/SQL code to do IATI.org XML exports from an Oracle database running Compiere/AFFM

This code is provided as an example implementation. It shows how to export Compiere/AFFM data to IATI.org XML format. Copy, paste and learn it is not meant as a drop-in installable version.

The code written for use with Oracle 11 Express Edition, DO NOT ATTEMPT TO RUN THIS IN YOUR PRODUCTION DATABASE. Rather install on a separate reporting server.


========================================================================

### Viewing results:

    https://www.iatiregistry.org/publisher/stichting_hivos
     

### Install instruction
Assumes you have an Oracle 11 instance running with a copy of your production data in the Compiere schema. I recommend to use SQL Developer to run these scripts. As Oracle user COMPIERE run:

    1. create-tables.sql
    2. create-user.sql
    3. SQL/output/hv_all_views.sql



### Running the export

    exec jasper.hv_iati202_buza.mainprogram;
    exec jasper.hv_iati202_buza.orgfile;

Dumps xml to /home/oracle/iati202buza.xml


### Altering code
Build script runs from Linux, cd to the `SQL` folder then run `./generate-hv-sql.sh`, this will create a new SQL/output/hv_all_views.sql file that can be ran from SQL Developer.


### Partner dump
The code also includes the more comprehensive `partner dump`. This export can be used the export the Compiere/AFFM database to XML format for use in other applications. It also includes a Google Geocode lookup (with cache). You can remove the code if you only need iati.
