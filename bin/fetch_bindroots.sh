#!/bin/bash
#
#  In my mailcleaner I have bind installed directly on the system so I dont have issues with too many requests for RBL queries.
#
#  Script to update the bind roots file.  Once in a while these change and I have not seen an announcement for it.
#  So this runs daily to update the roots file.
#
#  I had an issue where bind would break if the db.root file failed to download so there is a check in place to make sure the file downloads.
#
#  Thanks, Thomas Nelson (forum name uncltom)

cd /etc/bind
wget -q http://www.internic.net/domain/named.cache -O db.root.download
#  Check if the file downloaded, replace the file if it did.
if [ -s db.root.download ]
then
        rm db.root
        mv db.root.download db.root
        /etc/init.d/bind9 restart
# If http download didnt work switch to ftp as a backup.
else
        wget -q ftp://www.internic.net/domain/named.cache -O db.root.download
        # Check again if the file downloaded, replace the file if it did.
        if [ -s db.root.download ]
        then
                rm db.root
                mv db.root.download db.root
                /etc/init.d/bind9 restart
        fi
fi
# If neither method worked then stay with the old file.
