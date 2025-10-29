/**
 * This removes entries from data tables that no longer connect to
 * any editions.
 */

const mariadb = require('mariadb')
const chalk = require('chalk')


/**
 * After backing up the schema, we use a custom function to backup
 * all tables to separate files.  Each file should be a simple CSV.
 */

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

const sanitizeDB = async () => {
    console.log(chalk.blue('Attempting to clear orphaned entries from the data in the SQE_Database Docker...'))
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

    let deleteFromTables = []

    // Spin up the orphan clearing processes
    for (table of ownedTables) {
        const tname = table.replace('_owner', '')
        console.log(chalk.blue(`Clearing orphaned data from ${tname}.`))
        const query = `
        SET foreign_key_checks = 0;

        DELETE ${tname}
        FROM ${tname}
        LEFT JOIN ${table} USING(${tname}_id)
        WHERE ${table}.edition_id IS NULL;

        SET foreign_key_checks = 1;
        `
        deleteFromTables.push({query: query, table: table, tname: tname})
    }

    // Wait for the delete processes to finish and catch any errors
    for (let i = 0, process; (process = deleteFromTables[i]); i++) {
        try {
            await pool.query(process.query)
            console.log(chalk.green(`✓ Finished clearing orphaned data from ${process.tname}.`))
        } catch(err) {
            console.error(`Error clearing orphaned data from  ${process.table} and ${process.tname}`)
            console.error(err)
            process.exit(1)
        }
    }
    console.log(chalk.green(`\n✓ The database is now clean.`))
    try {
        await pool.end()
        process.exit(0)
    } catch(err) {
        console.error(chalk.red('Could not release pool.'))
        process.exit(0)
    }
}

sanitizeDB()