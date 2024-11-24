const express = require('express');
const router = express.Router();
const homeC = require('../controllers/home.c.js')

router.get('/', homeC.homeGet)
module.exports = router;