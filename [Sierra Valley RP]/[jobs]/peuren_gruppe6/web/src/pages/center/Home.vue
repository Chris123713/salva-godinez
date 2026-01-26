<script setup>
import { fetchNui } from '../../utils';
import { useGlobalState } from '../../stores/globalStore';
import { locale } from "../../locale";

const globalState = useGlobalState();    

const jobFeatures = [
    {
        icon: 'pi pi-dollar',
        title: locale('home', 'features.competitive_pay.title'),
        description: locale('home', 'features.competitive_pay.description')
    },
    {
        icon: 'pi pi-clock',
        title: locale('home', 'features.flexible_hours.title'),
        description: locale('home', 'features.flexible_hours.description')
    },
    {
        icon: 'pi pi-chart-line',
        title: locale('home', 'features.career_growth.title'),
        description: locale('home', 'features.career_growth.description')
    },
    {
        icon: 'pi pi-users',
        title: locale('home', 'features.team_environment.title'),
        description: locale('home', 'features.team_environment.description')
    }
];

const CreateJob = async () => {
    const result = await fetchNui('create-job');
    if (!result) return;
    globalState.pageData.value.current = result;
    globalState.changeCurrentTab('start-job');
}

const Groups = () => {
    globalState.changeCurrentTab('join-group');
}
</script>

<template>
    <div class="home-container">
        <!-- Actions Section -->
        <div class="actions-sidebar">
            <div class="action-card">
                <div class="action-icon">
                    <i class="pi pi-user-plus"></i>
                </div>
                <div class="action-info">
                    <h3>{{ locale('home', 'start_solo_job') }}</h3>
                    <p>{{ locale('home', 'group_job_description') }}</p>
                    <Button class="p-button-success" @click="CreateJob()">
                        <i class="pi pi-play"></i>
                        <span>{{ locale('home', 'start_job') }}</span>
                    </Button>
                </div>
            </div>

            <div class="action-card">
                <div class="action-icon">
                    <i class="pi pi-users"></i>
                </div>
                <div class="action-info">
                    <h3>{{ locale('home', 'join_group_title') }}</h3>
                    <p>{{ locale('home', 'groups_description') }}</p>
                    <Button @click="Groups()">
                        <i class="pi pi-search"></i>
                        <span>{{ locale('home', 'join_group') }}</span>
                    </Button>
                </div>
            </div>
        </div>

        <!-- Main Content Section -->
        <div class="main-content">
            <div class="header-image">
                <img src="/header.png" alt="Towing Service">
                <div class="overlay">
                    <h1>{{ locale('home', 'job_header_title') }}</h1>
                </div>
            </div>

            <div class="features-grid">
                <div v-for="feature in jobFeatures" 
                    :key="feature.title" 
                    class="feature-item">
                    <div class="feature-icon">
                        <i :class="feature.icon"></i>
                    </div>
                    <div class="feature-content">
                        <h3>{{ feature.title }}</h3>
                        <p>{{ feature.description }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.home-container {
    display: flex;
    gap: 2vh;
    padding: 2vh;
    height: 100%;
    width: 100%;
    color: white;
    min-height: 52vh;
    max-height: 52vh;
    min-width: 90vh;
    max-width: 90vh;

    .actions-sidebar {
        display: flex;
        flex-direction: column;
        gap: 2vh;
        width: 20vh;
        min-width: 20vh;
        max-width: 20vh;

        .action-card {
            background-color: rgb(32, 32, 32);
            border-radius: 0.8vh;
            padding: 1.5vh;
            gap: 1.5vh;
            display: flex;
            flex-direction: column;
            height: calc(50% - 1vh);
            min-height: 0;
            max-height: calc(50% - 1vh);

            .action-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 4.5vh;
                height: 4.5vh;
                min-width: 4.5vh;
                background: rgba(87, 182, 87, 0.1);
                border-radius: 0.6vh;
                margin: 0;

                i {
                    font-size: 2vh;
                    color: rgb(87, 182, 87);
                }
            }

            .action-info {
                display: flex;
                flex-direction: column;
                flex: 1;
                min-height: 0;
                gap: 1.5vh;

                h3 {
                    font-size: 1.6vh;
                    font-weight: 600;
                    margin: 0;
                }

                p {
                    font-size: 1.3vh;
                    color: rgb(200, 200, 200);
                    margin: 0;
                    line-height: 1.6vh;
                    flex: 1;
                    overflow: hidden;
                    display: -webkit-box;
                    -webkit-line-clamp: 2;
                    -webkit-box-orient: vertical;
                }

                .p-button {
                    margin: 0;
                    padding: 0;
                    height: 4vh;
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
    }

    .main-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 2vh;
        
        .header-image {
            position: relative;
            height: 23vh;
            border-radius: 0.8vh;
            overflow: hidden;

            img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .overlay {
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                padding: 2vh;
                background: linear-gradient(transparent, rgba(0, 0, 0, 0.8));

                h1 {
                    color: white;
                    font-size: 2.5vh;
                    font-weight: 600;
                    margin: 0;
                }
            }
        }

        .features-grid {
            display: grid;
            justify-content: center;
            align-items: center;
            grid-template-columns: repeat(2, 1fr);
            gap: 2vh;
            background: rgb(32, 32, 32);
            padding: 2vh;
            border-radius: 0.8vh;
            flex: 1;

            .feature-item {
                display: flex;
                gap: 1.5vh;
                padding: 1.5vh;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.8vh;
                transition: all 0.2s ease;
                height: 8vh;
                min-height: 8vh;
                max-height: 8vh;
                overflow: hidden;

                &:hover {
                    background: rgba(255, 255, 255, 0.08);
                }

                .feature-icon {
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

                .feature-content {
                    width: 0;
                    min-width: 0;
                    flex: 1;

                    h3 {
                        margin: 0 0 0.5vh 0;
                        font-size: 1.6vh;
                        font-weight: 600;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    p {
                        margin: 0;
                        font-size: 1.3vh;
                        color: rgb(200, 200, 200);
                        display: -webkit-box;
                        -webkit-line-clamp: 2;
                        -webkit-box-orient: vertical;
                        white-space: normal;
                        height: 3.6vh;
                    }
                }
            }
        }
    }
}
</style>