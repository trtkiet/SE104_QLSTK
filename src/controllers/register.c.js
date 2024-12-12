

const bcrypt = require('bcrypt');
const userM = require('../models/user.m')
module.exports = {
    registerGet: (req, res) => {
        if (req.isAuthenticated()) {
            return res.redirect('/home');
        }
        res.render('register', {
            title: "Register",
            style: "register.css",
            script: "register.js",
        })
    },
    registerPost: async (req, res) => {
        const pw = req.body.password;
        // console.log(req.body);
        var hashedpw = await bcrypt.hash(pw, 10);
        const user = {
            username: req.body.username,
            password: hashedpw,
            fullname: req.body.fullname,
            id: req.body.id,
            addr: req.body.address,
        }
        const checkUn = await userM.getAccountByUsername(user.username);
        if (checkUn.length) {
            res.send({ msg: 'Username has already exist' });
            return;
        }
        // console.log(user);
        const checkID = await userM.getAccountByID(user.id);
        if (checkID.length) {
            res.send({ msg: 'CMND/CCCD has already exist' })
            return;
        }
        await userM.addUser(user)
        req.logIn(user.username, function (err) {
            if (err) return next(err);
            // console.log('is authenticated?: ' + req.isAuthenticated());
            return res.send({ msg: "succeed" })
        });
        // res.send({msg: 'succeed'})
        // res.send({msg: 'test'})
    }
}