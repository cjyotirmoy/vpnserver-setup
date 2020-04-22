##Determine if your OS is eligible 1
distro=$(cat /etc/os-release | grep -w "ID=*" | sed "s/ID=//")
version=$(cat /etc/os-release | grep -w "VERSION_ID=*" | sed "s/VERSION_ID=//" |sed  "s/\"//g" | sed "s/\.//g")
type=$(cat /etc/os-release | grep -w "ID_LIKE=*" | sed "s/ID_LIKE=//")
if [[ "$type" == "debian" ]]
then
        echo "Your distro details: "
        echo "ID_LIKE=$type"
        if [[ "$distro" == "ubuntu" ]]
        then
            echo "ID=$distro"
            if [[ $version -ge "1910" ]]
            then
                echo "Version=19.10"
                flag=1
            else 
                echo "Version is older than 19.10"
                flag=2
            fi
        else
            echo "ID=$distro"
            flag=2
        fi
else
    echo "sorry we don't support your distro: $distro"
    echo "If you would like to contribute for testing for your distro kindly contact us"
    cat /etc/os-release > ~/Documents/distroinfo.txt
fi
