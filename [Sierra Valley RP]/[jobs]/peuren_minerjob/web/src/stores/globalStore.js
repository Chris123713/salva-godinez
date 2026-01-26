import { ref } from 'vue';
import { createGlobalState } from '@vueuse/core';
import { fetchNui, isEnvBrowser } from '../utils';

export const useGlobalState = createGlobalState(() => {
        const visible = ref(null);
        const currentTab = ref("job");
        const pageData = ref({});
        const locale = ref({});
        const groups = ref([]);
        const selectJobs = ref(false);
        const inventoryURL = ref("");

        const changeCurrentTab = (newTab) => {
            currentTab.value = newTab;
        };

        window.addEventListener("message", (event) => {
            if (event.data.type == "visible") {
                visible.value = event.data.value;
            } else if (event.data.type == "pageData") {     
                pageData.value = event.data.value;
                if (pageData.value.page) changeCurrentTab(pageData.value.page);  
            } else if (event.data.type == "groups") {
                groups.value = event.data.value;
            } else if (event.data.type == "loadInventoryURL") {
                inventoryURL.value = event.data.data;
            }
        });

        window.addEventListener("keydown", (event) => {
            if (event.key == "Escape") {
                fetchNui("close");
            }
        })

        return { visible, pageData, currentTab, changeCurrentTab, selectJobs, locale, groups, inventoryURL }
    }
);