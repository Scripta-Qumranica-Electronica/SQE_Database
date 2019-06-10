const fs = require('fs')
const fse = require('fs-extra')
const {promisify} = require("util")
const chalk = require('chalk')

const projectBaseDir = __dirname + '/..'
const dataDir = `${projectBaseDir}/data`

const clearDataDir = async () => {
    try {
        const readdir = promisify(fs.readdir)
        const items = await readdir(dataDir)
        const whitelistFiles = ['1-schema.sql', 'affine_transform.sql', 'multiply_matrix.sql']
        const deleteFiles = items.filter(x => whitelistFiles.indexOf(x) === -1)
        await Promise.all(deleteFiles.map(async x => {
            console.log(chalk.yellow('Removing: ' + x))
            await fse.remove(`${dataDir}/${x}`)
        }))
        console.log(chalk.green('Finished deleting unneeded files from the data directory.'))
        process.exit(0)
    } catch {
        console.log(chalk.red('Failed deleting unneeded files from the data directory.'))
        process.exit(1)
    }
}

clearDataDir()