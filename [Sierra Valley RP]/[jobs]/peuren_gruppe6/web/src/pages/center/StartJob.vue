<script setup>
    import { ref, onMounted } from "vue";
    import { useGlobalState } from '../../stores/globalStore';    
    import { fetchNui } from '../../utils';    
    import { useConfirm } from "primevue/useconfirm";
    import ConfirmPopup from 'primevue/confirmpopup';
    import { locale } from "../../locale";
    import 'primeicons/primeicons.css';

    const globalState = useGlobalState();
    const pageData = globalState.pageData.value;
    const confirm = useConfirm();
    const groupId = pageData.current.groupId;
    const isOwner = ref(false);
    const showPassword = ref(false);
    const isCopying = ref(false);
    const showVehicleWarning = ref(false);

    const CancelJob = async (groupId) => {
        const result = await fetchNui('cancel-job', { id: groupId, owner: isOwner.value });
        if (!result) return;
        globalState.pageData.value.current.args.started = false;
        globalState.pageData.value.current = null;
        globalState.changeCurrentTab('job');
    }

    const LeaveJob = async (groupId) => {
        if (globalState.pageData.value?.current?.args?.finished && 
            !globalState.pageData.value.current.args.vehReturned) {
            showVehicleWarning.value = true;
            return;
        }

        const result = await fetchNui('leave-job', { id: groupId, owner: isOwner.value });
        if (!result) return;        
        globalState.pageData.value.current.args.started = false;
        globalState.pageData.value.current = null;
        globalState.changeCurrentTab('job');
    }

    onMounted(async () => {
        isOwner.value = await fetchNui('getIsOwner', { id: groupId });
    });

    const StartJob = (event) => {
        confirm.require({
            target: event.currentTarget,
            message: locale('jobStart', 'want_to_start_job'),
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: locale('jobStart', 'prompt_not'),
            acceptLabel: locale('jobStart', 'prompt_yes'),
            accept: async () => {
                const result = await fetchNui('start-job', { id: groupId });
                if (!result) return;
                globalState.selectJobs.value = false;
                pageData.current.args.started = true;
            },
        });
    };

    const kick = (event, player) => {
        confirm.require({
            target: event.currentTarget,
            message: locale('jobStart', 'group_kick_player_confirm'),
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: locale('jobStart', 'prompt_not'),
            acceptLabel: locale('jobStart', 'prompt_yes'),
            accept: () => {
                fetchNui("kickPlayer", { id: groupId, player: player });
            },
        });
    };

    const copyPassword = () => {
        const el = document.createElement('textarea');
        el.value = globalState.pageData.value.current.pass;
        el.setAttribute('readonly', '');
        el.style.position = 'absolute';
        el.style.left = '-9999px';
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
        
        isCopying.value = true;
        
        setTimeout(() => {
            isCopying.value = false;
        }, 1000);
    };

    const confirmLeaveWithoutReturn = () => {
        showVehicleWarning.value = false;
        globalState.pageData.value.current.args.started = false;
        globalState.pageData.value.current = null;
        globalState.changeCurrentTab('job');
        fetchNui('leave-job', { id: groupId, owner: isOwner.value });
    }
</script>

