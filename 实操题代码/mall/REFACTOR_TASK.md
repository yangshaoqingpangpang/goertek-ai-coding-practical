# 实操题方向C —— 耦合代码重构（mall 门户下单）

> 本文档面向考生。请在 Claude Code 协助下完成下列重构任务，并通过项目自带的行为基线测试佐证"对外行为不变"。

---

## 一、重构目标（锁定对象）

**唯一重构目标方法**：

```
com.macro.mall.portal.service.impl.OmsPortalOrderServiceImpl#generateOrder(OrderParam orderParam)
```

文件路径：`mall-portal/src/main/java/com/macro/mall/portal/service/impl/OmsPortalOrderServiceImpl.java`（约第 94–250 行，单方法约 156 行）。

**只允许重构这一个方法的内部实现**。方法签名（`public Map<String, Object> generateOrder(OrderParam orderParam)`）、所属类、对外行为必须保持不变。

---

## 二、现状分析（它为什么是"耦合严重"）

`generateOrder` 是一个典型的"上帝方法"，把多种职责堆叠在一个方法体里，严重违反**单一职责原则（SRP）**。可清晰识别出以下 6 类混合职责：

| # | 职责类别 | 代码位置（行号近似） | 说明 |
|---|---------|--------------------|------|
| 1 | **参数校验** | 97-99 | 校验收货地址是否为空，缺失即 `Asserts.fail` |
| 2 | **购物车/商品装配** | 100-122 | 拉取当前会员、查购物车促销信息、把 `CartPromotionItem` 逐字段拷成 `OmsOrderItem` |
| 3 | **库存校验与锁定** | 123-126、164-165 | `hasStock` 判断真实库存；`lockStock` 调 sku 库存 mapper 锁定库存 |
| 4 | **优惠券计算** | 127-141 | 取可用券、判断可用性、按全场通用/指定分类/指定商品分摊券金额 |
| 5 | **积分扣减计算** | 142-161 | 判断积分规则（门槛、是否可与券共用、单笔抵扣上限）、分摊到每个明细 |
| 6 | **金额计算** | 162-186 | 实付金额、总金额、促销优惠、券优惠、积分抵扣、应付金额 |
| 7 | **订单/明细落库** | 187-229 | 装配 `OmsOrder`、回填收货人信息、生成订单号、`orderMapper.insert` + `orderItemDao.insertList` |
| 8 | **优惠券/积分状态更新** | 230-241 | 更新券使用状态、扣减会员积分 |
| 9 | **购物车清理 + MQ 消息** | 242-245 | 删除购物车下单商品、发送延迟取消订单消息 |

此外该方法直接依赖了 **15 个外部协作对象**（`memberService`、`cartItemService`、`memberReceiveAddressService`、`memberCouponService`、`integrationConsumeSettingMapper`、`skuStockMapper`、`couponHistoryDao`、`orderMapper`、`orderItemDao`、`couponHistoryMapper`、`redisService`、`portalOrderDao`、`orderSettingMapper`、`orderItemMapper`、`cancelOrderSender`），耦合面过宽，难以单独测试与维护。

**结论**：业务逻辑、数据访问、计算规则、消息发送、状态更新全部混在一个方法里，这正是本次要拆解的对象。

---

## 三、重构要求

### 3.1 拆分目标（建议但不仅限于）

将 `generateOrder` 内部逻辑拆分为清晰分层、按职责聚合的子方法或独立 Service，例如：

- `OrderParamValidator.validate(OrderParam)` —— 参数校验（收货地址等）
- `CartItemAssembler.assemble(cartIds, member)` —— 购物车 → 订单明细装配
- `InventoryService.checkAndLock(items)` —— 库存校验 + 锁定
- `CouponCalculator.calculate(items, couponId)` —— 优惠券可用性判断与金额分摊
- `IntegrationCalculator.calculate(items, useIntegration, member, hasCoupon)` —— 积分规则判断与分摊
- `OrderAmountCalculator.calculate(items, order)` —— 总额/促销/券/积分/应付金额计算
- `OrderPersistenceService.save(order, items)` —— 订单与明细落库、券状态更新、积分扣减、购物车清理
- `OrderMessageService.sendCancelDelay(orderId)` —— 延迟取消消息发送

