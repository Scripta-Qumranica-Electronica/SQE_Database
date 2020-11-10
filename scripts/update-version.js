/**
 * This will update the version in the package.json files.
 */
const args = require('minimist')(process.argv.slice(2))
const chalk = require('chalk')
const fs   = require('fs')

const filename = __dirname + '/../package.json'
if (!args.t) {
    console.error(chalk.red('✗ You must supply a version tag with the -t switch.'))
    process.exit(1)
} 

try {
    const package = require(filename)
    fs.writeFileSync(filename, JSON.stringify({...package, version: args.t}, null, 2) , 'utf-8')
    console.log(chalk.green(`✓ Successfully updated package.json version to ${args.t}.`))
} catch (err) {
    console.error(chalk.red(`✗ Could not updated package.json version to ${args.t}.`))
    console.log(err)
    process.exit(1)
}

const sqlUpdateFile = `Changes/${args.t}/db-updates-${args.t}.sql`
try {
    const sqlString = fs.readFileSync(sqlUpdateFile, 'utf8')
    fs.writeFileSync(sqlUpdateFile, sqlString.replace(/\$CURRENT_DATABASE_VERSION/g, args.t) , 'utf-8')
    console.log(chalk.green(`✓ Successfully updated ${sqlUpdateFile} database version to ${args.t}.`))
} catch (err) {
    console.error(chalk.red(`✗ Could not updated the file ${sqlUpdateFile} to database version to ${args.t}.`))
    console.log(err)
    process.exit(1)
}

process.exit(0)