/**
 * This does a good job, but we still should have a way to clean out
 * the "super" tables, like scroll, artefact, col, etc. when they
 * are orphaned due to deleted user data.
 */

const mariadb = require('mariadb')
const chalk = require('chalk')

// Default settings
const tableBlackList = ['user_sessions', 'sqe_session', 'single_action', 'main_action', 'user_email_token']
//const superTables = ['artefact', 'col', 'line', 'sign', 'scroll']

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

    let deleteFromTables = []

    // Delete the custom ROIs
    console.log(chalk.blue('Sanitizing custom ROIs.'))
    let query = `
    SET foreign_key_checks = 0;

    DELETE roi_position
    FROM roi_position
    JOIN sign_interpretation_roi USING(roi_position_id)
    JOIN sign_interpretation_roi_owner USING(sign_interpretation_roi_id)
    JOIN edition_editor USING(edition_editor_id)
    WHERE user_id != 1;

    DELETE roi_shape
    FROM roi_shape
    JOIN sign_interpretation_roi USING(roi_shape_id)
    JOIN sign_interpretation_roi_owner USING(sign_interpretation_roi_id)
    JOIN edition_editor USING(edition_editor_id)
    WHERE user_id != 1;

    SELECT @max := MAX(roi_position_id)+ 1 FROM roi_position;
    PREPARE stmt FROM CONCAT('ALTER TABLE roi_position AUTO_INCREMENT = ', @max OR 1);
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SELECT @max := MAX(roi_shape_id)+ 1 FROM roi_shape;
    PREPARE stmt FROM CONCAT('ALTER TABLE roi_shape AUTO_INCREMENT = ', @max OR 1);
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET foreign_key_checks = 1;
    `

    deleteFromTables.push({query: pool.query(query), table: 'custom', tname: 'ROI\'s'})

    // Spin up the delete processes
    for (table of ownedTables) {
        const tname = table.replace('_owner', '')
        console.log(chalk.blue(`Sanitizing ${table} and ${tname}.`))
        const query = `
        SET foreign_key_checks = 0;

        DELETE ${table}
        FROM ${table}
        JOIN edition_editor USING(edition_editor_id)
        WHERE edition_editor.user_id != 1;

        DELETE ${tname}
        FROM ${tname}
        LEFT JOIN ${table} USING(${tname}_id)
        WHERE ${table}.edition_editor_id is null;

        SELECT @max := MAX(${tname}_id)+ 1 FROM ${table};
        PREPARE stmt FROM CONCAT('ALTER TABLE ${table} AUTO_INCREMENT = ', @max OR 1);
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @max := MAX(${tname}_id)+ 1 FROM ${tname};
        PREPARE stmt FROM CONCAT('ALTER TABLE ${tname} AUTO_INCREMENT = ', @max OR 1);
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET foreign_key_checks = 1;
        `
        deleteFromTables.push({query: pool.query(query), table: table, tname: tname})
    }


    // Clean edition_editors
    console.log(chalk.blue(`Sanitizing edition_editor and related.`))
    query = `
        SET foreign_key_checks = 0;

        DELETE edition_editor, edition
        FROM edition_editor
        JOIN edition USING(edition_id)
        WHERE edition_editor.user_id != 1;

        SELECT @max := MAX(edition_editor_id) + 1 FROM edition_editor;
        PREPARE stmt FROM CONCAT('ALTER TABLE edition_editor AUTO_INCREMENT = ', @max OR 1);
        EXECUTE stmt;

        DEALLOCATE PREPARE stmt;
        SELECT @max := MAX(edition_id) + 1 FROM edition;
        PREPARE stmt FROM CONCAT('ALTER TABLE edition AUTO_INCREMENT = ', @max OR 1);
        EXECUTE stmt;

        SET foreign_key_checks = 1;
        `
    deleteFromTables.push({query: pool.query(query), table: 'custom', tname: 'edition_editor'})

    // Remove all but default users
    console.log(chalk.blue(`Sanitizing users.`))
    query = `
        SET foreign_key_checks = 0;

        DELETE user
        FROM user
        WHERE email != "sqe_api" AND email != "test" AND email != "test2";

        SELECT @max := MAX(user_id) + 1 FROM user;
        PREPARE stmt FROM CONCAT('ALTER TABLE user AUTO_INCREMENT = ', @max OR 1);
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET foreign_key_checks = 1;
        `
    deleteFromTables.push({query: pool.query(query), table: 'custom', tname: 'user'})

    // Clear out blacklisted tables
    for (table of tableBlackList) {
        console.log(chalk.blue(`Sanitizing blacklisted ${table}.`))
        const query = `
            SET foreign_key_checks = 0;

            TRUNCATE TABLE ${table};

            SET foreign_key_checks = 1;
            `
        deleteFromTables.push({query: pool.query(query), table: 'blacklist', tname: table})
    }

    // Wait for the delete processes to finish and catch any errors
    for (let i = 0, process; (process = deleteFromTables[i]); i++) {
        try {
            await process.query
            console.log(chalk.green(`✓ Finished sanitizing ${process.table}, ${process.tname}.`))
        } catch(err) {
            console.error(`Error sanitizing ${process.table} and ${process.tname}`)
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