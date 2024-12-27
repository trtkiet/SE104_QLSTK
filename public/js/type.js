var nameRegex =
  /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s\W|_]+$/;
var idRegex = /([1-9]{1})+([0-9]{8,11})\b/;

function checkinput() {
  if ($("#KyHan").val().trim() == "" || $("#KyHan").val() < 0) {
    alert("Kỳ hạn không hợp lệ!");
    return false;
    
  }
  if ($("#LaiSuat").val().trim() == "" || $("#LaiSuat").val() < 0) {
    alert("Lãi suất không hợp lệ!");
    return false;
  }
  return true;
}

function checkinputChange() {
  
  console.log($("#rateID").val)
  if ($("#deadlineID").val().trim() == "" || $("#deadlineID").val() < 0) {
    alert("Kỳ hạn không hợp lệ!");
    return false;
    
  }
  if ($("#rateID").val().trim() == "" || $("#rateID").val() < 0) {
    alert("Lãi suất không hợp lệ!");
    return false;
  }
  return true;
}


var depositInfo = null
function getJSBTN() {
  // Get the modal
  // console.log('nguuuu')
  var modal = document.getElementById("myModal");

  // Get the button that opens the modal
  var btns = document.getElementsByClassName("myBtn");

  // Get the <span> element that closes the modal
  var span = document.getElementsByClassName("close")[0];

  // When the user clicks the button, open the modal
  for (var i = 0; i < btns.length; i++) {
    btns[i].onclick = function (event) {
      modal.style.display = "block";
      var cells = this.closest("tr").getElementsByTagName("td");
      var info = { MaLoaiTK: cells[0].innerText }
      console.log(info)
      postData("/type/detail", info)
        .then((data) => {
          type = data.type
          console.log(type)

          document.querySelector("#myModal #interestID").value = type.MaLoaiTK
          document.querySelector("#myModal #deadlineID").value = type.KyHan
          document.querySelector("#myModal #rateID").value = type.LaiSuat * 100
        }
        )
    };
  }
  // When the user clicks on <span> (x), close the modal
  span.onclick = function () {
    modal.style.display = "none";
  };

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function (event) {
    if (event.target == modal) {
      modal.style.display = "none";
    }
  };
}

window.onload = getJSBTN();
formSearch = document.getElementById('form')
// event handlers for btn search
formSearch.addEventListener('submit', function (event) {
  event.preventDefault(); // Prevent form submission
  if (checkinput() && confirm("Tạo loại tiết kiệm?")){
    var form = event.target;
    var formData = {};
    for (var i = 0; i < form.elements.length - 1; i++) {
      var element = form.elements[i];
      if (element.type !== 'submit') {
        formData[element.name] = element.value;
      }
    }
    console.log(formData)
    data = {
      KyHan: formData.KyHan,
      LaiSuat: formData.LaiSuat / 100
    }
    console.log(form)
    postData('/type', data)
      .then((datas) => {
        alert(datas.mess)
        if (datas.status == true) {
          document.getElementById("myModal").style.display = "none";
          document.getElementById('confirmBtn').click();
        }
      })
      alert("Tạo loại tiết kiệm thành công!")
      location.reload();
  }
})

//event handler for btn change and delete  deposit info
document.querySelector('#forminfo').addEventListener('submit', function (event) {
  event.preventDefault();
  console.log("click");
  if (event.submitter.id === "changeBtn") {
    //event handler for btn change 

    if (checkinputChange()) {
      if (!confirm("Bạn có muốn sửa thông tin không?")) {
        return false
      }
      var form = event.target;
      var formData = {};
      for (var i = 0; i < form.elements.length - 1; i++) {
        var element = form.elements[i];
        if (element.type !== 'submit') {
          formData[element.name] = element.value;
        }
      }
      data = {
        MaLoaiTK: formData.interestID,
        KyHan: formData.deadlineID,
        LaiSuat: formData.rateID / 100
      }
      postData('/type/detail/change', data)
        .then((datas) => {
          alert(datas.mess)
          if (datas.status == true) {
            document.getElementById("myModal").style.display = "none";
            document.getElementById('confirmBtn').click();

          }
        })
        location.reload();
    }
  }
  else if (event.submitter.id === "deleteBtn") {

    if (!confirm("Bạn có chắc chắn xóa phiếu gửi?")) {
      return false
    }
    var form = event.target;
    postData('/type/detail/delete', { MaLoaiTK: form.elements.interestID.value })

      .then((datas) => {
        alert(datas.mess)
        if (datas.status == true) {
          document.getElementById("myModal").style.display = "none";
          document.getElementById('confirmBtn').click();
        }

      })
      location.reload();

    //event handler for btn  delete
  }
})
