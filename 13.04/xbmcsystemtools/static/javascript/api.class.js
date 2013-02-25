function Api() {
	this.request = function(pstrMethod, pstrParams, pfCallback) {
		var lstrParams = (pstrParams == undefined)? '' : pstrParams;
		var lfCallback = (pfCallback == undefined)? function(){} : pfCallback;

		$.ajax({
			type: 'GET',
			url: '/api',
			dataType: 'json',
			cache: false,
			data: {
				method: pstrMethod,
				params: lstrParams
			},
			success: function(data, textStatus, jqXHR) {
				lfCallback(data);
			},
			error: function(jqXHR, textStatus, errorThrown) {

			}
		});
	}

	this.getOperatingSystem = function(pstrTarget) {
		this.request('ubuntu.getVersion', '', function(poData){
			if(poData && poData.success) {
				$(pstrTarget).html(poData.result);
			}
		});
	}

	this.getCpuLoad = function(pstrTarget) {
		this.request('hardware.getCpuLoad', '', function(poData){
			if(poData && poData.success) {
				$(pstrTarget).html(poData.result);
			}
		});
	}

	this.getRamInUse = function(pstrTarget) {
		this.request('hardware.getRamInUse', '', function(poData){
			if(poData && poData.success) {
				$(pstrTarget).html(poData.result);
			}
		});
	}

	this.getTotalRam = function(pstrTarget) {
		this.request('hardware.getTotalRam', '', function(poData){
			if(poData && poData.success) {
				$(pstrTarget).html(poData.result);
			}
		});
	}

	this.aptInstall = function(pstrPackageName, pfCallback) {
		this.request('ubuntu.aptInstall', '"' +encodeURI(pstrPackageName)+ '"', function(poData){
			pfCallback(poData);
		});
	}

	this.aptRemove = function(pstrPackageName, pfCallback) {
		this.request('ubuntu.aptRemove', '"' +encodeURI(pstrPackageName)+ '"', function(poData){
			pfCallback(poData);
		});
	}

	this.aptUpdate = function(pfCallback) {
		this.request('ubuntu.aptUpdate', '', function(poData){
			pfCallback(poData);
		});
	}

	this.aptDistUpgrade = function(pfCallback) {
		this.request('ubuntu.aptDistUpgrade', '', function(poData){
			pfCallback(poData);
		});
	}

	this.addPpa = function(pstrPpa, pfCallback) {
		this.request('ubuntu.addPpa', '"' +encodeURI(pstrPpa)+ '"', function(poData){
			pfCallback(poData);
		});
	}

	this.removePpa = function(pstrPpa, pfCallback) {
		this.request('ubuntu.removePpa', '"' +encodeURI(pstrPpa)+ '"', function(poData){
			pfCallback(poData);
		});
	}

	this.getActivePpas = function(pfCallback){
		this.request('ubuntu.getActivePpas', '', function(poData){
			var laResult = (poData && poData.success)? poData.result : [];
			pfCallback(laResult);
		});
	}

	this.purgePpa = function(pstrPpa, pfCallback) {
		this.request('ubuntu.purgePpa', '"' +encodeURI(pstrPpa)+ '"', function(poData){
			pfCallback(poData);
		});
	}

	this.shutdown = function(pfCallback) {
		this.request('ubuntu.shutdown', '', function(poData){
			return (poData && poData.success)? pfCallback(poData.success) : pfCallback(false);
		});
	}

	this.reboot = function(pfCallback) {
		this.request('ubuntu.reboot', '', function(poData){
			return (poData && poData.success)? pfCallback(poData.success) : pfCallback(false);
		});
	}

	this.getAddonRepositories = function(pfCallback){
		this.request('addonRepositories.get', '', function(poData){
			pfCallback(poData);
		});
	}

	this.installAddonRepositoryFromUrl = function(pstrUrl, pstrFIleName, pfCallback){
		this.request('addonRepositories.install', '"' +encodeURI(pstrUrl)+ '","' +encodeURI(pstrFIleName)+ '"', function(poData){
			pfCallback(poData);
		});
	}
}
