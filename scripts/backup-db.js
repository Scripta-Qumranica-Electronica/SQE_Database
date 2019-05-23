const { spawn } = require('child_process')
const fs = require('fs')
const mariadb = require('mariadb')
const chalk = require('chalk')

const projectBaseDir = __dirname + '/..'
const dataDir = `${projectBaseDir}/data`

const getTables = async (pool) => {
    console.log(chalk.blue('\nAnalyzing tables:'))
    return new Promise(async (resolve, reject) => {
        try {
            const rows = await pool.query(`
                SELECT table_name AS Tables_in_SQE_DEV
                FROM information_schema.tables
                WHERE table_type = 'BASE TABLE' AND table_schema='SQE_DEV'
                ORDER BY table_name ASC`)
            resolve(rows.map(x => x['Tables_in_SQE_DEV']))
        } catch(err) {
            console.log(chalk.red(`✗ The backup has failed while trying to save individual tables.`))
            reject(chalk.red('✗ Database connection error.'))
        }
    })
}

const backupTable = async (table) => {
    return new Promise(async (resolve, reject) => {
        console.log(chalk.blue(`Backing up ${table} to ${table}.sql.`))
        const cmd = spawn('docker', ['exec', '-i', 'SQE_Database', '/usr/bin/mysqldump', '--skip-dump-date', '-u', 'root', '-pnone', '-h', '127.0.0.1', '-P', '3306', 'SQE_DEV', table], { encoding : 'utf8', cwd: projectBaseDir })
        cmd.stdout.pipe(fs.createWriteStream(`${dataDir}/${table}.sql`))
        cmd.on('exit', async (code/*, signal*/) => {
            if (code !== 0) reject(new Error(chalk.red(`✗ Failed while backing up ${table}.`)))
            else {
                resolve(chalk.green(`✓ The table ${table} has been copied.`))
            }
        })
    })
}

const backupSchema = async () => {
    return new Promise( (resolve, reject) => {
        console.log(chalk.blue(`Backing up schema to schema.sql.`))
        const cmd = spawn('docker', ['exec', '-i', 'SQE_Database', '/usr/bin/mysqldump', '--no-data', '--skip-dump-date', '--routines', '--events', '-u', 'root', '-pnone', 'SQE_DEV'], { encoding : 'utf8', cwd: projectBaseDir })
        cmd.stdout.pipe(fs.createWriteStream(`${dataDir}/1-schema.sql`))
        cmd.on('exit', async (code/*, signal*/) => {
            if (code !== 0) reject(new Error(chalk.red(`✗ Failed backing up schema.`)))
            else {
                resolve(chalk.green(`✓ The schema has been copied.`))
            }
        })
    })
}

const backupDB = async () => {
    console.log(chalk.blue('Attempting to backup the default data from SQE_Database Docker...'))
    console.log(chalk.blue('\tConnecting to DB.  This may take a moment.'))
    const pool = mariadb.createPool({
        host: 'localhost',
        port: 3307,
        user:'root',
        password: 'none',
        database: 'SQE_DEV',
        connectionLimit: 60
    })

    try {
        console.log(await backupSchema())
        for (table of await getTables(pool)) {
            console.log(await backupTable(table))
        }
        process.exit(0)
    } catch(err) {
        console.error(err)
        process.exit(1)
    }
}

backupDB()
