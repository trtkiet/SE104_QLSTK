const express = require('express');
const path = require('path');
const { engine } = require ('express-handlebars');
const app = express();
const port = 3000;
homeR = require('./routes/home.r.js')
//Template engine
app.engine('handlebars', engine());
app.set('view engine', 'handlebars');
app.set('views', path.join(__dirname, 'resources/views'))
app.use(express.static(path.join(__dirname, "/public")))


app.use('/home', homeR);

app.get('/', (req, res) => {
  res.redirect('home');
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
})