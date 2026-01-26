<script setup>
    import { ref } from "vue";
    import { fetchNui } from '../utils';
    import { useGlobalState } from '../stores/globalStore';
    import { useConfirm } from "primevue/useconfirm";
    import locale from "../locale";

    const globalState = useGlobalState();   
    const pageData = globalState.pageData.value;
    const groupId = pageData.current.groupId;
    const confirm = useConfirm();

    const Close = () => {
        globalState.changeCurrentTab("start-job");
    }

    const SelectJobType = (event, type) => {
        // Check if job is disabled before showing prompt
        const isDisabled = pageData.stock[type].amount >= pageData.stock[type].max;
        if (isDisabled) return;

        confirm.require({
            target: event.currentTarget,
            message: locale('jobStart', 'want_to_start_job'),
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: locale('jobStart', 'prompt_not'),
            acceptLabel: locale('jobStart', 'prompt_yes'),
            accept: async () => {
                const result = await fetchNui('start-job', { id: groupId, type: type });
                if (!result) return;
                globalState.selectJobs.value = false;
                pageData.current.args.started = true;
            },
        });
    };
</script>

<template>
    <Transition name="select-type">
        <div class="select-type-container">
            <div class="types-wrapper">
                <div class="types-header">
                    <div class="header-content">
                        <div class="header-main">
                            <div class="title-icon">
                                <i class="pi pi-list"></i>
                            </div>
                            <div class="header-text">
                                <h3>{{ locale('jobTypes', 'select_job_type') }}</h3>
                                <span class="subtitle">{{ locale('jobTypes', 'select_type_subtitle') }}</span>
                            </div>
                        </div>
                        <Button @click="Close()" 
                                icon="pi pi-times" 
                                class="close-button"
                                severity="danger" 
                                text
                                rounded />
                    </div>
                </div>

                <div class="job-types-grid">
                    <!-- Recycling Job -->
                    <div class="job-type-card" 
                         :class="{ 'disabled': pageData.stock['recycling'].amount >= pageData.stock['recycling'].max }"
                         @click="SelectJobType($event, 'recycling')">
                        <div class="type-icon">
                            <i class="pi pi-box"></i>
                            <i v-if="pageData.stock['recycling'].amount >= pageData.stock['recycling'].max" 
                               class="pi pi-lock lock-icon"></i>
                        </div>
                        <div class="type-content">
                            <h3>{{ locale('jobTypes', 'recycling_job_title') }}</h3>
                            <p>{{ locale('jobTypes', 'recycling_job_description') }}</p>
                            <div class="type-tags">
                                <Tag severity="info" class="stock-tag">
                                    <i class="pi pi-box"></i>
                                    {{ pageData.stock['recycling'].amount }}/{{ pageData.stock['recycling'].max }}
                                </Tag>
                                <Tag v-if="pageData.stock['recycling'].amount >= pageData.stock['recycling'].max"
                                     severity="danger">
                                    <i class="pi pi-lock"></i>
                                    {{ locale('jobTypes', 'recycle_job_disabled') }}
                                </Tag>
                            </div>
                        </div>
                    </div>

                    <!-- Depot Job -->
                    <div class="job-type-card"
                         :class="{ 'disabled': pageData.stock['depot'].amount >= pageData.stock['depot'].max }"
                         @click="SelectJobType($event, 'depot')">
                        <div class="type-icon">
                            <i class="pi pi-inbox"></i>
                            <i v-if="pageData.stock['depot'].amount >= pageData.stock['depot'].max" 
                               class="pi pi-lock lock-icon"></i>
                        </div>
                        <div class="type-content">
                            <h3>{{ locale('jobTypes', 'collect_job_title') }}</h3>
                            <p>{{ locale('jobTypes', 'collect_job_description') }}</p>
                            <div class="type-tags">
                                <Tag severity="info" class="stock-tag">
                                    <i class="pi pi-inbox"></i>
                                    {{ pageData.stock['depot'].amount }}/{{ pageData.stock['depot'].max }}
                                </Tag>
                                <Tag v-if="pageData.stock['depot'].amount >= pageData.stock['depot'].max"
                                     severity="danger">
                                    <i class="pi pi-lock"></i>
                                    {{ locale('jobTypes', 'collecting_job_disabled') }}
                                </Tag>
                            </div>
                        </div>
                    </div>
                </div>
                <ConfirmPopup />
            </div>
        </div>
    </Transition>
</template>

<style scoped lang="scss">
.select-type-enter-active,
.select-type-leave-active {
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    will-change: transform, opacity;
}

