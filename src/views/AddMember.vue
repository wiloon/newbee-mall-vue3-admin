<template>
  <div class="add">
    <el-card class="add-container">
      <el-form :model="state.goodForm" :rules="state.rules" ref="goodRef" label-width="100px" class="goodForm">
        <el-form-item required label="用户昵称">
            <el-input style="width: 300px" v-model="nickName" placeholder="请输入昵称"></el-input>
        </el-form-item>
        <el-form-item label="用户名(手机号)">
            <el-input style="width: 300px" v-model="username" placeholder="请输入用户名"></el-input>
        </el-form-item>
        <el-form-item label="密码">
            <el-input style="width: 300px" v-model="password" placeholder="请输入密码"></el-input>
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
import md5 from 'js-md5';

const nickName = ref('')
const username = ref('')
const password = ref('')

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
})
onBeforeUnmount(() => {
})
const submitAdd = () => {
// 默认新增用 post 方法
    let httpOption = axios.post
    let params = {
        nickName: nickName.value,
        username: username.value,
        password: md5(password.value),
    }
    console.log('params', params)
    httpOption('/adminSaveMember', params).then(() => {
        ElMessage.success( '添加成功')
        router.push({ path: '/guest' })
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