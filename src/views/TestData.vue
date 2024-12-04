<template>
  <el-card class="guest-container">
    <template #header>
      <div class="header">
        <el-button type="primary" :icon="Plus" @click="handleSolve">button-0</el-button>
        <el-button type="danger" :icon="Delete" @click="handleForbid">button-1</el-button>
        <el-button type="primary" :icon="Plus" @click="handleCreate()">button-2</el-button>
      </div>
    </template>
    <Table
        action='/test-data'
        ref="table"
    >
      <template #column>
        <el-table-column
            type="selection"
            width="55">
        </el-table-column>
        <el-table-column
            prop="networkType"
            label="制式"
        >
        </el-table-column>
        <el-table-column
            prop="gps"
            label="GPS"
        >
        </el-table-column>
        <el-table-column
            prop="snr"
            label="信噪比"
        >
        </el-table-column>
        <el-table-column
            prop="createTime"
            label="timestamp"
        >
        </el-table-column>
      </template>
    </Table>
  </el-card>
</template>

<script setup>
import { ref } from 'vue'
import Table from '@/components/Table.vue'
import { ElMessage } from 'element-plus'
import { Plus, Delete } from '@element-plus/icons-vue'
import axios from '@/utils/axios'
import {useRouter} from "vue-router";
const router = useRouter()

let table = ref(null)

// 解除禁用
const handleSolve = () => {
  if (!table.value.state.multipleSelection.length) {
    ElMessage.error('请选择项')
    return
  }
  axios.put(`/users/0`, {
    ids: table.value.state.multipleSelection.map(item => item.userId)
  }).then(() => {
    ElMessage.success('解除成功')
    table.value.getList()
  })
}

// 禁用账户
const handleForbid = () => {
  if (!table.value.state.multipleSelection.length) {
    ElMessage.error('请选择项')
    return
  }
  axios.put(`/users/1`, {
    ids: table.value.state.multipleSelection.map(item => item.userId)
  }).then(() => {
    ElMessage.success('禁用成功')
    table.value.getList()
  })
}

// 新建会员
const handleCreate = () => {
  console.log("create member")
  router.push({ path: '/addmember' })
}

</script>

<style>

</style>