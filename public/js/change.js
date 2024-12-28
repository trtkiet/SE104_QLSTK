
function checkinput() {
    console.log($("#minDay").val(), $("#minDeposit").val())
    if ($("#minDay").val().trim() === "" || $("#minDay").val() <= 0) {
        alert("Số ngày tối thiểu để rút tiền không hợp lệ!")
        return false;
    }
    if ($("#minDeposit").val().trim() === "" || $("#minDeposit").val() <= 0) {
        alert("Số tiền gửi tối thiểu không hợp lệ!")
        return false;
    }
    return true
}
document.getElementById('form').addEventListener('submit', function (event) {
    event.preventDefault(); // Prevent form submission
    console.log('click')
    var form = event.target;
    var formData = {};
    for (var i = 0; i < form.elements.length - 1; i++) {
        var element = form.elements[i];
        if (element.type !== 'submit') {
            formData[element.name] = element.value;
        }
    }
    if (checkinput() && confirm('Xác nhận thay đổi tham số?')) {
        postData('/change', formData)
            .then((data) => {
                
            })
            alert("Thay đổi tham số thành công")
            // location.reload()
    }


})