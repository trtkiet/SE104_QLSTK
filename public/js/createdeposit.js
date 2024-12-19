
const postCitizenID = document.getElementById('citizenID')
var nameRegex =
    /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s\W|_]+$/;
var idRegex = /([1-9]{1})+([0-9]{8,11})\b/;

function checkinput() {
    // console.log('Checkkkkkkkkkkk')
    var type = $("input[name = 'type']:checked").val();
    if ($("#citizenID").val().trim() == "") {
        alert("CMND/CCCD không hợp lệ!");
        return false;
    }
    if (
        $("#citizenID").val().trim() != "" &&
        idRegex.test($("#citizenID").val()) == false
    ) {
        alert("CMND/CCCD không hợp lệ!");
        return false;
    }
    if (
        $("#fullname").val().trim() == "" ||
        nameRegex.test($("#fullname").val()) == false
    ) {
        alert("Tên không hợp lệ!");
        return false;
    }
    if ($("#address").val().trim() == "") {
        alert("Địa chỉ không hợp lệ!");
        return false;
    }
    if ($("#type").val().trim() == "") {
        alert("Loại tiết kiệm không hợp lệ!");
        return false;
    }
    if ($("#deposit").val().trim() == "") {
        console.log($("#deposit").val())
        alert("Số tiền không hợp lệ!");
        return false;
    }
    return true;
}
var inputField = document.getElementById('type');
var dataList = document.getElementById('choice').getElementsByTagName('option');
inputField.addEventListener('change', function () {
    var inputValue = inputField.value;
    var valueExists = false;

    for (var i = 0; i < dataList.length; i++) {
        if (inputValue === dataList[i].value) {
            valueExists = true;
            break;
        }
    }

    if (!valueExists) {
        alert("Chọn loại phiếu gửi có sẵn!")
        inputField.value = ''; // Xóa giá trị nhập vào nếu không tồn tại trong danh sách
        return false;
    }
    return true;
});

var inputField1 = document.getElementById('type1');
var dataList1 = document.getElementById('choice1').getElementsByTagName('option');
inputField1.addEventListener('change', function () {
    var inputValue = inputField1.value;
    var valueExists = false;

    for (var i = 0; i < dataList1.length; i++) {
        if (inputValue === dataList1[i].value) {
            valueExists = true;
            break;
        }
    }

    if (!valueExists) {
        alert("Chọn loại tái tục có sẵn!")
        inputField1.value = ''; // Xóa giá trị nhập vào nếu không tồn tại trong danh sách
        return false;
    }
    return true;
});

document.getElementById("form").addEventListener('submit', function (event) {
    console.log('click')
    event.preventDefault();
    // window.open("/deposit/print", '_blank');
    if (checkinput()) {
        if (confirm("Xác nhận gửi tiền tiết kiệm?")) {
            var form = event.target;
            var formData = {};
            for (var i = 0; i < form.elements.length - 1; i++) {
                var element = form.elements[i];
                if (element.type !== 'submit') {
                    formData[element.name] = element.value;
                }
            }
            postData('/deposit', formData)
                .then((data) => {
                    alert(data.msg)
                    if (data.msg == "Gửi tiền thành công") {
                        // window.open("/deposit/print", '_blank');
                    }
                })

        }
    }


})