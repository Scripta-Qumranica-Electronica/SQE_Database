/*    
    This script runs some basic sanity checks before attempting to run the deploy.js script, just in case the state of affairs is not exactly as it "should" be.
    Running the deploy.js script without these checks might cause things to go horribly wrong. Following checks are performed:

    1. Make sure script is NOT run on a Windows platform
    2. Check if you're logged on to Github
    3. Get latest version of SQE_Database from Docker Hub
    4. Verify that the tag version is greater than the latest on Docker Hub    
    5. Make sure SQE_Database Docker container is running and its using port 3307
    6. If a container with id "qumranica/sqe_database" is found but the name is not "SQE_Database", rename it (Docker Desktop for Windows gives the containers random names!)
    
    Author: Hannu Kalavainen
    Version: 1.0 (20 Nov 2021)
    License: CC0    
*/

const { exec } = require('child_process');
const fs = require('fs');
const log   = console.log;

const convertVersionStringToArray = (version) => {
    return version.split('.').map(e => parseInt(e, 10));
}
/*
    Compare two version strings and return -1 if "a" is greater, 1 if "b" is greater and in case of an error return 0
*/
const compareVersions = (a, b) => {                                // a:String, b:String > Integer 
    if (a.length != 3 || a.length != 3) return 0;
    if (a[0] > b[0]) return -1;
    if (a[0] == b[0] && a[1] > b[1]) return -1;    
    if (a[0] == b[0] && a[1] == b[1] && a[2] > b[2]) return -1;
    return 1;
}

const run = (shellCmd, params) => {         // shellCmd:String, params:String > { status:String, msg:String }
    return new Promise((resolve, reject) => {
        exec(shellCmd + ' ' + params, (error, stdout, stderr) => {
            if (error) {
                return reject({ status:'ERR', msg:error.message, stderr });                
            }            
            resolve({ status:'ok', msg:stdout.toString(), stderr });
        });
    }).catch(e => {
        log(e);
    });
}

const checkLatestDockerHubVersion = async _ => {
    return new Promise(async (resolve, reject) => {
        const result = await run('wget', '-O- -q https://registry.hub.docker.com/v2/repositories/qumranica/sqe-database/tags');
        if (result.status == 'ok') {
            const json = JSON.parse(result.msg);            
            const sortedVersions = json['results'].map(e => convertVersionStringToArray(e.name)).filter(e => e.length == 3).sort(compareVersions);            
            resolve(sortedVersions[0]);
        }
    }).catch(e => {
        log('Error in promise');
        log(e);
        reject();
    });    
}

const checkDockerStatus = _ => {
    return new Promise(async (resolve, reject) => {
        const res   = await run('docker', 'container ls');     
        const lines = res.msg.split('\n').filter(Boolean);
        
        let   containers = 0;                           // number of running containers with ID 'qumranica/sqe-database'
        for (const l of lines) {
            const cols = l.split(/\s+/);

            if (cols[1].startsWith('qumranica/sqe-database')) {
                containers++;

                const port = cols.find(e => e.includes(':3307->3306'));
                if (port == null) return reject('Current qumranica/sqe-database Docker container must be forwarded to port 3307!');                                        

                if (cols[cols.length - 1] != 'SQE_Database') {
                    log('The qumranica/sqe-database is not named correctly!');
                    try {
                        await run('docker', 'rename ' + cols[cols.length - 1] + ' SQE_Database');                    
                    } catch (e) {
                        log('Error in renaming Docker container!');
                        log(e);
                    }          
                    return reject('Rename attempted, please re-run the script!');              
                }
            }            
        }

        if (containers != 1) return reject('Exactly one container with ID qumranica/sqe-database should be running. Found ' + containers + ' containers!');
        resolve('OK');
    }).catch(e => {
        log(e);
    });
}

const main = async (versionTag) => {
    log();
    log('Checking preconditions for running SQE_Database deploy.');

    const checks = 6;       // total checks
    let   c = 1;            // current check number
    
    // 1. check platform:
    log(`[${c++}/${checks}] Check platform:`, process.platform);
    if (process.platform == 'win32') {
        log('This script cannot be run on win32 platform!');
        return null;    
    }

    // check if the correct sql script file exists
    log(`[${c++}/${checks}] Check if SQL script file is found...`);
    const sqlUpdateFile = `Changes/${versionTag}/db-updates-${versionTag}.sql`;
    if (!fs.existsSync(sqlUpdateFile)) {
        log('SQL file not found:' + sqlUpdateFile);
        return null;
    }

    // 2. check if logged on to Git
    log(`[${c++}/${checks}] Check if logged on to GitHub...`);
    const result = await run('gh', 'auth status');    
    if (!(result && result.status == 'ok' && result.stderr.startsWith('github.com'))) {
        log('Not logged on to GitHub!');
        return null;
    } 
    
    // 3. check latest docker hub version:        
    log(`[${c++}/${checks}] Check latest docker hub version...`);
    const dockerVersion = await checkLatestDockerHubVersion();    
    if (dockerVersion == null) return null;
    log('Latest qumranica/sqe-database container version in Docker hub:', dockerVersion.join('.'));    

    // 4. check that tag given in argument -t is greater than the version in docker hub
    log(`[${c++}/${checks}] Check that the current version tag is greater than Docker hub version...`);
    if (compareVersions(convertVersionStringToArray(versionTag), dockerVersion) != -1) {
        log('Given tag is equal or less than the current version on Docker Hub!');
        return null;
    }    
    log('Given tag is greater than the current version on Docker Hub, good!');
    
    // 5. and 6. check that the Docker container is up and running, port and name are correct
    //log(`[${c++}/${checks}] Check that Docker is up and running...`);
    //const dockerStatus = await checkDockerStatus(); 
    
    //if (dockerStatus == 'OK') {
    //    log(`[${c++}/${checks}] All checks passed!`);
    //    log('')
    //    return true;
    //}
    return true;    
}

module.exports = { main };