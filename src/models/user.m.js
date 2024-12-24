
const db = require('../config/connectDB')

module.exports = {
    addUser: async user => {
        try {
            a = await db.Query(`insert into NguoiDung (MaNguoiDung, MaNhom, MatKhau, TenNguoiDung, DinhDanh, DiaChi, SoDuNguoiDung) values ('${user.username}', N'${1}', N'${user.password}', N'${user.fullname}', '${user.id}', N'${user.addr}', N'${0}')`)
            return 0
        }
        catch (error) {
            console.log(error)
            return 2
        }
    },
    getAccountByUsername: async Username => {
        var rs = await db.Query(`select * from NGUOIDUNG where MaNguoiDung= '${Username}'`)
        // console.log(rs)
        return rs;
    },
    getAccountByID: async ID => {
        var rs = await db.Query(`select * from NGUOIDUNG where DinhDanh= '${ID}'`)
        // console.log(rs)
        return rs;
    },
    getAccountTypeByUsername: async Username => {
        var rs = await db.Query(`select AccountTypeName  from AccountTypes where  AccountTypeID =(select AccountTypeID from Accounts where USERNAME='${Username}')`)
        return rs;
    },
    addCustomer: async Customer => {

        var rs = await db.Query(`exec dbo.addCustomer N'${Customer.CustomerName}', ${Customer.PhoneNumber}, ${Customer.CitizenID},N'${Customer.CustomerAddress}'`)
        return rs;
    },
    getCustomerDetailWithCitizenID: async (CitizenID = null) => {
        var rs = await db.Query(`EXEC dbo.getCustomerDetailWithCitizenID  '${CitizenID}' `)
        return rs;
    },
    getCustomersByCustomerName: async (CustomerName = null) => {
        if (CustomerName == null) {
            var rs = await db.Query(`select * from Customers`)
        }
        else {
            var rs = await db.Query(`select * from Customers where CustomerName='${CustomerName}' `)
        }
        return rs;
    },
    updateCustomer: async (Customer = null) => {
        if (Customer.CustomerName == null && Customer.CustomerAddress == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , ${Customer.CustomerName} , ${Customer.PhoneNumber} , ${Customer.CitizenID} , ${Customer.CustomerAddress} `)
        else if (Customer.CustomerName == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , ${Customer.CustomerName} , ${Customer.PhoneNumber} , ${Customer.CitizenID} , N'${Customer.CustomerAddress}' `)
        else if (Customer.CustomerAddress == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , N'${Customer.CustomerName}' , ${Customer.PhoneNumber} , ${Customer.CitizenID} , ${Customer.CustomerAddress} `)
        else
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , N'${Customer.CustomerName}' , ${Customer.PhoneNumber} , ${Customer.CitizenID} , N'${Customer.CustomerAddress}' `)
        return rs;
    },
}


