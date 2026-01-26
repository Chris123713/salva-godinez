let isDialogActive = false;

// Messages received by client
window.addEventListener('message', (event) => {
	let data = event.data;
	let action = data.action;

	if (action != 'showNotAllowedDialog') return;
    if (isDialogActive) return;

    const div = $(`
    <div style="background: rgba(25, 25, 25, 0.7); width: 100%; height: 100%; position: absolute; display: flex; align-items: center;"">
        <div class="container border border-danger rounded py-3" style="background-color: #222; color: white; width: 50%;">
            <button type="button" class="btn-close btn-close-white float-end"></button>

            <p class="text-center fs-1">${getLocalizedText("menu:not_allowed:you_are_not_allowed")}</p>
            <p class="text-center fs-3">${getLocalizedText("menu:not_allowed:if_you_are_admin")}</p>
            <p class="text-center fs-3 text-danger">Server restart required</p>
            
            <p class="text-center fs-3 mt-5 mb-2"># Only use one of these. If one doesn't work, try another one</p>

            <div class="container text-warning p-2">
                <hr class="mb-4">
                
                ${data.playerIdentifiers["license"] ? `
                <div class="d-flex align-items-center">
                    <p class="not-allowed-license font-monospace mb-0 flex-grow-1"></p>
                    <button class="btn btn-warning ms-2 copy-btn" data-target="not-allowed-license">
                        <i class="bi bi-clipboard-fill"></i>
                    </button>
                </div>
                <hr class="my-4">
                ` : ''}
                
                ${data.playerIdentifiers["license2"] ? `
                <div class="d-flex align-items-center">
                    <p class="not-allowed-license2 font-monospace mb-0 flex-grow-1"></p>
                    <button class="btn btn-warning ms-2 copy-btn" data-target="not-allowed-license2">
                        <i class="bi bi-clipboard-fill"></i>
                    </button>
                </div>
                <hr class="my-4">
                ` : ''}

                ${data.playerIdentifiers["steam"] ? `
                <div class="d-flex align-items-center">
                    <p class="not-allowed-steamid font-monospace mb-0 flex-grow-1"></p>
                    <button class="btn btn-warning ms-2 copy-btn" data-target="not-allowed-steamid">
                        <i class="bi bi-clipboard-fill"></i>
                    </button>
                </div>
                ` : ''}
            </div>
        </div>
    </div>
    `);

    div.find('.btn-close').click(() => {
        div.remove();
        toggleCursor(false);

        isDialogActive = false;
    });

    div.find('.copy-btn').click(function() {
        const target = $(this).data('target');
        const text = div.find(`.${target}`).text().trim();
        
        // Create temporary textarea element
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        
        // Select and copy text
        textarea.select();
        document.execCommand('copy');
        
        // Remove temporary element
        document.body.removeChild(textarea);
        
        // Visual feedback
        const btn = $(this);
        const originalHtml = btn.html();
        btn.html('<i class="bi bi-check-lg"></i>');
        setTimeout(() => {
            btn.html(originalHtml);
        }, 1000);
    });

    if (data.playerIdentifiers["license"]) {
        div.find(".not-allowed-license").text(`
            add_ace identifier.license:${data.playerIdentifiers["license"]} ${data.acePermission} allow # Add permission to '${data.playerName}' Rockstar license
        `);
    }

    if (data.playerIdentifiers["license2"]) {
        div.find(".not-allowed-license2").text(`
            add_ace identifier.license2:${data.playerIdentifiers["license2"]} ${data.acePermission} allow # Add permission to '${data.playerName}' Rockstar license2
        `);
    }

    if (data.playerIdentifiers["steam"]) {
        div.find(".not-allowed-steamid").text(`
            add_ace identifier.steam:${data.playerIdentifiers["steam"]} ${data.acePermission} allow # Add permission to '${data.playerName}' Steam account
        `);
    }

    $("html").append(div);
    toggleCursor(true);

    isDialogActive = true;
})