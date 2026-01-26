<script setup>
    import { useGlobalState } from '../stores/globalStore';    
    import { fetchNui } from '../utils';
    import { ref, computed, onMounted } from "vue";
    import locale from "../locale";
    import Dialog from 'primevue/dialog';
    import InputText from 'primevue/inputtext';
    
    const globalState = useGlobalState();
    const searchQuery = ref('');
    const loading = ref(true);

    const filteredGroups = computed(() => {
        if (!searchQuery.value) return Object.values(globalState.groups.value || {});
        return Object.values(globalState.groups.value || {}).filter(group => 
            group.groupId.toString().includes(searchQuery.value.toLowerCase())
        );
    });

    const showPasswordDialog = ref(false);
    const selectedGroupId = ref(null);
    const password = ref('');

    const openPasswordDialog = (groupId) => {
        selectedGroupId.value = groupId;
        password.value = '';
        showPasswordDialog.value = true;
    };

    const joinGroup = async () => {
        const result = await fetchNui('enter-group', { 
            id: selectedGroupId.value, 
            password: password.value 
        });
        
        if (!result) return;
        showPasswordDialog.value = false;
        globalState.current.value = result;
        globalState.changeCurrentTab("start-job");
    }


    onMounted(async() => {
        loading.value = true;
        try {
            const result = await fetchNui('get-groups');
            globalState.groups.value = result;
        } finally {
            loading.value = false;
        }
    });
</script>

