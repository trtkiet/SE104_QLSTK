// Bắt sự kiện click trên nút Confirm
var check = true

function checkinput() {
    // console.log(check);
    return check
}

async function postData(url = '', data = {}) {
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return response.json();
}

document.getElementById("form").addEventListener('submit', function (event) {
    console.log('click')
    event.preventDefault();
        if (confirm("Xác nhận rút tiền trong sổ tiết kiệm?")) {
            var form = event.target;
            var formData = {};
            for (var i = 0; i < form.elements.length - 1; i++) {
                var element = form.elements[i];
                if (element.type !== 'submit') {
                    formData[element.name] = element.value;
                }
            }
            postData('/passbook/detail/withdraw', formData)
                .then((data) => {
                    alert(data.msg)
                    if (data.msg == "Rút tiền thành công") {
                        // window.open("/withdraw/print", '_blank');
                        window.location.replace("/passbook")
                    }
                })
        }


})