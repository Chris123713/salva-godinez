<script setup>
  import Header from "./components/Header.vue";
  import Home from "./pages/Home.vue";
  import StartJob from "./pages/StartJob.vue";
  import Rank from "./pages/Rank.vue";
  import Group from "./pages/Groups.vue";

  import { useGlobalState } from "./stores/globalStore";
  const globalState = useGlobalState();
</script>

<template>
  <div class="MainContainer" v-if="globalState.visible.value">
    <div class="Content">
      <Header v-if="globalState.currentTab.value != 'current'" />
      <div class="Contents">
        <Home v-if="globalState.currentTab.value == 'job'" />
        <StartJob v-if="globalState.currentTab.value == 'start-job'" />
        <Rank v-if="globalState.currentTab.value == 'rank'" />
        <Group v-if="globalState.currentTab.value == 'join-group'" />
      </div>
    </div>
  </div>
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
