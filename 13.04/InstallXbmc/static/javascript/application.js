var loSystemInfoWindow, loConsoleWindow, loLoadingDialog;

$(document).ready(function(){
    $('#openSystemInfo').bind('click', function(){
        populateSystemInfo();
        loSystemInfoWindow.center();
        loSystemInfoWindow.open();
        return false;
    });

    loLoadingDialog = $('#loading').kendoWindow({
        actions: ["Minimize"],
        draggable: true,
        height: "180px",
        width: "500px",
        modal: true,
        visible: false,
        resizable: false,
        title: ""
    }).data("kendoWindow");

    loConsoleWindow = $('#console').kendoWindow({
        actions: ["Minimize"],
        draggable: false,
        height: "250px",
        width: "100%",
        modal: false,
        visible: true,
        resizable: false,
        title: "Console"
    }).data("kendoWindow");

    $('#console').closest(".k-window").css({
        bottom: "0px",
        left: "0px"
    });

    loLoadingDialog.center();
    loConsoleWindow.minimize();
});

function showLoading(pstrMessage) {
	$('#loading .message').html(pstrMessage);
	loLoadingDialog.open();
}

function hideLoading() {
	$('#loading .message').html('');
	loLoadingDialog.close();
}

function showConsole() {
	$('#console .k-i-restore').parent().trigger('click');
}

function hideConsole() {
	loConsoleWindow.minimize();
}

function populateSystemInfo() {
     loSystemInfoWindow = $('#systemInfo').kendoWindow({
        content: "/system",
        actions: ["Maximize", "Close"],
        draggable: true,
        height: "430px",
        width: "700px",
        modal: true,
        visible: false,
        resizable: false,
        title: "System information"
    }).data("kendoWindow");
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
