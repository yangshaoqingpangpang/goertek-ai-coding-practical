/*
 *  Copyright 2026 AIQ Assessment
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package me.zhengjie.modules.candidate.service;

import me.zhengjie.modules.candidate.domain.Candidate;
import me.zhengjie.utils.PageResult;
import org.springframework.data.domain.Pageable;

/**
 * 候选人服务接口
 * <p>
 * 注意：本接口为实操题方向A骨架。当前方法签名暂用实体 {@link Candidate} 作为返回类型，
 * 以保证骨架可编译。考生可在新建 CandidateDto 后，将返回类型由 {@code PageResult<Candidate>}
 * 改为 {@code PageResult<CandidateDto>}，与 eladmin 其它模块风格保持一致。
 *
 * @author AIQ Assessment
 * @date 2026-08-08
 */
public interface CandidateService {

    /**
     * 分页查询候选人（按姓名 / 手机号模糊查询）
     * <p>
     * TODO（考生实现）：
     * 1) 入参应为自定义的 CandidateQueryCriteria（含 name、phone 两个模糊查询条件），
     *    而不是直接用实体；请考生新建 CandidateQueryCriteria 并替换本方法签名；
     * 2) 调用 CandidateRepository（JpaSpecificationExecutor）配合 QueryHelp 完成动态查询；
     * 3) 通过 CandidateMapper（mapstruct）将实体转换为 CandidateDto；
     * 4) 使用 PageUtil.toPage 包装为 PageResult 返回。
     *
     * @param criteria 查询条件（占位：暂用实体，考生应替换为 CandidateQueryCriteria）
     * @param pageable 分页参数
     * @return 分页结果
     */
    PageResult<Candidate> queryAll(Candidate criteria, Pageable pageable);
}