.select-type-enter-from,
.select-type-leave-to {
    opacity: 0;
    transform: translateY(-1vh);
}

.select-type-container {
    display: flex;
    position: absolute;
    z-index: 1;
    padding: 2vh;
    width: 70vh;
    color: white;
    height: 45vh;
    min-height: 45vh;
    max-height: 45vh;
    filter: drop-shadow(0 0.2vh 0.5vh rgba(0, 0, 0, 0.2));
    transform: translateZ(0);
    backface-visibility: hidden;

    .types-wrapper {
        flex: 1;
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        display: flex;
        flex-direction: column;
        height: 100%;
        overflow: hidden;
        box-shadow: 0 0.5vh 2vh rgba(0, 0, 0, 0.25);

        .types-header {
            position: sticky;
            top: 0;
            z-index: 10;
            background-color: rgb(32, 32, 32);
            padding: 2vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;

            .header-content {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 2vh;

                .header-main {
                    display: flex;
                    align-items: center;
                    gap: 1.5vh;

                    .title-icon {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 5vh;
                        height: 5vh;
                        background: rgba(87, 182, 87, 0.1);
                        border: 2px solid rgba(87, 182, 87, 0.2);
                        border-radius: 0.8vh;

                        i {
                            font-size: 2.2vh;
                            color: rgb(87, 182, 87);
                        }
                    }

                    .header-text {
                        display: flex;
                        flex-direction: column;
                        gap: 0.4vh;

                        h3 {
                            margin: 0;
                            font-size: 2vh;
                            font-weight: 600;
                        }

                        .subtitle {
                            font-size: 1.3vh;
                            color: rgba(255, 255, 255, 0.5);
                        }
                    }
                }

                .close-button {
                    width: 4vh;
                    height: 4vh;
                }
            }
        }

        .job-types-grid {
            display: flex;
            gap: 2vh;
            padding: 4vh 2vh;
            justify-content: center;
            height: calc(100% - 8vh);

            .job-type-card {
                flex: 1;
                max-width: 35vh;
                height: 100%;
                min-height: 0;
                display: flex;
                flex-direction: column;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.8vh;
                padding: 2vh;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 0.2vh 1vh rgba(0, 0, 0, 0.2);

                &:not(.disabled):hover {
                    background: rgba(255, 255, 255, 0.08);
                    transform: translateY(-0.2vh);
                    box-shadow: 0 0.5vh 1.5vh rgba(0, 0, 0, 0.3);

                    .type-icon {
                        border-color: rgb(87, 182, 87);
                    }
                }

                &.disabled {
                    opacity: 0.7;
                    cursor: not-allowed;

                    .type-icon {
                        position: relative;

                        .lock-icon {
                            position: absolute;
                            bottom: -0.5vh;
                            right: -0.5vh;
                            font-size: 1.8vh;
                            color: rgb(220, 53, 69);
                            background: rgba(32, 32, 32, 0.9);
                            border-radius: 50%;
                            padding: 0.3vh;
                            width: 2.2vh;
                            height: 2.2vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                    }
                }

                .type-icon {
                    flex-shrink: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 6vh;
                    height: 6vh;
                    background: rgba(87, 182, 87, 0.1);
                    border: 2px solid rgba(87, 182, 87, 0.2);
                    border-radius: 1vh;
                    margin: 0 auto 2vh;
                    transition: all 0.2s ease;

                    i {
                        font-size: 2.5vh;
                        color: rgb(87, 182, 87);
                    }
                }

                .type-content {
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-between;
                    text-align: center;

                    h3 {
                        margin: 0 0 0.8vh;
                        font-size: 1.6vh;
                        font-weight: 600;
                    }

                    p {
                        margin: 0;
                        flex: 1;
                        font-size: 1.3vh;
                        color: rgba(255, 255, 255, 0.7);
                        line-height: 1.8vh;
                    }

                    .type-tags {
                        display: flex;
                        gap: 0.8vh;
                        justify-content: center;
                        margin-top: 2vh;

                        .p-tag {
                            font-size: 1.1vh;
                            padding: 0.4vh 0.8vh;
                            display: flex;
                            align-items: center;
                            gap: 0.5vh;

                            i {
                                font-size: 1.1vh;
                            }
                        }

                        .stock-tag {
                            background: rgba(87, 182, 87, 0.1);
                            color: rgb(87, 182, 87);
                            border: 1px solid rgba(87, 182, 87, 0.2);
                        }
                    }
                }
            }
        }
    }
}
</style>