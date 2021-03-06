#!/bin/sh
#
# This is a mini tool which can output the detail memory usage
# by analyzing /proc/meminfo.
#
# OS 		: CentOS-7.2-1151
# Kernel 	: 3.10.0-327.el7.x86_64
#
# Author 	: ZhiGang Gao
#
# The source code in this file can be freely used, adapted,
# and redistributed in source or binary form, so long as an
# acknowledgment appears in derived source files.
#

cp -f /proc/meminfo /tmp/meminfo
get_number_from_line()
{
	temp=`echo $1|sed -e "s/$2:\(.*\)kB/\1/g"`
	echo $temp
}
get_line()
{
	 grep "^${1}:" /tmp/meminfo
}

# Total
MemTotal_Line=`get_line MemTotal`
MemTotal_Number=`get_number_from_line "$MemTotal_Line" MemTotal`
#
MemFree_Line=`get_line MemFree`
MemFree_Number=`get_number_from_line "$MemFree_Line" MemFree`
#
MemAvailable_Line=`get_line MemAvailable`
MemAvailable_Number=`get_number_from_line "$MemAvailable_Line" MemAvailable`


######  NR_FILE_PAGES 
# Buffers
Buffers_line=`get_line Buffers`
Buffers_Number=`get_number_from_line "$Buffers_line" Buffers`
#Cached
Cached_line=`get_line Cached`
Cached_Number=`get_number_from_line "$Cached_line" Cached`
#NR_FILE_PAGES
NR_FILE_PAGES=`expr $Cached_Number + $Buffers_Number`

Shmem_line=`get_line Shmem`
Shmem_Number=`get_number_from_line "$Shmem_line" Shmem`
RealFile_Num=`expr $Cached_Number - $Shmem_Number`

Active_file_line=`get_line Active\(file\)`
Active_file_Number=`get_number_from_line "$Active_file_line" Active\(file\)`
Inactive_file_line=`get_line Inactive\(file\)`
Inactive_file_Number=`get_number_from_line "$Inactive_file_line" Inactive\(file\)`
FileTotal_Num=`expr $Active_file_Number + $Inactive_file_Number`
FileOthers_Num=`expr $NR_FILE_PAGES - $FileTotal_Num - ${Shmem_Number}`

# Slab
Slab_line=`get_line Slab`
Slab_Number=`get_number_from_line "$Slab_line" Slab`
#AnonPages
AnonPages_line=`get_line AnonPages`
AnonPages_Number=`get_number_from_line "$AnonPages_line" AnonPages`
AnonPages_Total_Num=`expr $AnonPages_Number + $Shmem_Number`
Active_anon_line=`get_line Active\(anon\)`
Active_anon_Number=`get_number_from_line "$Active_anon_line" Active\(anon\)`
Inactive_anon_line=`get_line Inactive\(anon\)`
Inactive_anon_Number=`get_number_from_line "$Inactive_anon_line" Inactive\(anon\)`
AnonTotal_Num=`expr $Active_anon_Number + $Inactive_anon_Number`
AnonOthers_Num=`expr $AnonPages_Total_Num - $AnonTotal_Num`

# Mapped
Mapped_line=`get_line Mapped`
Mapped_Number=`get_number_from_line "$Mapped_line" Mapped`
NamedMap_Num=`expr $Mapped_Number - $AnonOthers_Num`

# PageTables
PageTables_line=`get_line PageTables`
PageTables_Number=`get_number_from_line "$PageTables_line" PageTables`
#KernelStack
KernelStack_line=`get_line KernelStack`
KernelStack_Number=`get_number_from_line "$KernelStack_line" KernelStack`

#
Reclaimable_Num=`expr $MemAvailable_Number - $MemFree_Number`
#
Used_Num=`expr $MemTotal_Number - $MemFree_Number`
#
Used_Others_Num=`expr $Used_Num - ${NR_FILE_PAGES} -  ${Slab_Number} - ${AnonPages_Number} - ${PageTables_Number} - ${KernelStack_Number}`

green()
{
	echo "\033[32m${1}\033[0m"
}
red()
{
	echo "\033[31m${1}\033[0m"
}
yellow()
{
	echo "\033[33m${1}\033[0m"
}
blue()
{
	echo "\033[34m${1}\033[0m"
}

echo -e "`blue "$MemTotal_Line"`"
# Free
echo -e "\tMemAvailable\t`green "${MemAvailable_Number}"`\tkb"
## second ladder
echo -e "\t\tMemFree    \t`green "${MemFree_Number}"`\tkb"
echo -e "\t\tReclaimable\t`yellow "${Reclaimable_Num}"`\tkb"
# Used
echo -e "\tUsed(and rec)\t`red "${Used_Num}"`\tkb"

## second ladder
# Files
echo -e "\t\tFiles     \t`red "${NR_FILE_PAGES}"`\tkb = Cached `red "${Cached_Number}"` kb + Buffers `red "${Buffers_Number}"` kb"
echo -e "\t\t\tActive File  \t`red "${Active_file_Number}"`\tkb"
echo -e "\t\t\tInactive File\t`red "${Inactive_file_Number}"`\tkb"
echo -e "\t\t\tShare Memory \t`red "${Shmem_Number}"`\tkb"
echo -e "\t\t\tMis Count    \t`yellow "${FileOthers_Num}"`\tkb"

# Anon
echo -e "\t\tAnon      \t`red "${AnonPages_Total_Num}"`\tkb = AnonPages `red "${AnonPages_Number}"` kb + Share Memory `red "${Shmem_Number}"` kb"
echo -e "\t\t\tActive Anon\t`red "${Active_anon_Number}"`\tkb"
echo -e "\t\t\tInactive Anon\t`red "${Inactive_anon_Number}"`\tkb"
echo -e "\t\t\tMis Count    \t`yellow "${AnonOthers_Num}"`\tkb"

#echo -e "\t\tMapped     \t`red "${Mapped_Number}"`\tkb"
#echo -e "\t\t\tAnonOthers\t`yellow "${AnonOthers_Num}"`\tkb"
#echo -e "\t\t\tNamed Map \t`yellow "${NamedMap_Num}"`\tkb"

echo -e "\t\tSlab       \t`red "${Slab_Number}"`\tkb"
echo -e "\t\tPageTables \t`red "${PageTables_Number}"`\tkb"
echo -e "\t\tKernelStack\t`red "${KernelStack_Number}"`\tkb"
echo -e "\t\tOthers   \t`yellow "${Used_Others_Num}"`\tkb"
