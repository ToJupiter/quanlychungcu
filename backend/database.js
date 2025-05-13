// database.js
const mysql = require('mysql2/promise');
const config = require('./config');

const pool = mysql.createPool({
  host: config.db.host,
  user: config.db.user,
  password: config.db.password,
  database: config.db.name,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Test connection
pool.getConnection()
  .then(connection => {
    console.log('MySQL Connected successfully!');
    connection.release();
  })
  .catch(err => {
    console.error('Failed to connect to MySQL:', err.message);
    if (err.code === 'ER_BAD_DB_ERROR') {
        console.error(`Database '${config.db.name}' does not exist. Please create it.`);
    } else if (err.code === 'ECONNREFUSED') {
        console.error(`Connection to MySQL server at '${config.db.host}' was refused. Is the server running?`);
    } else if (err.code === 'ER_ACCESS_DENIED_ERROR') {
        console.error(`Access denied for user '${config.db.user}'. Check your credentials.`);
    }
    // It's good practice to exit if the DB connection fails as the app won't work.
    // process.exit(1); // Consider uncommenting in production if DB is critical at startup
  });


module.exports = pool;