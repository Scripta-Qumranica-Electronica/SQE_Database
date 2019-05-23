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
  var package = require(filename)
  fs.writeFileSync(filename, JSON.stringify({...package, version: args.t}, null, 2) , 'utf-8')
  console.log(chalk.green(`✓ Successfully updated package.json version to ${args.t}.`))
  process.exit(0)
} catch (err) {
  console.log(err)
  process.exit(1)
}