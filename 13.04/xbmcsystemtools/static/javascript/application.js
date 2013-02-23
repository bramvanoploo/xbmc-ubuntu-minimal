var loLoadingDialog;

$(document).ready(function(){
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
});

function showLoading(pstrMessage) {
	$('#loading .message').html(pstrMessage);
	loLoadingDialog.dialog('open');
}

function hideLoading() {
	$('#loading .message').html('');
	loLoadingDialog.dialog('close');
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
