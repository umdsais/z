// Load Javascript for the admin-index page
$(document).bind('turbolinks:load', function () {
    if ($("body.admin\\/audits.index").length == 0) {
        return;
    }
    initializeAuditDataTable(5, "desc", 6, 3, false);
});

function initializeAuditDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, showMoveButton) {

    var userTable = $('#audits-table').DataTable({
        drawCallback: function(settings) {
            var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
            pagination.toggle(this.api().page.info().pages > 1);
        },
        "pageLength": 25,
        columns: [
            {data: '0' },
            {data: '1' },
            {data: '2' },
            {data: '3' },
            {data: '4' },
            {data: '5' }
        ],
        "processing": true,
        "serverSide": true,
        "ajax": $('#audits-table').data('source'),
        "pagingType": "full_numbers",
        "order": [
            sortColumn,
            sortOrder
        ],
        columnDefs: [
            {
                className: 'select-checkbox',
                targets:   0,
                title:"<input type='checkbox' id='select-all' class='select-checkbox'/>"
            },
            {
                orderable: false,
                searchable: false,
                targets: [0, actionColumn]
            }
        ],
        select: {
            style:    'multi',
            selector: 'td:first-child'
        }
    });
    $('table.data-table').on("page.dt", function(e){
        userTable.rows().deselect();
        $("#select-all").prop("checked", false);
    });
    $("#select-all").click(function(e){
        $(e.target).prop("checked") === true ? userTable.rows({page:"current"}).select() : userTable.rows().deselect();
    });

 }

