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
            <el-select v-model="shop" class="m-2" v-on:change="shopChange">
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
          <el-input type="number" style="width: 300px" v-model="number" placeholder="请输入商品数量"></el-input>
        </el-form-item>
        <el-form-item label="支付方式" prop="sellingPrice">
            <el-select v-model="payType" class="m-2" v-on:change="payTypeChange">
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
          <el-form-item label="创建时间" prop="stockNum">
              <el-date-picker
                      v-model="createTime"
                      type="datetime"
                      placeholder="Select date and time"
                      value-format="YYYY-M-D[T]H:m:s"
              />
          </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitAdd()">{{ orderId>-1 ? '立即修改' : '立即创建' }}</el-button>
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

function nowDate() {
    var a = new Date().getTime(); //获取到当前时间戳
    var b = new Date(a); //创建一个指定的日期对象
    var now= b
    var year = now.getFullYear(); //年份
    var month = now.getMonth() + 1; //月份（0-11）
    var date = now.getDate(); //天数（1到31）
    var hour = now.getHours(); //小时数（0到23）
    var minute = now.getMinutes(); //分钟数（0到59）
    var second = now.getSeconds(); //秒数（0到59）
    return (
        year + "-" + month + "-" + date + "T" + hour + ":" + minute + ":" + second
    )
};

let orderId = ref(-1)
let orderNo = ref('')
let createTime = ref(nowDate())
let member = ref(-1)
const memberOptions = ref([])

let shop = ref(-1)
const shopList = ref([])

let goods = ref('')
const goodsList = ref([])

let payType = ref(1)
const payTypeList = ref([])

let number = ref(1)

let orderStatus = ref(4)
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

    let {orderIdTmp} = useRoute().query
    console.log('order id:'+orderIdTmp)
    if (orderIdTmp !== undefined){
        axios.get(`/shoporders/${orderIdTmp}`, {
            params: {}
        }).then(res => {
            console.log('on mount, order data')
            console.log(res)
            orderId.value = res.orderId
            orderNo.value = res.orderNo
            member.value = res.userId
            shop.value=res.shopId
            goods.value= res.goodsId
            payType.value= res.payType
            number.value= res.goodsCount
            orderStatus.value= res.orderStatus
            createTime.value = res.createTime

            getGoodsList()
        })

    }
})
onBeforeUnmount(() => {
})
const submitAdd = () => {
    console.log('submit add')
    console.log(number.value)
    console.log(typeof number.value)
    // 默认新增用 post 方法
    let httpOption = axios.post
    let params = {
        orderId: orderId.value,
        orderNo: orderNo.value,
        member: member.value,
        shop: shop.value,
        goods: goods.value,
        payType: payType.value,
        number: parseInt(number.value),
        orderStatus: orderStatus.value,
        createTime: createTime.value.substring(0, 19)
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
const shopChange = () => {
    goods.value=''
    getGoodsList()

}
const payTypeChange = () => {
    if (payType.value===0){
        orderStatus.value=0
    }else if (payType.value===1 ||payType.value===2){
        orderStatus.value=4
    }
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
        value: 0,
        label: "待支付",
    })
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


