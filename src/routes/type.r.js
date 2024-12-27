const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.typeGet)
router.post('/', passbookC.typePost)

router.post('/detail', passbookC.typeDetailPost)
router.post('/detail/delete', passbookC.typeDetailDeletePost)
router.post('/detail/change', passbookC.typeDetailUpdatePost)
module.exports = router;