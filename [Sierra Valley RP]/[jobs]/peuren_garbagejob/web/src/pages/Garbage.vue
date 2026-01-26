<script setup>
    import { useGlobalState } from '../stores/globalStore';    
    import { ref } from "vue";
    import ProgressBar from 'primevue/progressbar';
    import locale from "../locale";

    const value = ref(20);

    const globalState = useGlobalState();   
    const pageData = globalState.pageData.value;
</script>

<template>
    <div class="garbage-container">
        <div class="cards-grid">
            <!-- Garbage HQ Section -->
            <div class="stock-card garbage-hq">
                <div class="card-content">
                    <div class="stock-header">
                        <div class="header-icon">
                            <i class="pi pi-building"></i>
                        </div>
                        <div class="header-text">
                            <h3>{{ locale('stock', 'garbage_center_header') }}</h3>
                        </div>
                    </div>
                    
                    <div class="key-points">
                        <div class="point">
                            <i class="pi pi-check-circle"></i>
                            <span>Track current garbage capacity</span>
                        </div>
                        <div class="point">
                            <i class="pi pi-box"></i>
                            <span>Monitor available space</span>
                        </div>
                        <div class="point">
                            <i class="pi pi-sync"></i>
                            <span>Real-time updates</span>
                        </div>
                    </div>

                    <div class="progress-section">
                        <div class="progress-label">
                            <span>Current Capacity</span>
                            <span class="value">{{ pageData.stock['depot'].amount }}/{{ pageData.stock['depot'].max }}</span>
                        </div>
                        <ProgressBar 
                            :value="(pageData.stock['depot'].amount / pageData.stock['depot'].max) * 100"
                            class="custom-progress" />
                    </div>
                </div>
            </div>

            <!-- Recycling Center Section -->
            <div class="stock-card recycling-center">
                <div class="card-content">
                    <div class="stock-header">
                        <div class="header-icon">
                            <i class="pi pi-refresh"></i>
                        </div>
                        <div class="header-text">
                            <h3>{{ locale('stock', 'recycle_center_header') }}</h3>
                        </div>
                    </div>

                    <div class="key-points">
                        <div class="point">
                            <i class="pi pi-sort-alt"></i>
                            <span>Track recycling capacity</span>
                        </div>
                        <div class="point">
                            <i class="pi pi-chart-bar"></i>
                            <span>Monitor processing status</span>
                        </div>
                        <div class="point">
                            <i class="pi pi-clock"></i>
                            <span>Live status updates</span>
                        </div>
                    </div>

                    <div class="progress-section">
                        <div class="progress-label">
                            <span>Processing Capacity</span>
                            <span class="value">{{ pageData.stock['recycling'].amount }}/{{ pageData.stock['recycling'].max }}</span>
                        </div>
                        <ProgressBar 
                            :value="(pageData.stock['recycling'].amount / pageData.stock['recycling'].max) * 100"
                            class="custom-progress" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.garbage-container {
    display: flex;
    padding: 2vh;
    height: 100%;
    width: 100%;
    color: white;
    min-height: 52vh;
    max-height: 52vh;

    .cards-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 2vh;
        width: 100%;
        height: 100%;

        .stock-card {
            position: relative;
            background: rgb(32, 32, 32);
            border-radius: 0.8vh;
            padding: 2.5vh;
            transition: all 0.3s ease;
            overflow: hidden;
            display: flex;
            flex-direction: column;

            &::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 0.3vh;
                background: rgb(87, 182, 87);
                opacity: 0;
                transition: opacity 0.3s ease;
            }

            &:hover {
                transform: translateY(-0.3vh);
                box-shadow: 0 0.8vh 2vh rgba(0, 0, 0, 0.2);

                &::before {
                    opacity: 1;
                }

                .header-icon {
                    transform: scale(1.1);
                }
            }

            .card-content {
                display: flex;
                flex-direction: column;
                height: 100%;
                gap: 2vh;
            }

            .stock-header {
                display: flex;
                align-items: center;
                gap: 2vh;

                .header-icon {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 5vh;
                    height: 5vh;
                    background: rgba(87, 182, 87, 0.1);
                    border-radius: 0.6vh;
                    transition: transform 0.3s ease;

                    i {
                        font-size: 2.2vh;
                        color: rgb(87, 182, 87);
                    }
                }

                .header-text {
                    h3 {
                        font-size: 2vh;
                        font-weight: 600;
                        margin: 0;
                    }
                }
            }

            .key-points {
                display: flex;
                flex-direction: column;
                gap: 1.5vh;
                flex: 1;
                padding: 1vh 0;

                .point {
                    display: flex;
                    align-items: center;
                    gap: 1.2vh;
                    
                    i {
                        color: rgb(87, 182, 87);
                        font-size: 1.6vh;
                    }

                    span {
                        font-size: 1.4vh;
                        color: rgba(255, 255, 255, 0.9);
                    }
                }
            }

            .progress-section {
                .progress-label {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 1vh;
                    
                    span {
                        font-size: 1.3vh;
                        color: rgba(255, 255, 255, 0.7);

                        &.value {
                            color: rgb(87, 182, 87);
                            font-weight: 600;
                        }
                    }
                }

                :deep(.custom-progress) {
                    height: 1.2vh;
                    border-radius: 0.6vh;
                    background: rgba(255, 255, 255, 0.05);
                    overflow: hidden;

                    .p-progressbar-value {
                        background: rgb(87, 182, 87);
                        transition: width 0.5s ease;
                    }
                }

                :deep(.p-progressbar-label) {
                    display: none;
                }
            }
        }

        .garbage-hq {
            .header-icon {
                background: rgba(87, 182, 87, 0.15) !important;
            }
        }

        .recycling-center {
            .header-icon {
                background: rgba(87, 182, 87, 0.15) !important;
            }
        }
    }
}
</style>