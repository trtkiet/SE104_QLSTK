
function checkinput() {
    if ($("#minDay").val().trim() === "") {
        alert("Không bỏ trống số ngày tối thiểu để rút tiền!")
        return false;
    }
    if ($("#minDeposit").val().trim() === "") {
        alert("Không bỏ trống số tiền gửi tối thiểu!")
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
            location.reload()
    }


})