// const userM = require('../models/user.m');
const passbookM = require('../models/passbook.m')
const userM = require('../models/user.m')


module.exports = {
    homeGet: async (req, res) => {

        var currentDate = new Date()
        var Params = 0
        const user = await userM.getAccountByUsername(req.session.passport.user)
        const sumDeposit = await passbookM.getSumDeposit(req.session.passport.user)
        var balance = await passbookM.getBalance(req.session.passport.user)
        balance = balance[0].SoDuNguoiDung
        balance = balance.toLocaleString('vi', {style : 'currency', currency : 'VND'});
        console.log(balance)
        var type = await passbookM.getInterestTypeAll()
        for (i = 0; i < type.length; i++){
            type[i].LaiSuat *= 100
        }
        const accountType = await passbookM.getUserType(req.session.passport.user)
        var isStaff = false;
        if (accountType == 2) isStaff = true
        var isCustomer = false;
        if (accountType == 1) isCustomer = true
        res.render('home', {
            layout: "working",
            title: "Trang chủ",
            style: ["home.css", "table.css", "form.css"],
            script: "home.js",
            // form: true,
            // InterestTypeadad: InterestTypeadad,
            sumDeposit: sumDeposit[0].Total == null ? 0 : sumDeposit[0].Total,
            balance: balance,
            hideForm: false,
            type: type,
            isStaff: isStaff,
            isCustomer: isCustomer,
            // Monthwithdraw: monthReport[0].MonthCost == null ? 0 : monthReport[0].MonthCost,
            // MonthDeposit: monthReport[0].MonthRevenue == null ? 0 : monthReport[0].MonthRevenue,
            // month: currentDate.getMonth() + 1,
            // year: currentDate.getFullYear(),
            // hideForm: isAdmin,
            // Params: (Params == 0) ? 0 : Params[0].MinimumDeposit,
        })
    },
    updateparamPost: async (req, res) => {
        const updateParam = await passbookM.updateParam(req.body.money)
        if (updateParam == "err")
            res.json({
                msg: "Lỗi khi thay đổi số tiền gửi tối thiểu!",
            })
        else {
            res.json({
                msg: "Đổi tiền gửi tối thiểu thành công",
            })
        }
    },
    blockOrunlock: async (req, res) => {
        const lockorunlock = await passbookM.blockOrunlock(req.body.text, req.body.InterestTypeID)
        if (lockorunlock == 'err')
            res.json({ msg: `Lỗi khi thay đổi trạng thái của loại tiết kiệm ${req.body.InterestTypeID}` })
        else
            res.json({ msg: `Thay đổi thành công` })
    },
    addInterestType: async (req, res) => {
        const addInterestType = await passbookM.addInterestType(req.body.InterestRate, req.body.Term, req.body.MinimumTimeToWithdrawal)
        if (addInterestType == 'err')
            res.json({ msg: `Lỗi trùng kì hạn và lãi suất vui lòng mở khóa hoặc sử dụng lại cái đã có` })
        else
            res.json({ msg: `Thêm thành công thành công` })
    },
    updateInterestType: async (req, res) => {
        const addInterestType = await passbookM.updateInterestType(req.body.InterestTypeID, req.body.MinimumTimeToWithdrawal)
        if (addInterestType == 'err')
            res.json({ msg: `Lỗi khi sửa thời gian tối thiểu` })
        else
            res.json({ msg: `Thay đổi thành công` })
    }
}