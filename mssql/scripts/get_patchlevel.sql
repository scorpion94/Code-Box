SELECT SERVERPROPERTY('ProductLevel') as SP_installed, 
SERVERPROPERTY('ProductVersion') as Version,
SERVERPROPERTY('ProductUpdateLevel') as ProductUpdate_Level, 
SERVERPROPERTY('ProductUpdateReference') as KB_Number;