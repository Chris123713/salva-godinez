import { ref } from 'vue';
import { createGlobalState } from '@vueuse/core';
import { fetchNui, isEnvBrowser, isInIframe } from '../utils';

export const useGlobalState = createGlobalState(() => {
        const visible = ref(null);
        const currentTab = ref("job");
        const pageData = ref({});
        const locale = ref({});
        const groups = ref({});
        const selectJobs = ref(false);

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
            }
        });

        window.addEventListener("keydown", (event) => {
            if (event.key == "Escape") {
                // If in iframe, send message to parent instead of NUI
                if (isInIframe()) {
                    window.parent.postMessage({
                        action: "closeApp",
                        source: "garbageApp",
                        appId: "peuren_garbagejob"
                    }, '*');
                } else {
                    fetchNui("close");
                }
            }
        });

        // If running in iframe (laptop), set visible immediately
        if (isInIframe()) {
            console.log('[GarbageJob] Running in iframe, setting visible to true');
            visible.value = true;
            
            // Notify parent that app is ready
            window.parent.postMessage({
                action: "appReady",
                source: "garbageApp",
                appId: "peuren_garbagejob"
            }, '*');
        }

        return { visible, pageData, currentTab, changeCurrentTab, selectJobs, locale, groups }
    }
);