const userM = require('../models/user.m');
const passbookM = require('../models/passbook.m');
const { Int } = require('mssql');


module.exports = {
    // getcustomerspost: async (req, res) => {
    //     customer = await userM.getCustomerDetailWithCitizenID(req.body.id)
    //     if (customer.length == 0)
    //         res.json({ status: false })
    //     else
    //         res.json({ status: true, data: customer[0] })
    // },
    passbookListGet: async (req, res) => {
        const passbooks = await passbookM.getAllDeposit(req.session.passport.user)
        createable = true;
        for (i = 0; i < passbooks.length; i++) {
            if (passbooks[i].LoaiTaiTuc == 0) {
                passbooks[i].LoaiTaiTuc = "Tái tục gốc"
            }
            else if (passbooks[i].LoaiTaiTuc == 1) {
                passbooks[i].LoaiTaiTuc = "Tái tục toàn bộ"
            }
            else if (passbooks[i].LoaiTaiTuc == 2) {
                passbooks[i].LoaiTaiTuc = "Không tái tục"
            }
            passbooks[i].LaiSuatApDung *= 100
        }
        res.render('passbookList', {
            // active: {passbook: true},
            layout: "working",
            title: "Danh sách sổ tiết kiệm",
            style: ["form.css", "passbookList.css"],
            script: "dashboard.js",
            createable: createable,
            passbooks: passbooks,
        })
    },
    detailGet : async (req, res) => {
        // console.log(req.body)
        const temp = await passbookM.getDeposit(req.body.passbookID)
        const passbook = temp[0]
        var withdraw = await passbookM.getWithdraw(passbook.MaPhieu)
        withdraw = withdraw[0].withdraw
        // console.log(withdraw)
        var day = ("0" + passbook.NgayDaoHan.getDate()).slice(-2);
        var month = ("0" + (passbook.NgayDaoHan.getMonth() + 1)).slice(-2);
        passbook.NgayDaoHan = passbook.NgayDaoHan.getFullYear()+"-"+(month)+"-"+(day)
        day = ("0" + passbook.NgayGui.getDate()).slice(-2);
        month = ("0" + (passbook.NgayGui.getMonth() + 1)).slice(-2);
        passbook.NgayGui = passbook.NgayGui.getFullYear()+"-"+(month)+"-"+(day)
        passbook.LaiSuatApDung *= 100
        deposit = passbook.TienGui + passbook.TienLai
        deposit = deposit.toLocaleString('vi', {style : 'currency', currency : 'VND'})
        withdraw = withdraw.toLocaleString('vi', {style : 'currency', currency : 'VND'})
        res.render('passbookDetail', {    
            layout: "working",
            title: "Rút tiền",
            style: ["form.css", "passbookList.css"],
            script: "withdraw.js",
            passbookID: req.body.passbookID,
            passbook: passbook,
            deposit: deposit,
            withdraw: withdraw,
        })
    },
    detailPost: async (req, res) => {
        console.log(req.body)
        var err = await passbookM.CreateWithdraw(req.body.passbookID)
        err = err[0].err
        console.log(err)
        if (err == 1){
            res.json({msg: "Rút tiền không thành công do chưa tới ngày rút tối thiểu"})
        }
        else {
            res.json({msg: "Rút tiền thành công"})
        }
    },

    createDepositGet: async (req, res) => {
        const username = req.session.passport.user
        const LoaiTK = await passbookM.getLoaiTK()
        const user = await userM.getAccountByUsername(username)
        // console.log(user)
        const Params = await passbookM.getParams()
        res.render('createDeposit', {
            active: { deposit: true },
            layout: "working",
            title: "Gửi tiền",
            style: ["form.css"],
            script: "createdeposit.js",
            form: true,
            DinhDanh: user[0].DinhDanh,
            TenNguoiDung: user[0].TenNguoiDung,
            DiaChi: user[0].DiaChi,
            // username: Username,
            LoaiTK: LoaiTK,
            // InterestType: InterestType,
            // MinMoneyDeposit: null,
            // Params: (Params.length == 0) ? 0 : Params[0].MinimumDeposit
        })
    },
    createDepositPost: async (req, res) => {
        const username = req.session.passport.user
        const user = await userM.getAccountByUsername(username)
        // console.log(req.body.type)
        const LoaiTK = await passbookM.getLoaiTK(req.body.type.split(' ')[0], req.body.type.split(' ')[3].replace('%', ''))
        const LoaiTT = await passbookM.getLoaiTT(req.body.type1)
        // console.log(LoaiTK)
        Deposits = {
            username: username,
            MaLoaiTK: LoaiTK[0].MaLoaiTK,
            Fund: parseInt(req.body.deposit),
            LoaiTaiTuc: LoaiTT
        }
        // console.log(Deposits)
        const DepositInfo = await passbookM.addDeposits(Deposits)
        console.log(DepositInfo)
        if (DepositInfo[0].err != 2) {
            console.log('whyy')
            // req.session.printdeposit = { DepositID: DepositInfo[0].DepositID }
            res.json({ msg: "Gửi tiền thành công" })
        }
        else {
            res.json({ msg: "Lỗi tạo phiếu gửi!" })
        }
    },
    printDepositsGet: async (req, res) => {
        data = await passbookM.getDeposit(req.session.printdeposit.DepositID)
        // var date = new Date(data[0].OpenedDate);
        // var formattedDate = date.toLocaleString();
        // console.log(formattedDate);
        console.log(JSON.stringify(data[0].OpenedDate));
        data[0].OpenedDate = JSON.parse(JSON.stringify(data[0].OpenedDate).replace('T', " ").replace('.000Z', ""))
        res.render('printDeposit', {
            layout: "print",
            title: "In phiếu gửi tiền",
            script: "printDeposit.js",
            data: data[0]
        })
    },

    withdrawGet: (req, res) => {
        res.render('withdrawMoney', {
            active: { withdraw: true },
            layout: "working",
            title: "Rút tiền",
            style: ["form.css"],
            script: "withdraw.js",
            form: true,
        })
    },
    withdrawPost: async (req, res) => {
        const addwithdraw = await passbookM.addWithdrawal(req.body.depositID, req.body.fullname)
        // console.log(addwithdraw)
        if (addwithdraw === 'err') {
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} chưa tới ngày rút tối thiểu! Vui lòng quay lại sau.` })
        }
        else if (addwithdraw[0].err === 1) {
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} không tồn tại! Vui lòng nhập lại mã phiếu gửi.` })
        }
        else if (addwithdraw[0].err === 2) {
            // req.session.printdeposit = { DepositID: req.body.depositID, Withdrawn: 324324 }
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} đã rút và hủy.` })
        }
        else if (typeof (addwithdraw) === "object") {
            req.session.printdeposit = { DepositID: req.body.depositID, Withdrawn: addwithdraw[0].Withdrawn }
            res.json({ msg: "Rút tiền thành công" })
        }
        else
            res.json({ msg: "erro" })
    },
    printWithdrawGet: async (req, res) => {
        data = await passbookM.getDeposit(req.session.printdeposit.DepositID)
        data[0].Withdrawn = req.session.printdeposit.Withdrawn
        data[0].OpenedDate = JSON.parse(JSON.stringify(data[0].OpenedDate).replace('T', " ").replace('.000Z', ""))
        data[0].WithdrawalDate = JSON.parse(JSON.stringify(data[0].WithdrawalDate).replace('T', " ").replace('.000Z', ""))
        res.render('printWithdraw', {
            layout: "print",
            title: "In phiếu rút tiền",
            script: "printWithdraw.js",
            data: data[0]
        })
    },
    passbookGet: async (req, res) => {
        res.render('search', {
            active: { search: true },
            layout: "working",
            title: "Tra Cứu",
            style: ["modal.css", "form.css", "table.css"],
            script: "search.js",
            form: true,
            detailDeposit: false
        })
    },
    passbookPost: async (req, res) => {
        const citizenID = (req.body.citizenID == "") ? null : req.body.citizenID
        const depositID = (req.body.depositID == "") ? null : req.body.depositID
        const dateID = (req.body.dateID == "") ? null : req.body.dateID
        detailDeposit = await passbookM.searchDeposit(citizenID, depositID, dateID)
        res.json({
            detailDeposit: detailDeposit
        })
    },
    detailsPost: async (req, res) => {
        depositInfo = await passbookM.getDeposit(req.body.DepositID)

        res.json({
            depositInfo: depositInfo[0],
        })
    },
    detailchangePost: async (req, res) => {
        if (req.body.DepositID != false) {
            deleteWithdrawal = await passbookM.deleteWithdrawal(req.body.DepositID)
            if (deleteWithdrawal == "err")
                return res.json({
                    status: false,
                    mess: "Warning: Không được đổi người rút sau khi lập phiếu gửi quá 30 phút"
                })
        }
        updataCustomer = await userM.updateCustomer(req.body)
        res.json({
            status: true,
            mess: "Sửa thông tin thành công"
        })
    },
    detaildeletePost: async (req, res) => {
        if (req.session.accountType != "Admin") {
            var deleteDeposit = await passbookM.deleteDeposit(req.body.DepositID)
            if (deleteDeposit == 'err')
                return res.json({ status: false, mess: "Xóa phiếu thất bại do bạn không phải là admin nên chỉ xóa trước 30 phút lập phiếu!" })
            res.json({ status: true, mess: "Xóa phiếu thành công" })

        }
        else {
            var deleteDeposit = await passbookM.deleteDepositWithAdmin(req.body.DepositID)
            if (deleteDeposit == 'err')
                return res.json({ status: false, mess: "Lỗi khi xóa phiếu" })
            res.json({ status: true, mess: "Xóa phiếu thành công" })
        }
    },
    reportGet: (req, res) => {
        res.render('report', {
            active: { report: true },
            layout: "working",
            title: "Tra Cứu",
            style: ["report.css", "form.css", "table.css"],
            script: "report.js",
            form: true,
        })
    },
    reportPost: async (req, res) => {
        const detailReport = await passbookM.makeReportByDay(req.body.dateID)
        res.json({
            detailReport: (detailReport === "err") ? false : detailReport,
        })
    },


}