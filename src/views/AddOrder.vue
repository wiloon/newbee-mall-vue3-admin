<template>
  <div class="add">
    <el-card class="add-container">
      <el-form :model="state.goodForm" :rules="state.rules" ref="goodRef" label-width="100px" class="goodForm">
        <el-form-item required label="会员">
            <el-select v-model="member" class="m-2">
                <el-option v-for="item in memberOptions"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                />
            </el-select>
        </el-form-item>
        <el-form-item label="店铺">
            <el-select v-model="shop" class="m-2" v-on:change="getGoodsList">
                <el-option v-for="item in shopList"
                           :key="item.value"
                           :label="item.label"
                           :value="item.value"
                />
            </el-select>
        </el-form-item>
        <el-form-item label="商品">
            <el-select v-model="goods" class="m-2">
                <el-option v-for="item in goodsList"
                           :key="item.value"
                           :label="item.label"
                           :value="item.value"
                />
            </el-select>
        </el-form-item>
        <el-form-item label="数量" prop="originalPrice">
          <el-input type="number" min="0" style="width: 300px" v-model="number" placeholder="请输入商品数量"></el-input>
        </el-form-item>
        <el-form-item label="支付方式" prop="sellingPrice">
            <el-select v-model="payType" class="m-2">
                <el-option v-for="item in payTypeList"
                           :key="item.value"
                           :label="item.label"
                           :value="item.value"
                />
            </el-select>
        </el-form-item>
        <el-form-item label="订单状态" prop="stockNum">
            <el-select v-model="orderStatus" class="m-2">
                <el-option v-for="item in orderStatusList"
                           :key="item.value"
                           :label="item.label"
                           :value="item.value"
                />
            </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitAdd()">{{ state.id ? '立即修改' : '立即创建' }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, onBeforeUnmount, getCurrentInstance } from 'vue'
import axios from '@/utils/axios'
import { ElMessage } from 'element-plus'
import { useRoute, useRouter } from 'vue-router'
import { localGet, uploadImgServer } from '@/utils'

const member = ref('')
const memberOptions = ref([])

const shop = ref('')
const shopList = ref([])

const goods = ref('')
const goodsList = ref([])

const payType = ref(1)
const payTypeList = ref([])

const number = ref(1)

const orderStatus = ref(4)
const orderStatusList = ref([])

const { proxy } = getCurrentInstance()
const goodRef = ref(null)
const route = useRoute()
const router = useRouter()
const { id } = route.query
const state = reactive({
  uploadImgServer,
  token: localGet('token') || '',
  id: id,
  defaultCate: '',
  goodForm: {
    goodsName: '',
    goodsIntro: '',
    originalPrice: '',
    sellingPrice: '',
    stockNum: ''
  },
  categoryId: '',
  category: {
    lazy: true,
    lazyLoad(node, resolve) {
      const { level = 0, value } = node
      axios.get('/categories', {
        params: {
          pageNumber: 1,
          pageSize: 1000,
          categoryLevel: level + 1,
          parentId: value || 0
        }
      }).then(res => {
        const list = res.list
        const nodes = list.map(item => ({
          value: item.categoryId,
          label: item.categoryName,
          leaf: level > 1
        }))
        resolve(nodes)
      })
    }
  }
})

onMounted(() => {
    getAllUsers()
    getShopList()
    initPayTypeList()
    initOrderStatusList()
})
onBeforeUnmount(() => {
})
const submitAdd = () => {
// 默认新增用 post 方法
    let httpOption = axios.post
    let params = {
        member: member.value,
        shop: shop.value,
        goods: goods.value,
        payType: payType.value,
        number: number.value,
        orderStatus: orderStatus.value,
    }
    console.log('params', params)
    httpOption('/adminSaveOrder', params).then(() => {
        ElMessage.success( '添加成功')
        router.push({ path: '/order' })
    })
}

const getAllUsers = () => {
    console.log("get all users")
    axios.get('/user/all', {
        params: {}
    }).then(res => {
        res.forEach((row) => {
            memberOptions.value.push({
                value: row.userId,
                label: row.nickName,
            })
        });

    })
}

const getShopList = () => {
    console.log("get shop list")
    axios.get('/shops', {
        params: {}
    }).then(res => {
        res.forEach((row) => {
            shopList.value.push({
                value: row.id,
                label: row.name,
            })
        });

    })
}

const getGoodsList = () => {
    console.log("get goods list")
    console.log("shop id: "+ shop.value)
    axios.get('/goods/list', {
        params: {shopId: shop.value}
    }).then(res => {
        try{
            console.log(res.list)
            goodsList.value.splice(0,goodsList.value.length);
            res.list.forEach((row) => {
                goodsList.value.push({
                    value: row.goodsId,
                    label: row.goodsName,
                })


        });
        }catch (e){
            console.log(e)
        }

    })
}

const initPayTypeList = () => {
    console.log("init pay type list")
    payTypeList.value.push({
        value: 1,
        label: "微信",
    })
    payTypeList.value.push({
        value: 2,
        label: "支付宝",
    })
}

// 0.待支付 1.已支付 2.配货完成 3:出库成功 4.交易成功 -1.手动关闭 -2.超时关闭 -3.商家关闭
const initOrderStatusList = () => {
    console.log("init order status list")
    orderStatusList.value.push({
        value: 0,
        label: "待支付",
    })
    orderStatusList.value.push({
        value: 1,
        label: "已支付",
    })
    orderStatusList.value.push({
        value: 2,
        label: "配货完成",
    })
    orderStatusList.value.push({
        value: 3,
        label: "出库成功",
    })
    orderStatusList.value.push({
        value: 4,
        label: "交易成功",
    })
    orderStatusList.value.push({
        value: -1,
        label: "手动关闭",
    })
    orderStatusList.value.push({
        value: -2,
        label: "超时关闭",
    })
    orderStatusList.value.push({
        value: -3,
        label: "商家关闭",
    })
}

const handleBeforeUpload = (file) => {
  const sufix = file.name.split('.')[1] || ''
  if (!['jpg', 'jpeg', 'png'].includes(sufix)) {
    ElMessage.error('请上传 jpg、jpeg、png 格式的图片')
    return false
  }
}
const handleChangeCate = (val) => {
  state.categoryId = val[2] || 0
}
</script>

<style scoped>
  .add {
    display: flex;
  }
  .add-container {
    flex: 1;
    height: 100%;
  }
</style>