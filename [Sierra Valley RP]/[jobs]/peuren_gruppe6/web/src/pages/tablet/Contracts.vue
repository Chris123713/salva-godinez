<script setup>
    import { useGlobalState } from '../../stores/globalStore';
    import { useConfirm } from "primevue/useconfirm";
    import { fetchNui } from '../../utils';
    import { ref, onMounted, computed } from "vue";

    import ConfirmPopup from 'primevue/confirmpopup';
    import { locale } from "../../locale";

    const globalState = useGlobalState();
    const pageData = globalState.pageData.value;
    const confirm = useConfirm();
    const searchQuery = ref('');
    const selectedCategory = ref('all');
    
    const showConfirmModal = ref(false);
    const pendingContract = ref(null);
    const pendingContractIndex = ref(null);
    
    const hasAccess = ref(true);
    const isCheckingAccess = ref(false);
    
    const currentJobType = ref(pageData.current?.args?.job || null);
    const activeContractData = ref(null);
    
    if (currentJobType.value && pageData.contracts) {
        activeContractData.value = pageData.contracts.find(c => c.type === currentJobType.value) || null;
    }

    const filteredContracts = computed(() => {
        let contracts = pageData.contracts || [];
        
        if (searchQuery.value) {
            contracts = contracts.filter(c => 
                c.title.toLowerCase().includes(searchQuery.value.toLowerCase())
            );
        }

        if (selectedCategory.value !== 'all') {
            contracts = contracts.filter(c => c.category === selectedCategory.value);
        }

        return contracts;
    });

    const categories = computed(() => {
        const cats = new Set(pageData.contracts?.map(c => c.category).filter(Boolean) || []);
        return Array.from(cats);
    });

    const activeContract = computed(() => {
        return activeContractData.value;
    });

    const isActiveContract = (contract) => {
        return activeContractData.value && activeContractData.value.type === contract.type;
    };

    const TakeContract = (event, index, contract) => {
        if (globalState.isTabletMode.value) {
            pendingContract.value = contract;
            pendingContractIndex.value = index;
            showConfirmModal.value = true;
        } else {
            confirm.require({
                target: event.currentTarget,            
                message: locale('tablet', 'take_contract_confirm'),
                icon: 'pi pi-exclamation-triangle',
                rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
                acceptClass: 'p-button-sm',
                rejectLabel: locale('tablet', 'no'),
                acceptLabel: locale('tablet', 'yes'),
                accept: async () => {               
                    const result = await fetchNui("takeContract", contract);
                    if (!result) return;
                    pageData.contracts[index] = result;
                    if (!pageData.current) {
                        pageData.current = { args: {} };
                    }
                    if (!pageData.current.args) {
                        pageData.current.args = {};
                    }
                    pageData.current.args.job = contract.type;
                    currentJobType.value = contract.type;
                    activeContractData.value = contract;
                }
            });
        }
    };
    
    const confirmTakeContract = async () => {
        const result = await fetchNui("takeContract", pendingContract.value);
        if (result) {
            pageData.contracts[pendingContractIndex.value] = result;
            if (!pageData.current) {
                pageData.current = { args: {} };
            }
            if (!pageData.current.args) {
                pageData.current.args = {};
            }
            pageData.current.args.job = pendingContract.value.type;
            currentJobType.value = pendingContract.value.type;
            activeContractData.value = pendingContract.value;
        }
        closeConfirmModal();
    };
    
    const closeConfirmModal = () => {
        showConfirmModal.value = false;
        pendingContract.value = null;
        pendingContractIndex.value = null;
    };

    const displayTime = (time) => {
        var totalSeconds = Math.floor(time / 1000);
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds % 3600) / 60);
        var seconds = totalSeconds % 60;

        var formattedHours = String(hours).padStart(2, '0');
        var formattedMinutes = String(minutes).padStart(2, '0');
        var formattedSeconds = String(seconds).padStart(2, '0');

        return formattedHours + ':' + formattedMinutes + ':' + formattedSeconds;
    }

    const updateCooldowns = () => {
        setInterval(async () => {
            let data = pageData.contracts
            for (const key in data) {
                let contract = pageData.contracts[key]
                if (typeof contract.cooldown === 'number') {
                    if (contract.leftTime >= 0) {
                        contract.leftTime = (contract.cooldown * 1000) - Date.now()
                    } else {
                        contract.cooldown = false;
                        contract.leftTime = 0;
                    }
                }
            }
        }, 1000);
    };

    const checkJobState = async () => {
        isCheckingAccess.value = true;
        try {
            const result = await fetchNui("checkJobState");
            hasAccess.value = result === true;
        } catch (e) {
            hasAccess.value = false;
        }
        isCheckingAccess.value = false;
    };

    onMounted(async () => {
        await checkJobState();
        updateCooldowns();
    });
