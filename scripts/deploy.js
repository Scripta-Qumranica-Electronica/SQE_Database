const spawn = require('child_process').spawn
const chalk = require('chalk')
const args = require('minimist')(process.argv.slice(2))

if (args.h) {
    console.log(`
Please provide a version name with the -t switch
and a commit message with the -m switch.

You may avoid the database sanitizing with the -n switch.
(This will basically just copy the last database version through.)
    `)
    process.exit(1)
}

if (!args.t || !args.m) {
    console.error(chalk.red('✗ You must supply a tag with the -t switch and a commit message with the -m switch.'))
    process.exit(1)
}

const deploy = async () => {

    // Use the following if we need some os specific accomodations.
    // const os = require('os')
    // let node = ''
    // if (os.platform() === 'win32') {
    // node = 'node.cmd'
    // } else {
    // node = 'node'
    // }

    // Grab the input variables and get started
    const tag = args.t
    const msg = args.m

    console.log(chalk.blue(`Deploying build with version ${tag} and message: ${msg}`))

    try {
        // Backup the database
        if (!args.n) await runCMD('\nSanitizing database.\n', 'node', ['scripts/sanitize-db.js'])
        if (!args.n) await runCMD('\nBacking database up\n.','node', ['scripts/backup-db.js'])
        if (!args.n) await runCMD('\nBuilding the docker image.\n', 'docker', ['build', '--no-cache', '-t', 'qumranica/sqe-database:latest', '.'])

        // Update version and push up to GitHub
        await runCMD('\nCleaning unneeded data files.\n', 'node', ['scripts/clear-data-dir.js'])
        await runCMD('\nUpdating version in package.json.\n', 'node', ['scripts/update-version.js', '-t', tag])
        await runCMD('\nAdding files for commit.\n', 'git', ['add', '-A'])
        await runCMD('\nCommitting changes.\n', 'git', ['commit', '-m', msg])
        await runCMD(`\nTagging the version at ${tag}.\n`, 'git', ['tag', tag])
        await runCMD('\nPushing changes to remote.\n', 'git', ['push'])
        await runCMD('\nPushing the tag to remote.\n', 'git', ['push', 'origin', tag])

        // Build the Docker image and push it to Docker Hub
        if (!args.n) await runCMD(`\nTagging the docker image as ${tag}.\n`, 'docker', ['tag', 'qumranica/sqe-database:latest', `qumranica/sqe-database:${tag}`])
        if (!args.n) await runCMD('\nPushing the docker image to docker hub.\n', 'docker', ['push', 'qumranica/sqe-database'])

        // Done
        console.log(chalk.green(`\n✓ Successfully pushed version ${tag} to ${!args.n ? 'docker hub and to ' : ''}github.\n`))
        process.exit(0)
    } catch(err) {
        await spawnAsync('git', ['tag', '-d', tag])
        console.error(chalk.red('\n✗ Deploy failed.\n'))
        console.error(err)
        process.exit(1)
    }
}

// A handy Promise based wrapper for child_process.spawn
const runCMD = async (title, cmd, args) => {
    return new Promise((resolve, reject) => {
        console.log(chalk.blue(`${title}.`))
        try {
            const proc = spawn(cmd, args, {stdio: [null, process.stdout, process.stderr], cwd: './'})
            proc.on('exit', (code/*, signal*/) => {
                if (code === 0) resolve(proc)
                else throw new Error(code)
            })
        } catch(err) {
            reject(err)
        }
    })
}

deploy()