<template>
    <div class="groups-container">
        <div class="groups-wrapper">
            <div class="groups-header">
                <div class="header-content">
                    <div class="header-main">
                        <div class="title-icon">
                            <i class="pi pi-users"></i>
                        </div>
                        <div class="header-text">
                            <h3>{{ locale('groups', 'groups_header_title') }}</h3>
                            <span class="subtitle">{{ locale('groups', 'subtitle') }}</span>
                        </div>
                    </div>
                    <div class="search-bar">
                        <i class="pi pi-search"></i>
                        <input 
                            v-model="searchQuery"
                            type="text"
                            :placeholder="locale('groups', 'search_groups')"
                        >
                    </div>
                </div>
            </div>
            <div class="groups-content">
                <div v-if="loading" class="loading-container">
                    <i class="pi pi-spin pi-spinner"></i>
                    <span>Loading groups...</span>
                </div>
                <div v-else class="groups-grid">
                    <template v-if="filteredGroups.length > 0">
                        <div v-for="item in filteredGroups" 
                             :key="item.groupId" 
                             class="group-item">
                            <div class="group-main">
                                <div class="group-left">
                                    <div class="group-icon">
                                        <i class="pi pi-users"></i>
                                    </div>
                                    <div class="group-details">
                                        <div class="group-title">
                                            <h4>{{ locale('groups', 'group_title') + " " + item.groupId }}</h4>
                                            <div class="group-status">
                                                <i class="pi pi-circle-fill"></i>
                                                <span>{{ locale('groups', 'active_status') }}</span>
                                            </div>
                                        </div>
                                        <div class="group-meta">
                                            <Tag icon="pi pi-users" 
                                                 :value="item.pCount + ' Members'"
                                                 severity="success" />
                                        </div>
                                    </div>
                                </div>
                                <Button @click="openPasswordDialog(item.groupId)" 
                                        class="join-button"
                                        :class="{ 'p-button-outlined': true }">
                                    <i class="pi pi-sign-in"></i>
                                    <span>{{ locale('home', 'join_group') }}</span>
                                </Button>
                            </div>
                        </div>
                    </template>
                    <div v-else class="no-groups">
                        <div class="no-groups-content">
                            <i class="pi pi-info-circle"></i>
                            <h3>{{ locale('groups', 'no_groups_title') }}</h3>
                            <p>{{ locale('groups', 'no_groups_description') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Password Dialog -->
    <Dialog v-model:visible="showPasswordDialog" 
            :modal="true"
            :header="locale('groups', 'enter_password')"
            class="password-dialog">
        <div class="password-input-container">
            <span class="p-float-label">
                <InputText v-model="password" 
                          type="password"
                          @keyup.enter="joinGroup"
                          autofocus />
                <label>{{ locale('groups', 'group_password') }}</label>
            </span>
        </div>
        <template #footer>
            <Button @click="showPasswordDialog = false" 
                    class="p-button-text">
                {{ locale('groups', 'cancel') }}
            </Button>
            <Button @click="joinGroup" 
                    class="p-button-success">
                {{ locale('groups', 'join') }}
            </Button>
        </template>
    </Dialog>
</template>

<style scoped lang="scss">
.groups-container {
    display: flex;
    padding: 2vh;
    height: 100%;
    width: 100%;
    color: white;
    min-height: 52vh;
    max-height: 52vh;

    .groups-wrapper {
        flex: 1;
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        display: flex;
        flex-direction: column;
        overflow: hidden;

        .groups-header {
            position: sticky;
            top: 0;
            z-index: 10;
            background-color: rgb(32, 32, 32);
            padding: 2vh;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 0.8vh 0.8vh 0 0;

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

                .search-bar {
                    display: flex;
                    align-items: center;
                    gap: 1vh;
                    background: rgba(255, 255, 255, 0.05);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    border-radius: 0.8vh;
                    padding: 0 1.5vh;
                    height: 4vh;
                    min-width: 25vh;
                    transition: all 0.2s ease;

                    &:hover, &:focus-within {
                        background: rgba(255, 255, 255, 0.08);
                        border-color: rgba(87, 182, 87, 0.3);
                    }

                    i {
                        font-size: 1.4vh;
                        color: rgb(87, 182, 87);
                    }

                    input {
                        flex: 1;
                        background: none;
                        border: none;
                        outline: none;
                        color: white;
                        font-size: 1.3vh;
                        height: 100%;

                        &::placeholder {
                            color: rgba(255, 255, 255, 0.5);
                        }
                    }
                }
            }
        }

        .groups-content {
            flex: 1;
            overflow-y: auto;
            padding: 2vh;
            padding-top: 1vh;

            .loading-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                height: 100%;
                gap: 1vh;
                color: rgb(87, 182, 87);

                i {
                    font-size: 3vh;
                }

                span {
                    font-size: 1.4vh;
                    color: rgba(255, 255, 255, 0.7);
                }
            }

            .groups-grid {
                display: grid;
                gap: 1.5vh;

                .group-item {
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 0.8vh;
                    padding: 2vh;
                    transition: all 0.2s ease;

                    &:hover {
                        background: rgba(255, 255, 255, 0.08);
                        transform: translateY(-0.2vh);
                    }

                    .group-main {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        gap: 2vh;

                        .group-left {
                            display: flex;
                            align-items: center;
                            gap: 2vh;
                            flex: 1;

                            .group-icon {
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                width: 6vh;
                                height: 6vh;
                                background: rgba(87, 182, 87, 0.1);
                                border: 2px solid rgba(87, 182, 87, 0.2);
                                border-radius: 1vh;

                                i {
                                    font-size: 2.8vh;
                                    color: rgb(87, 182, 87);
                                }
                            }

                            .group-details {
                                display: flex;
                                flex-direction: column;
                                gap: 1vh;

                                .group-title {
                                    display: flex;
                                    align-items: center;
                                    gap: 1.5vh;

                                    h4 {
                                        margin: 0;
                                        font-size: 1.8vh;
                                        font-weight: 600;
                                    }

                                    .group-status {
                                        display: flex;
                                        align-items: center;
                                        gap: 0.5vh;
                                        font-size: 1.2vh;
                                        color: rgb(87, 182, 87);

                                        i {
                                            font-size: 0.8vh;
                                        }
                                    }
                                }

                                .group-meta {
                                    display: flex;
                                    gap: 1vh;

                                    .p-tag {
                                        background: rgba(87, 182, 87, 0.1);
                                        color: rgb(87, 182, 87);
                                        font-size: 1.2vh;
                                        padding: 0.6vh 1vh;
                                        border: 1px solid rgba(87, 182, 87, 0.2);
                                    }
                                }
                            }
                        }

                        .join-button {
                            height: 4.5vh;
                            min-width: 15vh;
                            padding: 0 2vh;
                            background: transparent;
                            border: 2px solid rgb(87, 182, 87);
                            color: rgb(87, 182, 87);
                            border-radius: 0.8vh;
                            transition: all 0.2s ease;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            gap: 1vh;
                            
                            &:hover {
                                background: rgb(87, 182, 87);
                                color: white;
                                transform: translateY(-0.2vh);
                                box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.2);
                            }

                            &:active {
                                transform: translateY(0);
                            }

                            i {
                                font-size: 1.6vh;
                            }

                            span {
                                font-size: 1.4vh;
                                font-weight: 600;
                                white-space: nowrap;
                            }
                        }
                    }
                }

                .no-groups {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 4vh;
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 0.8vh;
                    text-align: center;

                    .no-groups-content {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 1vh;

                        i {
                            font-size: 3vh;
                            color: rgb(87, 182, 87);
                        }

                        h3 {
                            margin: 0;
                            font-size: 1.8vh;
                            font-weight: 600;
                        }

                        p {
                            margin: 0;
                            font-size: 1.4vh;
                            color: rgba(255, 255, 255, 0.5);
                            max-width: 40vh;
                            line-height: 1.8vh;
                        }
                    }
                }
            }

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

                &:hover {
                    background: rgba(87, 182, 87, 0.5);
                }
            }
        }
    }
}

