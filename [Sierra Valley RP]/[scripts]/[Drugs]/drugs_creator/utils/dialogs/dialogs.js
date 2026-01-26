let dialogsLoadingTimeoutId = null;

function toggleCursor(enabled) {
	if (enabled) {
		$.post(`https://${resName}/enableCursor`, JSON.stringify({}));
	} else {
		$.post(`https://${resName}/disableCursor`, JSON.stringify({}));
	}
}

function loadDialog(dialogName) {
	var script = document.createElement('script');

	console.log(`../utils/dialogs/${dialogName}/${dialogName}.js`)
	script.setAttribute('src',`../utils/dialogs/${dialogName}/${dialogName}.js`);

	document.head.appendChild(script);
}

// Messages received by client
window.addEventListener('message', (event) => {
	let data = event.data;
	let action = data.action;

	switch(action) {
		case "loadDialog": {
			if(dialogsLoadingTimeoutId !== null) {
				clearTimeout(dialogsLoadingTimeoutId);
				dialogsLoadingTimeoutId = null;
			}

			if(dialogsLoadingTimeoutId === null) {
				dialogsLoadingTimeoutId = setTimeout(() => {
					const event = new CustomEvent('allDialogsLoaded');
					window.dispatchEvent(event);
				}, 2000);
			}
			

			var script = document.createElement('script');
			script.setAttribute('src',`../utils/dialogs/${data.dialogName}/${data.dialogName}.js`);
			document.head.appendChild(script);
			break;
		}
	}
})

$.post(`https://${resName}/nuiReady`, JSON.stringify({}));