var pg = require ('pg');
var username = '';
var password = ''
var server = 'localhost'
var db = ''
var con_string = 'tcp://' + username + ':' + password + '@' + server + '/' + db;

var pg_client = new pg.Client(con_string);
pg_client.connect();
console.log('Connected');
var query = pg_client.query('LISTEN table_update');
pg_client.on('notification', function(row) {
  console.log(row.payload);
});
