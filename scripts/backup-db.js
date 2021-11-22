const spawn = require('child_process').spawn
const chalk = require('chalk')

const backup = async () => {
    try {
        await runCMD('\nBacking up the new database.\n', 'docker', ['exec', 'SQE_Database', 'mariabackup', '--backup', '--target-dir=/backup/', '--user=root', '--password=none'])
        // await runCMD('\nPreparing the new database backup.\n', 'docker', ['exec', 'SQE_Database', 'mariabackup', '--prepare', '--target-dir=/backup/'])
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