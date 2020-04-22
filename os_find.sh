##Determine if your OS is eligible 1
distro=$(cat /etc/os-release | grep -w "ID=*" | sed "s/ID=//")
version=$(cat /etc/os-release | grep -w "VERSION_ID=*" | sed "s/VERSION_ID=//" |sed  "s/\"//g" | sed "s/\.//g")
os_like=$(cat /etc/os-release | grep -w "ID_LIKE=*" | sed "s/ID_LIKE=//")
echo "Your distro details: "
if [[ $os_like -eq "debian" ]]
    then
        echo "ID_LIKE=debian"
        if [[ $distro -eq "ubuntu" ]]
            then
                echo "ID=ubuntu"
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
fi
