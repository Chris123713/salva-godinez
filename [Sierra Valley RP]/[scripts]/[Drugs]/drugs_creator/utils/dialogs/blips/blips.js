function getDefaultBlipCustomization() {
	return {
		isEnabled: true,
		sprite: 480,
		label: "Auction",
		scale: "1.0",
		color: 1,
		display: 2,
        alpha: 255,
	}
}

async function blipDialog(currentBlipData) {
	return new Promise((resolve, reject) => {
		let div = $(`
        <div class="modal fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" role="dialog" style="z-index: 1070; background: rgba(25, 25, 25, 0.7);">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <form class="modal-content needs-validation" novalidate>
                    <div class="modal-header">
                        <h5 class="modal-title">${getLocalizedText("menu:blip_customization")}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body text-center">
                        <div class="form-check form-check-inline fs-4 mb-3">
                            <input class="form-check-input blip-enabled" type="checkbox" value="">
                            <label class="form-check-label">${getLocalizedText("menu:blip_enabled")}</label>
                        </div>

                        <div class="form-floating">
                            <input type="number" class="form-control blip-sprite" placeholder="Blip sprite" required>
                            <label>${getLocalizedText("menu:blip_sprite")}</label>
                        </div>
        
                        <a class="fst-italic" href="https://docs.fivem.net/docs/game-references/blips/" target="_blank" onclick='window.invokeNative("openUrl", "https://docs.fivem.net/docs/game-references/blips/")'>https://docs.fivem.net/docs/game-references/blips/</a>
        
                        <div class="form-floating mt-4">
                            <input type="text" class="form-control blip-name" placeholder="Blip name" required>
                            <label>${getLocalizedText("menu:blip_name")}</label>
                        </div>
        
                        <div class="mt-3">
                            <p class="fs-4">${getLocalizedText("menu:other")}</p>
        
                            <div class="row g-2 row-cols-auto align-items-center">
                                <div class="form-floating col-4">
                                    <input type="number" step="0.1" class="form-control blip-scale" placeholder="Blip scale" required>
                                    <label>${getLocalizedText("menu:blip_scale")}</label>
                                </div>
        
                                <div class="form-floating col-3">
                                    <input type="number" step="0.1" class="form-control blip-color" placeholder="Blip color" required>
                                    <label>${getLocalizedText("menu:blip_color")}</label>
                                </div>

                                <div class="form-floating col-5">
                                    <input type="number" min="0" max="255" class="form-control blip-transparency" placeholder="Blip transparency" required>
                                    <label>${getLocalizedText("menu:blip_transparency")}</label>
                                </div>
                            </div>
        
                            <select class="form-select col-12 mt-3 blip-display">
                                <option value="5" selected>${getLocalizedText("menu:blip_minimap_only")}</option>
                                <option value="3">${getLocalizedText("menu:blip_mainmap_only")}</option>
                                <option value="2">${getLocalizedText("menu:blip_main_and_minimap")}</option>
                            </select>
                        </div>
                    </div>
        
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">${getLocalizedText("menu:close")}</button>
                        <button type="submit" class="btn btn-success">${getLocalizedText("menu:confirm")}</button>
                    </div>
                </form>
            </div>
        </div>	
        `);

        // delete the div when the modal is closed
        div.on("hidden.bs.modal", function() {
            div.remove();
        });

		if(!currentBlipData) {
			currentBlipData = getDefaultBlipCustomization()
		}

		div.find(".blip-enabled").prop("checked", currentBlipData.isEnabled).change();
		div.find(".blip-sprite").val(currentBlipData.sprite);
		div.find(".blip-name").val(currentBlipData.label);
		div.find(".blip-color").val(currentBlipData.color);
		div.find(".blip-display").val(currentBlipData.display);
		div.find(".blip-scale").val(currentBlipData.scale);
		div.find(".blip-transparency").val(currentBlipData.alpha);

        div.find(".blip-enabled").change(function() {
            let isEnabled = $(this).prop("checked");
        
            div.find("input, select").not( $(this) )
                .prop("disabled", !isEnabled)
                .prop("required", isEnabled);
        })

		div.find("form").submit(function(event) {
            if(isThereAnyErrorInForm(event)) return;

			let blipData = {
				isEnabled: div.find(".blip-enabled").prop("checked"),
				sprite: parseInt( div.find(".blip-sprite").val() ),
				label: div.find(".blip-name").val(),
				scale: parseFloat( div.find(".blip-scale").val() ),
				color: parseInt( div.find(".blip-color").val() ),
				display: parseInt( div.find(".blip-display").val() ),
                alpha: parseInt( div.find(".blip-transparency").val() ),
			}

			div.modal("hide");

			resolve(blipData);
		})

		div.modal("show");
	});
}