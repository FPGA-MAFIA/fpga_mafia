# 

setting your personal PC as a server to run sanity action - gate keeper for Submit

1. cd ~/../..
1. mkdir actions-runner
1. cd actions-runner
1. curl -o actions-runner-win-x64-2.301.1.zip -L https://github.com/actions/runner/releases/download/v2.301.1/actions-runner-win-x64-2.301.1.zip
1. if [ "$(shasum -a 256 actions-runner-win-x64-2.301.1.zip | awk '{print $1}')" != "e83b27af969cb074ca53629b340f38d20e528071f4d6f9d4ba7819dace689ece" ]; then throw 'Computed checksum did not match'; fi
1. ./config.cmd --url https://github.com/amichai-bd/fpga_mafia --token ATKK63ZZDRXTGTP3DHJQ233D5NQJI
    1. Would you like to run the runner as service? (Y/N) [press Enter for N] N  /Press "N"
1. ./run.cmd



still WIP to get this to run on pull request & push