<template>
    <div class="Container">
        <!-- Control Panel -->
        <div class="control-sidebar">
            <div class="control-card">
                <div class="card-header">
                    <i class="pi pi-cog"></i>
                    <h2>{{ locale('jobStart', 'job_controls') }}</h2>
                </div>
                <div class="job-info">
                    <div class="info-item">
                        <i class="pi pi-id-card"></i>
                        <span>{{ locale('jobStart', 'group_id') + groupId }}</span>
                    </div>
                    <div class="info-item password-item">
                        <i class="pi pi-key"></i>
                        <span>{{ locale('jobStart', 'group_password') + (showPassword ? globalState.pageData.value?.current.pass : '•'.repeat(6)) }}</span>
                        <div class="password-controls">
                            <i class="pi pi-copy" :class="{ 'copying': isCopying }" @click="copyPassword"></i>
                            <i class="pi" :class="showPassword ? 'pi-eye-slash' : 'pi-eye'" @click="showPassword = !showPassword"></i>
                        </div>
                    </div>
                </div>
                <div class="action-buttons">
                    <Button v-if="!globalState.pageData.value?.current.args.started && isOwner" 
                            class="p-button-success" 
                            @click="StartJob($event)">
                        <i class="pi pi-play"></i>
                        <span>{{ locale('jobStart', 'group_start_job') }}</span>
                    </Button>
                    <Button v-if="globalState.pageData.value?.current.args.started && isOwner"
                            class="p-button-danger"
                            @click="LeaveJob(groupId)">
                        <i class="pi pi-power-off"></i>
                        <span>{{ locale('jobStart', 'group_end_job') }}</span>
                    </Button>
                    <Button v-if="!globalState.pageData.value?.current.args.started || !isOwner"
                            class="p-button-warning"
                            @click="CancelJob(groupId)">
                        <i class="pi pi-times"></i>
                        <span>{{ locale('jobStart', 'group_leave_job') }}</span>
                    </Button>
                </div>
            </div>

            <div class="stats-card">
                <div class="card-header">
                    <i class="pi pi-chart-line"></i>
                    <h2>{{ locale('jobStart', 'job_statistics') }}</h2>
                </div>
                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="stat-icon">
                            <i class="pi pi-check-circle"></i>
                        </div>
                        <div class="stat-content">
                            <span class="stat-value">{{ globalState.pageData.value?.current.args.completed }}</span>
                            <span class="stat-label">{{ locale('jobStart', 'completed_jobs') }}</span>
                        </div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-icon">
                            <i class="pi pi-dollar"></i>
                        </div>
                        <div class="stat-content">
                            <span class="stat-value">${{ globalState.pageData.value?.current.args.earnings }}</span>
                            <span class="stat-label">{{ locale('jobStart', 'total_earnings') }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Members Section -->
        <div class="members-section">
            <div class="section-header">
                <div class="header-title">
                    <i class="pi pi-users"></i>
                    <h2>{{ locale('jobStart', 'group_members_title') }}</h2>
                </div>
            </div>
            <div class="members-grid">
                <div v-for="(player, index) in globalState.pageData.value?.current.players" 
                     :key="index"
                     class="member-card"
                     :class="{ 'owner': player.owner }">
                    <div class="member-info">
                        <div class="member-avatar">
                            <i class="pi pi-user"></i>
                        </div>
                        <div class="member-details">
                            <span class="member-name">{{ player?.name?.full || 'NO NAME' }}</span>
                            <Tag v-if="player.owner" 
                                 severity="warning" 
                                 :value="locale('jobStart', 'group_owner_tag')" />
                        </div>
                    </div>
                    <Button v-if="isOwner && !player.owner"
                            icon="pi pi-times"
                            class="p-button-rounded p-button-danger p-button-outlined"
                            @click="kick($event, player)" />
                </div>
            </div>
            <ConfirmPopup></ConfirmPopup>
        </div>

        <!-- Vehicle Warning Dialog -->
        <div v-if="showVehicleWarning" class="dialog-overlay">
            <div class="warning-dialog">
                <div class="warning-icon">
                    <i class="pi pi-exclamation-triangle"></i>
                </div>
                <h2>{{ locale('jobStart', 'vehicle_warning_title') }}</h2>
                <p>{{ locale('jobStart', 'vehicle_warning_message') }}</p>
                <div class="dialog-buttons">
                    <Button class="p-button-danger" @click="confirmLeaveWithoutReturn">
                        <i class="pi pi-times"></i>
                        <span>{{ locale('jobStart', 'end_without_return') }}</span>
                    </Button>
                    <Button class="p-button-secondary" @click="showVehicleWarning = false">
                        <i class="pi pi-arrow-left"></i>
                        <span>{{ locale('jobStart', 'return_to_job') }}</span>
                    </Button>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.Container {
    display: flex;
    gap: 2vh;
    padding: 2vh;
    height: 100%;
    width: 100%;
    color: white;
    min-height: 52vh;
    max-height: 52vh;

    .control-sidebar {
        display: flex;
        flex-direction: column;
        gap: 2vh;
        width: 30vh;

        .control-card, .stats-card {
            background-color: rgb(32, 32, 32);
            border-radius: 0.8vh;
            padding: 2vh;

            .card-header {
                display: flex;
                align-items: center;
                gap: 1vh;
                padding-bottom: 1.5vh;
                margin-bottom: 1.5vh;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);

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

        .control-card {
            .job-info {
                display: flex;
                flex-direction: column;
                gap: 1vh;
                margin-bottom: 1vh;

                .info-item {
                    display: flex;
                    align-items: center;
                    gap: 1vh;
                    padding: 1.2vh;
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 0.6vh;

                    i {
                        font-size: 1.6vh;
                        color: rgb(87, 182, 87);
                    }

                    span {
                        font-size: 1.4vh;
                        color: rgb(200, 200, 200);
                    }
                }

                .password-item {
                    position: relative;
                    
                    .password-controls {
                        position: absolute;
                        right: 1vh;
                        display: flex;
                        gap: 1vh;
                        
                        .pi {
                            cursor: pointer;
                            font-size: 1.4vh;
                            color: rgb(200, 200, 200);
                            transition: color 0.2s ease;

                            &:hover {
                                color: rgb(87, 182, 87);
                            }
                        }

                        .pi-copy {
                            &.copying {
                                animation: copied 1s ease;
                                color: rgb(87, 182, 87);
                            }
                        }

                        @keyframes copied {
                            0% {
                                transform: scale(1);
                            }
                            50% {
                                transform: scale(1.3) rotate(10deg);
                            }
                            100% {
                                transform: scale(1) rotate(0);
                            }
                        }
                    }
                }
            }

            .action-buttons {
                display: flex;
                flex-direction: row;
                gap: 1vh;

                .p-button {
                    margin: 0;
                    padding: 0;
                    height: 4vh;
                    width: 100%;
                    min-height: 4vh;
                    border: none;
                    border-radius: 0.6vh;
                    transition: all 0.2s ease;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 1vh;
                    font-weight: 600;
                    font-size: 1.4vh;
                    
                    &.p-button-success {
                        background: rgb(87, 182, 87);
                        box-shadow: 0 0.2vh 0.4vh rgba(87, 182, 87, 0.2);
                        
                        &:hover {
                            background: darken(rgb(87, 182, 87), 5%);
                            transform: translateY(-0.2vh);
                            box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.3);
                        }

                        &:active {
                            transform: translateY(0);
                        }
                    }

                    &:not(.p-button-success) {
                        background: rgba(255, 255, 255, 0.1);
                        color: white;
                        box-shadow: 0 0.2vh 0.4vh rgba(0, 0, 0, 0.2);

                        &:hover {
                            background: rgba(255, 255, 255, 0.15);
                            transform: translateY(-0.2vh);
                            box-shadow: 0 0.4vh 0.8vh rgba(0, 0, 0, 0.3);
                        }

                        &:active {
                            transform: translateY(0);
                        }
                    }

                    i {
                        font-size: 1.4vh;
                    }

                    span {
                        font-size: 1.3vh;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }
                }
            }
        }

        .stats-card {
            .stats-grid {
                display: grid;
                gap: 1.5vh;

                .stat-box {
                    display: flex;
                    align-items: center;
                    gap: 1.5vh;
                    padding: 0.7vh;
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 0.8vh;

                    .stat-icon {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 4.5vh;
                        height: 4.5vh;
                        background: rgba(87, 182, 87, 0.1);
                        border-radius: 0.6vh;

                        i {
                            font-size: 2vh;
                            color: rgb(87, 182, 87);
                        }
                    }

                    .stat-content {
                        display: flex;
                        flex-direction: column;
                        gap: 0.4vh;

                        .stat-value {
                            font-size: 1.5vh;
                            font-weight: 600;
                        }

                        .stat-label {
                            font-size: 1.3vh;
                            color: rgb(200, 200, 200);
                        }
                    }
                }
            }
        }
    }

    .members-section {
        flex: 1;
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        padding: 2vh;
        display: flex;
        flex-direction: column;

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 2vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);

            .header-title {
                display: flex;
                align-items: center;
                gap: 1vh;

                i {
                    font-size: 2.2vh;
                    color: rgb(87, 182, 87);
                }

                h2 {
                    margin: 0;
                    font-size: 2vh;
                    font-weight: 600;
                }
            }
        }

        .members-grid {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 1vh;
            margin-top: 2vh;
            overflow-y: auto;
            padding-right: 1vh;

            &::-webkit-scrollbar {
                width: 0.4vh;
            }

            &::-webkit-scrollbar-track {
                background: rgba(255, 255, 255, 0.05);
                border-radius: 1vh;
            }

            &::-webkit-scrollbar-thumb {
                background: rgba(87, 182, 87, 0.3);
                border-radius: 1vh;
            }

            .member-card {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 1.5vh;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.8vh;
                transition: all 0.2s ease;

                &:hover {
                    background: rgba(255, 255, 255, 0.08);
                }

                &.owner {
                    background: rgba(255, 193, 7, 0.1);
                }

                .member-info {
                    display: flex;
                    align-items: center;
                    gap: 1.5vh;

                    .member-avatar {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 5vh;
                        height: 5vh;
                        background: rgba(87, 182, 87, 0.1);
                        border-radius: 0.6vh;

                        i {
                            font-size: 2vh;
                            color: rgb(87, 182, 87);
                        }
                    }

                    .member-details {
                        display: flex;
                        align-items: center;
                        gap: 1vh;

                        .member-name {
                            font-size: 1.5vh;
                            font-weight: 500;
                        }
                    }
                }
            }
        }
    }

    .dialog-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;

        .warning-dialog {
            background: rgb(32, 32, 32);
            border-radius: 0.8vh;
            padding: 2vh;
            width: 40vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2vh;
            box-shadow: 0 0.4vh 2vh rgba(0, 0, 0, 0.4);

            .warning-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 8vh;
                height: 8vh;
                background: rgba(220, 53, 69, 0.1);
                border-radius: 50%;

                i {
                    font-size: 4vh;
                    color: #dc3545;
                }
            }

            h2 {
                margin: 0;
                font-size: 2vh;
                font-weight: 600;
                text-align: center;
            }

            p {
                margin: 0;
                font-size: 1.4vh;
                color: rgb(200, 200, 200);
                text-align: center;
                line-height: 1.8vh;
            }

            .dialog-buttons {
                display: flex;
                gap: 1vh;
                width: 100%;

                .p-button {
                    flex: 1;
                    margin: 0;
                    padding: 0;
                    height: 4vh;
                    border: none;
                    border-radius: 0.6vh;
                    transition: all 0.2s ease;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 1vh;
                    font-weight: 600;
                    font-size: 1.4vh;

                    &.p-button-danger {
                        background: #dc3545;
                        
                        &:hover {
                            background: darken(#dc3545, 5%);
                            transform: translateY(-0.2vh);
                        }
                    }

                    &.p-button-secondary {
                        background: rgba(255, 255, 255, 0.1);
                        
                        &:hover {
                            background: rgba(255, 255, 255, 0.15);
                            transform: translateY(-0.2vh);
                        }
                    }

                    i {
                        font-size: 1.4vh;
                    }

                    span {
                        font-size: 1.3vh;
                    }
                }
            }
        }
    }
}
</style>