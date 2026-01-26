<script setup>
    import { useGlobalState } from '../../stores/globalStore';
    import Menubar from 'primevue/menubar';
    import { ref } from "vue";
    import { fetchNui } from '../../utils';
    import { locale } from "../../locale";

    const globalState = useGlobalState();
    const pageData = useGlobalState().pageData.value;

    const items = ref([
        {
            label: locale('header', 'job_tab_title'),
            icon: 'pi pi-briefcase',
            command: async () => {
                const result = await fetchNui('getJobState');
                if (!result) {
                    globalState.changeCurrentTab("job");
                } else  {
                    globalState.changeCurrentTab("start-job");
                }
            }
        },
        {
            label: locale('header', 'rank_tab_title'),
            icon: 'pi pi-star-fill',
            command: async () => {
                const result = await fetchNui('getProfile');
                pageData.profile = result;
                globalState.changeCurrentTab("rank");
            }
        }
    ]);
</script>

<template>
    <div class="Container">
        <div class="Content">
            <Menubar :model="items" />
        </div>
    </div>
</template>

<style scoped lang="scss">
    .Container {
        width: 100%;
        border-radius: 1vh;
        color: white !important;    

        .Content {
            padding: 1vh;
            padding-bottom: 0;
        }

        .p-menubar {
            border: none;
            background-color: rgb(32, 32, 32);
        }
    }

</style>