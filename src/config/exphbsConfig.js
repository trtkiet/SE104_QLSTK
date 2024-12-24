const exphbs = require('express-handlebars');
var path = require('path');
module.exports = app =>{
    app.engine('hbs', exphbs.engine({extname: 'hbs', defaultLayout: 'main.hbs', layoutsDir: 'src/views/layouts'}));
    app.set('view engine', 'hbs');
}
