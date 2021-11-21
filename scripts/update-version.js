/**
 * This will update the version in the package.json files.
 */
const args = require('minimist')(process.argv.slice(2), { boolean: true })
const chalk = require('chalk')
const fs   = require('fs')
const { runMain } = require('module')

const filename = __dirname + '/../package.json'
if (!args.t) {
    console.error(chalk.red('✗ You must supply a version tag with the -t switch.'))
    process.exit(1)
}

console.log(args);

(async _=> {
	try {
		const package = require(filename)
		fs.writeFileSync(filename, JSON.stringify({...package, version: args.t}, null, 2) , 'utf-8')
		console.log(chalk.green(`✓ Successfully updated package.json version to ${args.t}.`))
	} catch (err) {
		console.error(chalk.red(`✗ Could not updated package.json version to ${args.t}.`))
		console.log(err) 
		process.exit(1)
	}

	let sqlUpdateFile = `Changes/${args.t}/db-updates-${args.t}.sql`

	try {
		if (!fs.existsSync(sqlUpdateFile)) throw 'File not found:' + sqlUpdateFile;				// if the sql script file is gzipped, this would've exploded

		let sqlString = fs.readFileSync(sqlUpdateFile, 'utf8')
		if (!sqlString.startsWith('START TRANSACTION;') && args['wrap-SQL']) {
			// Wrap the SQL string with code required to update a version
			sqlString = 'START TRANSACTION;\n' + sqlString + 
						`SELECT @VER := "${args.t}";\n` +
						'INSERT INTO `db_version` (version, completed) VALUES (@VER, current_timestamp());\n' +
						'COMMIT;'
			console.log(chalk.green(`✓ Wrapped SQL at ${sqlUpdateFile}`));
		} else {
			sqlString = sqlString.replace(/\$CURRENT_DATABASE_VERSION/g, args.t);
		}
		fs.writeFileSync(sqlUpdateFile, sqlString, 'utf-8')
		
		console.log('Zipping the SQL file...');
		await run('gzip', sqlUpdateFile);
		
		console.log(chalk.green(`✓ Successfully updated ${sqlUpdateFile} database version to ${args.t}.`))    
	} catch (err) {
		console.error(chalk.red(`✗ Could not update the file ${sqlUpdateFile} to database version to ${args.t}.`))
		console.log(err)
	}

	process.exit(0)
})();