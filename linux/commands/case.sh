read -rp "y/n " reply
echo " "
while true
do
    case "${reply}" in
        y|Y)
            echo "True"
            break
            ;;
        n|N)
            echo "False"
            break
            ;;
        *)
            echo "invalid character"
    esac
done