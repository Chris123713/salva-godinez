// Mission Creator NUI JavaScript

(function() {
    'use strict';

    // State
    const state = {
        visible: false,
        panelCollapsed: false,
        placementMode: false,
        currentDraft: null,
        checklistItems: [],
        activeItemIndex: -1,
        placementData: {
            heading: 0,
            heightOffset: 0
        },
        selectedTags: {
            role: null,
            location: null
        },
        pendingElement: null
    };

    // Tag definitions
    const tagDefinitions = {
        role: [
            'contact_npc', 'informant', 'enemy', 'guard', 'victim', 'hostage',
            'witness', 'getaway_driver', 'lookout', 'buyer', 'seller'
        ],
        location: [
            'alley', 'parking', 'industrial', 'residential', 'commercial',
            'dock', 'rooftop', 'interior', 'rural', 'beach', 'highway'
        ]
    };

    // DOM Elements
    const elements = {
        container: null,
        panel: null,
        collapseBtn: null,
        expandBtn: null,
        collapsedIndicator: null,
        teleportBtn: null,
        draftInfo: null,
        draftSynopsis: null,
        checklistContainer: null,
        checklistProgress: null,
        previewBtn: null,
        saveBtn: null,
        undoBtn: null,
        cancelBtn: null,
        placementHud: null,
        hudHeading: null,
        hudHeight: null,
        tagModal: null,
        tagModalClose: null,
        tagSaveBtn: null,
        roleTags: null,
        locationTags: null,
        elementNotes: null,
        modelModal: null,
        modelModalClose: null,
        modelConfirmBtn: null,
        modelSearch: null,
        modelList: null
    };

    // Initialize
    function init() {
        cacheElements();
        bindEvents();
        console.log('[MissionCreator] NUI initialized');
    }

    function cacheElements() {
        elements.container = document.getElementById('mission-creator');
        elements.panel = document.getElementById('panel');
        elements.collapseBtn = document.getElementById('collapse-btn');
        elements.expandBtn = document.getElementById('expand-btn');
        elements.collapsedIndicator = document.getElementById('collapsed-indicator');
        elements.teleportBtn = document.getElementById('teleport-btn');
        elements.draftInfo = document.getElementById('draft-info');
        elements.draftSynopsis = document.getElementById('draft-synopsis');
        elements.checklistContainer = document.getElementById('checklist-container');
        elements.checklistProgress = document.getElementById('checklist-progress');
        elements.previewBtn = document.getElementById('preview-btn');
        elements.saveBtn = document.getElementById('save-btn');
        elements.undoBtn = document.getElementById('undo-btn');
        elements.cancelBtn = document.getElementById('cancel-btn');
        elements.placementHud = document.getElementById('placement-hud');
        elements.hudHeading = document.getElementById('hud-heading');
        elements.hudHeight = document.getElementById('hud-height');
        elements.tagModal = document.getElementById('tag-modal');
        elements.tagModalClose = document.getElementById('tag-modal-close');
        elements.tagSaveBtn = document.getElementById('tag-save-btn');
        elements.roleTags = document.getElementById('role-tags');
        elements.locationTags = document.getElementById('location-tags');
        elements.elementNotes = document.getElementById('element-notes');
        elements.modelModal = document.getElementById('model-modal');
        elements.modelModalClose = document.getElementById('model-modal-close');
        elements.modelConfirmBtn = document.getElementById('model-confirm-btn');
        elements.modelSearch = document.getElementById('model-search');
        elements.modelList = document.getElementById('model-list');
    }

    function bindEvents() {
        // Panel collapse/expand
        elements.collapseBtn.addEventListener('click', collapsePanel);
        elements.expandBtn.addEventListener('click', expandPanel);

        // Action buttons
        elements.teleportBtn.addEventListener('click', teleportToArea);
        elements.previewBtn.addEventListener('click', previewAll);
        elements.saveBtn.addEventListener('click', saveBlueprint);
        elements.undoBtn.addEventListener('click', undoLast);
        elements.cancelBtn.addEventListener('click', cancel);

        // Modal close buttons
        elements.tagModalClose.addEventListener('click', closeTagModal);
        elements.tagSaveBtn.addEventListener('click', saveTagsAndElement);
        elements.modelModalClose.addEventListener('click', closeModelModal);
        elements.modelConfirmBtn.addEventListener('click', confirmModel);

        // Keyboard events
        document.addEventListener('keydown', handleKeyDown);

        // NUI message listener
        window.addEventListener('message', handleNUIMessage);
    }

    // NUI Message Handler
    function handleNUIMessage(event) {
        const data = event.data;

        switch (data.action) {
            case 'show':
                showUI(data);
                break;
            case 'hide':
                hideUI();
                break;
            case 'loadDraft':
                loadDraft(data.draft);
                break;
            case 'updateChecklist':
                updateChecklist(data.items);
                break;
            case 'startPlacement':
                startPlacementMode(data);
                break;
            case 'endPlacement':
                endPlacementMode();
                break;
            case 'updatePlacementInfo':
                updatePlacementInfo(data);
                break;
            case 'itemPlaced':
                markItemPlaced(data.index, data.coords);
                break;
            case 'showTagModal':
                showTagModal(data);
                break;
        }
    }

    // UI Visibility
    function showUI(data) {
        state.visible = true;
        elements.container.classList.remove('hidden');

        if (data && data.draft) {
            loadDraft(data.draft);
        }

        sendNUI('onShow', {});
    }

    function hideUI() {
        state.visible = false;
        elements.container.classList.add('hidden');
        endPlacementMode();
        sendNUI('onHide', {});
    }

    // Panel Collapse/Expand
    function collapsePanel() {
        state.panelCollapsed = true;
        elements.panel.classList.add('collapsed');
        elements.collapsedIndicator.classList.remove('hidden');
    }

    function expandPanel() {
        state.panelCollapsed = false;
        elements.panel.classList.remove('collapsed');
        elements.collapsedIndicator.classList.add('hidden');
    }

    // Draft Loading
    function loadDraft(draft) {
        state.currentDraft = draft;

        if (draft.synopsis) {
            elements.draftInfo.classList.remove('hidden');
            elements.draftSynopsis.textContent = draft.synopsis;
        } else {
            elements.draftInfo.classList.add('hidden');
        }

        if (draft.required_assets) {
            updateChecklist(draft.required_assets);
        }
    }

    // Checklist Management
    function updateChecklist(items) {
        state.checklistItems = items || [];
        renderChecklist();
        updateProgress();
    }

    function renderChecklist() {
        if (state.checklistItems.length === 0) {
            elements.checklistContainer.innerHTML = '<div class="empty-state">No assets to place</div>';
            return;
        }

        let html = '';
        state.checklistItems.forEach((item, index) => {
            const isCompleted = item.placed === true;
            const isActive = state.activeItemIndex === index;
            const statusClass = isCompleted ? 'completed' : (isActive ? 'active' : '');
            const checkmark = isCompleted ? '&#10003;' : '';
            const coords = item.coords
                ? `${item.coords.x.toFixed(1)}, ${item.coords.y.toFixed(1)}, ${item.coords.z.toFixed(1)}`
                : 'Click to place';

            html += `
                <div class="checklist-item ${statusClass}" data-index="${index}" onclick="window.missionCreator.selectItem(${index})">
                    <div class="item-checkbox">${checkmark}</div>
                    <div class="item-content">
                        <div class="item-title">${item.name || item.role || 'Asset'}</div>
                        <div class="item-type">${item.type || 'Unknown'}</div>
                        <div class="item-coords">${coords}</div>
                    </div>
                </div>
            `;
        });

        elements.checklistContainer.innerHTML = html;
    }

    function updateProgress() {
        const completed = state.checklistItems.filter(i => i.placed).length;
        const total = state.checklistItems.length;
        elements.checklistProgress.textContent = `${completed}/${total}`;
    }

    function selectItem(index) {
        const item = state.checklistItems[index];
        if (!item || item.placed) return;

        state.activeItemIndex = index;
        renderChecklist();

        // Request placement mode from client
        sendNUI('requestPlacement', {
            index: index,
            type: item.type,
            model: item.model,
            name: item.name || item.role
        });
    }

    function markItemPlaced(index, coords) {
        if (state.checklistItems[index]) {
            state.checklistItems[index].placed = true;
            state.checklistItems[index].coords = coords;
            state.activeItemIndex = -1;
            renderChecklist();
            updateProgress();
        }
    }

    // Placement Mode
    function startPlacementMode(data) {
        state.placementMode = true;
        state.placementData = {
            heading: data.heading || 0,
            heightOffset: data.heightOffset || 0
        };
        elements.placementHud.classList.remove('hidden');
        collapsePanel();
        updatePlacementInfo(data);
    }

    function endPlacementMode() {
        state.placementMode = false;
        elements.placementHud.classList.add('hidden');
        state.activeItemIndex = -1;
        renderChecklist();
    }

    function updatePlacementInfo(data) {
        if (data.heading !== undefined) {
            state.placementData.heading = data.heading;
            elements.hudHeading.textContent = `Heading: ${Math.round(data.heading)}°`;
        }
        if (data.heightOffset !== undefined) {
            state.placementData.heightOffset = data.heightOffset;
            const sign = data.heightOffset >= 0 ? '+' : '';
            elements.hudHeight.textContent = `Height: ${sign}${data.heightOffset.toFixed(1)}m`;
        }
    }

    // Tag Modal
    function showTagModal(data) {
        state.pendingElement = data;
        state.selectedTags = { role: null, location: null };
        elements.elementNotes.value = '';

        // Populate tag grids
        populateTagGrid(elements.roleTags, tagDefinitions.role, 'role');
        populateTagGrid(elements.locationTags, tagDefinitions.location, 'location');

        elements.tagModal.classList.remove('hidden');
    }

    function populateTagGrid(container, tags, category) {
        container.innerHTML = tags.map(tag =>
            `<div class="tag-item" data-tag="${tag}" data-category="${category}" onclick="window.missionCreator.selectTag('${category}', '${tag}', this)">${tag}</div>`
        ).join('');
    }

    function selectTag(category, tag, element) {
        // Remove selected from siblings
        const siblings = element.parentElement.querySelectorAll('.tag-item');
        siblings.forEach(el => el.classList.remove('selected'));

        // Toggle selection
        if (state.selectedTags[category] === tag) {
            state.selectedTags[category] = null;
        } else {
            state.selectedTags[category] = tag;
            element.classList.add('selected');
        }
    }

    function closeTagModal() {
        elements.tagModal.classList.add('hidden');
        state.pendingElement = null;
    }

    function saveTagsAndElement() {
        if (!state.pendingElement) return;

        const elementData = {
            ...state.pendingElement,
            primary_tag: state.selectedTags.role,
            location_tag: state.selectedTags.location,
            notes: elements.elementNotes.value
        };

        sendNUI('saveElement', elementData);
        closeTagModal();
    }

    // Model Modal
    function closeModelModal() {
        elements.modelModal.classList.add('hidden');
    }

    function confirmModel() {
        const selected = elements.modelList.querySelector('.model-item.selected');
        if (selected) {
            sendNUI('selectModel', { model: selected.dataset.model });
        }
        closeModelModal();
    }

    // Actions
    function teleportToArea() {
        sendNUI('teleport', { coords: state.currentDraft?.area_coords });
    }

    function previewAll() {
        sendNUI('previewAll', { items: state.checklistItems });
    }

    function saveBlueprint() {
        const incompleteCount = state.checklistItems.filter(i => !i.placed).length;
        if (incompleteCount > 0) {
            // Could show a confirmation dialog
            console.log(`Warning: ${incompleteCount} items not placed`);
        }
        sendNUI('saveBlueprint', {
            draft: state.currentDraft,
            items: state.checklistItems
        });
    }

    function undoLast() {
        sendNUI('undo', {});
    }

    function cancel() {
        sendNUI('cancel', {});
        hideUI();
    }

    // Keyboard Handler
    function handleKeyDown(event) {
        if (!state.visible) return;

        if (event.key === 'Escape') {
            if (state.placementMode) {
                sendNUI('cancelPlacement', {});
                endPlacementMode();
            } else if (!elements.tagModal.classList.contains('hidden')) {
                closeTagModal();
            } else if (!elements.modelModal.classList.contains('hidden')) {
                closeModelModal();
            } else {
                cancel();
            }
        }
    }

    // NUI Communication
    function sendNUI(action, data) {
        fetch(`https://sv_nexus_tools/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).catch(err => console.error('[MissionCreator] NUI fetch error:', err));
    }

    // Expose public methods
    window.missionCreator = {
        selectItem: selectItem,
        selectTag: selectTag
    };

    // Initialize on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
