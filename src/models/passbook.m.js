const db = require('../config/connectDB')

module.exports = {
    addDeposits: async Deposits => {
        rs = await db.Query(`EXEC dbo.addDeposit '${Deposits.username}','${Deposits.MaLoaiTK}','${Deposits.Fund}', '${Deposits.LoaiTaiTuc}'`)
        // console.log(rs)
        return rs
    },
    CreateWithdraw: async (DepositID, Withdrawer) => {
        rs = await db.Query(`EXEC dbo.CreateWithdraw '${DepositID}'`)
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
        var rs = await db.Query(`select * from InterestTypes `)
        return rs;
    },
    getSumDeposit: async () => {
        var rs = await db.Query(`EXEC  dbo.sumActiveDeposit `)
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
    searchDeposit: async (citizenID, depositID, dateID) => {
        if (dateID !== null)
            var rs = await db.Query(`EXEC dbo.searchDeposit ${depositID},${citizenID},'${dateID}' `)
        else
            var rs = await db.Query(`EXEC dbo.searchDeposit ${depositID},${citizenID},${dateID} `)
        return rs;
    },
    makeReportByDay: async Day => {
        var rs = await db.QueryALL(`exec dbo.makeReportByDay '${Day}'`)
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
    updateParam: async (MinimumDeposit) => {
        var rs = await db.Query(`exec dbo.updateMinimumDeposit '${MinimumDeposit}' `)
        return rs
    },
    blockOrunlock: async (state, InterestTypeID) => {
        if (state == 'Khóa')
            var rs = await db.Query(`exec dbo.blockInterestType ${InterestTypeID}`)
        else if (state == "Mở")
            var rs = await db.Query(`exec dbo.unblockInterestType  ${InterestTypeID}`)
        return rs
    },
    addInterestType: async (InterestRate, Term, MinimumTimeToWithdrawal) => {
        var rs = await db.Query(`exec dbo.addInterestType  ${InterestRate},${Term},${MinimumTimeToWithdrawal}`)
        return rs
    },
    updateInterestType: async (InterestTypeID, MinimumTimeToWithdrawal) => {

        var rs = await db.Query(`exec dbo.updateInterestType ${InterestTypeID},${MinimumTimeToWithdrawal}`)
        return rs
    }
}

