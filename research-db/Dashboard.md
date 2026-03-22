---
title: 投资研究仪表盘
date: 2026-03-22
---

# 投资研究仪表盘

## 正在关注的公司

```dataview
TABLE status AS "状态", segment AS "赛道", date AS "录入日期"
FROM "research-db/companies"
WHERE status = "watching" OR status = "researching"
SORT date DESC
```

## 正在关注的赛道

```dataview
TABLE status AS "状态", date AS "录入日期"
FROM "research-db/segments"
WHERE status = "watching" OR status = "researching"
SORT date DESC
```

## 最近更新

```dataview
TABLE status AS "状态", type AS "类型"
FROM "research-db"
WHERE type
SORT file.mtime DESC
LIMIT 20
```

## 按赛道分布

```dataview
TABLE length(rows) AS "公司数"
FROM "research-db/companies"
WHERE segment
FLATTEN segment
GROUP BY segment
```

## 已归档

```dataview
TABLE status AS "状态", type AS "类型", date AS "录入日期"
FROM "research-db"
WHERE status = "archived"
SORT file.mtime DESC
```
