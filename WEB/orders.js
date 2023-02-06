function showOrders(page) {
    var tablica = '<table class="table table-fluid" id="myTable"><thead><tr>';
    tablica += '<th scope="col">name</th><th scope="col">quantity</th><th scope="col">price</th><th scope="col">total</th><th scope="col">action</th></tr></thead>';


    if (page == null || page == "") {
        page = 1;
    }

    $.ajax({
        type: 'POST',
        url: url,
        data: {"projekt": projekt, 
               "procedura": "p_get_orders",
               "ID": userID
            },
        success: function (data) {
            var jsonBody = JSON.parse(data);
            var errcode = jsonBody.h_errcode;
            var message = jsonBody.h_message;
            var count = jsonBody.count;
            tablica += '<tbody>';

            if (message == null || message == "", errcode == null || errcode == 0) {
                $.each(jsonBody.data, function (k, v) {
                    tablica += '<tr><td>' + v.NAZIV + '</td>';
                    tablica += '<td>' + v.QUANTITY + '</td>';
                    tablica += '<td>' + v.CIJENA + '$</td>';
                    x = v.QUANTITY * v.CIJENA;
                    tablica += '<td>' + x + '$</td>';
                    tablica += '<td><button type="button" class="btn btn-primary" onclick="showOrder(' + v.ID + ',' + page + ')">Edit <i class="fas fa-edit"></i></button> ';
                    tablica += '<button type="button" class="btn btn-danger" onclick="delOrder(' + v.ID + ',' + page + ')">Delete <i class="far fa-trash-alt"></i></button></td></tr>';
                });
                tablica += '</tbody></table>';
                //tablica += pagination(page, perPage, count);
                tablica += `<script>$(document).ready( function () {$('#myTable').DataTable();} );</script>`;
                $("#container").html(tablica);
            } else {
                if (errcode == 999) {
                    $("#container").html(loginForm);
                } else {
                    Swal.fire(message + '.' + errcode);
                }
            }
            refresh();
        },
        error: function (xhr, textStatus, error) {
            console.log(xhr.statusText);
            console.log(textStatus);
            console.log(error);
        },
        async: true

    });
}

//----------------
function showOrder(ID, page) {
    var tablica = '<table class="table table-hover"><tbody>';
    $.ajax({
        type: 'POST',
        url: url,
        data: { "projekt": projekt, "procedura": "p_get_order", "ID": ID },
        success: function (data) {
            var jsonBody = JSON.parse(data);
            var errcode = jsonBody.h_errcode;
            var message = jsonBody.h_message;

            if (message == null || message == "", errcode == null || errcode == 0) {
                $.each(jsonBody.data, function (k, v) {
                    tablica += '<tr><th scope="col">ID</th><td><input type="text" id="ID" value="' + v.ID + '" readonly></td></tr>';
                    tablica += '<tr><th scope="col">name</th><td><input type="text" id="NAZIV" value="' + v.NAZIV + '" readonly></td></tr>';
                    tablica += '<tr><th scope="col">quantity</th><td><input type="number" min="1" id="QUANTITY" value="' + v.QUANTITY + '"></td></tr>';
                    tablica += '<tr><th scope="col">price</th><td><input type="text" id="CIJENA" value="' + v.CIJENA + '" readonly></td></tr>';
                    tablica += '</table>';
                    tablica += '<button type="button" class="btn btn-warning" id="spremiOrder">Save <i class="fas fa-save"></i></button> ';
                    tablica += '<button type="button" class="btn btn-success" onclick="showOrders(' + page + ')">Cancel <i class="fas fa-window-close"></i></button>';
                });
                $("#container").html(tablica);
            } else {
                if (errcode == 999) {
                    $("#container").html(loginForm);
                } else {
                    Swal.fire(message + '.' + errcode);
                }
            }
            refresh();
        },
        error: function (xhr, textStatus, error) {
            console.log(xhr.statusText);
            console.log(textStatus);
            console.log(error);
        },
        async: true

    });
}

//-----------------------SAVE ORDER---------------------------
$(document).on('click', '#spremiOrder', function () {
    var QUANTITY = $('#QUANTITY').val();
    var ID = $('#ID').val();

    if (QUANTITY == null || QUANTITY == "") {
        Swal.fire('Molimo unesite kolicinu');
    } else {
        $.ajax({
            type: 'POST',
            url: url,
            data: {
                "projekt": projekt,
                "procedura": "p_save_orders",
                "ID": ID,
                "QUANTITY": QUANTITY,
            },
            success: function (data) {
                var jsonBody = JSON.parse(data);
                var errcode = jsonBody.h_errcode;
                var message = jsonBody.h_message;
                console.log(data);

                if ((message == null || message == "") && (errcode == null || errcode == 0)) {
                    Swal.fire('Uspješno se promjenili narudzbu');
                } else {
                    Swal.fire(message + '.' + errcode);
                }
                refresh();
                showOrders();
            },
            error: function (xhr, textStatus, error) {
                console.log(xhr.statusText);
                console.log(textStatus);
                console.log(error);
            },
            async: true
        });
    }
})

//-------------------Brisanje ordera---------------
function delOrder(ID, page){
    Swal.fire({
        title: 'Želite li zaista obrisati narudzbu?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Da, obriši!',
        cancelButtonText: 'Ipak nemoj!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                type: 'POST',
                url: url,
                data: {
                    "projekt": projekt,
                    "procedura": "p_save_orders",
                    "ID": ID,
                    "ACTION": "delete"
                },
                success: function (data) {
                    var jsonBody = JSON.parse(data);
                    var errcode = jsonBody.h_errcode;
                    var message = jsonBody.h_message;
                    console.log(data);

                    if ((message == null || message == "") && (errcode == null || errcode == 0)) {
                        Swal.fire(
                            'Uspješno ',
                            'ste obrisali narudzbu',
                            'success'
                        );
                    } else {
                        Swal.fire(message + '.' + errcode);
                    }
                    refresh();
                    showOrders();
                },
                error: function (xhr, textStatus, error) {
                    console.log(xhr.statusText);
                    console.log(textStatus);
                    console.log(error);
                },
                async: true
            });
        }
    })
}