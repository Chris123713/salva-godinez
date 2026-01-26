function setRewardDivData(rewardDiv, data) {
    if(typeof rewardDiv === "string") rewardDiv = $(rewardDiv);
    
    const chooseObjectDiv = rewardDiv.find(".choose-object-div");
    setChoosenObject(chooseObjectDiv, data.object);

    rewardDiv.find(".reward-metadata-field-id").val(data.metadataFieldId);
    rewardDiv.find(`.reward-type[value=${data.worthType}]`).prop("checked", true).change();
}

function getRewardDivData(rewardDiv) {
    if(typeof rewardDiv === "string") rewardDiv = $(rewardDiv);

	return {
		worthType: rewardDiv.find(".reward-type:checked").val(),
		object: getChoosenObject(rewardDiv.find(".choose-object-div")),
		metadataFieldId: rewardDiv.find(".reward-metadata-field-id").val()
	}
}

function loadRewardDiv(div) {
    const radioName = generateStaticId();

    // has a data-translation-id
    const title = div.data("translation-id") ? getLocalizedText(div.data("translation-id")) : "Reward";

    div.html(`
    <h3 class="mb-2 text-center"><i class="bi bi-cash-stack"></i> <span>${title}</span></h3>
        
    <div class="d-flex gap-3 justify-content-center">
        <div class="choose-object-div input-group w-25" data-metadata-disabled>
            <input type="text" class="form-control choose-object-label disabled-input" placeholder="Item ID" required>
            <button type="button" class="btn btn-secondary choose-object-btn" data-bs-toggle="tooltip" data-bs-placement="top" title="${getLocalizedText("menu:dialog:choose_item")}"><i class="bi bi-list-ul"></i></button>
        </div>	

        <div class="d-flex">
            <div class="form-check form-check-inline my-auto">
                <input class="form-check-input reward-type" type="radio" name="${radioName}" id="${radioName}-quantity" value="quantity" required>
                <label class="form-check-label" data-bs-toggle="tooltip" data-bs-placement="top" title="${getLocalizedText("menu:settings:black_money:quantity")}">Quantity</label>
            </div>

            <div class="form-check form-check-inline my-auto">
                <input class="form-check-input reward-type" type="radio" name="${radioName}" id="${radioName}-metadata" value="metadata">
                <label class="form-check-label" data-bs-toggle="tooltip" data-bs-placement="top" title="${getLocalizedText("menu:settings:black_money:metadata")}">Metadata</label>
            </div>

            <div class="input-group reward-metadata-field-id-div" style="display: none;">
                <span class="input-group-text">Metadata field ID</span>
                <input class="form-control reward-metadata-field-id" type="text" placeholder="worth">
            </div>
        </div>
    </div>
    `);

    const chooseObjectDiv = div.find(".choose-object-div");
    loadChooseObjectDivs(chooseObjectDiv);

    div.tooltip();

    div.find(".reward-type").change(function() {
        const worthType = $(this).val();
        const isMetadata = worthType === "metadata";
        
        div.find(".reward-metadata-field-id-div").toggle(isMetadata);
        div.find(".reward-metadata-field-id").prop("required", isMetadata);
    });
}

window.addEventListener('menuOpened', (e) => {
	$(".reward-div").each(function() {
        loadRewardDiv($(this));
    });
}, { once: true });