</script>

<template>
    <div class="contracts-container" :class="{ 'tablet-fullscreen': globalState.isTabletMode.value }">
        <div v-if="!hasAccess" class="no-access-overlay">
            <div class="no-access-content">
                <div class="no-access-icon">
                    <i class="pi pi-lock"></i>
                </div>
                <h2>No Access</h2>
                <p>You don't have access to this app. Make sure you have an active job started.</p>
                <button class="retry-btn" @click="checkJobState" :disabled="isCheckingAccess">
                    <i class="pi" :class="isCheckingAccess ? 'pi-spin pi-spinner' : 'pi-refresh'"></i>
                    <span>{{ isCheckingAccess ? 'Checking...' : 'Try Again' }}</span>
                </button>
            </div>
        </div>
        
        <div class="contracts-wrapper" v-show="hasAccess">
            <div class="header-section">
                <div class="header-top">
                    <div class="header-title">
                        <div class="icon-badge">
                            <i class="pi pi-briefcase"></i>
                        </div>
                        <div>
                            <h2>{{ locale('tablet', 'active_calls') }}</h2>
                            <p class="subtitle">{{ filteredContracts.length }} {{ locale('tablet', 'available_contracts') }}</p>
                        </div>
                    </div>
                </div>

                <div v-if="activeContract" class="current-contract-banner">
                    <div class="current-contract-icon">
                        <i class="pi pi-clock"></i>
                    </div>
                    <div class="current-contract-info">
                        <span class="current-label">Current Contract</span>
                        <span class="current-title">{{ activeContract.title }}</span>
                    </div>
                    <div class="current-contract-stats">
                        <div class="current-stat">
                            <i class="pi pi-shopping-bag"></i>
                            <span>{{ activeContract.bags }} bags</span>
                        </div>
                        <div class="current-stat">
                            <i class="pi pi-money-bill"></i>
                            <span>${{ activeContract.rewards?.Money?.amount || 0 }}</span>
                        </div>
                    </div>
                </div>

                <div class="categories-scroll" v-if="categories.length > 0">
                    <button 
                        @click="selectedCategory = 'all'"
                        :class="['category-btn', { active: selectedCategory === 'all' }]"
                    >
                        All
                    </button>
                    <button 
                        v-for="cat in categories"
                        :key="cat"
                        @click="selectedCategory = cat"
                        :class="['category-btn', { active: selectedCategory === cat }]"
                    >
                        {{ cat }}
                    </button>
                </div>
            </div>

            <div class="contracts-list">
                <template v-if="filteredContracts.length > 0">
                    <div class="contracts-scroll">
                        <div 
                            v-for="(contract, index) in filteredContracts"
                            :key="index"
                            class="contract-item"
                            :class="{ 'locked': pageData.profile.rank.Level < contract.level || typeof contract.cooldown === 'number' || isActiveContract(contract), 'active-contract': isActiveContract(contract) }"
                        >
                            <div class="contract-image">
                                <img src="/header.png" alt="Contract" class="contract-banner">
                                <div class="image-gradient"></div>
                                <div class="contract-icon">
                                    <img :src="`https://cfx-nui-peuren_gruppe6/web/dist/${contract.icon}.png`" :alt="contract.title">
                                </div>
                            </div>

                            <div class="contract-body">
                                <div class="contract-header">
                                    <h3>{{ contract.title }}</h3>
                                    <div v-if="pageData.profile.rank.Level < contract.level" class="level-badge">
                                        <i class="pi pi-star"></i>
                                        <span>Lvl {{ contract.level }}</span>
                                    </div>
                                </div>

                                <div class="contract-stats">
                                    <div class="stat">
                                        <div class="stat-icon">
                                            <i class="pi pi-shopping-bag"></i>
                                        </div>
                                        <div class="stat-content">
                                            <span class="label">{{ locale('tablet', 'contract_bags') }}</span>
                                            <span class="value">{{ contract.bags }}</span>
                                        </div>
                                    </div>
                                    <div class="stat-divider"></div>
                                    <div class="stat">
                                        <div class="stat-icon">
                                            <i class="pi pi-money-bill"></i>
                                        </div>
                                        <div class="stat-content">
                                            <span class="label">Reward</span>
                                            <span class="value">${{ contract.rewards.Money.amount }}</span>
                                        </div>
                                    </div>
                                </div>

                                <button 
                                    @click="TakeContract($event, index, contract)"
                                    :disabled="pageData.profile.rank.Level < contract.level || typeof contract.cooldown === 'number' || isActiveContract(contract)"
                                    class="take-btn"
                                >
                                    <i class="pi pi-check"></i>
                                    <span>{{ locale('tablet', 'contract_take') }}</span>
                                </button>
                            </div>

                            <div v-if="pageData.profile.rank.Level < contract.level || typeof contract.cooldown === 'number' || isActiveContract(contract)" class="lock-badge" :class="{ 'active-badge': isActiveContract(contract) }">
                                <div class="lock-content">
                                    <div class="icon-wrapper">
                                        <i v-if="isActiveContract(contract)" class="pi pi-clock"></i>
                                        <i v-else-if="pageData.profile.rank.Level < contract.level" class="pi pi-lock"></i>
                                        <i v-else class="pi pi-clock"></i>
                                    </div>
                                    <span v-if="isActiveContract(contract)">In Progress</span>
                                    <span v-else-if="pageData.profile.rank.Level < contract.level">Level {{ contract.level }}</span>
                                    <span v-else>{{ displayTime(contract.leftTime) }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </template>
            </div>
        </div>
        <ConfirmPopup></ConfirmPopup>
        
        <div v-if="showConfirmModal" class="confirm-modal-overlay" @click.self="closeConfirmModal">
            <div class="confirm-modal">
                <div class="confirm-icon">
                    <i class="pi pi-exclamation-triangle"></i>
                </div>
                <h3>{{ locale('tablet', 'take_contract_confirm') }}</h3>
                <div class="confirm-buttons">
                    <button class="confirm-btn cancel" @click="closeConfirmModal">
                        {{ locale('tablet', 'no') }}
                    </button>
                    <button class="confirm-btn accept" @click="confirmTakeContract">
                        {{ locale('tablet', 'yes') }}
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
:deep(.p-confirm-popup) {
    z-index: 10000 !important;
}

.contracts-container {
    display: flex;
    padding: 0;
    height: 100%;
    width: 100%;
    color: white;
    background: rgb(24, 24, 24);

    &.tablet-fullscreen {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        z-index: 9999;
        min-height: unset;
        max-height: unset;
        padding: 0 !important;

        .contracts-wrapper {
            width: 100%;
            height: 100%;
            padding: 2vh 3vh !important;

            .header-section {
                padding: 2vh 4vh !important;

                .header-top {
                    .header-title {
                        gap: 3vh;

                        .icon-badge {
                            width: 8vh;
                            height: 8vh;

                            i {
                                font-size: 4vh;
                            }
                        }

                        h2 {
                            font-size: 3.5vh;
                        }

                        .subtitle {
                            font-size: 1.8vh;
                        }
                    }
                }

                .current-contract-banner {
                    padding: 2vh 3vh;
                    margin-top: 2.5vh;
                    gap: 3vh;

                    .current-contract-icon {
                        width: 6vh;
                        height: 6vh;

                        i {
                            font-size: 3vh;
                        }
                    }

                    .current-contract-info {
                        .current-label {
                            font-size: 1.4vh;
                        }

                        .current-title {
                            font-size: 2.2vh;
                        }
                    }

                    .current-contract-stats {
                        gap: 2.5vh;

                        .current-stat {
                            padding: 1vh 2vh;

                            i {
                                font-size: 1.8vh;
                            }

                            span {
                                font-size: 1.6vh;
                            }
                        }
                    }
                }

                .categories-scroll {
                    gap: 1.5vh;

                    .category-btn {
                        padding: 1.2vh 2.5vh;
                        font-size: 1.6vh;
                    }
                }
            }

            .contracts-list {
                padding: 2vh !important;
                justify-content: flex-start;

                .contracts-scroll {
                    gap: 3vh;
                }

                .contract-item {
                    width: 42vh;
                    padding: 3vh !important;
                    gap: 2vh;

                    .contract-image {
                        height: 18vh;

                        .contract-icon {
                            img {
                                width: 11vh;
                                height: 11vh;
                            }
                        }
                    }

                    .contract-body {
                        gap: 2.5vh;

                        .contract-header {
                            gap: 1.2vh;

                            h3 {
                                font-size: 2.4vh;
                            }

                            .level-badge {
                                padding: 0.8vh 1.5vh;
                                font-size: 1.4vh;

                                i {
                                    font-size: 1.3vh;
                                }
                            }
                        }

                        .contract-stats {
                            gap: 2vh;

                            .stat {
                                gap: 1.8vh;

                                .stat-icon {
                                    width: 5vh;
                                    height: 5vh;

                                    i {
                                        font-size: 2vh;
                                    }
                                }

                                .stat-content {
                                    .label {
                                        font-size: 1.3vh;
                                    }

                                    .value {
                                        font-size: 2vh;
                                    }
                                }
                            }
                        }

                        .take-btn {
                            padding: 1.5vh 3vh;
                            font-size: 1.6vh;

                            i {
                                font-size: 1.6vh;
                            }
                        }
                    }

                    .lock-badge {
                        .lock-content {
                            gap: 1.2vh;

                            .icon-wrapper {
                                display: flex;
                                justify-content: center;
                                align-items: center;
                                width: 8vh;
                                height: 8vh;

                                i {
                                    font-size: 3.5vh;
                                }
                            }

                            span {
                                font-size: 1.6vh;
                            }
                        }
                    }
                }

                .empty-state {
                    .empty-icon {
                        width: 12vh;
                        height: 12vh;

                        i {
                            font-size: 6vh;
                        }
                    }

                    h3 {
                        font-size: 2.8vh;
                    }

                    p {
                        font-size: 1.8vh;
                    }
                }
            }
        }
    }

    .contracts-wrapper {
        flex: 1;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        background: rgb(24, 24, 24);

        .header-section {
            flex-shrink: 0;
            padding: 3vh 4vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            background: rgb(32, 32, 32);

            .header-top {
                .header-title {
                    display: flex;
                    align-items: center;
                    gap: 2vh;

                    .icon-badge {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 5vh;
                        height: 5vh;
                        background: rgba(87, 182, 87, 0.1);
                        border: 2px solid rgba(87, 182, 87, 0.3);
                        border-radius: 0.6vh;

                        i {
                            font-size: 2.4vh;
                            color: rgb(87, 182, 87);
                        }
                    }

                    h2 {
                        margin: 0;
                        font-size: 2.2vh;
                        font-weight: 700;
                        letter-spacing: -0.5px;
                    }

                    .subtitle {
                        display: block;
                        font-size: 1.2vh;
                        color: rgba(255, 255, 255, 0.4);
                        margin-top: 0.4vh;
                    }
                }
            }

            .current-contract-banner {
                display: flex;
                align-items: center;
                gap: 2vh;
                padding: 1.5vh 2vh;
                margin-top: 2vh;
                background: rgba(87, 182, 87, 0.1);
                border: 1px solid rgba(87, 182, 87, 0.3);
                border-radius: 0.6vh;

                .current-contract-icon {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 4vh;
                    height: 4vh;
                    background: rgba(87, 182, 87, 0.2);
                    border-radius: 50%;

                    i {
                        font-size: 2vh;
                        color: rgb(87, 182, 87);
                    }
                }

                .current-contract-info {
                    display: flex;
                    flex-direction: column;
                    gap: 0.3vh;
                    flex: 1;

                    .current-label {
                        font-size: 1vh;
                        color: rgba(87, 182, 87, 0.8);
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        font-weight: 600;
                    }

                    .current-title {
                        font-size: 1.6vh;
                        font-weight: 600;
                        color: white;
                    }
                }

                .current-contract-stats {
                    display: flex;
                    gap: 2vh;

                    .current-stat {
                        display: flex;
                        align-items: center;
                        gap: 0.6vh;
                        padding: 0.6vh 1.2vh;
                        background: rgba(255, 255, 255, 0.05);
                        border-radius: 0.4vh;

                        i {
                            font-size: 1.2vh;
                            color: rgb(87, 182, 87);
                        }

                        span {
                            font-size: 1.2vh;
                            font-weight: 500;
                            color: rgba(255, 255, 255, 0.8);
                        }
                    }
                }
            }

            .search-bar {
                position: relative;
                margin-bottom: 2vh;

                i {
                    position: absolute;
                    left: 1.2vh;
                    top: 50%;
                    transform: translateY(-50%);
                    color: rgba(255, 255, 255, 0.3);
                    font-size: 1.2vh;
                }

                .search-input {
                    width: 100%;
                    padding: 1.2vh 1.2vh 1.2vh 3.5vh;
                    background: rgb(24, 24, 24);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    border-radius: 0.6vh;
                    color: white;
                    font-size: 1.4vh;
                    transition: all 0.2s ease;

                    &::placeholder {
                        color: rgba(255, 255, 255, 0.3);
                    }

                    &:focus {
                        outline: none;
                        border-color: rgba(87, 182, 87, 0.5);
                        background: rgba(87, 182, 87, 0.05);
                        box-shadow: 0 0 0 3px rgba(87, 182, 87, 0.1);
                    }
                }
            }

            .categories-scroll {
                display: flex;
                gap: 1vh;
                overflow-x: auto;
                padding-bottom: 0.5vh;
                scroll-behavior: smooth;

                &::-webkit-scrollbar {
                    height: 0.3vh;
                }

                &::-webkit-scrollbar-track {
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 1vh;
                }

                &::-webkit-scrollbar-thumb {
                    background: rgba(87, 182, 87, 0.3);
                    border-radius: 1vh;

                    &:hover {
                        background: rgba(87, 182, 87, 0.5);
                    }
                }

                .category-btn {
                    flex-shrink: 0;
                    padding: 0.8vh 1.8vh;
                    background: rgba(255, 255, 255, 0.05);
                    border: 1px solid rgba(255, 255, 255, 0.08);
                    border-radius: 0.5vh;
                    color: rgba(255, 255, 255, 0.6);
                    font-size: 1.2vh;
                    font-weight: 500;
                    cursor: pointer;
                    transition: all 0.2s ease;
                    white-space: nowrap;

                    &:hover {
                        background: rgba(255, 255, 255, 0.08);
                        border-color: rgba(87, 182, 87, 0.3);
                        color: rgba(255, 255, 255, 0.8);
                    }

                    &.active {
                        background: rgb(87, 182, 87);
                        border-color: rgb(87, 182, 87);
                        color: white;
                    }
                }
            }
        }

        .contracts-list {
            flex: 1;
            overflow-x: auto;
            overflow-y: hidden;
            padding: 3vh 4vh;
            scroll-behavior: smooth;
            display: flex;
            align-items: center;

            &::-webkit-scrollbar {
                height: 0.4vh;
            }

            &::-webkit-scrollbar-track {
                background: rgba(255, 255, 255, 0.05);
                border-radius: 1vh;
            }

            &::-webkit-scrollbar-thumb {
                background: rgba(87, 182, 87, 0.3);
                border-radius: 1vh;

                &:hover {
                    background: rgba(87, 182, 87, 0.5);
                }
            }

            .contracts-scroll {
                display: flex;
                gap: 2vh;
                height: 100%;
                width: fit-content;

                &::-webkit-scrollbar {
                    display: none;
                }
            }

            .contract-item {
                display: flex;
                flex-direction: column;
                gap: 1.5vh;
                padding: 2vh;
                background: rgb(32, 32, 32);
                border: 1px solid rgba(255, 255, 255, 0.08);
                border-radius: 0.8vh;
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
                padding: 1vh;
                width: 28vh;
                flex-shrink: 0;
                height: 100%;

                &:hover:not(.locked) {
                    border-color: rgba(87, 182, 87, 0.4);
                    background: rgba(87, 182, 87, 0.05);
                    transform: translateY(-0.3vh);
                }

                &.locked {
                    opacity: 0.6;
                    pointer-events: none;
                }

                .contract-image {
                    position: relative;
                    width: 100%;
                    height: 12vh;
                    border-radius: 0.6vh;
                    overflow: hidden;
                    flex-shrink: 0;

                    .contract-banner {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                    }

                    .image-gradient {
                        position: absolute;
                        inset: 0;
                        background: linear-gradient(135deg, rgba(87, 182, 87, 0.2) 0%, transparent 100%);
                    }

                    .contract-icon {
                        position: absolute;
                        inset: 0;
                        display: flex;
                        align-items: center;
                        justify-content: center;

                        img {
                            width: 7vh;
                            height: 7vh;
                            object-fit: contain;
                            filter: drop-shadow(0 0.4vh 0.8vh rgba(0, 0, 0, 0.4));
                        }
                    }
                }

                .contract-body {
                    display: flex;
                    flex-direction: column;
                    gap: 1.2vh;
                    flex: 1;
                    min-width: 0;

                    .contract-header {
                        display: flex;
                        flex-direction: column;
                        gap: 0.8vh;

                        h3 {
                            margin: 0;
                            font-size: 1.6vh;
                            font-weight: 600;
                            line-height: 1.3;
                            word-wrap: break-word;
                        }

                        .level-badge {
                            align-self: flex-start;
                            display: flex;
                            align-items: center;
                            gap: 0.4vh;
                            padding: 0.5vh 1vh;
                            background: rgba(255, 184, 0, 0.1);
                            border: 1px solid rgba(255, 184, 0, 0.3);
                            border-radius: 0.4vh;
                            color: #ffb800;
                            font-size: 1vh;
                            font-weight: 600;

                            i {
                                font-size: 0.9vh;
                            }
                        }
                    }

                    .contract-stats {
                        display: flex;
                        flex-direction: column;
                        gap: 0.8vh;

                        .stat {
                            display: flex;
                            align-items: center;
                            gap: 1vh;

                            .stat-icon {
                                width: 3.2vh;
                                height: 3.2vh;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                background: rgba(87, 182, 87, 0.1);
                                border-radius: 0.4vh;
                                flex-shrink: 0;

                                i {
                                    font-size: 1.2vh;
                                    color: rgb(87, 182, 87);
                                }
                            }

                            .stat-content {
                                display: flex;
                                flex-direction: column;
                                gap: 0.2vh;

                                .label {
                                    display: block;
                                    font-size: 0.9vh;
                                    color: rgba(255, 255, 255, 0.4);
                                }

                                .value {
                                    display: block;
                                    font-size: 1.3vh;
                                    font-weight: 600;
                                    color: #8ac84d;
                                }
                            }
                        }

                        .stat-divider {
                            display: none;
                        }
                    }

                    .take-btn {
                        width: 100%;
                        padding: 0.9vh 1.8vh;
                        background: rgb(87, 182, 87);
                        border: 1px solid rgb(87, 182, 87);
                        border-radius: 0.5vh;
                        color: white;
                        font-size: 1.1vh;
                        font-weight: 600;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 0.6vh;
                        transition: all 0.2s ease;
                        box-shadow: 0 0.2vh 0.4vh rgba(87, 182, 87, 0.2);

                        i {
                            font-size: 1.1vh;
                        }

                        &:hover:not(:disabled) {
                            background: rgb(70, 160, 70);
                            border-color: rgb(70, 160, 70);
                            transform: translateY(-0.2vh);
                            box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.3);
                        }

                        &:disabled {
                            opacity: 0.5;
                            cursor: not-allowed;
                        }
                    }
                }

                .lock-badge {
                    position: absolute;
                    inset: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    background: rgba(13, 14, 17, 0.85);
                    backdrop-filter: blur(0.4vh);
                    border-radius: 0.8vh;
                    z-index: 10;

                    &.active-badge {
                        background: rgba(87, 182, 87, 0.15);
                        border: 1px solid rgba(87, 182, 87, 0.3);

                        .lock-content {
                            .icon-wrapper {
                                width: 5vh;
                                height: 5vh;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                background: rgba(87, 182, 87, 0.2);
                                border-radius: 50%;
                                
                                i {
                                    color: rgb(87, 182, 87);
                                    font-size: 2.4vh;
                                }
                            }

                            span {
                                color: rgb(87, 182, 87);
                            }
                        }
                    }

                    .lock-content {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 0.8vh;
                        text-align: center;

                        .icon-wrapper {
                            width: 5vh;
                            height: 5vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            background: rgba(255, 255, 255, 0.1);
                            border-radius: 50%;

                            i {
                                font-size: 2.4vh;
                                color: rgba(255, 255, 255, 0.3);
                            }
                        }

                        span {
                            font-size: 1.1vh;
                            font-weight: 600;
                            color: rgba(255, 255, 255, 0.6);
                        }
                    }
                }
            }

            .empty-state {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 6vh;
                text-align: center;
                width: 100%;

                .empty-icon {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 8vh;
                    height: 8vh;
                    margin-bottom: 2vh;
                    background: rgba(87, 182, 87, 0.1);
                    border-radius: 1vh;

                    i {
                        font-size: 4vh;
                        color: rgba(87, 182, 87, 0.5);
                    }
                }

                h3 {
                    margin: 0 0 1vh 0;
                    font-size: 1.8vh;
                    font-weight: 600;
                    color: rgba(255, 255, 255, 0.8);
                }

                p {
                    margin: 0;
                    font-size: 1.2vh;
                    color: rgba(255, 255, 255, 0.4);
                }
            }
        }
    }
    
    .confirm-modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10001;
        backdrop-filter: blur(0.4vh);
        
        .confirm-modal {
            background: rgb(32, 32, 32);
            border-radius: 1vh;
            padding: 3vh;
            min-width: 35vh;
            max-width: 50vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2vh;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 1vh 3vh rgba(0, 0, 0, 0.5);
            
            .confirm-icon {
                width: 6vh;
                height: 6vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: rgba(255, 184, 0, 0.1);
                border-radius: 50%;
                
                i {
                    font-size: 3vh;
                    color: #ffb800;
                }
            }
            
            h3 {
                margin: 0;
                font-size: 2vh;
                font-weight: 600;
                text-align: center;
                color: white;
            }
            
            .confirm-buttons {
                display: flex;
                gap: 1.5vh;
                width: 100%;
                
                .confirm-btn {
                    flex: 1;
                    padding: 1.2vh 2vh;
                    border-radius: 0.6vh;
                    font-size: 1.6vh;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s ease;
                    border: none;
                    
                    &.cancel {
                        background: rgba(255, 255, 255, 0.1);
                        color: white;
                        
                        &:hover {
                            background: rgba(255, 255, 255, 0.15);
                        }
                    }
                    
                    &.accept {
                        background: rgb(87, 182, 87);
                        color: white;
                        box-shadow: 0 0.2vh 0.4vh rgba(87, 182, 87, 0.2);
                        
                        &:hover {
                            background: rgb(70, 160, 70);
                            transform: translateY(-0.2vh);
                            box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.3);
                        }
                    }
                }
            }
        }
    }
    
    .no-access-overlay {
        position: absolute;
        inset: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgb(24, 24, 24);
        z-index: 100;
        
        .no-access-content {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2vh;
            text-align: center;
            padding: 4vh;
            
            .no-access-icon {
                width: 10vh;
                height: 10vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: rgba(255, 100, 100, 0.1);
                border: 2px solid rgba(255, 100, 100, 0.3);
                border-radius: 50%;
                
                i {
                    font-size: 4vh;
                    color: rgb(255, 100, 100);
                }
            }
            
            h2 {
                margin: 0;
                font-size: 3vh;
                font-weight: 700;
                color: white;
            }
            
            p {
                margin: 0;
                font-size: 1.6vh;
                color: rgba(255, 255, 255, 0.6);
                max-width: 40vh;
                line-height: 1.5;
            }
            
            .retry-btn {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 1vh;
                padding: 1.5vh 4vh;
                margin-top: 1vh;
                background: rgb(87, 182, 87);
                border: none;
                border-radius: 0.6vh;
                color: white;
                font-size: 1.6vh;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 0.2vh 0.4vh rgba(87, 182, 87, 0.2);
                
                i {
                    font-size: 1.6vh;
                }
                
                &:hover:not(:disabled) {
                    background: rgb(70, 160, 70);
                    transform: translateY(-0.2vh);
                    box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.3);
                }
                
                &:disabled {
                    opacity: 0.7;
                    cursor: not-allowed;
                }
            }
        }
    }
}
</style>