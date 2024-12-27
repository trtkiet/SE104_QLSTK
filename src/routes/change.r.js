const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.changeGet)
router.post('/', passbookC.changePost)

module.exports = router;