/**
 * Move all data from source edition to target edition.
 * All preexisting data in the target edition will be overwritten.
 */

const mariadb = require('mariadb')
const chalk = require('chalk')

const cli_args = process.argv.slice(2)

if (cli_args.length != 2) {
    console.log(`You have provided ${cli_args.length} command line arguments. You must provide the src edition_id and the target edition_id `)
    process.exit(1)
}

const src_edition_id = cli_args[0]
const tgt_edition_id = cli_args[1]

console.log(`Moving all data from ${src_edition_id} to ${tgt_edition_id}`)

// Default settings
const tableBlackList = ['single_action', 'main_action', 'user_email_token']
//const superTables = ['artefact', 'col', 'line', 'sign', 'scroll']

const getOwnedTables = async (pool) => {
    console.log(chalk.blue('\nAnalyzing tables:'))
    return new Promise(async (resolve, reject) => {
        try {
            const rows = await pool.query(`
                SELECT table_name AS ownedTable
                FROM information_schema.tables
                WHERE table_type = 'BASE TABLE' AND table_schema='SQE' AND table_name LIKE "%_owner"
                ORDER BY table_name ASC`)
            resolve(rows.map(x => x.ownedTable))
        } catch(err) {
            console.log(chalk.red(`✗ The backup has failed while trying to save individual tables.`))
            reject('Database connection error.')
        }
    })

}

const copyEdition = async () => {
    console.log(chalk.blue('Attempting to sanitize the data in the SQE_Database Docker...'))
    console.log(chalk.blue('Connecting to DB.  This may take a moment.'))
    const pool = mariadb.createPool({
    host: 'localhost',
    port: 3307,
    user:'root',
    password: 'none',
    database: 'SQE',
    connectionLimit: 80,
    multipleStatements: true
    })
    console.log(chalk.green('✓ Connected to DB.'))
    let ownedTables

    try {
        ownedTables = await getOwnedTables(pool, 0)
    } catch(err) {
        console.error(chalk.red('✗ Could not get tables from the database.\n'))
        console.error(err)
        process.exit(1)
    }

    // Spin up the delete processes
    for (table of ownedTables) {
        const tname = table.replace('_owner', '')        
        console.log(chalk.blue(`Deleting existing entried from ${table}.`))
        const delete_query = `
        SET foreign_key_checks = 0;

        DELETE ${table}
        FROM ${table}
        WHERE edition_id = ${tgt_edition_id};

        SET foreign_key_checks = 1;
        `
        
        const delete_success = await pool.query(delete_query)

        console.log(chalk.blue(`Moving all entries in ${table} from ${src_edition_id} to ${tgt_edition_id}.`))
        const copy_query = `
        SET foreign_key_checks = 0;

        INSERT INTO ${table} (edition_id, edition_editor_id, ${tname}_id)
        SELECT ${tgt_edition_id}, ${tgt_edition_id}, ${tname}_id
        FROM ${table}
        WHERE edition_id = ${src_edition_id};

        SET foreign_key_checks = 1;
        `

        const copy_success = await pool.query(copy_query)
    }

    console.log(chalk.green(`\n✓ Finished copying ${src_edition_id} to ${tgt_edition_id}.`))
    try {
        await pool.end()
        process.exit(0)
    } catch(err) {
        console.error(chalk.red('Could not release pool.'))
        process.exit(0)
    }
}

copyEdition()