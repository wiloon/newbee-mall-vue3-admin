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
        <el-form-item label="店铺" prop="goodsName">
          <el-input style="width: 300px" v-model="state.goodForm.goodsName"></el-input>
        </el-form-item>
        <el-form-item label="商品" prop="goodsIntro">
          <el-input style="width: 300px" type="textarea" v-model="state.goodForm.goodsIntro" placeholder="请输入商品简介(100字)"></el-input>
        </el-form-item>
        <el-form-item label="数量" prop="originalPrice">
          <el-input type="number" min="0" style="width: 300px" v-model="state.goodForm.originalPrice" placeholder="请输入商品价格"></el-input>
        </el-form-item>
        <el-form-item label="支付方式" prop="sellingPrice">
          <el-input type="number" min="0" style="width: 300px" v-model="state.goodForm.sellingPrice" placeholder="请输入商品售价"></el-input>
        </el-form-item>
        <el-form-item label="订单状态" prop="stockNum">
          <el-input type="number" min="0" style="width: 300px" v-model="state.goodForm.stockNum" placeholder="请输入商品库存"></el-input>
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
import { localGet, uploadImgServer, uploadImgsServer } from '@/utils'

const member = ref('')
const memberOptions = ref([])
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
  rules: {
    goodsName: [
      { required: 'true', message: '请填写商品名称', trigger: ['change'] }
    ],
    originalPrice: [
      { required: 'true', message: '请填写商品价格', trigger: ['change'] }
    ],
    sellingPrice: [
      { required: 'true', message: '请填写商品售价', trigger: ['change'] }
    ],
    stockNum: [
      { required: 'true', message: '请填写商品库存', trigger: ['change'] }
    ],
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
})
onBeforeUnmount(() => {
})
const submitAdd = () => {
  goodRef.value.validate((vaild) => {
    if (vaild) {
      // 默认新增用 post 方法
      let httpOption = axios.post
      let params = {
        goodsCategoryId: state.categoryId,
        goodsDetailContent: instance.txt.html(),
        goodsIntro: state.goodForm.goodsIntro,
        goodsName: state.goodForm.goodsName,
        originalPrice: state.goodForm.originalPrice,
        sellingPrice: state.goodForm.sellingPrice,
        stockNum: state.goodForm.stockNum
      }
      console.log('params', params)
      if (id) {
        params.goodsId = id
        // 修改商品使用 put 方法
        httpOption = axios.put
      }
      httpOption('/goods', params).then(() => {
        ElMessage.success(id ? '修改成功' : '添加成功')
        router.push({ path: '/good' })
      })
    }
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
  .avatar-uploader {
    width: 100px;
    height: 100px;
    color: #ddd;
    font-size: 30px;
  }
  .avatar-uploader-icon {
    display: block;
    width: 100%;
    height: 100%;
    border: 1px solid #e9e9e9;
    padding: 32px 17px;
  }
</style>