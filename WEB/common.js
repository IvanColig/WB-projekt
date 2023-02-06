//------konstante------------------------------------------------
var url = "https://dev.vub.zone/sandbox/router.php";
var projekt = "p_icolig";
var perPage = 10;
var userID;

//------hendlanje link button-a----------------------------------
$("#loginBtn").click(function () {
    {$("#container").html(loginForm);}
});

$("#logoutBtn").click(function () {
    logout();
});

$("#korisniciBtn").click(function () {
    showKorisnici();
});

$("#ordersBtn").click(function () {
    showOrders();
});

$("#menuBtn").click(function () {
    showMenu();
});

//------------refresh-------------------------------------------------
$(function () {
    refresh();
});

//------------refresh--------------------------------------------------
function refresh() {
    $.ajax({
        type: 'POST',
        url: url,
        data: { "projekt": "p_common", 
                "procedura": "p_refresh" 
              },
        success: function (data) {
            var jsonBody = JSON.parse(data);
            if (jsonBody.h_errcode !== 999){
                var podaci = '<small>ID: ' + jsonBody.ID + '<br>' + 'name: ' + jsonBody.ime + ' ' + jsonBody.prezime + '<br>' + 'email: ' + jsonBody.email + '</small>';
                $("#podaci").html(podaci);
                userID = jsonBody.ID;
            }  
        },
        error: function (xhr, textStatus, error) {
            console.log(xhr.statusText);
            console.log(textStatus);
            console.log(error);
        },
        async: true

    });
}

//----------------------------------------------------------------
function pagination(pageNmb, perPage, count) {
    //ne treba prikazivati ništa
    if (count < perPage) {
        return '';
    } else {
        var quotient = Math.ceil(count / perPage);
    }
    var next = pageNmb + 1;
    var prev = pageNmb - 1;
    var pagination = '<div class="float-right pagination">';

    //treba prikazati previous
    if (pageNmb > 1) {
        pagination += '<ul class="pagination"><li class="page-item "><a class="page-link" onclick="showKlijenti(' + prev + ')" href="javascript:void(0)">‹</a></li>';
    }

    for (let i = pageNmb; i < pageNmb + 5; i++) {
        pagination += '<li class="page-item"><a class="page-link" onclick="showKlijenti(' + i + ')" href="javascript:void(0)">' + i + '</a></li>';
    }

    pagination += '<li class="page-item"><a class="page-link"  href="javascript:void(0)">...</a></li>';

    pagination += '<li class="page-item"><a class="page-link" onclick="showKlijenti(' + quotient + ')" href="javascript:void(0)">' + quotient + '</a></li>';

    pagination += '<li class="page-item"><a class="page-link" onclick="showKlijenti(' + next + ')" href="javascript:void(0)">›</a></li>';
    pagination += '</ul></div>';
    return pagination;
}
//-----------ajaxSetup-------------------------------------------------------
$.ajaxSetup({
    xhrFields: {
        withCredentials: true
    }
});