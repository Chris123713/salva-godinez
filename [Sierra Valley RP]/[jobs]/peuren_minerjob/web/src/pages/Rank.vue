<script setup>
    import { useGlobalState } from '../stores/globalStore';
    import { useConfirm } from "primevue/useconfirm";
    import { fetchNui } from '../utils';
    import ConfirmPopup from 'primevue/confirmpopup';
    import ProgressBar from 'primevue/progressbar';
    import 'primeicons/primeicons.css';
    import { computed } from 'vue';
    import locale from "../locale";
    
    const getImageSource = (itemName) => {
        return `https://cfx-nui-${globalState.inventoryURL.value}/${itemName}.png`;
    };
    
    const confirm = useConfirm();
    const globalState = useGlobalState();

    const requireConfirmation = (event, item) => {
        confirm.require({
            target: event.currentTarget,
            message: locale('rank', 'want_to_purchase'),
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: locale('rank', 'prompt_not'),
            acceptLabel: locale('rank', 'prompt_yes'),
            accept: () => {
                fetchNui('purchase', { item: item });
            },
        });
    }

    const sortedRanks = computed(() => {
        return globalState.pageData.value.ranks[0]?.sort((a, b) => a.level - b.level) || [];
    });
</script>

<template>
    <div class="rank-container">
        <!-- Profile Section -->
        <div class="level-card">
            <div class="user-info">
                <div class="user-avatar">
                    <i class="pi pi-user"></i>
                </div>
                <div class="user-details">
                    <div style="display: flex; flex-direction: row; gap: 1vh;">
                        <h3>{{ globalState.pageData.value.profile.name.full }}</h3> 
                        <Tag severity="warning" class="level-tag">
                            <i class="pi pi-star"></i>
                            {{ locale('rank', 'level') + ' ' + globalState.pageData.value.profile.rank.Level }}
                        </Tag>
                    </div>
                    <div class="xp-progress">
                        <div class="xp-text">
                            {{ globalState.pageData.value.profile.rank.XP }} / {{ globalState.pageData.value.profile.rank.Next }} XP
                        </div>
                        <ProgressBar :value="Math.ceil((globalState.pageData.value.profile.rank.XP / globalState.pageData.value.profile.rank.Next) * 100)" 
                                   class="rank-progress" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Tools Grid Section -->
        <div class="tools-section">
            <div class="section-header">
                <div class="header-title">
                    <i class="pi pi-box"></i>
                    <h2>{{ locale('rank', 'unlockables_header') }}</h2>
                </div>
            </div>
            <div class="tools-grid">
                <div v-for="(item, index) in globalState.pageData.value.ranks.Levels" 
                     :key="index" 
                     class="tool-card"
                     :class="{ 'locked': globalState.pageData.value.profile.rank.Level < item.level }">
                    <div class="tool-content">
                        <div class="tool-image-container">
                            <img class="tool-image" :src="getImageSource(item.tool.item)" :alt="item.tool.title">
                        </div>
                        <div class="tool-info">
                            <h3>{{ item.tool.title }}</h3>
                            <p>{{ item.tool.description }}</p>
                            <div class="tool-meta">
                                <Tag severity="warning" icon="pi pi-star" :value="item.level + ' lvl'" />
                                <Tag icon="pi pi-dollar" severity="success" :value="item.tool.price" />
                            </div>
                            <Button @click="requireConfirmation($event, item.tool)" 
                                    class="purchase-button"
                                    :disabled="globalState.pageData.value.profile.rank.Level < item.level">
                                <i class="pi pi-cart-plus"></i>
                                <span>{{ locale('rank', 'purchase_button') }}</span>
                            </Button>
                        </div>
                    </div>
                    <div v-if="globalState.pageData.value.profile.rank.Level < item.level" class="locked-overlay">
                        <i class="pi pi-lock"></i>
                        <Tag icon="pi pi-star" severity="warning" :value="item.level + ' lvl'" />
                    </div>
                </div>
            </div>
        </div>
        <ConfirmPopup />
    </div>
</template>