你可以选择：
- **方案 A（推荐）**：在 `OmsPortalOrderServiceImpl` 内提取若干 `private` 子方法（最小改动，仍保持一个类）。
- **方案 B（更彻底）**：抽出独立的 `@Service` 类（如 `CouponService`、`InventoryService`、`OrderPersistenceService`、`MessageService`），由 `OmsPortalOrderServiceImpl` 编排调用。

无论选哪种方案，`generateOrder` 方法体应缩短到 30-50 行以内的"编排"代码，逻辑清晰可读。

### 3.2 硬性约束（不可破坏）

1. **对外签名不变**：`public Map<String, Object> generateOrder(OrderParam orderParam)` 签名、返回类型、所属类、所在接口 `OmsPortalOrderService` 都不能改。
2. **对外行为不变**：
   - 返回的 `Map` 必须仍包含 key：`"order"`（`OmsOrder`）、`"orderItemList"`（`List<OmsOrderItem>`）。
   - 异常类型与异常消息必须逐字一致（例如 `"请选择收货地址！"`、`"库存不足，无法下单"`、`"该优惠券不可用"`、`"积分不可用"`）。
   - 副作用顺序与调用次数保持一致（订单落库、明细落库、库存锁定、券状态更新、积分扣减、购物车清理、延迟消息发送）。
3. **不破坏现有功能**：其余方法（`paySuccess`、`cancelOrder`、`list`、`detail` 等）保持原样。
4. **不动 `pom.xml`、不动公共模块**。

---

## 四、验证依据（行为基线测试）

项目已内置一个**行为基线测试**（你不得修改其断言与 Mock 契约）：

```
mall-portal/src/test/java/com/macro/mall/portal/OmsPortalOrderBehaviorTest.java
```

该测试基于 Mockito，把 `generateOrder` 的所有依赖全部 Mock 掉，**不依赖数据库/MQ/Redis 环境**，可稳定快速运行。它覆盖了 `generateOrder` 的 5 条核心行为路径：

| 用例 | 验证的行为 | 期望 |
|------|-----------|------|
| 1 | 收货地址为空 | 抛 `ApiException("请选择收货地址！")`，且不调用任何下游 |
| 2 | 库存不足（realStock < quantity） | 抛 `ApiException("库存不足，无法下单")`，订单未落库 |
| 3 | 优惠券不在可用列表 | 抛 `ApiException("该优惠券不可用")`，订单未落库 |
| 4 | 正常下单（不用券/不用积分） | 返回含 `order`/`orderItemList` 的 Map；订单落库 1 次；明细落库 1 次；库存锁定写回 1 次；发送延迟取消消息 1 次；删除购物车 1 次；不更新券状态、不扣积分 |
| 5 | 使用积分但未达门槛 | 抛 `ApiException("积分不可用")`，订单未落库 |

**验收标准：重构后该测试必须 100% 全绿。** 这就是"行为不变"的客观佐证。

### 运行测试

在 mall 根目录或 mall-portal 目录执行：

```bash
mvn -pl mall-portal -am test -Dtest=OmsPortalOrderBehaviorTest
```

> 注：本测试为纯 Mockito 单元测试（`@ExtendWith(MockitoExtension.class)`），不启动 Spring 上下文，不依赖 MySQL/Redis/RabbitMQ，因此在任何环境都能跑通。

---

## 五、提交要求

提交内容：

1. **重构后的代码**：`OmsPortalOrderServiceImpl.java`（以及你新增的 Service 类，如有）。
2. **重构说明**（写在提交说明或单独 `REFACTOR_NOTES.md`）：
   - 每一步重构的**意图**（拆出了什么职责、为什么这么拆）。
   - 拆分前后的结构对比（可用简图/列表）。
   - 你是**如何保证行为不变**的（对应 `OmsPortalOrderBehaviorTest` 的 5 个用例，说明你的新结构如何满足每条契约）。
3. **测试通过证据**：贴出 `mvn test -Dtest=OmsPortalOrderBehaviorTest` 全绿的输出。

---

## 六、评分要点（供参考）

- `generateOrder` 是否被拆成职责单一、可读性高的结构（30%）
- 拆分是否合理分层、命名清晰、依赖清晰（30%）
- **`OmsPortalOrderBehaviorTest` 全绿**（25%）
- 重构说明质量（15%）

祝重构顺利。
