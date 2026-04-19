# COCO Workspace — 执行摘要

## 竞品分析核心发现

调研了 ChatGPT Team、Claude Team、Copilot Business、Cursor Teams、Windsurf、Replit、Notion AI、Taskade、Lindy、Relevance AI 共 10 款竞品。三个关键洞察：

1. **"共享记忆"是蓝海** — 几乎所有竞品的"团队功能"只是共享账单+管理面板，缺乏真正的跨用户动态记忆
2. **"AI 员工"定位极度稀缺** — 仅 Lindy 走类似路线但局限于个人场景，"团队共享 AI 员工"是全市场独一无二的定位
3. **竞品定价 $25-$40/用户/月** — 对应"AI 工具"价值，COCO 的"AI 员工"价值主张可支撑 $59-$79 溢价

## 四项决策结论

**A. 个人订阅与 Workspace 共存**：个人用户自动获得"个人 Workspace"，团队 Workspace 独立订阅。两者共存，零感知迁移，不破坏现有营收。

**B. 私聊隐私模型**：私聊内容默认仅自己可见。Agent 采用"知识双轨制"——事实性知识进共享记忆，个人观点留私有层。Enterprise 保留审计能力。

**C. 单 Agent vs 多 Agent**：MVP 单 Agent，Phase 2 引入 Agent 角色系统（低成本满足 80% 需求），Phase 3 再考虑多 Agent（Enterprise 高阶功能）。

**D. 计费模型**：Team $79/用户/月（3 人起）、Business $59/用户/月（10 人起）、Enterprise 自定义。个人计划保持不变。

## 路线图

- **Phase 1 MVP (8-10 周)**: Workspace 创建、成员邀请、权限模型、公共/私密频道、共享记忆 v1、Agent 持续运行、统一计费
- **Phase 2 团队增强 (6-8 周)**: 自定义频道、Agent 角色、用量统计、记忆管理、SSO、迁移工具
- **Phase 3 企业级 (8-12 周)**: 审计日志、SCIM、多 Agent、API、合规认证

完整 PRD 见 `coco-workspace-prd.md`。
