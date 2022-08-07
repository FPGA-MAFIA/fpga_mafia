# Simple Git cheat-sheet - Minimal flow to add to the project 
## (1) Clone from repository  
git clone https://github.com/amichai-bd/rvc_asap.git

## (2) Create a new branch  
git checkout -b "branch_name"
  
## (3) Modified, staging and commits  
git add .
git commit -m 'your commit'  
  
## (4) Pull from origin/master (to make sure no conflicts)  
git pull origin master
  
## (5) Push to origin
git push origin "branch_name"

## (6) Add a pull request
From "https://github.com/" add a pull request by "Pull requests->New pull request"