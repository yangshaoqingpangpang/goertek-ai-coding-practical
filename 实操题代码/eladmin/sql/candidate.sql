/*
 * 候选人模块建表脚本（实操题方向A）
 * 风格对齐 eladmin.sql 中的 sys_ 系列表
 */

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_candidate
-- ----------------------------
DROP TABLE IF EXISTS `sys_candidate`;
CREATE TABLE `sys_candidate` (
  `candidate_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) NOT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `position` varchar(50) DEFAULT NULL COMMENT '应聘岗位',
  `status` tinyint(1) DEFAULT 0 COMMENT '测评状态：0待测评，1已测评',
  `create_by` varchar(255) DEFAULT NULL COMMENT '创建者',
  `update_by` varchar(255) DEFAULT NULL COMMENT '更新者',
  `create_time` datetime DEFAULT NULL COMMENT '创建日期',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`candidate_id`) USING BTREE,
  KEY `idx_name` (`name`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=COMPACT COMMENT='候选人';

-- ----------------------------
-- Records of sys_candidate
-- ----------------------------
BEGIN;
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (1, '张伟', '13800138001', 'zhangwei@example.com', 'Java开发工程师', 0, 'admin', 'admin', '2026-08-01 09:00:00', '2026-08-01 09:00:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (2, '王芳', '13912345678', 'wangfang@example.com', '前端开发工程师', 1, 'admin', 'admin', '2026-08-02 10:30:00', '2026-08-03 14:20:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (3, '李娜', '13700001111', 'lina@example.com', '产品经理', 0, 'admin', 'admin', '2026-08-03 11:15:00', '2026-08-03 11:15:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (4, '刘洋', '13622223333', 'liuyang@example.com', '测试工程师', 1, 'admin', 'admin', '2026-08-04 09:45:00', '2026-08-05 16:00:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (5, '陈静', '13533334444', 'chenjing@example.com', 'UI设计师', 0, 'admin', 'admin', '2026-08-05 13:20:00', '2026-08-05 13:20:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (6, '杨明', '18855556666', 'yangming@example.com', 'Java开发工程师', 0, 'admin', 'admin', '2026-08-06 08:50:00', '2026-08-06 08:50:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (7, '赵雪', '15977778888', 'zhaoxue@example.com', '数据分析师', 1, 'admin', 'admin', '2026-08-06 15:10:00', '2026-08-07 10:05:00');
INSERT INTO `sys_candidate` (`candidate_id`, `name`, `phone`, `email`, `position`, `status`, `create_by`, `update_by`, `create_time`, `update_time`) VALUES (8, '孙强', '18699990000', 'sunqiang@example.com', '运维工程师', 0, 'admin', 'admin', '2026-08-07 09:30:00', '2026-08-07 09:30:00');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
