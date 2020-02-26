
    while read $line
    do 
        ssh root@$line "dpkg -l | grep $1"
    done < servers.txt
