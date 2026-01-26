import { ref } from 'vue';
import { createGlobalState } from '@vueuse/core';
import { fetchNui, isEnvBrowser } from '../utils';
import { setLocale } from '../locale';

export const useGlobalState = createGlobalState(() => {
        const visible = ref(false);
        const currentTab = ref("tablet");
        const pageData = ref({});
        const locale = ref({});
        const groups = ref({});
        const selectJobs = ref(false);
        const isTabletMode = ref(false);
        const { appReady } = window;

        const changeCurrentTab = (newTab) => {
            currentTab.value = newTab;
        };

        const fetchLocale = async () => {
            if (Object.keys(locale.value).length === 0) {
                try {
                    const data = await fetchNui('loadLocale');
                    setLocale(data);
                } catch (e) {
                    console.error('Failed to load locale', e);
                }
            }
        };

        window.addEventListener("message", async (event) => {
            await fetchLocale();
            
            if (event.data === 'componentsLoaded') {
                console.log('componentsLoaded received');
                visible.value = 'tablet';
                isTabletMode.value = true;
                pageData.value = await fetchNui("getTabletData");
                changeCurrentTab('contracts')
                return
            };
        
            if (event.data === 'parentReady') {
                console.log('parentReady received');
                visible.value = 'tablet';
                isTabletMode.value = true;
                pageData.value = await fetchNui("getTabletData");
                changeCurrentTab('contracts')
                appReady();
                return                                                                              
            };

            if (event.data.type == "visible") {
                visible.value = event.data.value;
            } else if (event.data.type == "pageData") {       
                pageData.value = event.data.value;
                if (pageData.value.page) changeCurrentTab(pageData.value.page);  
            } else if (event.data.type == "groups") {
                groups.value = event.data.value;
            }
        });

        window.addEventListener("keydown", (event) => {
            if (event.key == "Escape") {
                fetchNui("close");
            }
        })

        return { visible, pageData, currentTab, changeCurrentTab, selectJobs, locale, groups, isTabletMode }
    }
);