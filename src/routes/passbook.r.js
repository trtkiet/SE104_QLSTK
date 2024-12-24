const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.passbookListGet)

// router.post('/', passbookC.passbookListPost)

router.post('/detail', passbookC.detailGet)

router.post('/detail/withdraw', passbookC.detailPost)

module.exports = router;