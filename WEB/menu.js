//--------forma za unos jela
function insertMenuForm(page) {
    var output = '<table class="table table-hover"><tbody>';
    output += '<tr><th scope="col">type</th><td><input type="number min="1"" id="VRSTA"></td></tr>';
    output += '<tr><th scope="col">name</th><td><input type="text" id="NAZIV"></td></tr>';
    output += '<tr><th scope="col">ingredients</th><td><input type="text" id="SASTOJCI"></td></tr>';
    output += '<tr><th scope="col">price</th><td><input type="email" id="CIJENA"></td></tr>';
    output += '</table>';
    output += '<button type="button" class="btn btn-warning" id="spremiJelo">Save <i class="fas fa-save"></i></button> ';
    output += '<button type="button" class="btn btn-success" onclick="showMenu(' + page + ')">Cancel <i class="fas fa-window-close"></i></button>';
    $("#container").html(output);
}


//-------------------------------------------------------------
function showMenu(page) {
    var tablica = '<div><br><button type="button" class="btn btn-success bt1" onclick="insertMenuForm(' + page + ')">Insert <i class="fa fa-pen" aria-hidden="true"></i></button></div><br>';
    tablica += '<table class="table table-fluid" id="myTable"><thead><tr>';
    tablica += '<th scope="col">name</th><th scope="col">ingredients</th><th scope="col">price</th><th scope="col">action</th></tr></thead>';

    if (page == null || page == "") {
        page = 1;
    }

    $.ajax({
        type: 'POST',
        url: url,
        data: {"projekt": projekt, 
               "procedura": "p_get_pizza", 
               "perPage": perPage, 
               "page": page 
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
                    tablica += '<td>' + v.SASTOJCI + '</td>';
                    tablica += '<td>' + v.CIJENA + '$</td>';
                    tablica += '<td><button type="button" class="btn btn-primary" onclick="showDish(' + v.ID + ',' + page + ')">Edit <i class="fas fa-edit"></i></button> ';
                    tablica += '<button type="button" class="btn btn-danger" onclick="delDish(' + v.ID + ',' + page + ')">Delete <i class="far fa-trash-alt"></i></button> ';
                    tablica += '<button type="button" class="btn btn-success" onclick="addDish(' + v.ID + ',' + page + ')">Add</button></td></tr>';
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
//-----------------------------------------------------------------------------
function showDish(ID, page) {
    var tablica = '<table class="table table-hover"><tbody>';
    $.ajax({
        type: 'POST',
        url: url,
        data: { "projekt": projekt, "procedura": "p_get_pizza", "ID": ID },
        success: function (data) {
            var jsonBody = JSON.parse(data);
            var errcode = jsonBody.h_errcode;
            var message = jsonBody.h_message;

            if (message == null || message == "", errcode == null || errcode == 0) {
                $.each(jsonBody.data, function (k, v) {
                    tablica += '<tr><th scope="col">ID</th><td><input type="text" id="ID" value="' + v.ID + '" readonly></td></tr>';
                    tablica += '<tr><th scope="col">name</th><td><input type="text" id="NAZIV" value="' + v.NAZIV + '"></td></tr>';
                    tablica += '<tr><th scope="col">ingredients</th><td><input type="text" id="SASTOJCI" value="' + v.SASTOJCI + '"></td></tr>';
                    tablica += '<tr><th scope="col">price</th><td><input type="text" id="CIJENA" value="' + v.CIJENA + '"></td></tr>';
                    tablica += '</table>';
                    tablica += '<button type="button" class="btn btn-warning" id="spremiJelo">Save <i class="fas fa-save"></i></button> ';
                    tablica += '<button type="button" class="btn btn-success" onclick="showMenu(' + page + ')">Cancel <i class="fas fa-window-close"></i></button>';
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

//-----------------------SAVE Dish---------------------------
$(document).on('click', '#spremiJelo', function () {
    var NAZIV = $('#NAZIV').val();
    var SASTOJCI = $('#SASTOJCI').val();
    var CIJENA = $('#CIJENA').val();
    var ID = $('#ID').val();

    if (NAZIV == null || NAZIV == "") {
        Swal.fire('Molimo unesite naziv jela');
    } else if (SASTOJCI == null || SASTOJCI == "") {
        Swal.fire('Molimo unesite sastojke');
    } else if (CIJENA == null || CIJENA == "") {
        Swal.fire('Molimo unesite cijenu');
    } else {
        $.ajax({
            type: 'POST',
            url: url,
            data: {
                "projekt": projekt,
                "procedura": "p_save_pizza",
                "ID": ID,
                "NAZIV": NAZIV,
                "SASTOJCI": SASTOJCI,
                "CIJENA": CIJENA,
            },
            success: function (data) {
                var jsonBody = JSON.parse(data);
                var errcode = jsonBody.h_errcode;
                var message = jsonBody.h_message;
                console.log(data);

                if ((message == null || message == "") && (errcode == null || errcode == 0)) {
                    Swal.fire('Uspješno se unijeli jelo');
                } else {
                    Swal.fire(message + '.' + errcode);
                }
                refresh();
                showMenu();
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

//-------------------Brisanje jela---------------
function delDish(ID, page){
    Swal.fire({
        title: 'Želite li zaista obrisati jelo?',
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
                    "procedura": "p_save_pizza",
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
                            'ste obrisali jelo',
                            'success'
                        );
                    } else {
                        Swal.fire(message + '.' + errcode);
                    }
                    refresh();
                    showMenu();
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
//-------------------dodavanje jela u order---------------
function addDish(ID, page){
    Swal.fire({
        title: 'Dodaj jelo u narudzbu?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Da!',
        cancelButtonText: 'Ne!'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                type: 'POST',
                url: url,
                data: {
                    "projekt": projekt,
                    "procedura": "p_add_order",
                    "ID": ID,
                    "UID":userID
                },
                success: function (data) {
                    var jsonBody = JSON.parse(data);
                    var errcode = jsonBody.h_errcode;
                    var message = jsonBody.h_message;
                    console.log(data);

                    if ((message == null || message == "") && (errcode == null || errcode == 0)) {
                        Swal.fire(
                            'Uspješno ',
                            'ste dodali jelo',
                            'success'
                        );
                    } else {
                        Swal.fire(message + '.' + errcode);
                    }
                    refresh();
                    showMenu();
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