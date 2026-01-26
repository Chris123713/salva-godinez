<script setup>
  import { useGlobalState } from "./stores/globalStore";
  import { useTaskStore } from "./stores/taskStore";

  import CenterHeader from "./components/center/Header.vue";
  import Home from "./pages/center/Home.vue";
  import StartJob from "./pages/center/StartJob.vue";
  import Rank from "./pages/center/Rank.vue";
  import Group from "./pages/center/Groups.vue";
  import Contracts from "./pages/tablet/Contracts.vue";
  import Task from "./pages/center/Task.vue";
  import { locale } from "./locale";

  const globalState = useGlobalState();
  const taskStore = useTaskStore();
</script>

<template>
  <div class="Center" v-if="globalState.visible.value == 'center'">
    <div class="Content">
      <CenterHeader v-if="globalState.currentTab.value != 'current'" />
      <div class="Contents">
        <Home v-if="globalState.currentTab.value == 'job'" />
        <StartJob v-if="globalState.currentTab.value == 'start-job'" />
        <Rank v-if="globalState.currentTab.value == 'rank'" />
        <Group v-if="globalState.currentTab.value == 'join-group'" />
      </div>
    </div>
  </div>
  <Task />
  <div class="Tablet" v-if="globalState.visible.value == 'tablet'">
      <div class="Content"> 
          <Contracts v-if="globalState.currentTab.value == 'contracts'" />
      </div>
    </div>
    <div>    
  </div>
</template>

<style scoped lang="scss">
  .Tablet {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;

    .Header {
      font-size: 2vh;
      color: white;
      padding: 2vh;
    }

    .Content {
      display: flex;
      align-items: center;
      justify-content: center;
      flex-flow: column;
      width: 96vh;
      background-color: rgb(15, 15, 15);
      border-radius: 0.5vh;
    }
  }

  .Center {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;

    .Content {
      display: flex;
      align-items: center;
      flex-flow: column;
      width: 90vh;
      background-color: rgb(15, 15, 15);
      border-radius: 0.5vh;

      .Contents {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 52vh;
        width: 100%;        
  
      }
    }
  }
</style>