<style scoped lang="scss">
.rank-container {
    display: flex;
    flex-direction: column;
    gap: 2vh;
    padding: 2vh;
    height: 100%;
    width: 100%;
    color: white;

    .level-card {
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        padding: 2vh;

        .user-info {
            display: flex;
            gap: 2vh;

            .user-avatar {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 8vh;
                height: 8vh;
                background: rgba(87, 182, 87, 0.1);
                border: 2px solid rgba(87, 182, 87, 0.2);
                border-radius: 0.8vh;
                
                i {
                    font-size: 3.5vh;
                    color: rgb(87, 182, 87);
                }
            }

            .user-details {
                flex: 1;
                
                h3 {
                    margin: 0;
                    font-size: 2vh;
                    font-weight: 600;
                }

                .xp-progress {
                    margin-top: 1vh;
                    
                    .xp-text {
                        font-size: 1.3vh;
                        color: rgba(255, 255, 255, 0.7);
                        margin-bottom: 0.5vh;
                    }

                    .rank-progress {
                        margin-bottom: 1vh;
                        height: 1vh;
                        border-radius: 0.5vh;

                        :deep(.p-progressbar-value) {
                            background: rgb(87, 182, 87);
                        }
                    }

                    .level-tag {
                        gap: 1vh;
                        background: rgba(255, 193, 7, 0.1);
                        color: rgb(255, 193, 7);
                        border: 1px solid rgba(255, 193, 7, 0.2);
                        padding: 0.4vh 0.8vh;
                        font-size: 1.2vh;
                    }
                }
            }
        }
    }

    .tools-section {
        flex: 1;
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        display: flex;
        flex-direction: column;
        overflow: hidden; // Added to contain scrolling child

        .section-header {
            padding: 2vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);

            .header-title {
                display: flex;
                align-items: center;
                gap: 1vh;

                i {
                    font-size: 2vh;
                    color: rgb(87, 182, 87);
                }

                h2 {
                    margin: 0;
                    font-size: 1.8vh;
                    font-weight: 600;
                }
            }
        }

        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(18vh, 1fr));
            gap: 1.5vh;
            padding: 2vh;
            overflow-y: auto;
            height: 100%;  
            
            &::-webkit-scrollbar {
                width: 0.6vh; // Slightly wider scrollbar
            }

            &::-webkit-scrollbar-track {
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.3vh;
            }

            &::-webkit-scrollbar-thumb {
                background: rgba(87, 182, 87, 0.3);
                border-radius: 0.3vh;

                &:hover {
                    background: rgba(87, 182, 87, 0.5);
                }
            }

            .tool-card {
                position: relative;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.8vh;
                overflow: hidden;
                transition: all 0.2s ease;
                display: flex;
                flex-direction: column;

                &:hover:not(.locked) {
                    transform: translateY(-0.2vh);
                    background: rgba(255, 255, 255, 0.08);
                }

                .tool-content {
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    padding: 1vh;

                    .tool-image-container {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        background: rgba(0, 0, 0, 0.2);
                        border-radius: 0.6vh;
                        padding: 0.5vh;
                        margin-bottom: 1vh;
                        height: 8vh;
                        flex-shrink: 0;

                        .tool-image {
                            max-width: 100%;
                            max-height: 100%;
                            object-fit: contain;
                        }
                    }

                    .tool-info {
                        display: flex;
                        flex-direction: column;
                        gap: 0.5vh;
                        flex: 1;
                        min-height: 0;

                        h3 {
                            margin: 0;
                            font-size: 1.2vh;
                            font-weight: 600;
                            text-align: center;
                            color: rgb(87, 182, 87);
                            line-height: 1.4;
                        }

                        p {
                            margin: 0;
                            font-size: 1vh;
                            color: rgba(255, 255, 255, 0.7);
                            text-align: center;
                            line-height: 1.2;
                            flex: 1;
                            overflow: hidden;
                            display: -webkit-box;
                            -webkit-line-clamp: 2;
                            line-clamp: 2;
                            -webkit-box-orient: vertical;
                        }

                        .tool-meta {
                            display: flex;
                            justify-content: center;
                            gap: 0.5vh;
                            margin: 0.5vh 0;

                            .p-tag {
                                background: rgba(255, 255, 255, 0.1);
                                border: 1px solid rgba(255, 255, 255, 0.2);
                                font-size: 0.9vh;
                                padding: 0.2vh 0.4vh;
                                
                                &.p-tag-warning {
                                    background: rgba(255, 193, 7, 0.1);
                                    border-color: rgba(255, 193, 7, 0.2);
                                }
                                
                                &.p-tag-success {
                                    background: rgba(87, 182, 87, 0.1);
                                    border-color: rgba(87, 182, 87, 0.2);
                                }
                            }
                        }

                        .purchase-button {
                            height: 3vh;
                            background: rgb(87, 182, 87);
                            border: none;
                            border-radius: 0.6vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            gap: 0.5vh;
                            transition: all 0.2s ease;
                            margin-top: 0.5vh;
                            flex-shrink: 0;

                            &:hover:not(:disabled) {
                                background: darken(rgb(87, 182, 87), 5%);
                                transform: translateY(-0.2vh);
                                box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.2);
                            }

                            &:disabled {
                                opacity: 0.5;
                                cursor: not-allowed;
                            }

                            i {
                                font-size: 1vh;
                            }

                            span {
                                font-size: 1vh;
                                font-weight: 600;
                            }
                        }
                    }
                }

                .locked-overlay {
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(0, 0, 0, 0.8);
                    backdrop-filter: blur(0.3vh);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    gap: 1.5vh;

                    i {
                        font-size: 3.5vh;
                        color: rgba(255, 255, 255, 0.5);
                    }

                    .p-tag {
                        background: rgba(255, 193, 7, 0.2);
                        border: 1px solid rgba(255, 193, 7, 0.3);
                    }
                }
            }
        }
    }
}
</style>