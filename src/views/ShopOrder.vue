<template>
  <el-card class="order-container">
    <template #header>
      <div class="header">
        <el-select v-model="shop" class="m-2" v-on:change="getOrderList">
            <el-option v-for="item in shopList"
                       :key="item.value"
                       :label="item.label"
                       :value="item.value"
            />
        </el-select>
      </div>
    </template>
    <div>
        <QrcodeVue :value="links" size="75" level="H" />
    </div>
    <el-table
      :load="state.loading"
      :data="state.tableData"
      tooltip-effect="dark"
      style="width: 100%"
      @selection-change="handleSelectionChange">
      <el-table-column
        type="selection"
        width="55">
      </el-table-column>
      <el-table-column
        prop="orderNo"
        label="订单号"
      >
      </el-table-column>
        <el-table-column
                prop="goodsName"
                label="商品名称"
        >
        </el-table-column>
        <el-table-column
                prop="sellingPrice"
                label="销售价格"
        >
        </el-table-column>
        <el-table-column
                prop="goodsCount"
                label="数量"
        >
        </el-table-column>
      <el-table-column
        prop="totalPrice"
        label="订单总价"
      >
      </el-table-column>
      <el-table-column
        prop="orderStatus"
        label="订单状态"
      >
        <template #default="scope">
          <span>{{ $filters.orderMap(scope.row.orderStatus) }}</span>
        </template>
      </el-table-column>

      <el-table-column
        prop="createTime"
        label="创建时间"
      >
      </el-table-column>
    </el-table>
    <el-pagination
      background
      layout="prev, pager, next"
      :total="state.total"
      :page-size="state.pageSize"
      :current-page="state.currentPage"
      @current-change="changePage"
    />
  </el-card>
</template>

<script setup>
import {onMounted, reactive, ref} from 'vue'
import { ElMessage } from 'element-plus'
import axios from '@/utils/axios'
import {useRouter} from "vue-router"
import QrcodeVue from 'qrcode.vue'

let links ='https://mall.wiloon.com'
const shop = ref(0)
const shopList = ref([])

const router = useRouter()
const state = reactive({
  loading: false,
  tableData: [], // 数据列表
  multipleSelection: [], // 选中项
  total: 0, // 总条数
  currentPage: 1, // 当前页
  pageSize: 10, // 分页大小
  orderNo: '', // 订单号
  orderStatus: '', // 订单状态
  // 订单状态筛选项默认值
  options: [{
    value: '',
    label: '全部'
  }, {
    value: 0,
    label: '待支付'
  }, {
    value: 1,
    label: '已支付'
  }, {
    value: 2,
    label: '配货完成'
  }, {
    value: 3,
    label: '出库成功'
  }, {
    value: 4,
    label: '交易成功'
  }, {
    value: -1,
    label: '手动关闭'
  }, {
    value: -2,
    label: '超时关闭'
  }, {
    value: -3,
    label: '商家关闭'
  }]
})

// 初始化获取订单列表
onMounted(() => {
    getShopList()
  getOrderList()

})

// 获取列表方法
const getOrderList = () => {
    links="https://mall.wiloon.com/#/home?shop="+shop.value
  state.loading = true
  axios.get('/shoporders', {
    params: {
      pageNumber: state.currentPage,
      pageSize: state.pageSize,
      orderNo: state.orderNo,
      orderStatus: state.orderStatus,
      shopId:shop.value
    }
  }).then(res => {
    state.tableData = res.list
    state.total = res.totalCount
    state.currentPage = res.currPage
    state.loading = false
  })
}
// 触发过滤项方法
const handleOption = () => {
  state.currentPage = 1
  getOrderList()
}
// checkbox 选择项
const handleSelectionChange = (val) => {
  state.multipleSelection = val
}
// 翻页方法
const changePage = (val) => {
  state.currentPage = val
  getOrderList()
}
// 配货方法
const handleConfig = (id) => {
  let params
  // 当个配置
  if (id) {
    params = [id]
  } else {
    if (!state.multipleSelection.length) {
      console.log('state.multipleSelection', state.multipleSelection.length)
      ElMessage.error('请选择项')
      return
    }
    // 多选配置
    params = state.multipleSelection.map(i => i.orderId)
  }
  axios.put('/orders/checkDone', {
    ids: params
  }).then(() => {
    ElMessage.success('配货成功')
    getOrderList()
  })
}
// 出库方法
const handleSend = (id) => {
  let params
  if (id) {
    params = [id]
  } else {
    if (!state.multipleSelection.length) {
      ElMessage.error('请选择项')
      return
    }
    params = state.multipleSelection.map(i => i.orderId)
  }
  axios.put('/orders/checkOut', {
    ids: params
  }).then(() => {
    ElMessage.success('出库成功')
    getOrderList()
  })
}
// 关闭订单方法
const handleClose = (id) => {
  let params
  if (id) {
    params = [id]
  } else {
    if (!state.multipleSelection.length) {
      ElMessage.error('请选择项')
      return
    }
    params = state.multipleSelection.map(i => i.orderId)
  }
  axios.put('/orders/close', {
    ids: params
  }).then(() => {
    ElMessage.success('关闭成功')
    getOrderList()
  })
}
const handleCreate = () => {
    console.log("create order")
    router.push({ path: '/addorder' })
}

const getShopList = () => {
    console.log("get shop list")
    axios.get('/shops', {
        params: {}
    }).then(res => {
        console.log('shop list response')
        console.log(res)
        res.list.forEach((row) => {
            shopList.value.push({
                value: row.id,
                label: row.name,
            })
        });

    })
}
</script>