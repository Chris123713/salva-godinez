<script setup>
    import { useGlobalState } from '../../stores/globalStore';    
    import ProgressBar from 'primevue/progressbar';
    import 'primeicons/primeicons.css';
    import { locale } from "../../locale";

    const pageData = useGlobalState().pageData.value;
</script>

<template>
    <div class="rank-container">
        <!-- Profile Section -->
        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-main">
                    <div class="profile-avatar">
                        <i class="pi pi-user"></i>
                    </div>
                    <div class="profile-info">
                        <h3>{{ pageData.profile.name.full }}</h3>
                        <div class="level-progress">
                            <ProgressBar :value="(pageData.profile.rank.XP / pageData.profile.rank.Next) * 100">
                                {{ pageData.profile.rank.XP + "/" + pageData.profile.rank.Next }}
                            </ProgressBar>
                            <Tag icon="pi pi-star" :value="pageData.profile.rank.Level + ' lvl'" severity="warning" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Jobs Grid -->
        <div class="jobs-section">
            <div class="section-header">
                <div class="header-title">
                    <i class="pi pi-star"></i>
                    <h2>{{ locale('rank', 'rank_unlockable_jobs_header') }}</h2>
                </div>
            </div>
            <div class="jobs-grid">
                <div v-for="(job, index) in pageData.jobs" 
                     :key="index"
                     class="job-card"
                     :class="{ 'locked': pageData.profile.rank.Level < job.level }">
                    <div class="job-content">
                        <div class="job-icon">
                            <img :src="`https://cfx-nui-peuren_gruppe6/web/dist/${job.icon}.png`" :alt="job.label">
                        </div>
                        <div class="job-details">
                            <h3>{{ job.label }}</h3>
                            <p>{{ job.description }}</p>
                            <Tag severity="warning" 
                                 icon="pi pi-star" 
                                 :value="job.level + ' lvl'" />
                        </div>
                    </div>
                    <div v-if="pageData.profile.rank.Level < job.level" class="lock-overlay">
                        <i class="pi pi-lock"></i>
                        <Tag icon="pi pi-star" 
                             severity="warning" 
                             :value="job.level + ' lvl'" />
                    </div>
                </div>
            </div>
        </div>
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
    min-height: 52vh;
    max-height: 52vh;

    .profile-card {
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        padding: 2vh;

        .profile-header {
            .profile-main {
                display: flex;
                align-items: center;
                gap: 2vh;

                .profile-avatar {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 6vh;
                    height: 6vh;
                    background: rgba(87, 182, 87, 0.1);
                    border: 2px solid rgba(87, 182, 87, 0.2);
                    border-radius: 0.8vh;

                    i {
                        font-size: 2.8vh;
                        color: rgb(87, 182, 87);
                    }
                }

                .profile-info {
                    flex: 1;

                    h3 {
                        margin: 0;
                        font-size: 1.8vh;
                        font-weight: 600;
                    }

                    .level-progress {
                        display: flex;
                        align-items: center;
                        gap: 1vh;
                        margin-top: 1vh;

                        .p-progressbar {
                            flex: 1;
                            height: 0.8vh;
                            background: rgba(255, 255, 255, 0.1);
                            border: none;

                            .p-progressbar-value {
                                background: rgb(87, 182, 87);
                            }
                        }

                        .p-tag {
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
    }

    .jobs-section {
        flex: 1;
        background-color: rgb(32, 32, 32);
        border-radius: 0.8vh;
        padding: 2vh;
        display: flex;
        flex-direction: column;
        overflow: hidden;

        .section-header {
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

        .jobs-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(20vh, 1fr));
            gap: 2vh;
            padding: 2vh 0;
            overflow-y: auto;
            margin-right: -1vh;
            padding-right: 1vh;
            max-height: 36vh; // Added to show 3 jobs at a time

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
                    background: rgba(87, 182, 87, 0.4); // Added hover effect
                }
            }

            .job-card {
                position: relative;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 0.8vh;
                overflow: hidden;
                transition: all 0.2s ease;

                &:hover {
                    transform: translateY(-0.2vh);
                    background: rgba(255, 255, 255, 0.08);
                }

                .job-content {
                    padding: 1.5vh;
                    display: flex;
                    flex-direction: column;
                    gap: 1.5vh;

                    .job-icon {
                        height: 10vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;

                        img {
                            max-height: 100%;
                            max-width: 100%;
                            object-fit: contain;
                        }
                    }

                    .job-details {
                        text-align: center;

                        h3 {
                            margin: 0 0 0.8vh 0;
                            font-size: 1.4vh;
                            font-weight: 600;
                        }

                        p {
                            margin: 0 0 1vh 0;
                            font-size: 1.2vh;
                            color: rgb(200, 200, 200);
                            line-height: 1.6vh;
                        }

                        .p-tag {
                            background: rgba(255, 193, 7, 0.1);
                            color: rgb(255, 193, 7);
                            border: 1px solid rgba(255, 193, 7, 0.2);
                            padding: 0.4vh 0.8vh;
                            font-size: 1.2vh;
                        }
                    }
                }

                .lock-overlay {
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(32, 32, 32, 0.9);
                    backdrop-filter: blur(0.5vh);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    gap: 1vh;

                    i {
                        font-size: 3vh;
                        color: rgba(255, 255, 255, 0.3);
                    }
                }
            }
        }
    }
}
</style>