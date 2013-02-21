var loSystemInfoWindow, loConsoleWindow, loLoadingDialog;

$(document).ready(function(){
	loSystemInfoWindow = $('#systemInfo').dialog({
        draggable: true,
        height: 470,
        width: 700,
        modal: true,
        resizable: false,
        autoOpen: false
    }).load('/system');

	loLoadingDialog = $("#loading").dialog({
        modal: true,
        draggable: true,
        height: 150,
        width: 450,
        autoOpen: false,
        closeOnEscape: false,
        open: function(event, ui) {
        	$(".ui-dialog-titlebar-close", ui.dialog).remove();
        }
  });

    $('#openSystemInfo').bind('click', function(){
    	loSystemInfoWindow.dialog('open');
        return false;
    });
});

function showLoading(pstrMessage) {
	$('#loading .message').html(pstrMessage);
	loLoadingDialog.dialog('open');
}

function hideLoading() {
	$('#loading .message').html('');
	loLoadingDialog.dialog('close');
}

function apiRequest(pstrMethod, poParams, pfCallback) {
	var loParams = (!poParams)? {} : poParams;

	$.ajax({
		type: 'GET',
		url: '/api',
		dataType: 'json',
		cache: false,
		data: {
			method: pstrMethod,
			params: JSON.stringify(loParams)
		},
		success: function(data, textStatus, jqXHR) {
			pfCallback(data);
		},
		error: function(jqXHR, textStatus, errorThrown) {

		}
	})
}

function getDateAndTime() {
	var currentTime = new Date();
	var month = currentTime.getMonth() + 1;
	var day = currentTime.getDate();
	var year = currentTime.getFullYear();
	var hours = currentTime.getHours();
	var minutes = currentTime.getMinutes();
	var seconds = currentTime.getSeconds();

	if (day < 10){
		day = "0" + day
	}

	if (month < 10){
		month = "0" + month
	}

	if (hours < 10){
		hours = "0" + hours
	}

	if (minutes < 10){
		minutes = "0" + minutes
	}

	if (seconds < 10){
		seconds = "0" + seconds
	}

	return day+ "-" +month+ "-" +year+ " " +hours+ ":" +minutes+ ":" +seconds;
}
