<script setup>
import { ref, computed } from 'vue';
import { useTaskStore } from '../../stores/taskStore';
import ProgressBar from 'primevue/progressbar';
import { locale } from "../../locale";

const taskStore = useTaskStore();

const positionClass = computed(() => ({
    'task-container': true,
    [taskStore.task.value.position]: true
}));

const calculateProgress = computed(() => {
    if (!taskStore.task.value.progress) return 0;
    const { progress, progressMax } = taskStore.task.value;
    return Number(((progress / progressMax) * 100).toFixed(1));
});
</script>

<template>
    <Transition name="fade">
        <div v-if="taskStore.task.value.visible" :class="positionClass">
            <div class="task-wrapper">
                <div class="task-header">
                    <div class="header-content">
                        <div class="header-main">
                            <div class="title-icon">
                                <i class="pi pi-clock"></i>
                            </div>
                            <div class="header-text">
                                <h3>{{ locale('task', 'header') }}</h3>
                                <span class="subtitle">{{ locale('task', 'subtitle') }}</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="task-content">
                    <div class="task-message">
                        <i class="pi pi-info-circle"></i>
                        <span class="task-text">{{ taskStore.task.value.text }}</span>
                    </div>
                    <div v-if="taskStore.task.value.progress !== null" class="progress-section">
                        <div class="progress-label">
                            <span>{{ locale('task', 'progress') }}</span>
                            <span>{{ calculateProgress }}%</span>
                        </div>
                        <ProgressBar :value="calculateProgress" class="task-progress" />
                    </div>
                </div>
            </div>
        </div>
    </Transition>
</template>

<style scoped lang="scss">
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.task-container {
    position: fixed;
    z-index: 1000;
    padding: 1vh;

    &.middle-right {
        top: 50%;
        right: 2vh;
        transform: translateY(-50%);
    }
    &.top-left {
        top: 2vh;
        left: 2vh;
    }
    &.top-center {
        top: 2vh;
        left: 50%;
        transform: translateX(-50%);
    }
    &.top-right {
        top: 2vh;
        right: 2vh;
    }
    &.middle-left {
        top: 50%;
        left: 2vh;
        transform: translateY(-50%);
    }
    &.middle-center {
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
    }
    &.bottom-left {
        bottom: 2vh;
        left: 2vh;
    }
    &.bottom-center {
        bottom: 2vh;
        left: 50%;
        transform: translateX(-50%);
    }
    &.bottom-right {
        bottom: 2vh;
        right: 2vh;
    }

    .task-wrapper {
        background: rgba(32, 32, 32, 0.85);
        border-radius: 0.6vh;
        min-width: 30vh;
        box-shadow: 0 0.4vh 1vh rgba(0, 0, 0, 0.2);
        overflow: hidden;

        .task-header {
            padding: 1.5vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background-color: rgba(32, 32, 32, 0.85);

            .header-content {
                .header-main {
                    display: flex;
                    align-items: center;
                    gap: 1.2vh;

                    .title-icon {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 4vh;
                        height: 4vh;
                        border-radius: 0.6vh;

                        i {
                            font-size: 1.8vh;
                            color: rgb(87, 182, 87);
                        }
                    }

                    .header-text {
                        display: flex;
                        flex-direction: column;
                        gap: 0.2vh;

                        h3 {
                            margin: 0;
                            font-size: 1.6vh;
                            font-weight: 600;
                            color: white;
                        }

                        .subtitle {
                            font-size: 1.1vh;
                            color: rgba(255, 255, 255, 0.5);
                        }
                    }
                }
            }
        }

        .task-content {
            padding: 1.5vh;
            display: flex;
            flex-direction: column;
            gap: 1.5vh;

            .task-message {
                display: flex;
                align-items: flex-start;
                gap: 1.2vh;
                background: rgba(255, 255, 255, 0.03);
                padding: 1.2vh;
                border-radius: 0.6vh;

                i {
                    font-size: 1.6vh;
                    color: rgb(87, 182, 87);
                    margin-top: 0.1vh;
                }

                .task-text {
                    color: white;
                    font-size: 1.2vh;
                    line-height: 1.8vh;
                    flex: 1;
                }
            }

            .progress-section {
                display: flex;
                flex-direction: column;
                gap: 0.8vh;

                .progress-label {
                    display: flex;
                    justify-content: space-between;
                    color: rgba(255, 255, 255, 0.7);
                    font-size: 1.1vh;
                }

                .task-progress {
                    height: 0.6vh;
                    border-radius: 0.3vh;
                    background: rgba(255, 255, 255, 0.05);
                    border: none;

                    :deep(.p-progressbar-value) {
                        background: rgb(87, 182, 87);
                        transition: width 0.3s ease;
                    }

                    :deep(.p-progressbar-label) {
                        display: none;
                    }
                }
            }
        }
    }
}
</style>
