var loSystemInfoWindow, loConsoleWindow;

$(document).ready(function(){
    $('#openSystemInfo').bind('click', function(){
        populateSystemInfo();
        loSystemInfoWindow.center();
        loSystemInfoWindow.open();
        return false;
    });

    populateConsole();
    loConsoleWindow.minimize();
    
    populateFooter();
    setInterval("populateFooter()", 5000);
});

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

function populateConsole() {
     loConsoleWindow = $('#systemConsole').kendoWindow({
        content: "/system_console",
        actions: ["Minimize"],
        draggable: false,
        height: "300px",
        width: "100%",
        modal: false,
        visible: true,
        resizable: false,
        title: "Console"
    }).data("kendoWindow");
    
    $('#systemConsole').closest(".k-window").css({
        bottom: "0px",
        left: "0px"
    });
}

function populateFooter() {
    $.get('/footer', function(data) {
        $('#footer').html(data);
    });
}