.password-dialog {
    :deep(.p-dialog) {
        background: rgb(32, 32, 32);
        border-radius: 0.8vh;
        min-width: 40vh;
    }

    :deep(.p-dialog-header) {
        padding: 2vh;
        background: rgb(32, 32, 32);
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 0.8vh 0.8vh 0 0;
        
        .p-dialog-title {
            color: white;
            font-size: 1.8vh;
            font-weight: 600;
        }
        
        .p-dialog-header-close {
            width: 3vh;
            height: 3vh;
            border-radius: 0.4vh;
            transition: all 0.2s ease;
            
            &:hover {
                background: rgba(255, 255, 255, 0.1);
            }
            
            .p-dialog-header-close-icon {
                color: rgba(255, 255, 255, 0.7);
                font-size: 1.6vh;
            }
        }
    }

    :deep(.p-dialog-content) {
        background: rgb(32, 32, 32);
        padding: 2vh;

        .password-input-container {
            display: flex;
            flex-direction: column;
            gap: 1vh;

            .p-float-label {
                position: relative;
                margin-top: 1vh;

                input {
                    width: 100%;
                    background: rgba(255, 255, 255, 0.05);
                    border: 2px solid rgba(87, 182, 87, 0.2);
                    color: white;
                    border-radius: 0.6vh;
                    padding: 1.5vh;
                    font-size: 1.4vh;
                    transition: all 0.2s ease;
                    height: 4.5vh;

                    &:hover {
                        background: rgba(255, 255, 255, 0.08);
                        border-color: rgba(87, 182, 87, 0.3);
                    }

                    &:focus {
                        background: rgba(255, 255, 255, 0.08);
                        border-color: rgb(87, 182, 87);
                        outline: none;
                    }

                    &:focus ~ label {
                        color: rgb(87, 182, 87);
                    }
                }

                label {
                    position: absolute;
                    left: 1vh;
                    top: -1.2vh;
                    font-size: 1.2vh;
                    padding: 0 0.5vh;
                    color: rgba(255, 255, 255, 0.7);
                    background: rgb(32, 32, 32);
                    transition: all 0.2s ease;
                }
            }
        }
    }

    :deep(.p-dialog-footer) {
        background: rgb(32, 32, 32);
        padding: 2vh;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
        display: flex;
        gap: 1vh;
        justify-content: flex-end;
        border-radius: 0 0 0.8vh 0.8vh;

        .p-button {
            height: 4vh;
            padding: 0 2vh;
            font-size: 1.4vh;
            border-radius: 0.6vh;
            transition: all 0.2s ease;

            &.p-button-text {
                color: rgba(255, 255, 255, 0.7);
                background: transparent;
                border: none;

                &:hover {
                    background: rgba(255, 255, 255, 0.1);
                }
            }

            &.p-button-success {
                background: rgb(87, 182, 87);
                border: none;
                color: white;

                &:hover {
                    background: darken(rgb(87, 182, 87), 5%);
                    transform: translateY(-0.2vh);
                    box-shadow: 0 0.4vh 0.8vh rgba(87, 182, 87, 0.2);
                }

                &:active {
                    transform: translateY(0);
                }
            }
        }
    }
}
</style>