until [ ! -z "$PLOP" ]; do
    echo -n 'enter value here: '
    read PLOP
done

echo "Good ... PLOP is $PLOP"

chmod +x /usr/src/app/dockerStart.sh

./dockerStart.sh
