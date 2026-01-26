<script setup>
  import { useGlobalState } from "./stores/globalStore";
  import Header from "./components/Header.vue";
  import Home from "./pages/Home.vue";
  import StartJob from "./pages/StartJob.vue";
  import SelectType from "./pages/SelectType.vue";
  import Group from "./pages/Groups.vue";
  import Garbage from "./pages/Garbage.vue";
  import Task from "./pages/Task.vue";

  const globalState = useGlobalState();
</script>

<template>
  <div class="MainContainer" v-if="globalState.visible.value">
    <div class="Content">
      <Header v-if="globalState.currentTab.value != 'current'" />
      <div class="Contents">
        <Home v-if="globalState.currentTab.value == 'job'" />
        <SelectType v-if="globalState.currentTab.value == 'select-jobs'" />
        <StartJob v-if="globalState.currentTab.value == 'start-job' || globalState.currentTab.value == 'select-jobs'" />
        <Group v-if="globalState.currentTab.value == 'join-group'" />
        <Garbage v-if="globalState.currentTab.value == 'garbage'" />
      </div>
    </div>
  </div>
  <Task />
</template>

<style scoped lang="scss">
  .MainContainer {
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
