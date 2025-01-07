const db = require('../config/connectDB')

module.exports = {
    addDeposits: async Deposits => {
        rs = await db.Query(`EXEC dbo.addDeposit '${Deposits.username}','${Deposits.MaLoaiTK}','${Deposits.Fund}', '${Deposits.LoaiTaiTuc}'`)
        // console.log(rs)
        return rs
    },
    CreateWithdraw: async (DepositID, Withdraw) => {
        // console.log(DepositID, Withdraw)
        rs = await db.Query(`EXEC dbo.CreateWithdraw '${DepositID}', ${Withdraw}`)
        return rs
    },
    getParams: async () => {
        rs = await db.Query(`select * from THAMSO`)
        return rs
    },
    getLoaiTK: async (Term = null, InterestRate = null, ID = null) => {
        // console.log(Term)
        // console.log(InterestRate)
        var rs = await db.Query(`EXEC dbo.getInterestType ${Term}, ${InterestRate}, ${ID}`)
        // console.log(rs)
        return rs;
    },
    getLoaiTT: async (Name) => {
        var rs ;
        if (Name == "Tái tục gốc") rs = 0;
        else if (Name == "Tái tục toàn bộ") rs = 1;
        else rs = 2;
        return rs;
    },
    getWithdraw: async (MaPhieu) => {
        var rs = await db.Query(`EXEC dbo.getWithdraw '${MaPhieu}'`)
        return rs;
    },
    getInterestTypeAll: async () => {
        var rs = await db.Query(`select * from LOAITK `)
        return rs;
    },
    getInterestType: async (ID) => {
        var rs = await db.Query(`select * from LOAITK where MaLoaiTK = ${ID}`)
        return rs;
    },
    getSumDeposit: async (MaKH) => {
        var rs = await db.Query(`SELECT SUM(TienGui) as Total FROM PHIEUGUI WHERE MaKH = '${MaKH}' AND NgayDong IS NULL`)
        // console.log(rs)
        return rs;
    },
    getDeposit: async (DepositID) => {
        var rs = await db.Query(`SELECT * FROM PHIEUGUI WHERE MaPhieu = ${DepositID}`)
        return rs;
    },
    getAllDeposit: async (username) => {
        var rs = await db.Query(`exec dbo.getAllDeposit ${username}  `)
        for (const item of rs){
            item.TienGui = item.TienGui.toLocaleString('vi', {style : 'currency', currency : 'VND'});
            item.TienLai = item.TienLai.toLocaleString('vi', {style : 'currency', currency : 'VND'});
        }
        return rs;
    },
    searchDeposit: async (citizenID, depositID, dateID, interestID, username) => {
        var rs;
        if (citizenID != null) citizenID = `'${citizenID}'`
        if (dateID != null) dateID = `'${dateID}'`
        if (username != null) username = `'${username}'`
        console.log(citizenID, depositID, dateID, username)
        rs = await db.Query(`exec dbo.searchDeposit ${citizenID},${depositID},${dateID}, ${interestID}, ${username}`);
        return rs;
    },
    makeReportByDay: async Day => {
        var rs = await db.QueryALL(`exec dbo.makeReportByDay '${Day}'`)
        // console.log(`'${Day}'`)
        return rs
    },
    sumReportByDay: async Day => {
        var rs = await db.Query(`SELECT SUM(TongThu) as TongThu, SUM(TongChi) as TongChi, SUM(ChenhLechDS) as ChenhLech FROM BAOCAODOANHSO WHERE NgayDS = '${Day}'`)
        return rs
    },
    summaryMonthReport: async (Month, Year) => {
        var rs = await db.Query(`exec dbo.summaryMonthReport '${Month}','${Year}'`)
        return rs
    },
    deleteWithdrawal: async (DepositID) => {
        var rs = await db.Query(`exec dbo.deleteWithdrawal ${DepositID}`)
        return rs
    },
    deleteDeposit: async (DepositID) => {
        var rs = await db.Query(`exec dbo.deleteDeposit ${DepositID}`)
        return rs
    },
    deleteDepositWithAdmin: async (DepositID) => {
        const deleteTransactions = db.Query(`delete Transactions where DepositID= ${DepositID}`)
        var rs = await db.Query(`delete  Deposits where DepositID= ${DepositID}`)
        return rs
    },
    updateParam: async (NgayRutToiThieu, TienGuiToiThieu) => {
        var rs = await db.Query(`UPDATE THAMSO SET NgayRutToiThieu = ${NgayRutToiThieu}, TienGuiToiThieu = ${TienGuiToiThieu}`)
        return rs
    },
    blockOrunlock: async (state, InterestTypeID) => {
        if (state == 'Khóa')
            var rs = await db.Query(`exec dbo.blockInterestType ${InterestTypeID}`)
        else if (state == "Mở")
            var rs = await db.Query(`exec dbo.unblockInterestType  ${InterestTypeID}`)
        return rs
    },
    addInterestType: async (InterestRate, Term) => {
        console.log(InterestRate, Term)
        var rs = await db.Query(`INSERT INTO LOAITK(LaiSuat, KyHan) VALUES (${InterestRate},${Term})`)
        return rs
    },
    updateInterestType: async (InterestTypeID, KyHan, LaiSuat) => {

        var rs = await db.Query(`UPDATE LOAITK SET KyHan = ${KyHan}, LaiSuat = ${LaiSuat} WHERE MaLoaiTK = ${InterestTypeID}`)
        return rs
    },
    getBalance: async (username) => {
        var rs = await db.Query(`select SoDuNguoiDung from NGUOIDUNG where MaNguoiDung = '${username}'`)
        // console.log(rs[0].SoDuNguoiDung)
        return rs;
    },
    getUserType: async (username) => {
        var rs = await db.Query(`select MaNhom from NGUOIDUNG where MaNguoiDung = '${username}'`)
        // console.log(rs)
        return rs[0].MaNhom;
    },
    deleteInterestType: async (InterestTypeID) => {
        var rs = await db.Query(`DELETE FROM LOAITK WHERE MaLoaiTK = ${InterestTypeID}`)
        return rs
    },

    getNoDay: async (DepositID) => {
        var rs = await db.Query(`SELECT DATEDIFF(day, NgayGui, GETDATE()) as NoDay FROM PHIEUGUI WHERE MaPhieu = ${DepositID}`)
        return rs;
    },
}

