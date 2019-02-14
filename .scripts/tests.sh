ED='\033[0;31m'
NC='\033[0m' # No Color
printf "I ${RED}love${NC} Stack Overflow\n"
echo -e "I ${RED}love${NC} Stack Overflow"
tput setaf 1; echo "this is red text"
echo -e "\033[1;31m This is red text \033[0m"


