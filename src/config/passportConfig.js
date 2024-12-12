const passport = require('passport');
const localStrategy = require('passport-local').Strategy;
const userM = require('../models/user.m');
const bcrypt = require('bcrypt');

// kiểm tra xem mật khẩu có đúng không
passport.serializeUser((user, done) => {
    done(null, user)
})
passport.deserializeUser(async (Username, done) => {
    try {
        // console.log(Username);
        const user = await userM.getAccountByUsername(Username);
        done(null, user[0].MaNguoiDung);
    }
    catch (err) {
        done(err, null);
    }   
})
passport.use(new localStrategy(
    async (Username, Password, done) => {
        try {
            const user = await userM.getAccountByUsername(Username)
            // console.log(user)
            if (!user) return done(null, false)
            // console.log(Password)
            // console.log(user[0].MatKhau)
            if (!bcrypt.compare(Password, user[0].MatKhau)) return done(null, false)
            return done(null, user[0].MaNguoiDung);
        }
        catch (err) {
            return done(err);
        }
    }
))
module.exports = passport