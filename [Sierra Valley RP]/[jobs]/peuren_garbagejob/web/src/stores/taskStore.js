import { ref } from 'vue';
import { createGlobalState } from '@vueuse/core';

export const useTaskStore = createGlobalState(() => {
    const task = ref({
        visible: false,
        text: '',
        progress: null,
        progressMax: 100,
        position: 'middle-right'
    });

    const showTask = (text, progress = null, position = 'middle-right', max = 100) => {
        task.value = {
            visible: true,
            text,
            progress,
            progressMax: max,
            position
        };
    };

    const hideTask = () => {
        task.value.visible = false;
    };

    const updateProgress = (progress) => {
        if (task.value.visible) {
            task.value.progress = progress;
        }
    };

    // Listen for NUI messages
    window.addEventListener('message', (event) => {
        if (event.data.type === 'showTask') {
            showTask(
                event.data.text, 
                event.data.progress, 
                event.data.position,
                event.data.max || 100
            );
        } else if (event.data.type === 'hideTask') {
            hideTask();
        } else if (event.data.type === 'updateTaskProgress') {
            updateProgress(event.data.progress);
        }
    });

    return {
        task,
        showTask,
        hideTask,
        updateProgress
    };
});
