#!/bin/bash 
# THis Script ignore Tag name if you update new image use same name with diff tag 
# if you create new run new image use diff name previouse image so this script easy to manage docker images
declare -A imagesCount

abs() {
    local num=$1
    echo $(( num < 0 ? -num : num ))
}


for i in $( docker images | awk 'NR != 1 { print $1 }'); do 
    (( imagesCount["$i"]++ ))
done

for key in "${!imagesCount[@]}"; do
    if [ ${imagesCount[$key]} -ge 4 ]; then
        numToDelete=$(abs $(( ${imagesCount[$key]} - 3 ))) 
        for del in $(docker images | awk 'NR != 1 && $1 == "'"$key"'" { print $1 ":" $2 }' | tail -n $numToDelete ); do
            echo "Deleting image: $del"
            docker image rm -f "$del" || echo "Failed to delete image $del"
        done
    fi
done
