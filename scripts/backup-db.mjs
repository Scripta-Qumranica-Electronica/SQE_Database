import { username } from 'username'
import { createRequire } from 'module'
const require = createRequire(import.meta.url)
const spawn = require('child_process').spawn
const chalk = require('chalk')

const backup = async () => {
    try {
        const current_user = await username()
        await runCMD('\nDeleting existing data dir.\n', 'docker', ['exec', 'SQE_Database', '/bin/bash', '-c', 'rm -rf /backup/*'])
        await runCMD('\nBacking up the new database.\n', 'docker', ['exec', 'SQE_Database', 'mariabackup', '--backup', '--target-dir=/backup/', '--user=root', '--password=none'])
        // TODO: we need to run a different command to do this on Windows
        await runCMD(`\nMaking the backups accessible to ${current_user}.\n`, 'sudo', ['chown', '-R', `${current_user}:${current_user}`, './data'])
    } catch (err) {
        console.error(chalk.red('\n✗ Failed to backup the new database.\n'))
        console.error(err)
        process.exit(1)
    }
}

// A handy Promise based wrapper for child_process.spawn
const runCMD = async (title, cmd, args) => {
    return new Promise((resolve, reject) => {
        console.log(chalk.blue(`${title}.`))
        try {
            const proc = spawn(cmd, args, { stdio: [null, process.stdout, process.stderr], cwd: './' })
            proc.on('exit', (code/*, signal*/) => {
                if (code === 0) resolve(proc)
                else throw new Error(code)
            })
        } catch (err) {
            reject(err)
        }
    })
}

backup()